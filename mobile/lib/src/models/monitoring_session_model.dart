import 'transcription_segment_model.dart';
import 'fact_check_result_model.dart';

/// Represents a complete monitoring session with all associated data
class MonitoringSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<TranscriptionSegment> transcriptionSegments;
  final List<FactCheckResult> factCheckResults;
  final List<LegalAlert> legalAlerts;
  final Map<String, String> speakerLabels;
  final List<SessionEvent> events;
  final SessionStatus status;
  final String? location;
  final String? jurisdiction;
  final Map<String, dynamic> metadata;

  const MonitoringSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.transcriptionSegments,
    required this.factCheckResults,
    required this.legalAlerts,
    required this.speakerLabels,
    required this.events,
    required this.status,
    this.location,
    this.jurisdiction,
    required this.metadata,
  });

  factory MonitoringSession.fromJson(Map<String, dynamic> json) {
    return MonitoringSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      transcriptionSegments: (json['transcriptionSegments'] as List)
          .map((e) => TranscriptionSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
      factCheckResults: (json['factCheckResults'] as List)
          .map((e) => FactCheckResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      legalAlerts: (json['legalAlerts'] as List)
          .map((e) => LegalAlert.fromJson(e as Map<String, dynamic>))
          .toList(),
      speakerLabels: Map<String, String>.from(json['speakerLabels'] as Map),
      events: (json['events'] as List)
          .map((e) => SessionEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.active,
      ),
      location: json['location'] as String?,
      jurisdiction: json['jurisdiction'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'transcriptionSegments': transcriptionSegments.map((e) => e.toJson()).toList(),
      'factCheckResults': factCheckResults.map((e) => e.toJson()).toList(),
      'legalAlerts': legalAlerts.map((e) => e.toJson()).toList(),
      'speakerLabels': speakerLabels,
      'events': events.map((e) => e.toJson()).toList(),
      'status': status.name,
      'location': location,
      'jurisdiction': jurisdiction,
      'metadata': metadata,
    };
  }

  MonitoringSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    List<TranscriptionSegment>? transcriptionSegments,
    List<FactCheckResult>? factCheckResults,
    List<LegalAlert>? legalAlerts,
    Map<String, String>? speakerLabels,
    List<SessionEvent>? events,
    SessionStatus? status,
    String? location,
    String? jurisdiction,
    Map<String, dynamic>? metadata,
  }) {
    return MonitoringSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      transcriptionSegments: transcriptionSegments ?? this.transcriptionSegments,
      factCheckResults: factCheckResults ?? this.factCheckResults,
      legalAlerts: legalAlerts ?? this.legalAlerts,
      speakerLabels: speakerLabels ?? this.speakerLabels,
      events: events ?? this.events,
      status: status ?? this.status,
      location: location ?? this.location,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Get session duration
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Get session summary statistics
  SessionSummary get summary {
    return SessionSummary(
      sessionId: id,
      duration: duration,
      totalSegments: transcriptionSegments.length,
      totalWords: transcriptionSegments
          .map((s) => s.text.split(' ').length)
          .fold<int>(0, (a, b) => a + b),
      uniqueSpeakers: transcriptionSegments
          .where((s) => s.speakerId != null)
          .map((s) => s.speakerId!)
          .toSet()
          .length,
      averageConfidence: transcriptionSegments.isEmpty
          ? 0.0
          : transcriptionSegments
                  .map((s) => s.confidence)
                  .reduce((a, b) => a + b) /
              transcriptionSegments.length,
      factCheckResults: factCheckResults.length,
      verifiedClaims: factCheckResults
          .where((r) => r.status == FactCheckStatus.verified)
          .length,
      disputedClaims: factCheckResults
          .where((r) => r.status == FactCheckStatus.disputed)
          .length,
      falseClaims: factCheckResults
          .where((r) => r.status == FactCheckStatus.false_claim)
          .length,
      legalAlerts: legalAlerts.length,
      criticalAlerts: legalAlerts
          .where((a) => a.severity == LegalAlertSeverity.critical)
          .length,
      highSeverityAlerts: legalAlerts
          .where((a) => a.severity == LegalAlertSeverity.high)
          .length,
      keyEvents: events
          .where((e) => e.importance == EventImportance.high)
          .length,
    );
  }

  /// Get critical issues that require immediate attention
  List<String> get criticalIssues {
    final issues = <String>[];
    
    // Critical legal alerts
    final criticalAlerts = legalAlerts
        .where((a) => a.severity == LegalAlertSeverity.critical)
        .toList();
    for (final alert in criticalAlerts) {
      issues.add('CRITICAL: ${alert.title}');
    }
    
    // False claims
    final falseClaims = factCheckResults
        .where((r) => r.status == FactCheckStatus.false_claim)
        .toList();
    for (final claim in falseClaims) {
      issues.add('FALSE CLAIM: ${claim.claim}');
    }
    
    // High importance events
    final highImportanceEvents = events
        .where((e) => e.importance == EventImportance.high)
        .toList();
    for (final event in highImportanceEvents) {
      issues.add('EVENT: ${event.description}');
    }
    
    return issues;
  }

  /// Check if session has any critical issues
  bool get hasCriticalIssues {
    return legalAlerts.any((a) => a.severity == LegalAlertSeverity.critical) ||
           factCheckResults.any((r) => r.status == FactCheckStatus.false_claim) ||
           events.any((e) => e.importance == EventImportance.high);
  }

  void validate() {
    if (id.isEmpty) {
      throw ArgumentError('Session ID cannot be empty');
    }
    if (endTime != null && endTime!.isBefore(startTime)) {
      throw ArgumentError('End time cannot be before start time');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonitoringSession &&
        other.id == id &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.status == status;
  }

  @override
  int get hashCode {
    return Object.hash(id, startTime, endTime, status);
  }

  @override
  String toString() {
    return 'MonitoringSession(id: $id, status: $status, duration: $duration)';
  }
}

/// Represents an event that occurred during a monitoring session
class SessionEvent {
  final String id;
  final DateTime timestamp;
  final EventType type;
  final String description;
  final EventImportance importance;
  final Map<String, dynamic> data;
  final String? relatedSegmentId;
  final String? relatedAlertId;

  const SessionEvent({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.description,
    required this.importance,
    required this.data,
    this.relatedSegmentId,
    this.relatedAlertId,
  });

  factory SessionEvent.fromJson(Map<String, dynamic> json) {
    return SessionEvent(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.other,
      ),
      description: json['description'] as String,
      importance: EventImportance.values.firstWhere(
        (e) => e.name == json['importance'],
        orElse: () => EventImportance.medium,
      ),
      data: Map<String, dynamic>.from(json['data'] as Map),
      relatedSegmentId: json['relatedSegmentId'] as String?,
      relatedAlertId: json['relatedAlertId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'description': description,
      'importance': importance.name,
      'data': data,
      'relatedSegmentId': relatedSegmentId,
      'relatedAlertId': relatedAlertId,
    };
  }

  /// Get formatted timestamp for display
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
           '${timestamp.minute.toString().padLeft(2, '0')}:'
           '${timestamp.second.toString().padLeft(2, '0')}';
  }

  void validate() {
    if (description.isEmpty) {
      throw ArgumentError('Event description cannot be empty');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionEvent &&
        other.id == id &&
        other.timestamp == timestamp &&
        other.type == type &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(id, timestamp, type, description);
  }

  @override
  String toString() {
    return 'SessionEvent(type: $type, importance: $importance, description: $description)';
  }
}

/// Summary statistics for a monitoring session
class SessionSummary {
  final String sessionId;
  final Duration duration;
  final int totalSegments;
  final int totalWords;
  final int uniqueSpeakers;
  final double averageConfidence;
  final int factCheckResults;
  final int verifiedClaims;
  final int disputedClaims;
  final int falseClaims;
  final int legalAlerts;
  final int criticalAlerts;
  final int highSeverityAlerts;
  final int keyEvents;

  const SessionSummary({
    required this.sessionId,
    required this.duration,
    required this.totalSegments,
    required this.totalWords,
    required this.uniqueSpeakers,
    required this.averageConfidence,
    required this.factCheckResults,
    required this.verifiedClaims,
    required this.disputedClaims,
    required this.falseClaims,
    required this.legalAlerts,
    required this.criticalAlerts,
    required this.highSeverityAlerts,
    required this.keyEvents,
  });

  /// Get formatted duration string
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Get confidence percentage as string
  String get confidencePercentage {
    return '${(averageConfidence * 100).toStringAsFixed(1)}%';
  }

  @override
  String toString() {
    return 'SessionSummary(duration: $formattedDuration, segments: $totalSegments, alerts: $legalAlerts)';
  }
}

/// Status of a monitoring session
enum SessionStatus {
  active,
  paused,
  completed,
  error,
  cancelled,
}

/// Types of events that can occur during a session
enum EventType {
  sessionStart,
  sessionEnd,
  transcriptionStart,
  transcriptionEnd,
  factCheckTriggered,
  legalAlertTriggered,
  emergencyActivated,
  incidentFlagged,
  legalHelpRequested,
  other,
}

/// Importance levels for session events
enum EventImportance {
  low,
  medium,
  high,
  critical,
}