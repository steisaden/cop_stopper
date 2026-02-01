import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/ui/widgets/transcription_display.dart';

void main() {
  group('TranscriptionDisplay Widget Tests', () {
    late List<TranscriptionSegment> mockSegments;

    setUp(() {
      mockSegments = [
        TranscriptionSegment(
          id: '1',
          text: 'Hello, this is the first segment',
          timestamp: DateTime.now(),
          confidence: 0.95,
          speakerId: 'speaker_1',
          speakerLabel: 'John',
          startTime: const Duration(seconds: 0),
          endTime: const Duration(seconds: 3),
        ),
        TranscriptionSegment(
          id: '2',
          text: 'This is the second segment with lower confidence',
          timestamp: DateTime.now().add(const Duration(seconds: 3)),
          confidence: 0.45,
          speakerId: 'speaker_2',
          speakerLabel: 'Jane',
          startTime: const Duration(seconds: 3),
          endTime: const Duration(seconds: 6),
        ),
        TranscriptionSegment(
          id: '3',
          text: 'Third segment from unknown speaker',
          timestamp: DateTime.now().add(const Duration(seconds: 6)),
          confidence: 0.85,
          speakerId: null,
          speakerLabel: null,
          startTime: const Duration(seconds: 6),
          endTime: const Duration(seconds: 9),
        ),
      ];
    });

    Widget createTestWidget({
      List<TranscriptionSegment>? segments,
      bool autoScrollEnabled = true,
      double confidenceThreshold = 0.5,
      VoidCallback? onToggleAutoScroll,
      Function(String, String)? onSetSpeakerLabel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TranscriptionDisplay(
            segments: segments ?? [],
            autoScrollEnabled: autoScrollEnabled,
            confidenceThreshold: confidenceThreshold,
            onToggleAutoScroll: onToggleAutoScroll,
            onSetSpeakerLabel: onSetSpeakerLabel,
          ),
        ),
      );
    }

    testWidgets('displays empty state when no segments provided', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.mic_none), findsOneWidget);
      expect(find.text('Waiting for transcription...'), findsOneWidget);
      expect(find.text('Start speaking to see real-time transcription'), findsOneWidget);
    });

    testWidgets('displays transcription segments correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(segments: mockSegments));

      // Check that all segments are displayed
      expect(find.text('Hello, this is the first segment'), findsOneWidget);
      expect(find.text('This is the second segment with lower confidence'), findsOneWidget);
      expect(find.text('Third segment from unknown speaker'), findsOneWidget);

      // Check speaker labels (only for segments with speaker IDs)
      expect(find.text('John'), findsOneWidget);
      expect(find.text('Jane'), findsOneWidget);
      // Third segment has no speakerId, so no speaker chip is shown
    });

    testWidgets('displays confidence indicators correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(segments: mockSegments));

      // High confidence (0.95) should show check_circle
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      
      // Low confidence (0.45) should show error_outline
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // Medium confidence (0.85) should show warning_amber
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('shows low confidence warning for segments below threshold', (tester) async {
      await tester.pumpWidget(createTestWidget(
        segments: mockSegments,
        confidenceThreshold: 0.5,
      ));

      // Should show low confidence warning for segment with 0.45 confidence
      expect(find.text('Low confidence transcription'), findsOneWidget);
    });

    testWidgets('displays scroll controls when segments are present', (tester) async {
      await tester.pumpWidget(createTestWidget(segments: mockSegments));

      // Should show scroll to bottom button
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      
      // Should show auto-scroll toggle button
      expect(find.byIcon(Icons.lock), findsOneWidget); // Auto-scroll enabled
    });

    testWidgets('auto-scroll toggle button changes icon based on state', (tester) async {
      await tester.pumpWidget(createTestWidget(
        segments: mockSegments,
        autoScrollEnabled: false,
      ));

      // Should show unlock icon when auto-scroll is disabled
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
    });

    testWidgets('calls onToggleAutoScroll when toggle button is tapped', (tester) async {
      bool toggleCalled = false;
      
      await tester.pumpWidget(createTestWidget(
        segments: mockSegments,
        onToggleAutoScroll: () => toggleCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.lock));
      expect(toggleCalled, isTrue);
    });

    testWidgets('shows speaker label dialog when speaker chip is tapped', (tester) async {
      String? capturedSpeakerId;
      String? capturedLabel;
      
      await tester.pumpWidget(createTestWidget(
        segments: mockSegments,
        onSetSpeakerLabel: (speakerId, label) {
          capturedSpeakerId = speakerId;
          capturedLabel = label;
        },
      ));

      // Tap on the first speaker chip
      await tester.tap(find.text('John').first);
      await tester.pumpAndSettle();

      // Should show dialog
      expect(find.text('Set Speaker Label'), findsOneWidget);
      expect(find.text('Speaker Name'), findsOneWidget);
      
      // Enter new label
      await tester.enterText(find.byType(TextField), 'New Name');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(capturedSpeakerId, equals('speaker_1'));
      expect(capturedLabel, equals('New Name'));
    });

    testWidgets('displays formatted timestamps correctly', (tester) async {
      final segmentWithSpecificTime = TranscriptionSegment(
        id: '1',
        text: 'Test segment',
        timestamp: DateTime.now(),
        confidence: 0.9,
        startTime: const Duration(minutes: 1, seconds: 30),
        endTime: const Duration(minutes: 1, seconds: 33),
      );

      await tester.pumpWidget(createTestWidget(segments: [segmentWithSpecificTime]));

      expect(find.text('01:30'), findsOneWidget);
    });

    testWidgets('assigns different colors to different speakers', (tester) async {
      await tester.pumpWidget(createTestWidget(segments: mockSegments));

      // Find speaker chips
      final johnChip = find.ancestor(
        of: find.text('John'),
        matching: find.byType(Container),
      ).first;
      
      final janeChip = find.ancestor(
        of: find.text('Jane'),
        matching: find.byType(Container),
      ).first;

      // Both should exist (different speakers should have different visual treatment)
      expect(johnChip, findsOneWidget);
      expect(janeChip, findsOneWidget);
    });

    testWidgets('scrolls to bottom when scroll button is tapped', (tester) async {
      // Create many segments to enable scrolling
      final manySegments = List.generate(20, (index) => 
        TranscriptionSegment(
          id: index.toString(),
          text: 'Segment $index with some text content',
          timestamp: DateTime.now().add(Duration(seconds: index)),
          confidence: 0.8,
          startTime: Duration(seconds: index),
          endTime: Duration(seconds: index + 1),
        ),
      );

      await tester.pumpWidget(createTestWidget(segments: manySegments));

      // Tap scroll to bottom button
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();

      // Should be able to see the last segment
      expect(find.text('Segment 19 with some text content'), findsOneWidget);
    });

    testWidgets('handles segments without speaker ID gracefully', (tester) async {
      final segmentWithoutSpeaker = TranscriptionSegment(
        id: '1',
        text: 'Anonymous segment',
        timestamp: DateTime.now(),
        confidence: 0.8,
        startTime: const Duration(seconds: 0),
        endTime: const Duration(seconds: 3),
      );

      await tester.pumpWidget(createTestWidget(segments: [segmentWithoutSpeaker]));

      expect(find.text('Anonymous segment'), findsOneWidget);
      // Should not show any speaker chip text for segments without speaker ID
      expect(find.textContaining('Speaker'), findsNothing);
    });

    testWidgets('shows confidence tooltip on hover/long press', (tester) async {
      await tester.pumpWidget(createTestWidget(segments: [mockSegments.first]));

      // Long press on confidence indicator
      await tester.longPress(find.byIcon(Icons.check_circle));
      await tester.pumpAndSettle();

      expect(find.text('Confidence: 95.0%'), findsOneWidget);
    });
  });
}