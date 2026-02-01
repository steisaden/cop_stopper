import 'dart:async';
import 'dart:convert';

import 'package:mobile/src/collaborative_monitoring/interfaces/officer_records_service.dart';
import 'package:mobile/src/collaborative_monitoring/models/officer_profile.dart';
import 'package:mobile/src/collaborative_monitoring/models/career_timeline.dart';
import 'package:mobile/src/collaborative_monitoring/models/commendation.dart';
import 'package:mobile/src/collaborative_monitoring/models/complaint_record.dart';
import 'package:mobile/src/collaborative_monitoring/models/community_rating.dart';
import 'package:mobile/src/collaborative_monitoring/models/disciplinary_action.dart';
import 'package:mobile/src/collaborative_monitoring/models/encounter.dart';
import 'package:mobile/src/services/api_service.dart';

class OfficerRecordsServiceImpl implements OfficerRecordsService {
  final ApiService _apiService;
  final Map<String, OfficerProfile> _profileCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration _cacheExpiry = Duration(minutes: 15);

  OfficerRecordsServiceImpl(this._apiService);

  @override
  Future<OfficerProfile> getOfficer(String officerId) async {
    if (_isProfileCached(officerId)) {
      return _profileCache[officerId]!;
    }

    try {
      // The backend returns the full officer object at /officers/:id
      // Note: The backend uses badgeNumber as the ID in some cases of the mock DB, 
      // ensuring we pass the right ID.
      final response = await _apiService.get('/officers/$officerId');
      
      if (response['success'] == true && response['officer'] != null) {
        final officerData = response['officer'];
        final profile = _mapBackendOfficerToProfile(officerData);
        
        _profileCache[officerId] = profile;
        _cacheTimestamps[officerId] = DateTime.now();
        
        return profile;
      } else {
        throw Exception(response['error'] ?? 'Officer not found');
      }
    } catch (e) {
      throw Exception('Failed to retrieve officer profile: $e');
    }
  }

  OfficerProfile _mapBackendOfficerToProfile(Map<String, dynamic> data) {
    // Parse complaints
    final complaints = (data['complaints'] as List<dynamic>? ?? [])
        .map((c) {
          final dateString = c['date'] as String? ?? c['dateReported'] as String?;
          final parsedDate = DateTime.tryParse(dateString ?? '') ?? DateTime.now();
          final reportedDate =
              DateTime.tryParse(c['dateReported'] as String? ?? dateString ?? '') ?? parsedDate;
          return ComplaintRecord(
            id: (c['id'] ?? c['caseNumber'] ?? 'Unknown').toString(),
            date: parsedDate,
            description: c['description'] ?? '',
            status: c['status'] ?? 'Unknown',
            caseNumber: (c['caseNumber'] ?? c['id'] ?? 'Unknown').toString(),
            dateReported: reportedDate,
          );
        })
        .toList();

    // Parse commendations
    final commendations = (data['commendations'] as List<dynamic>? ?? [])
        .map((c) {
          final dateString = c['date'] as String? ?? c['dateAwarded'] as String?;
          final parsedDate = DateTime.tryParse(dateString ?? '') ?? DateTime.now();
          final awardedDate =
              DateTime.tryParse(c['dateAwarded'] as String? ?? dateString ?? '') ?? parsedDate;
          return Commendation(
            id: (c['id'] ?? 'Unknown').toString(),
            date: parsedDate,
            description: c['description'] ?? '',
            type: c['type'] ?? 'Unknown',
            dateAwarded: awardedDate,
          );
        })
        .toList();

    // Mock timeline generation from years of service if no explicit events
    final careerEvents = <CareerTimelineEvent>[]; // Backend doesn't return explicit timeline events yet
    
    // Disciplinary actions - currently mapped from complaints outcome
    final disciplinaryActions = <DisciplinaryAction>[]; // Backend folds this into complaints

    return OfficerProfile(
      id: data['badgeNumber'] ?? 'Unknown', // Using badge as ID for simplicity
      name: data['name'] ?? 'Unknown',
      badgeNumber: data['badgeNumber'] ?? 'Unknown',
      department: data['department'] ?? 'Unknown',
      complaintRecords: complaints,
      disciplinaryActions: disciplinaryActions,
      commendations: commendations,
      careerTimeline: CareerTimeline(events: careerEvents),
      communityRating: CommunityRating(
         officerId: data['badgeNumber'] ?? 'Unknown',
         averageRating: 0.0,
         totalRatings: 0,
         ratingBreakdown: {},
         recentComments: []
      ),
    );
  }

