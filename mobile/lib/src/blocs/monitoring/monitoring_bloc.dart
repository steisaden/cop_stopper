import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/transcription_segment_model.dart';
import '../../models/fact_check_result_model.dart';
import '../../models/monitoring_session_model.dart';
import 'monitoring_event.dart';
import 'monitoring_state.dart';

/// BLoC for managing monitoring session state and transcription
class MonitoringBloc extends Bloc<MonitoringEvent, MonitoringState> {
  MonitoringBloc() : super(const MonitoringInitial()) {
    on<StartMonitoring>(_onStartMonitoring);
    on<StopMonitoring>(_onStopMonitoring);
    on<AddTranscriptionSegment>(_onAddTranscriptionSegment);
    on<UpdateTranscriptionSegment>(_onUpdateTranscriptionSegment);
    on<ClearTranscription>(_onClearTranscription);
    on<ToggleAutoScroll>(_onToggleAutoScroll);
    on<SetSpeakerLabel>(_onSetSpeakerLabel);
    on<UpdateConfidenceThreshold>(_onUpdateConfidenceThreshold);
    on<AddFactCheckResult>(_onAddFactCheckResult);
    on<AddLegalAlert>(_onAddLegalAlert);
    on<ClearFactCheckResults>(_onClearFactCheckResults);
    on<ClearLegalAlerts>(_onClearLegalAlerts);
    on<FlagIncident>(_onFlagIncident);
    on<RequestLegalHelp>(_onRequestLegalHelp);
    on<ContactEmergency>(_onContactEmergency);
    on<GenerateReport>(_onGenerateReport);
    on<AddSessionEvent>(_onAddSessionEvent);
    on<FactCheckRequested>(_onFactCheckRequested);
  }

  void _onStartMonitoring(
    StartMonitoring event,
    Emitter<MonitoringState> emit,
  ) {
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final startTime = DateTime.now();

    // Create session start event
    final startEvent = SessionEvent(
      id: '${sessionId}_start',
      timestamp: startTime,
      type: EventType.sessionStart,
      description: 'Monitoring session started',
      importance: EventImportance.medium,
      data: {'sessionId': sessionId},
    );

    emit(MonitoringActive(
      transcriptionSegments: const [],
      speakerLabels: const {},
      autoScrollEnabled: true,
      confidenceThreshold: 0.5,
      sessionStartTime: startTime,
      factCheckResults: const [],
      legalAlerts: const [],
      sessionEvents: [startEvent],
      currentSession: MonitoringSession(
        id: sessionId,
        startTime: startTime,
        transcriptionSegments: const [],
        factCheckResults: const [],
        legalAlerts: const [],
        speakerLabels: const {},
        events: [startEvent],
        status: SessionStatus.active,
        metadata: {},
      ),
    ));
  }

