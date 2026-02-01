enum EmergencyType {
  manualTrigger,
  consensusBased,
  unresponsiveBroadcaster,
  audioAnalysis,
  locationBased,
  participantReport,
}

enum EmergencyStatus {
  pending,
  escalated,
  resolved,
  falseAlarm,
}

enum EmergencySeverity {
  low,
  medium,
  high,
  critical,
}

class EmergencyTrigger {
  final String participantId;
  final EmergencyType type;
  final String reason;
  final DateTime timestamp;
  final Map<String, dynamic>? evidence;

  const EmergencyTrigger({
    required this.participantId,
    required this.type,
    required this.reason,
    required this.timestamp,
    this.evidence,
  });

  Map<String, dynamic> toJson() {
    return {
      'participantId': participantId,
      'type': type.toString(),
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'evidence': evidence,
    };
  }

  factory EmergencyTrigger.fromJson(Map<String, dynamic> json) {
    return EmergencyTrigger(
      participantId: json['participantId'] as String,
      type: EmergencyType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => EmergencyType.participantReport,
      ),
      reason: json['reason'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      evidence: json['evidence'] as Map<String, dynamic>?,
    );
  }
}

class EmergencyResponse {
  final String id;
  final String contactType; // 'emergency_services', 'emergency_contact', 'legal_aid'
  final String contactInfo;
  final DateTime contactedAt;
  final String? responseReceived;
  final DateTime? responseTime;

  const EmergencyResponse({
    required this.id,
    required this.contactType,
    required this.contactInfo,
    required this.contactedAt,
    this.responseReceived,
    this.responseTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactType': contactType,
      'contactInfo': contactInfo,
      'contactedAt': contactedAt.toIso8601String(),
      'responseReceived': responseReceived,
      'responseTime': responseTime?.toIso8601String(),
    };
  }

  factory EmergencyResponse.fromJson(Map<String, dynamic> json) {
    return EmergencyResponse(
      id: json['id'] as String,
      contactType: json['contactType'] as String,
      contactInfo: json['contactInfo'] as String,
      contactedAt: DateTime.parse(json['contactedAt'] as String),
      responseReceived: json['responseReceived'] as String?,
      responseTime: json['responseTime'] != null
          ? DateTime.parse(json['responseTime'] as String)
          : null,
    );
  }
}

class EmergencyEvent {
  final String id;
  final String sessionId;
  final EmergencyType type;
  final EmergencyStatus status;
  final EmergencySeverity severity;
  final DateTime timestamp;
  final String description;
  final List<EmergencyTrigger> triggers;
  final List<EmergencyResponse> responses;
  final Map<String, dynamic>? location;
  final Map<String, dynamic>? metadata;
  final DateTime? resolvedAt;

  const EmergencyEvent({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.status,
    required this.severity,
    required this.timestamp,
    required this.description,
    required this.triggers,
    required this.responses,
    this.location,
    this.metadata,
    this.resolvedAt,
  });

  EmergencyEvent copyWith({
    String? id,
    String? sessionId,
    EmergencyType? type,
    EmergencyStatus? status,
    EmergencySeverity? severity,
    DateTime? timestamp,
    String? description,
    List<EmergencyTrigger>? triggers,
    List<EmergencyResponse>? responses,
    Map<String, dynamic>? location,
    Map<String, dynamic>? metadata,
    DateTime? resolvedAt,
  }) {
    return EmergencyEvent(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      status: status ?? this.status,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      triggers: triggers ?? this.triggers,
      responses: responses ?? this.responses,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  bool get isActive => status == EmergencyStatus.pending || status == EmergencyStatus.escalated;
  bool get isResolved => status == EmergencyStatus.resolved;
  bool get requiresConsensus => type == EmergencyType.consensusBased;
  
  int get triggerCount => triggers.length;
  Duration get duration => (resolvedAt ?? DateTime.now()).difference(timestamp);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'type': type.toString(),
      'status': status.toString(),
      'severity': severity.toString(),
      'timestamp': timestamp.toIso8601String(),
      'description': description,
      'triggers': triggers.map((t) => t.toJson()).toList(),
      'responses': responses.map((r) => r.toJson()).toList(),
      'location': location,
      'metadata': metadata,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory EmergencyEvent.fromJson(Map<String, dynamic> json) {
    return EmergencyEvent(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      type: EmergencyType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => EmergencyType.participantReport,
      ),
      status: EmergencyStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => EmergencyStatus.pending,
      ),
      severity: EmergencySeverity.values.firstWhere(
        (e) => e.toString() == json['severity'],
        orElse: () => EmergencySeverity.medium,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
      triggers: (json['triggers'] as List<dynamic>)
          .map((t) => EmergencyTrigger.fromJson(t as Map<String, dynamic>))
          .toList(),
      responses: (json['responses'] as List<dynamic>)
          .map((r) => EmergencyResponse.fromJson(r as Map<String, dynamic>))
          .toList(),
      location: json['location'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'EmergencyEvent(id: $id, type: $type, status: $status, severity: $severity)';
  }
}
