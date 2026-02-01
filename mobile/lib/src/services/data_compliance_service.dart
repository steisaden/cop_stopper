import '../models/compliance_audit_log.dart';
import '../models/data_retention_policy.dart';

/// Data compliance service ensuring GDPR/CCPA compliance for public records
class DataComplianceService {
  final List<ComplianceAuditLog> _auditLogs = [];
  final DataRetentionPolicy retentionPolicy;

  DataComplianceService({
    required this.retentionPolicy,
  });

  /// Validate that data access is compliant with privacy laws
  Future<ComplianceValidationResult> validateDataAccess({
    required String dataType,
    required String purpose,
    required String jurisdiction,
    String? userConsent,
  }) async {
    final validationId = _generateValidationId();
    
    try {
      // Check if this is public records data (always allowed)
      if (_isPublicRecordsData(dataType)) {
        await _logDataAccess(
          validationId: validationId,
          dataType: dataType,
          purpose: purpose,
          jurisdiction: jurisdiction,
          result: ComplianceResult.approved,
          reason: 'Public records - no privacy restrictions',
        );
        
        return ComplianceValidationResult.approved(
          validationId: validationId,
          reason: 'Public records access is permitted under transparency laws',
        );
      }

      // Check for explicit user consent for non-public data
      if (userConsent == null) {
        await _logDataAccess(
          validationId: validationId,
          dataType: dataType,
          purpose: purpose,
          jurisdiction: jurisdiction,
          result: ComplianceResult.denied,
          reason: 'No user consent provided for non-public data',
        );
        
        return ComplianceValidationResult.denied(
          validationId: validationId,
          reason: 'User consent required for non-public data access',
        );
      }

      // Validate purpose limitation (GDPR Article 5)
      if (!_isValidPurpose(purpose)) {
        await _logDataAccess(
          validationId: validationId,
          dataType: dataType,
          purpose: purpose,
          jurisdiction: jurisdiction,
          result: ComplianceResult.denied,
          reason: 'Invalid purpose for data processing',
        );
        
        return ComplianceValidationResult.denied(
          validationId: validationId,
          reason: 'Purpose does not meet legal requirements',
        );
      }

      // Check data minimization (only collect what's necessary)
      if (!_meetsDataMinimization(dataType, purpose)) {
        await _logDataAccess(
          validationId: validationId,
          dataType: dataType,
          purpose: purpose,
          jurisdiction: jurisdiction,
          result: ComplianceResult.denied,
          reason: 'Violates data minimization principle',
        );
        
        return ComplianceValidationResult.denied(
          validationId: validationId,
          reason: 'Data collection exceeds necessity for stated purpose',
        );
      }

      // All checks passed
      await _logDataAccess(
        validationId: validationId,
        dataType: dataType,
        purpose: purpose,
        jurisdiction: jurisdiction,
        result: ComplianceResult.approved,
        reason: 'All compliance checks passed',
      );

      return ComplianceValidationResult.approved(
        validationId: validationId,
        reason: 'Data access approved under privacy regulations',
      );

    } catch (e) {
      await _logDataAccess(
        validationId: validationId,
        dataType: dataType,
        purpose: purpose,
        jurisdiction: jurisdiction,
        result: ComplianceResult.error,
        reason: 'Validation error: $e',
      );
      
      return ComplianceValidationResult.error(
        validationId: validationId,
        reason: 'Compliance validation failed: $e',
      );
    }
  }

  /// Check if data type is public records (no privacy restrictions)
  bool _isPublicRecordsData(String dataType) {
    const publicDataTypes = {
      'officer_badge_number',
      'officer_name',
      'officer_department',
      'public_complaint_records',
      'court_records',
      'disciplinary_actions_public',
      'commendations',
      'employment_history_public',
    };
    
    return publicDataTypes.contains(dataType);
  }

  /// Validate that the purpose is legitimate and specific
  bool _isValidPurpose(String purpose) {
    const validPurposes = {
      'police_accountability',
      'transparency_research',
      'legal_defense',
      'public_safety',
      'journalism',
      'academic_research',
    };
    
    return validPurposes.contains(purpose);
  }

