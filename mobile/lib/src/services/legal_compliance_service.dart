import 'dart:convert';
import 'package:mobile/src/services/storage_service.dart';
import 'package:mobile/src/services/location_service.dart';
import 'package:mobile/src/services/api_service.dart';

/// Service for managing legal compliance and recording laws
class LegalComplianceService {
  final StorageService _storageService;
  final LocationService _locationService;
  final ApiService _apiService;
  
  static const String _consentRecordsKey = 'consent_records';
  static const String _recordingLawsKey = 'recording_laws';
  static const String _privacySettingsKey = 'privacy_settings';
  
  LegalComplianceService(
    this._storageService,
    this._locationService,
    this._apiService,
  );
  
  /// Check if recording is legal in current jurisdiction
  Future<RecordingLegalityResult> checkRecordingLegality() async {
    try {
      // Get current location
      final locationResult = await _locationService.getCurrentLocation();
      final jurisdiction = await _locationService.getCurrentJurisdiction();
      
      // Get recording laws for jurisdiction
      final laws = await getRecordingLaws(jurisdiction?.toString() ?? 'federal');
      
      return RecordingLegalityResult(
        isLegal: laws.allowsRecording,
        requiresConsent: laws.requiresConsent,
        consentType: laws.consentType,
        jurisdiction: jurisdiction.toString(),
        laws: laws,
        warnings: _generateWarnings(laws),
        recommendations: _generateRecommendations(laws),
      );
    } catch (e) {
      // Return conservative result if we can't determine legality
      return RecordingLegalityResult(
        isLegal: false,
        requiresConsent: true,
        consentType: ConsentType.allParties,
        jurisdiction: 'Unknown',
        laws: RecordingLaws.restrictive(),
        warnings: ['Unable to determine local recording laws. Proceed with caution.'],
        recommendations: ['Obtain consent from all parties before recording.'],
      );
    }
  }
  
  /// Get recording laws for a specific jurisdiction
  Future<RecordingLaws> getRecordingLaws(String jurisdiction) async {
    try {
      // Try to get from cache first
      final cachedLaws = await _getCachedRecordingLaws(jurisdiction);
      if (cachedLaws != null) {
        return cachedLaws;
      }
      
      // Fetch from API
      final response = await _apiService.get('/legal/recording-laws/$jurisdiction');
      if (response['success'] == true) {
        final laws = RecordingLaws.fromJson(response['data']);
        await _cacheRecordingLaws(jurisdiction, laws);
        return laws;
      }
    } catch (e) {
      print('Error fetching recording laws: $e');
    }
    
    // Return default restrictive laws if we can't fetch
    return RecordingLaws.restrictive();
  }
  
