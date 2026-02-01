import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/blocs/monitoring/monitoring_bloc.dart';
import 'package:mobile/src/blocs/monitoring/monitoring_event.dart';
import 'package:mobile/src/blocs/monitoring/monitoring_state.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/models/fact_check_result_model.dart';

void main() {
  group('MonitoringBloc', () {
    late MonitoringBloc monitoringBloc;
    late TranscriptionSegment mockSegment;

    setUp(() {
      monitoringBloc = MonitoringBloc();
      mockSegment = TranscriptionSegment(
        id: '1',
        text: 'Test transcription segment',
        timestamp: DateTime.now(),
        confidence: 0.85,
        speakerId: 'speaker_1',
        speakerLabel: 'Test Speaker',
        startTime: const Duration(seconds: 0),
        endTime: const Duration(seconds: 3),
      );
    });

    tearDown(() {
      monitoringBloc.close();
    });

    test('initial state is MonitoringInitial', () {
      expect(monitoringBloc.state, equals(const MonitoringInitial()));
    });

    group('StartMonitoring', () {
      blocTest<MonitoringBloc, MonitoringState>(
        'emits MonitoringActive when StartMonitoring is added',
        build: () => monitoringBloc,
        act: (bloc) => bloc.add(const StartMonitoring()),
        expect: () => [
          isA<MonitoringActive>()
              .having((state) => state.transcriptionSegments, 'segments', isEmpty)
              .having((state) => state.speakerLabels, 'labels', isEmpty)
              .having((state) => state.autoScrollEnabled, 'autoScroll', isTrue)
              .having((state) => state.confidenceThreshold, 'threshold', equals(0.5))
              .having((state) => state.factCheckResults, 'factChecks', isEmpty)
              .having((state) => state.legalAlerts, 'alerts', isEmpty),
        ],
      );
    });

    group('StopMonitoring', () {
      blocTest<MonitoringBloc, MonitoringState>(
        'emits MonitoringStopped when StopMonitoring is added during active session',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: [mockSegment],
          speakerLabels: const {'speaker_1': 'Test Speaker'},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now().subtract(const Duration(minutes: 5)),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) => bloc.add(const StopMonitoring()),
        expect: () => [
          isA<MonitoringStopped>()
              .having((state) => state.finalTranscriptionSegments, 'segments', hasLength(1))
              .having((state) => state.speakerLabels, 'labels', hasLength(1))
              .having((state) => state.finalFactCheckResults, 'factChecks', isEmpty)
              .having((state) => state.finalLegalAlerts, 'alerts', isEmpty),
        ],
      );

      blocTest<MonitoringBloc, MonitoringState>(
        'does not emit when StopMonitoring is added in initial state',
        build: () => monitoringBloc,
        act: (bloc) => bloc.add(const StopMonitoring()),
        expect: () => [],
      );
    });

    group('AddTranscriptionSegment', () {
      blocTest<MonitoringBloc, MonitoringState>(
        'adds segment to active monitoring session',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: const [],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) => bloc.add(AddTranscriptionSegment(mockSegment)),
        expect: () => [
          isA<MonitoringActive>()
              .having((state) => state.transcriptionSegments, 'segments', hasLength(1))
              .having((state) => state.transcriptionSegments.first.text, 'text', 
                      equals('Test transcription segment')),
        ],
      );

      blocTest<MonitoringBloc, MonitoringState>(
        'emits error when adding invalid segment',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: const [],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) {
          final invalidSegment = TranscriptionSegment(
            id: '1',
            text: '', // Invalid empty text
            timestamp: DateTime.now(),
            confidence: 0.85,
            startTime: const Duration(seconds: 0),
            endTime: const Duration(seconds: 3),
          );
          bloc.add(AddTranscriptionSegment(invalidSegment));
        },
        expect: () => [
          isA<MonitoringError>()
              .having((state) => state.message, 'message', 
                      contains('Invalid transcription segment')),
        ],
      );
    });

    group('AddFactCheckResult', () {
      blocTest<MonitoringBloc, MonitoringState>(
        'adds fact-check result to active monitoring session',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: const [],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) {
          final factCheck = FactCheckResult(
            id: '1',
            claim: 'Test claim',
            segmentId: 'segment_1',
            status: FactCheckStatus.verified,
            confidence: 0.9,
            sources: ['Test Source'],
            timestamp: DateTime.now(),
          );
          bloc.add(AddFactCheckResult(factCheck));
        },
        expect: () => [
          isA<MonitoringActive>()
              .having((state) => state.factCheckResults, 'factChecks', hasLength(1))
              .having((state) => state.factCheckResults.first.claim, 'claim', 
                      equals('Test claim')),
        ],
      );
    });

    group('AddLegalAlert', () {
      blocTest<MonitoringBloc, MonitoringState>(
        'adds legal alert to active monitoring session',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: const [],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) {
          final alert = LegalAlert(
            id: '1',
            segmentId: 'segment_1',
            type: LegalAlertType.rightsViolation,
            title: 'Test Alert',
            description: 'Test description',
            suggestedResponse: 'Test response',
            severity: LegalAlertSeverity.high,
            relevantLaws: ['Test Law'],
            timestamp: DateTime.now(),
          );
          bloc.add(AddLegalAlert(alert));
        },
        expect: () => [
          isA<MonitoringActive>()
              .having((state) => state.legalAlerts, 'alerts', hasLength(1))
              .having((state) => state.legalAlerts.first.title, 'title', 
                      equals('Test Alert')),
        ],
      );
    });

    // Continue with other existing tests, updated with new fields...
    group('UpdateTranscriptionSegment', () {
      blocTest<MonitoringBloc, MonitoringState>(
        'updates existing segment in active monitoring session',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: [mockSegment],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) {
          final updatedSegment = mockSegment.copyWith(
            text: 'Updated transcription text',
            confidence: 0.95,
          );
          bloc.add(UpdateTranscriptionSegment(updatedSegment));
        },
        expect: () => [
          isA<MonitoringActive>()
              .having((state) => state.transcriptionSegments.first.text, 'text',
                      equals('Updated transcription text'))
              .having((state) => state.transcriptionSegments.first.confidence, 'confidence',
                      equals(0.95)),
        ],
      );
    });

    group('ClearTranscription', () {
      blocTest<MonitoringBloc, MonitoringState>(
        'clears all transcription segments',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: [mockSegment],
          speakerLabels: const {'speaker_1': 'Test Speaker'},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) => bloc.add(const ClearTranscription()),
        expect: () => [
          isA<MonitoringActive>()
              .having((state) => state.transcriptionSegments, 'segments', isEmpty),
        ],
      );
    });

    group('ToggleAutoScroll', () {
      blocTest<MonitoringBloc, MonitoringState>(
        'toggles auto-scroll setting',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: const [],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) => bloc.add(const ToggleAutoScroll()),
        expect: () => [
          isA<MonitoringActive>()
              .having((state) => state.autoScrollEnabled, 'autoScroll', isFalse),
        ],
      );
    });

    group('SetSpeakerLabel', () {
      blocTest<MonitoringBloc, MonitoringState>(
        'sets speaker label and updates segments',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: [mockSegment],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) => bloc.add(const SetSpeakerLabel('speaker_1', 'New Label')),
        expect: () => [
          isA<MonitoringActive>()
              .having((state) => state.speakerLabels['speaker_1'], 'label', 
                      equals('New Label'))
              .having((state) => state.transcriptionSegments.first.speakerLabel, 
                      'segmentLabel', equals('New Label')),
        ],
      );
    });

    group('UpdateConfidenceThreshold', () {
      blocTest<MonitoringBloc, MonitoringState>(
        'updates confidence threshold',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: const [],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) => bloc.add(const UpdateConfidenceThreshold(0.8)),
        expect: () => [
          isA<MonitoringActive>()
              .having((state) => state.confidenceThreshold, 'threshold', equals(0.8)),
        ],
      );

      blocTest<MonitoringBloc, MonitoringState>(
        'emits error for invalid confidence threshold',
        build: () => monitoringBloc,
        seed: () => MonitoringActive(
          transcriptionSegments: const [],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        ),
        act: (bloc) => bloc.add(const UpdateConfidenceThreshold(1.5)), // Invalid > 1.0
        expect: () => [
          isA<MonitoringError>()
              .having((state) => state.message, 'message',
                      contains('Confidence threshold must be between 0.0 and 1.0')),
        ],
      );
    });

    group('MonitoringActive state methods', () {
      test('filteredSegments returns segments above confidence threshold', () {
        final lowConfidenceSegment = TranscriptionSegment(
          id: '2',
          text: 'Low confidence segment',
          timestamp: DateTime.now(),
          confidence: 0.3,
          startTime: const Duration(seconds: 3),
          endTime: const Duration(seconds: 6),
        );

        final state = MonitoringActive(
          transcriptionSegments: [mockSegment, lowConfidenceSegment],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        );

        expect(state.filteredSegments, hasLength(1));
        expect(state.filteredSegments.first.confidence, equals(0.85));
      });

      test('uniqueSpeakers returns set of unique speaker IDs', () {
        final anotherSegment = TranscriptionSegment(
          id: '2',
          text: 'Another segment',
          timestamp: DateTime.now(),
          confidence: 0.8,
          speakerId: 'speaker_2',
          startTime: const Duration(seconds: 3),
          endTime: const Duration(seconds: 6),
        );

        final state = MonitoringActive(
          transcriptionSegments: [mockSegment, anotherSegment, mockSegment],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        );

        expect(state.uniqueSpeakers, hasLength(2));
        expect(state.uniqueSpeakers, contains('speaker_1'));
        expect(state.uniqueSpeakers, contains('speaker_2'));
      });

      test('lowConfidenceSegments returns segments below threshold', () {
        final lowConfidenceSegment = TranscriptionSegment(
          id: '2',
          text: 'Low confidence segment',
          timestamp: DateTime.now(),
          confidence: 0.3,
          startTime: const Duration(seconds: 3),
          endTime: const Duration(seconds: 6),
        );

        final state = MonitoringActive(
          transcriptionSegments: [mockSegment, lowConfidenceSegment],
          speakerLabels: const {},
          autoScrollEnabled: true,
          confidenceThreshold: 0.5,
          sessionStartTime: DateTime.now(),
          factCheckResults: const [],
          legalAlerts: const [],
        );

        expect(state.lowConfidenceSegments, hasLength(1));
        expect(state.lowConfidenceSegments.first.confidence, equals(0.3));
      });
    });

    group('MonitoringStopped state methods', () {
      test('sessionSummary returns correct statistics', () {
        final segments = [
          mockSegment,
          TranscriptionSegment(
            id: '2',
            text: 'Second segment with multiple words here',
            timestamp: DateTime.now(),
            confidence: 0.7,
            speakerId: 'speaker_2',
            startTime: const Duration(seconds: 3),
            endTime: const Duration(seconds: 6),
          ),
        ];

        final startTime = DateTime.now().subtract(const Duration(minutes: 5));
        final endTime = DateTime.now();

        final state = MonitoringStopped(
          finalTranscriptionSegments: segments,
          speakerLabels: const {'speaker_1': 'Speaker 1', 'speaker_2': 'Speaker 2'},
          sessionStartTime: startTime,
          sessionEndTime: endTime,
          finalFactCheckResults: const [],
          finalLegalAlerts: const [],
        );

        final summary = state.sessionSummary;
        expect(summary['totalSegments'], equals(2));
        expect(summary['uniqueSpeakers'], equals(2));
        expect(summary['averageConfidence'], closeTo(0.775, 0.001)); // (0.85 + 0.7) / 2
        expect(summary['totalWords'], equals(9)); // 4 + 5 words
        expect(summary['factCheckResults'], equals(0));
        expect(summary['legalAlerts'], equals(0));
        expect(summary['criticalAlerts'], equals(0));
      });
    });
  });
}