  /// Check data minimization principle
  bool _meetsDataMinimization(String dataType, String purpose) {
    // Define what data is necessary for each purpose
    const purposeDataMap = {
      'police_accountability': {
        'officer_badge_number',
        'officer_name',
        'officer_department',
        'public_complaint_records',
        'disciplinary_actions_public',
      },
      'transparency_research': {
        'officer_department',
        'public_complaint_records',
        'disciplinary_actions_public',
        'court_records',
      },
      'legal_defense': {
        'officer_badge_number',
        'officer_name',
        'court_records',
        'disciplinary_actions_public',
      },
    };

    final allowedData = purposeDataMap[purpose];
    return allowedData?.contains(dataType) ?? false;
  }

  /// Log data access for audit trail
  Future<void> _logDataAccess({
    required String validationId,
    required String dataType,
    required String purpose,
    required String jurisdiction,
    required ComplianceResult result,
    required String reason,
  }) async {
    final log = ComplianceAuditLog(
      id: validationId,
      timestamp: DateTime.now(),
      dataType: dataType,
      purpose: purpose,
      jurisdiction: jurisdiction,
      result: result,
      reason: reason,
      userAgent: 'CopStopper/1.0',
    );

    _auditLogs.add(log);
    
    // In production, this would be sent to a secure audit logging service
    print('Compliance audit: ${log.toJson()}');
  }

  /// Generate unique validation ID for audit trail
  String _generateValidationId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 1000000;
    return 'val_${timestamp}_$random';
  }

  /// Handle data subject rights (GDPR Article 15-22)
  Future<DataSubjectRightsResponse> handleDataSubjectRequest({
    required DataSubjectRightType rightType,
    required String subjectId,
    String? specificData,
  }) async {
    final requestId = _generateValidationId();
    
    switch (rightType) {
      case DataSubjectRightType.access:
        return _handleAccessRequest(requestId, subjectId);
      
      case DataSubjectRightType.rectification:
        return _handleRectificationRequest(requestId, subjectId, specificData);
      
      case DataSubjectRightType.erasure:
        return _handleErasureRequest(requestId, subjectId);
      
      case DataSubjectRightType.portability:
        return _handlePortabilityRequest(requestId, subjectId);
      
      case DataSubjectRightType.objection:
        return _handleObjectionRequest(requestId, subjectId);
    }
  }

  Future<DataSubjectRightsResponse> _handleAccessRequest(
    String requestId,
    String subjectId,
  ) async {
    // For public records, we can provide information about what data we have
    return DataSubjectRightsResponse(
      requestId: requestId,
      success: true,
      message: 'Public records data access provided',
      data: {
        'note': 'This app only accesses public records which are not subject to privacy restrictions',
        'data_types': ['officer_public_records', 'court_records', 'public_complaints'],
        'retention_period': retentionPolicy.defaultRetentionPeriod.inDays,
      },
    );
  }

  Future<DataSubjectRightsResponse> _handleRectificationRequest(
    String requestId,
    String subjectId,
    String? specificData,
  ) async {
    return DataSubjectRightsResponse(
      requestId: requestId,
      success: false,
      message: 'Public records cannot be rectified through this app. Contact the original data source.',
      data: {
        'note': 'This app displays public records from government sources. To correct inaccurate information, contact the relevant government agency.',
      },
    );
  }

  Future<DataSubjectRightsResponse> _handleErasureRequest(
    String requestId,
    String subjectId,
  ) async {
    return DataSubjectRightsResponse(
      requestId: requestId,
      success: false,
      message: 'Public records cannot be erased as they are maintained by government agencies for transparency.',
      data: {
        'note': 'Public records are maintained by government agencies and cannot be deleted from this app.',
        'alternative': 'Contact the relevant government agency if you believe records are inaccurate.',
      },
    );
  }

  Future<DataSubjectRightsResponse> _handlePortabilityRequest(
    String requestId,
    String subjectId,
  ) async {
    return DataSubjectRightsResponse(
      requestId: requestId,
      success: true,
      message: 'Public records data can be exported',
      data: {
        'format': 'JSON',
        'note': 'Public records are available in machine-readable format from original government sources',
      },
    );
  }

  Future<DataSubjectRightsResponse> _handleObjectionRequest(
    String requestId,
    String subjectId,
  ) async {
    return DataSubjectRightsResponse(
      requestId: requestId,
      success: false,
      message: 'Cannot object to processing of public records as they serve legitimate public interest',
      data: {
        'legal_basis': 'Public records processing is based on legitimate public interest in transparency and accountability',
      },
    );
  }

  /// Get audit logs for compliance reporting
  List<ComplianceAuditLog> getAuditLogs({
    DateTime? startDate,
    DateTime? endDate,
    ComplianceResult? result,
  }) {
    return _auditLogs.where((log) {
      if (startDate != null && log.timestamp.isBefore(startDate)) return false;
      if (endDate != null && log.timestamp.isAfter(endDate)) return false;
      if (result != null && log.result != result) return false;
      return true;
    }).toList();
  }

  /// Generate compliance report
  Map<String, dynamic> generateComplianceReport({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final logs = getAuditLogs(startDate: startDate, endDate: endDate);
    
    final totalRequests = logs.length;
    final approvedRequests = logs.where((log) => log.result == ComplianceResult.approved).length;
    final deniedRequests = logs.where((log) => log.result == ComplianceResult.denied).length;
    final errorRequests = logs.where((log) => log.result == ComplianceResult.error).length;

    return {
      'report_period': {
        'start': startDate?.toIso8601String() ?? 'inception',
        'end': endDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      },
      'summary': {
        'total_requests': totalRequests,
        'approved_requests': approvedRequests,
        'denied_requests': deniedRequests,
        'error_requests': errorRequests,
        'approval_rate': totalRequests > 0 ? (approvedRequests / totalRequests * 100).toStringAsFixed(2) : '0.00',
      },
      'data_types_accessed': logs.map((log) => log.dataType).toSet().toList(),
      'purposes': logs.map((log) => log.purpose).toSet().toList(),
      'jurisdictions': logs.map((log) => log.jurisdiction).toSet().toList(),
    };
  }
}

