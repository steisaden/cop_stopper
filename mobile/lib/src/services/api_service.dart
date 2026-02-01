
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  static const String _tokenKey = 'auth_token';
  
  final http.Client _client = http.Client();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Get stored auth token
  Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Store auth token
  Future<void> _storeToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Remove auth token
  Future<void> _removeToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Get headers with auth token
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Generic GET request
  Future<Map<String, dynamic>> get(String endpoint, {bool includeAuth = true}) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data, {
    bool includeAuth = true
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> data, {
    bool includeAuth = true
  }) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Generic DELETE request
  Future<Map<String, dynamic>> delete(String endpoint, {bool includeAuth = true}) async {
    try {
      final headers = await _getHeaders(includeAuth: includeAuth);
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  // Upload file with multipart request
  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    File file,
    String fieldName, {
    Map<String, String>? additionalFields,
    bool includeAuth = true,
  }) async {
    try {
      final token = includeAuth ? await _getToken() : null;
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Upload error: $e');
    }
  }

  // Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data;
    
    try {
      data = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Invalid JSON response');
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return data;
      case 400:
        throw ApiException(data['error'] ?? 'Bad request');
      case 401:
        _removeToken(); // Remove invalid token
        throw ApiException(data['error'] ?? 'Unauthorized');
      case 403:
        throw ApiException(data['error'] ?? 'Forbidden');
      case 404:
        throw ApiException(data['error'] ?? 'Not found');
      case 429:
        throw ApiException(data['error'] ?? 'Rate limit exceeded');
      case 500:
        throw ApiException(data['error'] ?? 'Server error');
      default:
        throw ApiException('HTTP ${response.statusCode}: ${data['error'] ?? 'Unknown error'}');
    }
  }

  // Authentication methods
  Future<AuthResult> register(String email, String password, String deviceId) async {
    final response = await post('/auth/register', {
      'email': email,
      'password': password,
      'deviceId': deviceId,
    }, includeAuth: false);

    final token = response['token'] as String;
    await _storeToken(token);

    return AuthResult(
      token: token,
      user: UserData.fromJson(response['user']),
    );
  }

  Future<AuthResult> login(String email, String password, String deviceId) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
      'deviceId': deviceId,
    }, includeAuth: false);

    final token = response['token'] as String;
    await _storeToken(token);

    return AuthResult(
      token: token,
      user: UserData.fromJson(response['user']),
    );
  }

  Future<UserData> getProfile() async {
    final response = await get('/auth/profile');
    return UserData.fromJson(response);
  }

  Future<void> logout() async {
    await _removeToken();
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null;
  }

  // Generic internal GET request to external URL
  Future<dynamic> getExternal(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load external data: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('External network error: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _client.close();
  }
}

// Data models
class AuthResult {
  final String token;
  final UserData user;

  AuthResult({required this.token, required this.user});
}

class UserData {
  final String id;
  final String email;
  final String? createdAt;
  final String? lastLogin;

  UserData({
    required this.id,
    required this.email,
    this.createdAt,
    this.lastLogin,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] as String?,
      lastLogin: json['lastLogin'] as String?,
    );
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}
