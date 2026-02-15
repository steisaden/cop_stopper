import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/officer_record_model.dart';
import '../models/api_response.dart';
import 'encryption_service.dart';
import 'storage_service.dart';

/// Enhanced police conduct database service with multiple API integrations
class PoliceConductDatabaseService {
  final EncryptionService _encryptionService;
  final StorageService _storageService;
  final http.Client _httpClient;
  
  // API configurations
  static const String _citizenPoliceDataProjectUrl = 'https://api.cpdp.co/api/v2';
  static const String _policeDataInitiativeUrl = 'https://api.policedatainitiative.org/v1';
  static const String _transparencyProjectUrl = 'https://api.transparencyproject.org/v1';
  static const String _mappingPoliceViolenceUrl = 'https://api.mappingpoliceviolence.org/v1';
  
  // Cache for API responses
  final Map<String, CachedResponse> _cache = {};
  static const Duration _cacheExpiry = Duration(hours: 6);

  PoliceConductDatabaseService({
    required EncryptionService encryptionService,
    required StorageService storageService,
    http.Client? httpClient,
  }) : _encryptionService = encryptionService,
       _storageService = storageService,
       _httpClient = httpClient ?? http.Client();

  /// Search for officers across multiple databases
  Future<List<OfficerRecord>> searchOfficers({
    required String query,
    String? department,
    String? jurisdiction,
    int limit = 20,
  }) async {
    try {
      final results = <OfficerRecord>[];
      
      // Search across multiple APIs in parallel
      final futures = [
        _searchCPDP(query, department, jurisdiction, limit),
        _searchPoliceDataInitiative(query, department, jurisdiction, limit),
        _searchTransparencyProject(query, department, jurisdiction, limit),
        _searchMappingPoliceViolence(query, department, jurisdiction, limit),
      ];
      
      final responses = await Future.wait(futures, eagerError: false);
      
      // Combine and deduplicate results
      for (final response in responses) {
        if (response.isSuccess && response.data != null) {
          results.addAll(response.data!);
        }
      }
      
      // Remove duplicates based on badge number and department
      final uniqueResults = _deduplicateOfficers(results);
      
      // Sort by relevance and data completeness
      uniqueResults.sort((a, b) => _calculateRelevanceScore(b, query)
          .compareTo(_calculateRelevanceScore(a, query)));
      
      return uniqueResults.take(limit).toList();
      
    } catch (e) {
      throw Exception('Failed to search officers: $e');
    }
  }

  /// Get detailed officer information by badge number
  Future<OfficerRecord?> getOfficerByBadge({
    required String badgeNumber,
    required String department,
  }) async {
    try {
      final cacheKey = 'officer_${badgeNumber}_$department';
      
      // Check cache first
      if (_cache.containsKey(cacheKey) && !_cache[cacheKey]!.isExpired) {
        return _cache[cacheKey]!.data as OfficerRecord?;
      }
      
      // Search across all databases
      final futures = [
        _getOfficerFromCPDP(badgeNumber, department),
        _getOfficerFromPoliceDataInitiative(badgeNumber, department),
        _getOfficerFromTransparencyProject(badgeNumber, department),
        _getOfficerFromMappingPoliceViolence(badgeNumber, department),
      ];
      
      final responses = await Future.wait(futures, eagerError: false);
      
      // Merge data from all sources
      OfficerRecord? mergedRecord;
      for (final response in responses) {
        if (response.isSuccess && response.data != null) {
          if (mergedRecord == null) {
            mergedRecord = response.data!;
          } else {
            mergedRecord = _mergeOfficerRecords(mergedRecord, response.data!);
          }
        }
      }
      
      // Cache the result
      if (mergedRecord != null) {
        _cache[cacheKey] = CachedResponse(mergedRecord, DateTime.now());
      }
      
      return mergedRecord;
      
    } catch (e) {
      throw Exception('Failed to get officer details: $e');
    }
  }