  Future<List<String>> searchOfficersByName(String name, {String? jurisdiction}) async {
    try {
      final response = await _apiService.get('/officers/search?name=$name${jurisdiction != null ? '&department=$jurisdiction' : ''}');
      
      if (response['success'] == true) {
         final results = response['results'] as List<dynamic>;
         return results.map((o) => o['badgeNumber'] as String).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search officers: $e');
    }
  }

  Future<List<String>> searchOfficersByBadge(String badgeNumber, {String? jurisdiction}) async {
    try {
      final response = await _apiService.get('/officers/search?badge=$badgeNumber${jurisdiction != null ? '&department=$jurisdiction' : ''}');
      
      if (response['success'] == true) {
         final results = response['results'] as List<dynamic>;
         return results.map((o) => o['badgeNumber'] as String).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search officers by badge: $e');
    }
  }

  // Other methods left as stubs or simplified since backend support might be limited
  
  Future<List<ComplaintRecord>> getComplaintHistory(String officerId) async {
    final profile = await getOfficer(officerId);
    return profile.complaintRecords;
  }

  Future<List<DisciplinaryAction>> getDisciplinaryActions(String officerId) async {
    final profile = await getOfficer(officerId);
    return profile.disciplinaryActions;
  }

  Future<CareerTimeline> getCareerTimeline(String officerId) async {
    final profile = await getOfficer(officerId);
    return profile.careerTimeline;
  }

  Future<void> submitCommunityIncidentReport({
    required String officerId,
    required String incidentType,
    required String description,
    required DateTime incidentDate,
    String? location,
    List<String>? witnesses,
    List<String>? evidence,
  }) async {
    await _apiService.post('/officers/interaction', {
      'badgeNumber': officerId,
      'interactionType': 'other', // Mapping to backend enum
      'description': description,
      'location': location != null ? {'address': location} : null,
      'timestamp': incidentDate.toIso8601String(),
    });
    _invalidateOfficerCache(officerId);
  }

  Future<void> subscribeToOfficerNotifications(String officerId) async {
    // Backend support incomplete for specific officer subscription
    // calling generic register
    await _apiService.post('/officers/notifications/register', {
        'deviceToken': 'current_device_token', 
        'platform': 'android' // detect
    });
  }

  bool _isProfileCached(String officerId) {
    if (!_profileCache.containsKey(officerId)) return false;
    final cacheTime = _cacheTimestamps[officerId];
    if (cacheTime == null) return false;
    return DateTime.now().difference(cacheTime) < _cacheExpiry;
  }

  void _invalidateOfficerCache(String officerId) {
    _profileCache.remove(officerId);
    _cacheTimestamps.remove(officerId);
  }

  void clearCache() {
    _profileCache.clear();
    _cacheTimestamps.clear();
  }

  Future<OfficerProfile> createOfficer({
    required String name,
    String? badgeNumber,
    String? department,
  }) async {
     // Backend doesn't support creating officers explicitly yet
     // Returning a dummy profile
    return OfficerProfile(
      id: 'temp-id',
      name: name,
      badgeNumber: badgeNumber ?? 'Unknown',
      department: department ?? 'Unknown',
      complaintRecords: [],
      disciplinaryActions: [],
      commendations: [],
      careerTimeline: CareerTimeline(events: []),
      communityRating: CommunityRating(
        officerId: 'temp-id',
        averageRating: 0,
        totalRatings: 0,
        ratingBreakdown: {},
        recentComments: [],
      ),
      isUserGenerated: true,
      createdBy: 'current_user',
    );
  }

  @override
  Future<void> addEncounter(String officerId, Encounter encounter) async {
     await _apiService.post('/officers/interaction', {
      'badgeNumber': officerId,
      'interactionType': 'traffic_stop', // map from encounter
      'description': encounter.description,
      'timestamp': encounter.timestamp.toIso8601String(),
    });
  }
}