/// Result of compliance validation
class ComplianceValidationResult {
  final String validationId;
  final ComplianceResult result;
  final String reason;

  const ComplianceValidationResult({
    required this.validationId,
    required this.result,
    required this.reason,
  });

  factory ComplianceValidationResult.approved({
    required String validationId,
    required String reason,
  }) {
    return ComplianceValidationResult(
      validationId: validationId,
      result: ComplianceResult.approved,
      reason: reason,
    );
  }

  factory ComplianceValidationResult.denied({
    required String validationId,
    required String reason,
  }) {
    return ComplianceValidationResult(
      validationId: validationId,
      result: ComplianceResult.denied,
      reason: reason,
    );
  }

  factory ComplianceValidationResult.error({
    required String validationId,
    required String reason,
  }) {
    return ComplianceValidationResult(
      validationId: validationId,
      result: ComplianceResult.error,
      reason: reason,
    );
  }

  bool get isApproved => result == ComplianceResult.approved;
  bool get isDenied => result == ComplianceResult.denied;
  bool get isError => result == ComplianceResult.error;
}

/// Data subject rights response
class DataSubjectRightsResponse {
  final String requestId;
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const DataSubjectRightsResponse({
    required this.requestId,
    required this.success,
    required this.message,
    this.data,
  });
}

/// Types of data subject rights under GDPR
enum DataSubjectRightType {
  access,        // Article 15 - Right of access
  rectification, // Article 16 - Right to rectification
  erasure,       // Article 17 - Right to erasure
  portability,   // Article 20 - Right to data portability
  objection,     // Article 21 - Right to object
}

/// Compliance result types
enum ComplianceResult {
  approved,
  denied,
  error,
}