  /// Search Chicago Police Data Project
  Future<ApiResponse<List<OfficerRecord>>> _searchCPDP(
    String query,
    String? department,
    String? jurisdiction,
    int limit,
  ) async {
    try {
      final uri = Uri.parse('$_citizenPoliceDataProjectUrl/officers/')
          .replace(queryParameters: {
        'name': query,
        if (department != null) 'current_unit__description': department,
        'limit': limit.toString(),
      });

      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final officers = <OfficerRecord>[];
        
        for (final item in data['results'] ?? []) {
          officers.add(_parseCPDPOfficer(item));
        }
        
        return ApiResponse.success(officers);
      } else {
        return ApiResponse.error('CPDP API error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('CPDP search failed: $e');
    }
  }

  /// Search Police Data Initiative
  Future<ApiResponse<List<OfficerRecord>>> _searchPoliceDataInitiative(
    String query,
    String? department,
    String? jurisdiction,
    int limit,
  ) async {
    try {
      final uri = Uri.parse('$_policeDataInitiativeUrl/officers/search')
          .replace(queryParameters: {
        'q': query,
        if (department != null) 'department': department,
        if (jurisdiction != null) 'jurisdiction': jurisdiction,
        'limit': limit.toString(),
      });

      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final officers = <OfficerRecord>[];
        
        for (final item in data['officers'] ?? []) {
          officers.add(_parsePoliceDataInitiativeOfficer(item));
        }
        
        return ApiResponse.success(officers);
      } else {
        return ApiResponse.error('Police Data Initiative API error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Police Data Initiative search failed: $e');
    }
  }

  /// Search Transparency Project
  Future<ApiResponse<List<OfficerRecord>>> _searchTransparencyProject(
    String query,
    String? department,
    String? jurisdiction,
    int limit,
  ) async {
    try {
      final uri = Uri.parse('$_transparencyProjectUrl/officers')
          .replace(queryParameters: {
        'name': query,
        if (department != null) 'agency': department,
        if (jurisdiction != null) 'state': jurisdiction,
        'limit': limit.toString(),
      });

      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final officers = <OfficerRecord>[];
        
        for (final item in data['data'] ?? []) {
          officers.add(_parseTransparencyProjectOfficer(item));
        }
        
        return ApiResponse.success(officers);
      } else {
        return ApiResponse.error('Transparency Project API error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Transparency Project search failed: $e');
    }
  }

  /// Search Mapping Police Violence
  Future<ApiResponse<List<OfficerRecord>>> _searchMappingPoliceViolence(
    String query,
    String? department,
    String? jurisdiction,
    int limit,
  ) async {
    try {
      final uri = Uri.parse('$_mappingPoliceViolenceUrl/officers')
          .replace(queryParameters: {
        'search': query,
        if (department != null) 'department': department,
        if (jurisdiction != null) 'state': jurisdiction,
        'limit': limit.toString(),
      });

      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final officers = <OfficerRecord>[];
        
        for (final item in data['officers'] ?? []) {
          officers.add(_parseMappingPoliceViolenceOfficer(item));
        }
        
        return ApiResponse.success(officers);
      } else {
        return ApiResponse.error('Mapping Police Violence API error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Mapping Police Violence search failed: $e');
    }
  }

  /// Get officer from CPDP by badge number
  Future<ApiResponse<OfficerRecord?>> _getOfficerFromCPDP(
    String badgeNumber,
    String department,
  ) async {
    try {
      final uri = Uri.parse('$_citizenPoliceDataProjectUrl/officers/')
          .replace(queryParameters: {
        'current_badge': badgeNumber,
        'current_unit__description': department,
      });

      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List?;
        
        if (results != null && results.isNotEmpty) {
          return ApiResponse.success(_parseCPDPOfficer(results.first));
        }
      }
      
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('CPDP officer lookup failed: $e');
    }
  }

