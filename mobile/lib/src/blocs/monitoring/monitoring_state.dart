import 'package:equatable/equatable.dart';
import '../../models/transcription_segment_model.dart';
import '../../models/fact_check_result_model.dart';
import '../../models/monitoring_session_model.dart';

/// States for the monitoring BLoC
abstract class MonitoringState extends Equatable {
  const MonitoringState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MonitoringInitial extends MonitoringState {
  const MonitoringInitial();
}

/// Monitoring session is active
class MonitoringActive extends MonitoringState {
  final List<TranscriptionSegment> transcriptionSegments;
  final Map<String, String> speakerLabels;
  final bool autoScrollEnabled;
  final double confidenceThreshold;
  final DateTime sessionStartTime;
  final List<FactCheckResult> factCheckResults;
  final List<LegalAlert> legalAlerts;
  final List<SessionEvent> sessionEvents;
  final MonitoringSession? currentSession;

  const MonitoringActive({
    required this.transcriptionSegments,
    required this.speakerLabels,
    required this.autoScrollEnabled,
    required this.confidenceThreshold,
    required this.sessionStartTime,
    required this.factCheckResults,
    required this.legalAlerts,
    required this.sessionEvents,
    this.currentSession,
  });

  MonitoringActive copyWith({
    List<TranscriptionSegment>? transcriptionSegments,
    Map<String, String>? speakerLabels,
    bool? autoScrollEnabled,
    double? confidenceThreshold,
    DateTime? sessionStartTime,
    List<FactCheckResult>? factCheckResults,
    List<LegalAlert>? legalAlerts,
    List<SessionEvent>? sessionEvents,
    MonitoringSession? currentSession,
  }) {
    return MonitoringActive(
      transcriptionSegments: transcriptionSegments ?? this.transcriptionSegments,
      speakerLabels: speakerLabels ?? this.speakerLabels,
      autoScrollEnabled: autoScrollEnabled ?? this.autoScrollEnabled,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      factCheckResults: factCheckResults ?? this.factCheckResults,
      legalAlerts: legalAlerts ?? this.legalAlerts,
      sessionEvents: sessionEvents ?? this.sessionEvents,
      currentSession: currentSession ?? this.currentSession,
    );
  }

  /// Get segments filtered by confidence threshold
  List<TranscriptionSegment> get filteredSegments {
    return transcriptionSegments
        .where((segment) => segment.confidence >= confidenceThreshold)
        .toList();
  }

  /// Get unique speakers in the session
  Set<String> get uniqueSpeakers {
    return transcriptionSegments
        .where((segment) => segment.speakerId != null)
        .map((segment) => segment.speakerId!)
        .toSet();
  }

  /// Get session duration
  Duration get sessionDuration {
    return DateTime.now().difference(sessionStartTime);
  }

  /// Get total transcription segments count
  int get totalSegments => transcriptionSegments.length;

  /// Get segments with low confidence
  List<TranscriptionSegment> get lowConfidenceSegments {
    return transcriptionSegments
        .where((segment) => segment.confidence < confidenceThreshold)
        .toList();
  }

  /// Get fact-check results that require attention
  List<FactCheckResult> get attentionRequiredResults {
    return factCheckResults.where((result) => result.requiresAttention).toList();
  }

  /// Get legal alerts by severity
  List<LegalAlert> getAlertsBySeverity(LegalAlertSeverity severity) {
    return legalAlerts.where((alert) => alert.severity == severity).toList();
  }

  /// Get critical legal alerts
  List<LegalAlert> get criticalAlerts {
    return legalAlerts
        .where((alert) => alert.severity == LegalAlertSeverity.critical)
        .toList();
  }

  /// Get high importance events
  List<SessionEvent> get highImportanceEvents {
    return sessionEvents
        .where((event) => event.importance == EventImportance.high)
        .toList();
  }

  /// Get current session summary
  SessionSummary get sessionSummary {
    return SessionSummary(
      sessionId: currentSession?.id ?? 'current',
      duration: sessionDuration,
      totalSegments: transcriptionSegments.length,
      totalWords: transcriptionSegments
          .map((s) => s.text.split(' ').length)
          .fold<int>(0, (a, b) => a + b),
      uniqueSpeakers: uniqueSpeakers.length,
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
      criticalAlerts: criticalAlerts.length,
      highSeverityAlerts: legalAlerts
          .where((a) => a.severity == LegalAlertSeverity.high)
          .length,
      keyEvents: highImportanceEvents.length,
    );
  }

  @override
  List<Object?> get props => [
        transcriptionSegments,
        speakerLabels,
        autoScrollEnabled,
        confidenceThreshold,
        sessionStartTime,
        factCheckResults,
        legalAlerts,
        sessionEvents,
        currentSession,
      ];
}

/// Monitoring session is stopped
class MonitoringStopped extends MonitoringState {
  final List<TranscriptionSegment> finalTranscriptionSegments;
  final Map<String, String> speakerLabels;
  final DateTime sessionStartTime;
  final DateTime sessionEndTime;
  final List<FactCheckResult> finalFactCheckResults;
  final List<LegalAlert> finalLegalAlerts;
  final List<SessionEvent> finalSessionEvents;
  final MonitoringSession? finalSession;

  const MonitoringStopped({
    required this.finalTranscriptionSegments,
    required this.speakerLabels,
    required this.sessionStartTime,
    required this.sessionEndTime,
    required this.finalFactCheckResults,
    required this.finalLegalAlerts,
    required this.finalSessionEvents,
    this.finalSession,
  });

  /// Get session duration
  Duration get sessionDuration {
    return sessionEndTime.difference(sessionStartTime);
  }

  /// Get session summary statistics
  Map<String, dynamic> get sessionSummary {
    return {
      'totalSegments': finalTranscriptionSegments.length,
      'uniqueSpeakers': finalTranscriptionSegments
          .where((s) => s.speakerId != null)
          .map((s) => s.speakerId!)
          .toSet()
          .length,
      'averageConfidence': finalTranscriptionSegments.isEmpty
          ? 0.0
          : finalTranscriptionSegments
                  .map((s) => s.confidence)
                  .reduce((a, b) => a + b) /
              finalTranscriptionSegments.length,
      'duration': sessionDuration,
      'totalWords': finalTranscriptionSegments
          .map((s) => s.text.split(' ').length)
          .fold<int>(0, (a, b) => a + b),
      'factCheckResults': finalFactCheckResults.length,
      'legalAlerts': finalLegalAlerts.length,
      'criticalAlerts': finalLegalAlerts
          .where((alert) => alert.severity == LegalAlertSeverity.critical)
          .length,
      'sessionEvents': finalSessionEvents.length,
      'keyEvents': finalSessionEvents
          .where((event) => event.importance == EventImportance.high)
          .length,
    };
  }

  @override
  List<Object?> get props => [
        finalTranscriptionSegments,
        speakerLabels,
        sessionStartTime,
        sessionEndTime,
        finalFactCheckResults,
        finalLegalAlerts,
        finalSessionEvents,
        finalSession,
      ];
}

/// Error state
class MonitoringError extends MonitoringState {
  final String message;
  final String? errorCode;

  const MonitoringError(this.message, {this.errorCode});

  @override
  List<Object?> get props => [message, errorCode];
}