import '../services/data_compliance_service.dart';

/// Audit log entry for compliance tracking
class ComplianceAuditLog {
  final String id;
  final DateTime timestamp;
  final String dataType;
  final String purpose;
  final String jurisdiction;
  final ComplianceResult result;
  final String reason;
  final String userAgent;

  const ComplianceAuditLog({
    required this.id,
    required this.timestamp,
    required this.dataType,
    required this.purpose,
    required this.jurisdiction,
    required this.result,
    required this.reason,
    required this.userAgent,
  });

  /// Convert to JSON for logging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'data_type': dataType,
      'purpose': purpose,
      'jurisdiction': jurisdiction,
      'result': result.name,
      'reason': reason,
      'user_agent': userAgent,
    };
  }

  /// Create from JSON
  factory ComplianceAuditLog.fromJson(Map<String, dynamic> json) {
    return ComplianceAuditLog(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      dataType: json['data_type'] as String,
      purpose: json['purpose'] as String,
      jurisdiction: json['jurisdiction'] as String,
      result: ComplianceResult.values.byName(json['result'] as String),
      reason: json['reason'] as String,
      userAgent: json['user_agent'] as String,
    );
  }

  @override
  String toString() {
    return 'ComplianceAuditLog(id: $id, result: $result, dataType: $dataType)';
  }
}