  /// Get officer from Police Data Initiative by badge number
  Future<ApiResponse<OfficerRecord?>> _getOfficerFromPoliceDataInitiative(
    String badgeNumber,
    String department,
  ) async {
    try {
      final uri = Uri.parse('$_policeDataInitiativeUrl/officers/$badgeNumber')
          .replace(queryParameters: {
        'department': department,
      });

      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_parsePoliceDataInitiativeOfficer(data));
      }
      
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Police Data Initiative officer lookup failed: $e');
    }
  }

  /// Get officer from Transparency Project by badge number
  Future<ApiResponse<OfficerRecord?>> _getOfficerFromTransparencyProject(
    String badgeNumber,
    String department,
  ) async {
    try {
      final uri = Uri.parse('$_transparencyProjectUrl/officers/$badgeNumber')
          .replace(queryParameters: {
        'agency': department,
      });

      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_parseTransparencyProjectOfficer(data));
      }
      
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Transparency Project officer lookup failed: $e');
    }
  }

  /// Get officer from Mapping Police Violence by badge number
  Future<ApiResponse<OfficerRecord?>> _getOfficerFromMappingPoliceViolence(
    String badgeNumber,
    String department,
  ) async {
    try {
      final uri = Uri.parse('$_mappingPoliceViolenceUrl/officers/$badgeNumber')
          .replace(queryParameters: {
        'department': department,
      });

      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(_parseMappingPoliceViolenceOfficer(data));
      }
      
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error('Mapping Police Violence officer lookup failed: $e');
    }
  }

  /// Parse CPDP officer data
  OfficerRecord _parseCPDPOfficer(Map<String, dynamic> data) {
    return OfficerRecord(
      id: data['id']?.toString() ?? '',
      badgeNumber: data['current_badge']?.toString() ?? '',
      name: '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim(),
      department: data['current_unit']?['description'] ?? '',
      rank: data['current_rank'] ?? '',
      yearsOfService: _calculateYearsOfService(data['appointed_date']),
      complaints: _parseCPDPComplaints(data['complaint_records'] ?? []),
      commendations: _parseCPDPCommendations(data['awards'] ?? []),
      lastUpdated: DateTime.now(),
      dataSource: 'Chicago Police Data Project',
      reliability: 0.9,
    );
  }

  /// Parse Police Data Initiative officer data
  OfficerRecord _parsePoliceDataInitiativeOfficer(Map<String, dynamic> data) {
    return OfficerRecord(
      id: data['id']?.toString() ?? '',
      badgeNumber: data['badge_number']?.toString() ?? '',
      name: data['name'] ?? '',
      department: data['department'] ?? '',
      rank: data['rank'] ?? '',
      yearsOfService: data['years_of_service'] ?? 0,
      complaints: _parseGenericComplaints(data['complaints'] ?? []),
      commendations: _parseGenericCommendations(data['commendations'] ?? []),
      lastUpdated: DateTime.now(),
      dataSource: 'Police Data Initiative',
      reliability: 0.8,
    );
  }

  /// Parse Transparency Project officer data
  OfficerRecord _parseTransparencyProjectOfficer(Map<String, dynamic> data) {
    return OfficerRecord(
      id: data['uid']?.toString() ?? '',
      badgeNumber: data['badge_no']?.toString() ?? '',
      name: data['name'] ?? '',
      department: data['agency'] ?? '',
      rank: data['rank'] ?? '',
      yearsOfService: _calculateYearsOfService(data['hire_date']),
      complaints: _parseGenericComplaints(data['complaints'] ?? []),
      commendations: _parseGenericCommendations(data['commendations'] ?? []),
      lastUpdated: DateTime.now(),
      dataSource: 'Transparency Project',
      reliability: 0.85,
    );
  }

  /// Parse Mapping Police Violence officer data
  OfficerRecord _parseMappingPoliceViolenceOfficer(Map<String, dynamic> data) {
    return OfficerRecord(
      id: data['id']?.toString() ?? '',
      badgeNumber: data['badge_number']?.toString() ?? '',
      name: data['officer_name'] ?? '',
      department: data['department'] ?? '',
      rank: data['rank'] ?? '',
      yearsOfService: data['years_on_force'] ?? 0,
      complaints: _parseGenericComplaints(data['incidents'] ?? []),
      commendations: [],
      lastUpdated: DateTime.now(),
      dataSource: 'Mapping Police Violence',
      reliability: 0.9,
    );
  }

  /// Parse CPDP complaints
  List<ComplaintRecord> _parseCPDPComplaints(List<dynamic> complaints) {
    return complaints.map((complaint) => ComplaintRecord(
      id: complaint['cr_id']?.toString() ?? '',
      date: _parseDate(complaint['incident_date']),
      type: complaint['category'] ?? 'Unknown',
      description: complaint['summary'] ?? '',
      status: complaint['final_finding'] ?? 'Unknown',
      outcome: complaint['final_outcome'] ?? '',
    )).toList();
  }

  /// Parse CPDP commendations
  List<CommendationRecord> _parseCPDPCommendations(List<dynamic> awards) {
    return awards.map((award) => CommendationRecord(
      id: award['id']?.toString() ?? '',
      date: _parseDate(award['start_date']),
      type: award['award_type'] ?? 'Recognition',
      description: award['award_type'] ?? '',
    )).toList();
  }

  /// Parse generic complaints format
  List<ComplaintRecord> _parseGenericComplaints(List<dynamic> complaints) {
    return complaints.map((complaint) => ComplaintRecord(
      id: complaint['id']?.toString() ?? '',
      date: _parseDate(complaint['date'] ?? complaint['incident_date']),
      type: complaint['type'] ?? complaint['allegation'] ?? 'Unknown',
      description: complaint['description'] ?? complaint['summary'] ?? '',
      status: complaint['status'] ?? complaint['disposition'] ?? 'Unknown',
      outcome: complaint['outcome'] ?? complaint['action_taken'] ?? '',
    )).toList();
  }

  /// Parse generic commendations format
  List<CommendationRecord> _parseGenericCommendations(List<dynamic> commendations) {
    return commendations.map((commendation) => CommendationRecord(
      id: commendation['id']?.toString() ?? '',
      date: _parseDate(commendation['date']),
      type: commendation['type'] ?? 'Recognition',
      description: commendation['description'] ?? commendation['reason'] ?? '',
    )).toList();
  }

  /// Calculate years of service from hire date
  int _calculateYearsOfService(String? hireDateStr) {
    if (hireDateStr == null) return 0;
    
    try {
      final hireDate = DateTime.parse(hireDateStr);
      final now = DateTime.now();
      return now.difference(hireDate).inDays ~/ 365;
    } catch (e) {
      return 0;
    }
  }

  /// Parse date string to DateTime
  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null) return null;
    
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  /// Remove duplicate officers based on badge number and department
  List<OfficerRecord> _deduplicateOfficers(List<OfficerRecord> officers) {
    final seen = <String>{};
    final unique = <OfficerRecord>[];
    
    for (final officer in officers) {
      final key = '${officer.badgeNumber}_${officer.department}';
      if (!seen.contains(key)) {
        seen.add(key);
        unique.add(officer);
      }
    }
    
    return unique;
  }

  /// Calculate relevance score for search results
  double _calculateRelevanceScore(OfficerRecord officer, String query) {
    double score = 0.0;
    final queryLower = query.toLowerCase();
    
    // Name match
    if (officer.name.toLowerCase().contains(queryLower)) {
      score += 10.0;
    }
    
    // Badge number match
    if (officer.badgeNumber.toLowerCase().contains(queryLower)) {
      score += 15.0;
    }
    
    // Department match
    if (officer.department.toLowerCase().contains(queryLower)) {
      score += 5.0;
    }
    
    // Data completeness
    score += officer.complaints.length * 0.5;
    score += officer.commendations.length * 0.3;
    
    // Data source reliability
    score += officer.reliability * 5.0;
    
    return score;
  }

  /// Merge officer records from multiple sources
  OfficerRecord _mergeOfficerRecords(OfficerRecord primary, OfficerRecord secondary) {
    // Use the record with higher reliability as primary
    if (secondary.reliability > primary.reliability) {
      return _mergeOfficerRecords(secondary, primary);
    }
    
    return OfficerRecord(
      id: primary.id,
      badgeNumber: primary.badgeNumber.isNotEmpty ? primary.badgeNumber : secondary.badgeNumber,
      name: primary.name.isNotEmpty ? primary.name : secondary.name,
      department: primary.department.isNotEmpty ? primary.department : secondary.department,
      rank: primary.rank.isNotEmpty ? primary.rank : secondary.rank,
      yearsOfService: primary.yearsOfService > 0 ? primary.yearsOfService : secondary.yearsOfService,
      complaints: [...primary.complaints, ...secondary.complaints],
      commendations: [...primary.commendations, ...secondary.commendations],
      lastUpdated: primary.lastUpdated.isAfter(secondary.lastUpdated) 
          ? primary.lastUpdated 
          : secondary.lastUpdated,
      dataSource: '${primary.dataSource}, ${secondary.dataSource}',
      reliability: (primary.reliability + secondary.reliability) / 2,
    );
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }

  /// Dispose resources
  void dispose() {
    _httpClient.close();
    clearCache();
  }
}

/// Cached response wrapper
class CachedResponse {
  final dynamic data;
  final DateTime timestamp;
  
  CachedResponse(this.data, this.timestamp);
  
  bool get isExpired => DateTime.now().difference(timestamp) > PoliceConductDatabaseService._cacheExpiry;
}

