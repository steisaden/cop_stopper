import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';
import 'api_key_manager.dart';
import 'rate_limiter.dart';

/// Abstract base class for public records API clients
abstract class PublicRecordsApiClient {
  final String baseUrl;
  final ApiKeyManager apiKeyManager;
  final RateLimiter rateLimiter;
  final Duration timeout;

  PublicRecordsApiClient({
    required this.baseUrl,
    required this.apiKeyManager,
    required this.rateLimiter,
    this.timeout = const Duration(seconds: 30),
  });

  /// Get officer records by badge number
  Future<ApiResponse<Map<String, dynamic>>> getOfficerByBadge(
    String badgeNumber, {
    String? jurisdiction,
  });

  /// Search officers by name
  Future<ApiResponse<List<Map<String, dynamic>>>> searchOfficersByName(
    String name, {
    String? jurisdiction,
    int limit = 10,
  });

  /// Get complaint records for an officer
  Future<ApiResponse<List<Map<String, dynamic>>>> getComplaintRecords(
    String officerId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get disciplinary actions for an officer
  Future<ApiResponse<List<Map<String, dynamic>>>> getDisciplinaryActions(
    String officerId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get court records involving an officer
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourtRecords(
    String officerId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Generic HTTP request method with rate limiting and error handling
  Future<ApiResponse<T>> makeRequest<T>(
    String method,
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    required T Function(Map<String, dynamic>) parser,
  }) async {
    try {
      // Check rate limits
      await rateLimiter.waitForAvailability();

      // Get API key
      final apiKey = await apiKeyManager.getApiKey();
      if (apiKey == null) {
        return ApiResponse.error('API key not available');
      }

      // Build URL
      final uri = Uri.parse('$baseUrl$endpoint');
      final finalUri = queryParams != null 
          ? uri.replace(queryParameters: queryParams)
          : uri;

      // Prepare headers
      final finalHeaders = {
        'Content-Type': 'application/json',
        'User-Agent': 'CopStopper/1.0',
        ...getAuthHeaders(apiKey),
        ...?headers,
      };

      // Make request
      late http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(finalUri, headers: finalHeaders)
              .timeout(timeout);
          break;
        case 'POST':
          response = await http.post(
            finalUri,
            headers: finalHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeout);
          break;
        default:
          throw UnsupportedError('HTTP method $method not supported');
      }

      // Update rate limit info
      rateLimiter.updateFromResponse(response);

      // Handle response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.success(parser(data));
      } else {
        return ApiResponse.error(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      return ApiResponse.error('Request timeout');
    } on http.ClientException catch (e) {
      return ApiResponse.error('Network error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get authentication headers for this API
  Map<String, String> getAuthHeaders(String apiKey);

  /// Validate that the API is accessible
  Future<bool> validateConnection() async {
    try {
      final response = await makeRequest<bool>(
        'GET',
        '/health',
        parser: (data) => data['status'] == 'ok',
      );
      return response.isSuccess && response.data == true;
    } catch (e) {
      return false;
    }
  }
}

/// FOIA.gov API client for federal records
class FoiaApiClient extends PublicRecordsApiClient {
  FoiaApiClient({
    required super.apiKeyManager,
    required super.rateLimiter,
  }) : super(baseUrl: 'https://api.foia.gov/api');

  @override
  Map<String, String> getAuthHeaders(String apiKey) {
    return {'X-API-Key': apiKey};
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getOfficerByBadge(
    String badgeNumber, {
    String? jurisdiction,
  }) async {
    return makeRequest<Map<String, dynamic>>(
      'GET',
      '/officer',
      queryParams: {
        'badge_number': badgeNumber,
        if (jurisdiction != null) 'jurisdiction': jurisdiction,
      },
      parser: (data) => data,
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> searchOfficersByName(
    String name, {
    String? jurisdiction,
    int limit = 10,
  }) async {
    return makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/officers/search',
      queryParams: {
        'name': name,
        'limit': limit.toString(),
        if (jurisdiction != null) 'jurisdiction': jurisdiction,
      },
      parser: (data) => (data['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getComplaintRecords(
    String officerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/officer/$officerId/complaints',
      queryParams: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
      parser: (data) => (data['complaints'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getDisciplinaryActions(
    String officerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/officer/$officerId/disciplinary',
      queryParams: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
      parser: (data) => (data['actions'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourtRecords(
    String officerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/officer/$officerId/court-records',
      queryParams: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
      parser: (data) => (data['records'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
    );
  }
}

/// MuckRock API client for FOIA requests and transparency data
class MuckRockApiClient extends PublicRecordsApiClient {
  MuckRockApiClient({
    required super.apiKeyManager,
    required super.rateLimiter,
  }) : super(baseUrl: 'https://www.muckrock.com/api_v1');

  @override
  Map<String, String> getAuthHeaders(String apiKey) {
    return {'Authorization': 'Token $apiKey'};
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> getOfficerByBadge(
    String badgeNumber, {
    String? jurisdiction,
  }) async {
    // MuckRock doesn't have direct officer lookup, search FOIA requests
    return makeRequest<Map<String, dynamic>>(
      'GET',
      '/foia',
      queryParams: {
        'q': 'badge $badgeNumber',
        if (jurisdiction != null) 'jurisdiction': jurisdiction,
      },
      parser: (data) => data,
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> searchOfficersByName(
    String name, {
    String? jurisdiction,
    int limit = 10,
  }) async {
    return makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/foia',
      queryParams: {
        'q': 'officer $name',
        'limit': limit.toString(),
        if (jurisdiction != null) 'jurisdiction': jurisdiction,
      },
      parser: (data) => (data['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getComplaintRecords(
    String officerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/foia',
      queryParams: {
        'q': 'complaint $officerId',
        if (startDate != null) 'date_range_min': startDate.toIso8601String(),
        if (endDate != null) 'date_range_max': endDate.toIso8601String(),
      },
      parser: (data) => (data['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getDisciplinaryActions(
    String officerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/foia',
      queryParams: {
        'q': 'disciplinary $officerId',
        if (startDate != null) 'date_range_min': startDate.toIso8601String(),
        if (endDate != null) 'date_range_max': endDate.toIso8601String(),
      },
      parser: (data) => (data['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<ApiResponse<List<Map<String, dynamic>>>> getCourtRecords(
    String officerId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return makeRequest<List<Map<String, dynamic>>>(
      'GET',
      '/foia',
      queryParams: {
        'q': 'court case $officerId',
        if (startDate != null) 'date_range_min': startDate.toIso8601String(),
        if (endDate != null) 'date_range_max': endDate.toIso8601String(),
      },
      parser: (data) => (data['results'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
    );
  }
}