  /// Record consent for a recording session
  Future<void> recordConsent({
    required String sessionId,
    required ConsentType consentType,
    required List<ConsentRecord> consents,
    String? jurisdiction,
  }) async {
    try {
      final consentData = {
        'session_id': sessionId,
        'consent_type': consentType.toString(),
        'consents': consents.map((c) => c.toJson()).toList(),
        'jurisdiction': jurisdiction,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Store locally
      final existingConsents = await _getStoredConsents();
      existingConsents.add(consentData);
      await _storageService.writeToFile(
        _consentRecordsKey,
        jsonEncode(existingConsents),
      );
      
      // Send to API for backup
      try {
        await _apiService.post('/legal/consent-records', consentData);
      } catch (e) {
        print('Failed to backup consent record: $e');
        // Continue - local storage is primary
      }
    } catch (e) {
      print('Error recording consent: $e');
      throw Exception('Failed to record consent');
    }
  }
  
  /// Get consent records for a session
  Future<List<ConsentRecord>> getConsentRecords(String sessionId) async {
    try {
      final allConsents = await _getStoredConsents();
      final sessionConsents = allConsents
          .where((consent) => consent['session_id'] == sessionId)
          .toList();
      
      return sessionConsents
          .expand((consent) => (consent['consents'] as List))
          .map((consentJson) => ConsentRecord.fromJson(consentJson))
          .toList();
    } catch (e) {
      print('Error getting consent records: $e');
      return [];
    }
  }
  
  /// Check if adequate consent has been obtained
  Future<bool> hasAdequateConsent(String sessionId) async {
    try {
      final legality = await checkRecordingLegality();
      if (!legality.requiresConsent) {
        return true; // No consent required
      }
      
      final consents = await getConsentRecords(sessionId);
      
      switch (legality.consentType) {
        case ConsentType.oneParty:
          // One-party consent - recorder's consent is sufficient
          return true;
        case ConsentType.allParties:
          // All-party consent - need consent from all participants
          // This would require additional logic to determine all participants
          return consents.isNotEmpty;
        case ConsentType.none:
          return true;
      }
    } catch (e) {
      print('Error checking consent adequacy: $e');
      return false; // Conservative approach
    }
  }
  
  /// Get privacy settings
  Future<PrivacySettings> getPrivacySettings() async {
    try {
      final settingsJson = await _storageService.readFromFile(_privacySettingsKey);
      if (settingsJson != null) {
        final settingsMap = jsonDecode(settingsJson);
        return PrivacySettings.fromJson(settingsMap);
      }
    } catch (e) {
      print('Error reading privacy settings: $e');
    }
    
    return PrivacySettings.defaultSettings();
  }
  
  /// Save privacy settings
  Future<void> savePrivacySettings(PrivacySettings settings) async {
    try {
      final settingsJson = jsonEncode(settings.toJson());
      await _storageService.writeToFile(_privacySettingsKey, settingsJson);
    } catch (e) {
      print('Error saving privacy settings: $e');
      throw Exception('Failed to save privacy settings');
    }
  }
  
  /// Generate legal disclaimer for recording
  Future<String> generateRecordingDisclaimer() async {
    try {
      final legality = await checkRecordingLegality();
      
      String disclaimer = 'LEGAL NOTICE: ';
      
      if (legality.isLegal) {
        disclaimer += 'Recording is permitted in this jurisdiction. ';
        
        if (legality.requiresConsent) {
          switch (legality.consentType) {
            case ConsentType.oneParty:
              disclaimer += 'One-party consent is required. ';
              break;
            case ConsentType.allParties:
              disclaimer += 'All-party consent is required. ';
              break;
            case ConsentType.none:
              break;
          }
        }
      } else {
        disclaimer += 'Recording may not be permitted in this jurisdiction. ';
      }
      
      disclaimer += 'By proceeding, you acknowledge responsibility for compliance with local laws. ';
      disclaimer += 'This app does not provide legal advice. Consult an attorney for legal guidance.';
      
      return disclaimer;
    } catch (e) {
      return 'LEGAL NOTICE: Unable to determine local recording laws. '
          'Proceed with caution and obtain appropriate consent. '
          'This app does not provide legal advice. Consult an attorney for legal guidance.';
    }
  }
  
  /// Get data retention requirements
  Future<DataRetentionRequirements> getDataRetentionRequirements() async {
    try {
      final jurisdiction = await _locationService.getCurrentJurisdiction();
      final response = await _apiService.get('/legal/data-retention/$jurisdiction');
      
      if (response['success'] == true) {
        return DataRetentionRequirements.fromJson(response['data']);
      }
    } catch (e) {
      print('Error fetching data retention requirements: $e');
    }
    
    // Return conservative default requirements
    return DataRetentionRequirements.defaultRequirements();
  }
  
  /// Check if user can delete data
  Future<bool> canDeleteData(String dataType, DateTime createdDate) async {
    try {
      final requirements = await getDataRetentionRequirements();
      final retentionPeriod = requirements.getRetentionPeriod(dataType);
      
      if (retentionPeriod == null) {
        return true; // No retention requirement
      }
      
      final retentionEndDate = createdDate.add(retentionPeriod);
      return DateTime.now().isAfter(retentionEndDate);
    } catch (e) {
      print('Error checking data deletion eligibility: $e');
      return false; // Conservative approach
    }
  }
  
  /// Generate warnings based on recording laws
  List<String> _generateWarnings(RecordingLaws laws) {
    final warnings = <String>[];
    
    if (!laws.allowsRecording) {
      warnings.add('Recording may be prohibited in this jurisdiction.');
    }
    
    if (laws.requiresConsent && laws.consentType == ConsentType.allParties) {
      warnings.add('All parties must consent to recording.');
    }
    
    if (laws.hasSpecialRestrictions) {
      warnings.add('Special restrictions may apply to recording in this area.');
    }
    
    return warnings;
  }
  
  /// Generate recommendations based on recording laws
  List<String> _generateRecommendations(RecordingLaws laws) {
    final recommendations = <String>[];
    
    if (laws.requiresConsent) {
      recommendations.add('Obtain explicit consent before starting recording.');
    }
    
    recommendations.add('Inform all parties that recording is taking place.');
    recommendations.add('Keep records of consent for legal protection.');
    recommendations.add('Consult local laws or an attorney for specific guidance.');
    
    return recommendations;
  }
  
  /// Get cached recording laws
  Future<RecordingLaws?> _getCachedRecordingLaws(String jurisdiction) async {
    try {
      final cachedData = await _storageService.readFromFile('$_recordingLawsKey-$jurisdiction');
      if (cachedData != null) {
        final lawsMap = jsonDecode(cachedData);
        return RecordingLaws.fromJson(lawsMap);
      }
    } catch (e) {
      print('Error reading cached recording laws: $e');
    }
    return null;
  }
  
  /// Cache recording laws
  Future<void> _cacheRecordingLaws(String jurisdiction, RecordingLaws laws) async {
    try {
      final lawsJson = jsonEncode(laws.toJson());
      await _storageService.writeToFile('$_recordingLawsKey-$jurisdiction', lawsJson);
    } catch (e) {
      print('Error caching recording laws: $e');
    }
  }
  
  /// Get stored consent records
  Future<List<Map<String, dynamic>>> _getStoredConsents() async {
    try {
      final consentsJson = await _storageService.readFromFile(_consentRecordsKey);
      if (consentsJson != null) {
        final consentsList = jsonDecode(consentsJson) as List;
        return consentsList.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error reading stored consents: $e');
    }
    return [];
  }
}

/// Recording legality result
class RecordingLegalityResult {
  final bool isLegal;
  final bool requiresConsent;
  final ConsentType consentType;
  final String jurisdiction;
  final RecordingLaws laws;
  final List<String> warnings;
  final List<String> recommendations;
  
  RecordingLegalityResult({
    required this.isLegal,
    required this.requiresConsent,
    required this.consentType,
    required this.jurisdiction,
    required this.laws,
    required this.warnings,
    required this.recommendations,
  });
}

/// Recording laws model
class RecordingLaws {
  final bool allowsRecording;
  final bool requiresConsent;
  final ConsentType consentType;
  final bool hasSpecialRestrictions;
  final String jurisdiction;
  final List<String> restrictions;
  final List<String> exceptions;
  
  RecordingLaws({
    required this.allowsRecording,
    required this.requiresConsent,
    required this.consentType,
    required this.hasSpecialRestrictions,
    required this.jurisdiction,
    required this.restrictions,
    required this.exceptions,
  });
  
  factory RecordingLaws.restrictive() {
    return RecordingLaws(
      allowsRecording: false,
      requiresConsent: true,
      consentType: ConsentType.allParties,
      hasSpecialRestrictions: true,
      jurisdiction: 'Unknown',
      restrictions: ['Recording may be prohibited'],
      exceptions: [],
    );
  }
  
  factory RecordingLaws.fromJson(Map<String, dynamic> json) {
    return RecordingLaws(
      allowsRecording: json['allows_recording'] ?? false,
      requiresConsent: json['requires_consent'] ?? true,
      consentType: ConsentType.values.firstWhere(
        (e) => e.toString() == json['consent_type'],
        orElse: () => ConsentType.allParties,
      ),
      hasSpecialRestrictions: json['has_special_restrictions'] ?? false,
      jurisdiction: json['jurisdiction'] ?? 'Unknown',
      restrictions: List<String>.from(json['restrictions'] ?? []),
      exceptions: List<String>.from(json['exceptions'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'allows_recording': allowsRecording,
      'requires_consent': requiresConsent,
      'consent_type': consentType.toString(),
      'has_special_restrictions': hasSpecialRestrictions,
      'jurisdiction': jurisdiction,
      'restrictions': restrictions,
      'exceptions': exceptions,
    };
  }
}

/// Consent type enum
enum ConsentType {
  none,
  oneParty,
  allParties,
}

/// Consent record model
class ConsentRecord {
  final String participantId;
  final String participantName;
  final bool hasConsented;
  final DateTime timestamp;
  final String method; // verbal, written, digital
  final String? signature;
  
  ConsentRecord({
    required this.participantId,
    required this.participantName,
    required this.hasConsented,
    required this.timestamp,
    required this.method,
    this.signature,
  });
  
  factory ConsentRecord.fromJson(Map<String, dynamic> json) {
    return ConsentRecord(
      participantId: json['participant_id'],
      participantName: json['participant_name'],
      hasConsented: json['has_consented'],
      timestamp: DateTime.parse(json['timestamp']),
      method: json['method'],
      signature: json['signature'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'participant_id': participantId,
      'participant_name': participantName,
      'has_consented': hasConsented,
      'timestamp': timestamp.toIso8601String(),
      'method': method,
      'signature': signature,
    };
  }
}

/// Privacy settings model
class PrivacySettings {
  final bool allowDataSharing;
  final bool allowAnalytics;
  final bool allowCrashReporting;
  final bool autoDeleteRecordings;
  final int autoDeleteDays;
  final bool encryptLocalStorage;
  final bool requireBiometricAccess;
  
  PrivacySettings({
    required this.allowDataSharing,
    required this.allowAnalytics,
    required this.allowCrashReporting,
    required this.autoDeleteRecordings,
    required this.autoDeleteDays,
    required this.encryptLocalStorage,
    required this.requireBiometricAccess,
  });
  
  factory PrivacySettings.defaultSettings() {
    return PrivacySettings(
      allowDataSharing: false,
      allowAnalytics: false,
      allowCrashReporting: true,
      autoDeleteRecordings: true,
      autoDeleteDays: 30,
      encryptLocalStorage: true,
      requireBiometricAccess: true,
    );
  }
  
  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    return PrivacySettings(
      allowDataSharing: json['allow_data_sharing'] ?? false,
      allowAnalytics: json['allow_analytics'] ?? false,
      allowCrashReporting: json['allow_crash_reporting'] ?? true,
      autoDeleteRecordings: json['auto_delete_recordings'] ?? true,
      autoDeleteDays: json['auto_delete_days'] ?? 30,
      encryptLocalStorage: json['encrypt_local_storage'] ?? true,
      requireBiometricAccess: json['require_biometric_access'] ?? true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'allow_data_sharing': allowDataSharing,
      'allow_analytics': allowAnalytics,
      'allow_crash_reporting': allowCrashReporting,
      'auto_delete_recordings': autoDeleteRecordings,
      'auto_delete_days': autoDeleteDays,
      'encrypt_local_storage': encryptLocalStorage,
      'require_biometric_access': requireBiometricAccess,
    };
  }
}

/// Data retention requirements model
class DataRetentionRequirements {
  final Map<String, Duration> retentionPeriods;
  final bool allowsUserDeletion;
  final List<String> protectedDataTypes;
  
  DataRetentionRequirements({
    required this.retentionPeriods,
    required this.allowsUserDeletion,
    required this.protectedDataTypes,
  });
  
  factory DataRetentionRequirements.defaultRequirements() {
    return DataRetentionRequirements(
      retentionPeriods: {
        'recordings': const Duration(days: 365),
        'transcripts': const Duration(days: 365),
        'consent_records': const Duration(days: 2555), // 7 years
        'location_data': const Duration(days: 90),
      },
      allowsUserDeletion: true,
      protectedDataTypes: ['consent_records'],
    );
  }
  
  factory DataRetentionRequirements.fromJson(Map<String, dynamic> json) {
    final retentionMap = <String, Duration>{};
    final retentionJson = json['retention_periods'] as Map<String, dynamic>? ?? {};
    
    for (final entry in retentionJson.entries) {
      retentionMap[entry.key] = Duration(days: entry.value as int);
    }
    
    return DataRetentionRequirements(
      retentionPeriods: retentionMap,
      allowsUserDeletion: json['allows_user_deletion'] ?? true,
      protectedDataTypes: List<String>.from(json['protected_data_types'] ?? []),
    );
  }
  
  Duration? getRetentionPeriod(String dataType) {
    return retentionPeriods[dataType];
  }
  
  bool isProtectedDataType(String dataType) {
    return protectedDataTypes.contains(dataType);
  }
}