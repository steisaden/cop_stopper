import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/officer_record_model.dart';
import '../models/api_response.dart';

/// Real police API service using actual public databases
class RealPoliceApiService {
  final http.Client _httpClient;
  
  // Real API endpoints
  static const String _ukPoliceApiUrl = 'https://data.police.uk/api';
  static const String _openOversightUrl = 'https://openoversight.com/api';
  
  RealPoliceApiService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Test UK Police API - Get all forces
  Future<ApiResponse<List<Map<String, dynamic>>>> getUKPoliceForces() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_ukPoliceApiUrl/forces'),
        headers: {'User-Agent': 'CopStopper/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return ApiResponse.success(data.cast<Map<String, dynamic>>());
      } else {
        return ApiResponse.error('UK Police API error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('UK Police API failed: $e');
    }
  }

  /// Test UK Police API - Get force details
  Future<ApiResponse<Map<String, dynamic>>> getUKPoliceForceDetails(String forceId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_ukPoliceApiUrl/forces/$forceId'),
        headers: {'User-Agent': 'CopStopper/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('UK Police API error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('UK Police API failed: $e');
    }
  }

  /// Test UK Police API - Get senior officers for a force
  Future<ApiResponse<List<Map<String, dynamic>>>> getUKPoliceSeniorOfficers(String forceId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_ukPoliceApiUrl/forces/$forceId/people'),
        headers: {'User-Agent': 'CopStopper/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return ApiResponse.success(data.cast<Map<String, dynamic>>());
      } else {
        return ApiResponse.error('UK Police API error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('UK Police API failed: $e');
    }
  }

  /// Test OpenOversight API - Check if API exists
  Future<ApiResponse<Map<String, dynamic>>> testOpenOversightApi() async {
    try {
      // Try to access OpenOversight API
      final response = await _httpClient.get(
        Uri.parse('$_openOversightUrl/officers'),
        headers: {'User-Agent': 'CopStopper/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('OpenOversight API error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('OpenOversight API failed: $e');
    }
  }

  /// Test Chicago Data Portal API
  Future<ApiResponse<Map<String, dynamic>>> testChicagoDataPortal() async {
    try {
      // Chicago has a Socrata-based data portal
      final response = await _httpClient.get(
        Uri.parse('https://data.cityofchicago.org/api/views/metadata/v1'),
        headers: {'User-Agent': 'CopStopper/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('Chicago Data Portal error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Chicago Data Portal failed: $e');
    }
  }

  /// Test Fatal Encounters database (if they have an API)
  Future<ApiResponse<String>> testFatalEncountersApi() async {
    try {
      // Try to access Fatal Encounters website to see if they have an API
      final response = await _httpClient.get(
        Uri.parse('https://fatalencounters.org/'),
        headers: {'User-Agent': 'CopStopper/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return ApiResponse.success('Fatal Encounters website accessible');
      } else {
        return ApiResponse.error('Fatal Encounters error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Fatal Encounters failed: $e');
    }
  }

  /// Test Washington Post Police Shootings API
  Future<ApiResponse<List<Map<String, dynamic>>>> testWashingtonPostApi() async {
    try {
      // Washington Post has a GitHub repository with police shooting data
      final response = await _httpClient.get(
        Uri.parse('https://raw.githubusercontent.com/washingtonpost/data-police-shootings/master/fatal-police-shootings-data.csv'),
        headers: {'User-Agent': 'CopStopper/1.0'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Parse CSV data (first few lines)
        final lines = response.body.split('\n').take(5).toList();
        return ApiResponse.success([
          {'status': 'success', 'data_preview': lines}
        ]);
      } else {
        return ApiResponse.error('Washington Post data error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Washington Post data failed: $e');
    }
  }

  /// Convert UK Police senior officer data to OfficerRecord
  OfficerRecord _convertUKOfficerToRecord(Map<String, dynamic> data, String forceId) {
    return OfficerRecord(
      id: '${forceId}_${data['name']?.toString().replaceAll(' ', '_') ?? 'unknown'}',
      badgeNumber: 'N/A', // UK doesn't use badge numbers like US
      name: data['name'] ?? 'Unknown',
      department: data['force'] ?? forceId,
      rank: data['rank'] ?? 'Unknown',
      yearsOfService: 0, // Not provided in UK API
      complaints: [], // Not available in public UK API
      commendations: [], // Not available in public UK API
      lastUpdated: DateTime.now(),
      dataSource: 'UK Police API',
      reliability: 0.9,
    );
  }

  /// Search UK police officers (senior officers only - public data)
  Future<List<OfficerRecord>> searchUKPoliceOfficers({
    String? forceId,
    String? nameQuery,
  }) async {
    try {
      final officers = <OfficerRecord>[];
      
      if (forceId != null) {
        // Get senior officers for specific force
        final response = await getUKPoliceSeniorOfficers(forceId);
        if (response.isSuccess && response.data != null) {
          for (final officerData in response.data!) {
            final officer = _convertUKOfficerToRecord(officerData, forceId);
            if (nameQuery == null || 
                officer.name.toLowerCase().contains(nameQuery.toLowerCase())) {
              officers.add(officer);
            }
          }
        }
      } else {
        // Search specific forces known to have officer data
        // Note: Most UK police forces don't publish senior officer data publicly
        final forcesToSearch = [
          'leicestershire', // Known to have data
          'metropolitan',   // Try anyway
          'west-midlands',  // Try anyway
          'greater-manchester',
          'thames-valley'
        ];
        
        for (final forceId in forcesToSearch) {
          try {
            final officersResponse = await getUKPoliceSeniorOfficers(forceId);
            if (officersResponse.isSuccess && officersResponse.data != null && officersResponse.data!.isNotEmpty) {
              for (final officerData in officersResponse.data!) {
                final officer = _convertUKOfficerToRecord(officerData, forceId);
                if (nameQuery == null || 
                    officer.name.toLowerCase().contains(nameQuery.toLowerCase())) {
                  officers.add(officer);
                }
              }
            }
            // Add delay to be respectful to the API
            await Future.delayed(const Duration(milliseconds: 500));
          } catch (e) {
            print('Failed to get officers from $forceId: $e');
            // Continue with next force
          }
        }
      }
      
      return officers;
    } catch (e) {
      throw Exception('Failed to search UK police officers: $e');
    }
  }

  /// Run comprehensive API tests
  Future<Map<String, dynamic>> runApiTests() async {
    final results = <String, dynamic>{};
    
    print('🔍 Testing Real Police APIs...\n');
    
    // Test UK Police API
    print('Testing UK Police API...');
    try {
      final forcesResponse = await getUKPoliceForces();
      if (forcesResponse.isSuccess) {
        results['uk_police_forces'] = {
          'status': 'success',
          'count': forcesResponse.data?.length ?? 0,
          'sample': forcesResponse.data?.take(3).toList(),
        };
        print('✅ UK Police API: ${forcesResponse.data?.length} forces found');
        
        // Test getting senior officers for Leicestershire (known to have data)
        final leicestershireResponse = await getUKPoliceSeniorOfficers('leicestershire');
        if (leicestershireResponse.isSuccess && leicestershireResponse.data!.isNotEmpty) {
          results['uk_police_officers'] = {
            'status': 'success',
            'force': 'Leicestershire Police',
            'count': leicestershireResponse.data?.length ?? 0,
            'sample': leicestershireResponse.data?.take(2).toList(),
          };
          print('✅ UK Police Officers: ${leicestershireResponse.data?.length} senior officers found for Leicestershire Police');
        } else {
          results['uk_police_officers'] = {
            'status': 'warning',
            'message': 'No officer data available in tested forces',
          };
          print('⚠️ UK Police Officers: No public officer data found');
        }
      } else {
        results['uk_police_forces'] = {'status': 'error', 'message': forcesResponse.error};
        print('❌ UK Police API failed: ${forcesResponse.error}');
      }
    } catch (e) {
      results['uk_police_forces'] = {'status': 'error', 'message': e.toString()};
      print('❌ UK Police API exception: $e');
    }
    
    // Test OpenOversight API
    print('\nTesting OpenOversight API...');
    try {
      final response = await testOpenOversightApi();
      if (response.isSuccess) {
        results['openoversight'] = {'status': 'success', 'data': response.data};
        print('✅ OpenOversight API accessible');
      } else {
        results['openoversight'] = {'status': 'error', 'message': response.error};
        print('❌ OpenOversight API failed: ${response.error}');
      }
    } catch (e) {
      results['openoversight'] = {'status': 'error', 'message': e.toString()};
      print('❌ OpenOversight API exception: $e');
    }
    
    // Test Chicago Data Portal
    print('\nTesting Chicago Data Portal...');
    try {
      final response = await testChicagoDataPortal();
      if (response.isSuccess) {
        results['chicago_data'] = {'status': 'success', 'data': response.data};
        print('✅ Chicago Data Portal accessible');
      } else {
        results['chicago_data'] = {'status': 'error', 'message': response.error};
        print('❌ Chicago Data Portal failed: ${response.error}');
      }
    } catch (e) {
      results['chicago_data'] = {'status': 'error', 'message': e.toString()};
      print('❌ Chicago Data Portal exception: $e');
    }
    
    // Test Washington Post data
    print('\nTesting Washington Post Police Shootings Data...');
    try {
      final response = await testWashingtonPostApi();
      if (response.isSuccess) {
        results['washington_post'] = {'status': 'success', 'data': response.data};
        print('✅ Washington Post data accessible');
      } else {
        results['washington_post'] = {'status': 'error', 'message': response.error};
        print('❌ Washington Post data failed: ${response.error}');
      }
    } catch (e) {
      results['washington_post'] = {'status': 'error', 'message': e.toString()};
      print('❌ Washington Post data exception: $e');
    }
    
    // Test Fatal Encounters
    print('\nTesting Fatal Encounters...');
    try {
      final response = await testFatalEncountersApi();
      if (response.isSuccess) {
        results['fatal_encounters'] = {'status': 'success', 'message': response.data};
        print('✅ Fatal Encounters website accessible');
      } else {
        results['fatal_encounters'] = {'status': 'error', 'message': response.error};
        print('❌ Fatal Encounters failed: ${response.error}');
      }
    } catch (e) {
      results['fatal_encounters'] = {'status': 'error', 'message': e.toString()};
      print('❌ Fatal Encounters exception: $e');
    }
    
    return results;
  }

  void dispose() {
    _httpClient.close();
  }
}