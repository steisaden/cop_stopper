/// Webhook event for real-time data updates
class WebhookEvent {
  final String id;
  final WebhookEventType type;
  final String topic;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final String? source;

  const WebhookEvent({
    required this.id,
    required this.type,
    required this.topic,
    required this.timestamp,
    this.data,
    this.source,
  });

  /// Create from JSON
  factory WebhookEvent.fromJson(Map<String, dynamic> json) {
    return WebhookEvent(
      id: json['id'] as String,
      type: WebhookEventType.values.byName(json['type'] as String),
      topic: json['topic'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      data: json['data'] as Map<String, dynamic>?,
      source: json['source'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'topic': topic,
      'timestamp': timestamp.toIso8601String(),
      if (data != null) 'data': data,
      if (source != null) 'source': source,
    };
  }

  /// Check if this event is for a specific officer
  bool isForOfficer(String officerId) {
    return data?['officer_id'] == officerId;
  }

  /// Check if this event is for a specific jurisdiction
  bool isForJurisdiction(String jurisdiction) {
    return data?['jurisdiction'] == jurisdiction;
  }

  /// Get the updated data type from the event
  String? get updatedDataType => data?['data_type'] as String?;

  /// Get the change type (created, updated, deleted)
  String? get changeType => data?['change_type'] as String?;

  @override
  String toString() {
    return 'WebhookEvent(id: $id, type: $type, topic: $topic)';
  }
}

/// Types of webhook events
enum WebhookEventType {
  dataUpdate,           // New or updated data available
  dataDeleted,          // Data has been deleted/removed
  systemNotification,   // System-wide notifications
  heartbeat,           // Keep-alive heartbeat
  error,               // Error notifications
  maintenance,         // Maintenance notifications
}

/// Specific webhook topics for officer records
class WebhookTopics {
  static const String officerUpdates = 'officer_updates';
  static const String complaintUpdates = 'complaint_updates';
  static const String disciplinaryUpdates = 'disciplinary_updates';
  static const String courtRecordUpdates = 'court_record_updates';
  static const String jurisdictionUpdates = 'jurisdiction_updates';
  static const String publicRecordsUpdates = 'public_records_updates';
  static const String systemNotifications = 'system_notifications';
}