  void _onStopMonitoring(
    StopMonitoring event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;
      final endTime = DateTime.now();

      // Create session end event
      final endEvent = SessionEvent(
        id: '${activeState.currentSession?.id ?? 'unknown'}_end',
        timestamp: endTime,
        type: EventType.sessionEnd,
        description: 'Monitoring session ended',
        importance: EventImportance.medium,
        data: {
          'duration':
              endTime.difference(activeState.sessionStartTime).inSeconds,
          'totalSegments': activeState.transcriptionSegments.length,
          'totalAlerts': activeState.legalAlerts.length,
        },
      );

      final finalEvents = [...activeState.sessionEvents, endEvent];

      // Create final session
      final finalSession = activeState.currentSession?.copyWith(
        endTime: endTime,
        transcriptionSegments: activeState.transcriptionSegments,
        factCheckResults: activeState.factCheckResults,
        legalAlerts: activeState.legalAlerts,
        speakerLabels: activeState.speakerLabels,
        events: finalEvents,
        status: SessionStatus.completed,
      );

      emit(MonitoringStopped(
        finalTranscriptionSegments: activeState.transcriptionSegments,
        speakerLabels: activeState.speakerLabels,
        sessionStartTime: activeState.sessionStartTime,
        sessionEndTime: endTime,
        finalFactCheckResults: activeState.factCheckResults,
        finalLegalAlerts: activeState.legalAlerts,
        finalSessionEvents: finalEvents,
        finalSession: finalSession,
      ));
    }
  }

  void _onAddTranscriptionSegment(
    AddTranscriptionSegment event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;

      // Validate the segment
      try {
        event.segment.validate();
      } catch (e) {
        emit(MonitoringError('Invalid transcription segment: $e'));
        return;
      }

      final updatedSegments = List<TranscriptionSegment>.from(
        activeState.transcriptionSegments,
      )..add(event.segment);

      emit(activeState.copyWith(transcriptionSegments: updatedSegments));
    }
  }

  void _onUpdateTranscriptionSegment(
    UpdateTranscriptionSegment event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;

      // Validate the segment
      try {
        event.segment.validate();
      } catch (e) {
        emit(MonitoringError('Invalid transcription segment: $e'));
        return;
      }

      final updatedSegments = activeState.transcriptionSegments.map((segment) {
        return segment.id == event.segment.id ? event.segment : segment;
      }).toList();

      emit(activeState.copyWith(transcriptionSegments: updatedSegments));
    }
  }

  void _onClearTranscription(
    ClearTranscription event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;
      emit(activeState.copyWith(transcriptionSegments: []));
    }
  }

  void _onToggleAutoScroll(
    ToggleAutoScroll event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;
      emit(activeState.copyWith(
          autoScrollEnabled: !activeState.autoScrollEnabled));
    }
  }

  void _onSetSpeakerLabel(
    SetSpeakerLabel event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;
      final updatedLabels = Map<String, String>.from(activeState.speakerLabels);
      updatedLabels[event.speakerId] = event.label;

      // Update all segments with this speaker ID to use the new label
      final updatedSegments = activeState.transcriptionSegments.map((segment) {
        if (segment.speakerId == event.speakerId) {
          return segment.copyWith(speakerLabel: event.label);
        }
        return segment;
      }).toList();

      emit(activeState.copyWith(
        speakerLabels: updatedLabels,
        transcriptionSegments: updatedSegments,
      ));
    }
  }

  void _onUpdateConfidenceThreshold(
    UpdateConfidenceThreshold event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;

      // Validate threshold
      if (event.threshold < 0.0 || event.threshold > 1.0) {
        emit(const MonitoringError(
            'Confidence threshold must be between 0.0 and 1.0'));
        return;
      }

      emit(activeState.copyWith(confidenceThreshold: event.threshold));
    }
  }

  void _onAddFactCheckResult(
    AddFactCheckResult event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;

      // Validate the result
      try {
        event.result.validate();
      } catch (e) {
        emit(MonitoringError('Invalid fact-check result: $e'));
        return;
      }

      final updatedResults = List<FactCheckResult>.from(
        activeState.factCheckResults,
      )..add(event.result);

      emit(activeState.copyWith(factCheckResults: updatedResults));
    }
  }

  void _onAddLegalAlert(
    AddLegalAlert event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;

      // Validate the alert
      try {
        event.alert.validate();
      } catch (e) {
        emit(MonitoringError('Invalid legal alert: $e'));
        return;
      }

      final updatedAlerts = List<LegalAlert>.from(
        activeState.legalAlerts,
      )..add(event.alert);

      emit(activeState.copyWith(legalAlerts: updatedAlerts));
    }
  }

  void _onClearFactCheckResults(
    ClearFactCheckResults event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;
      emit(activeState.copyWith(factCheckResults: []));
    }
  }

  void _onClearLegalAlerts(
    ClearLegalAlerts event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;
      emit(activeState.copyWith(legalAlerts: []));
    }
  }

  /// Add a mock transcription segment for testing
  void addMockSegment(String text, {String? speakerId, String? speakerLabel}) {
    final segment = TranscriptionSegment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      timestamp: DateTime.now(),
      confidence: 0.85,
      speakerId: speakerId,
      speakerLabel: speakerLabel,
      startTime: Duration(seconds: DateTime.now().second),
      endTime: Duration(seconds: DateTime.now().second + 3),
    );

    add(AddTranscriptionSegment(segment));
  }

  /// Add a mock fact-check result for testing
  void addMockFactCheck(
      String claim, String segmentId, FactCheckStatus status) {
    final result = FactCheckResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      claim: claim,
      segmentId: segmentId,
      status: status,
      confidence: 0.8,
      explanation: 'Mock fact-check explanation for testing',
      sources: ['Mock Source 1', 'Mock Source 2'],
      timestamp: DateTime.now(),
      jurisdiction: 'Test Jurisdiction',
    );

    add(AddFactCheckResult(result));
  }

  void _onFlagIncident(
    FlagIncident event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;

      final incidentEvent = SessionEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: EventType.incidentFlagged,
        description: 'Incident flagged: ${event.description}',
        importance: EventImportance.high,
        data: {'description': event.description},
        relatedSegmentId: event.segmentId,
      );

      final updatedEvents = [...activeState.sessionEvents, incidentEvent];
      emit(activeState.copyWith(sessionEvents: updatedEvents));
    }
  }

  void _onRequestLegalHelp(
    RequestLegalHelp event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;

      final helpEvent = SessionEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: EventType.legalHelpRequested,
        description: 'Legal help requested: ${event.reason}',
        importance: EventImportance.high,
        data: {
          'reason': event.reason,
          'contactInfo': event.contactInfo,
        },
      );

      final updatedEvents = [...activeState.sessionEvents, helpEvent];
      emit(activeState.copyWith(sessionEvents: updatedEvents));
    }
  }

  void _onContactEmergency(
    ContactEmergency event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;

      final emergencyEvent = SessionEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: EventType.emergencyActivated,
        description: 'Emergency contact activated: ${event.reason}',
        importance: EventImportance.critical,
        data: {
          'reason': event.reason,
          'location': event.location,
        },
      );

      final updatedEvents = [...activeState.sessionEvents, emergencyEvent];
      emit(activeState.copyWith(sessionEvents: updatedEvents));
    }
  }

  void _onGenerateReport(
    GenerateReport event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;

      final reportEvent = SessionEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        type: EventType.other,
        description: 'Session report generated',
        importance: EventImportance.medium,
        data: {
          'reportType': 'session_summary',
          'segmentCount': activeState.transcriptionSegments.length,
          'alertCount': activeState.legalAlerts.length,
        },
      );

      final updatedEvents = [...activeState.sessionEvents, reportEvent];
      emit(activeState.copyWith(sessionEvents: updatedEvents));
    }
  }

  void _onAddSessionEvent(
    AddSessionEvent event,
    Emitter<MonitoringState> emit,
  ) {
    if (state is MonitoringActive) {
      final activeState = state as MonitoringActive;

      // Validate the event
      try {
        event.event.validate();
      } catch (e) {
        emit(MonitoringError('Invalid session event: $e'));
        return;
      }

      final updatedEvents = [...activeState.sessionEvents, event.event];
      emit(activeState.copyWith(sessionEvents: updatedEvents));
    }
  }

  /// Add a mock legal alert for testing
  void addMockLegalAlert(
      String segmentId, LegalAlertType type, LegalAlertSeverity severity) {
    final alert = LegalAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      segmentId: segmentId,
      type: type,
      title: 'Mock Legal Alert',
      description: 'This is a mock legal alert for testing purposes',
      suggestedResponse: 'Suggested response for this alert',
      severity: severity,
      relevantLaws: ['Mock Law 1', 'Mock Law 2'],
      jurisdiction: 'Test Jurisdiction',
      timestamp: DateTime.now(),
    );

    add(AddLegalAlert(alert));
  }

  void _onFactCheckRequested(
    FactCheckRequested event,
    Emitter<MonitoringState> emit,
  ) {
    // Mock implementation for fact check
    if (state is MonitoringActive) {
      addMockFactCheck('Mock claim detected in transcription', 'segment_1',
          FactCheckStatus.verified);
    }
  }
}
