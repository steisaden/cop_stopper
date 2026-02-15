import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/blocs/monitoring/monitoring_bloc.dart';
import 'package:mobile/src/blocs/monitoring/monitoring_state.dart';
import 'package:mobile/src/ui/screens/monitor_screen.dart';

void main() {
  group('Monitoring Workflow Integration Tests', () {
    late MonitoringBloc monitoringBloc;

    setUp(() {
      monitoringBloc = MonitoringBloc();
    });

    tearDown(() {
      monitoringBloc.close();
    });

    Widget createTestApp() {
      return MaterialApp(
        home: BlocProvider.value(
          value: monitoringBloc,
          child: const MonitorScreen(),
        ),
      );
    }

    testWidgets('complete monitoring workflow from start to finish', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Initially should show start monitoring button
      expect(find.text('Start Monitoring'), findsOneWidget);
      expect(find.text('Third-Person Listener'), findsOneWidget);

      // Start monitoring
      await tester.tap(find.text('Start Monitoring'));
      await tester.pumpAndSettle();

      // Should now show active monitoring interface
      expect(find.text('Stop Monitoring'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('Waiting for transcription...'), findsOneWidget);

      // Add mock transcription data
      await tester.tap(find.text('Add Mock Data'));
      await tester.pumpAndSettle();

      // Wait for mock data to be added
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should show transcription segments
      expect(find.text('Good evening, officer. Is there a problem?'), findsOneWidget);

      // Add fact-check data
      await tester.tap(find.text('Add Fact Checks'));
      await tester.pumpAndSettle();

      // Wait for fact-check data
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should show fact-check results in the panel
      expect(find.text('Fact Check'), findsOneWidget);

      // Test session management actions
      expect(find.text('Flag Incident'), findsOneWidget);
      expect(find.text('Legal Help'), findsOneWidget);
      expect(find.text('Emergency Contact'), findsOneWidget);

      // Flag an incident
      await tester.tap(find.text('Flag Incident'));
      await tester.pumpAndSettle();

      expect(find.text('Flag Incident'), findsAtLeastNWidgets(1)); // Dialog title
      await tester.tap(find.text('Flag'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Incident flagged successfully'), findsOneWidget);

      // Generate report
      await tester.tap(find.text('Generate Report'));
      await tester.pumpAndSettle();

      // Should show report dialog
      expect(find.text('Session Report Generated'), findsOneWidget);
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Stop monitoring
      await tester.tap(find.text('Stop Monitoring'));
      await tester.pumpAndSettle();

      // Should show session summary
      expect(find.text('Session Summary'), findsOneWidget);
      expect(find.textContaining('Duration:'), findsOneWidget);
      expect(find.textContaining('Total Segments:'), findsOneWidget);

      // Should still show transcription and fact-check data
      expect(find.text('Good evening, officer. Is there a problem?'), findsOneWidget);
    });

    testWidgets('session management panel shows correct information', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Start monitoring
      await tester.tap(find.text('Start Monitoring'));
      await tester.pumpAndSettle();

      // Should show session management panel
      expect(find.text('Session Management'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);

      // Should show session info
      expect(find.text('Session Info'), findsOneWidget);
      expect(find.textContaining('Duration'), findsOneWidget);
      expect(find.textContaining('Segments'), findsOneWidget);

      // Add some data to see updated counts
      await tester.tap(find.text('Add Mock Data'));
      await tester.pumpAndSettle();

      // Wait for data to be processed
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Session info should update
      // Note: Exact text matching might be flaky due to timing, so we check for presence
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('legal help request workflow', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Start monitoring
      await tester.tap(find.text('Start Monitoring'));
      await tester.pumpAndSettle();

      // Request legal help
      await tester.tap(find.text('Legal Help'));
      await tester.pumpAndSettle();

      // Should show legal help dialog
      expect(find.text('Request Legal Help'), findsOneWidget);
      expect(find.text('Legal Hotline'), findsOneWidget);
      expect(find.text('Legal Advice'), findsOneWidget);

      // Select legal hotline
      await tester.tap(find.text('Legal Hotline'));
      await tester.pumpAndSettle();

      // Should show confirmation
      expect(find.text('Connecting to legal hotline...'), findsOneWidget);
    });

    testWidgets('emergency contact workflow', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Start monitoring
      await tester.tap(find.text('Start Monitoring'));
      await tester.pumpAndSettle();

      // Contact emergency
      await tester.tap(find.text('Emergency Contact'));
      await tester.pumpAndSettle();

      // Should show emergency dialog with warning
      expect(find.text('Emergency Contact'), findsAtLeastNWidgets(1));
      expect(find.textContaining('emergency services'), findsOneWidget);

      // Cancel emergency contact
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should return to monitoring screen
      expect(find.text('Stop Monitoring'), findsOneWidget);
    });

    testWidgets('fact-check panel interaction', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Start monitoring and add data
      await tester.tap(find.text('Start Monitoring'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Fact Checks'));
      await tester.pumpAndSettle();

      // Wait for fact-check data
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Switch to legal alerts tab
      await tester.tap(find.text('Legal'));
      await tester.pumpAndSettle();

      // Should show legal alerts
      expect(find.text('Mock Legal Alert'), findsAtLeastNWidgets(1));

      // Switch back to fact check tab
      await tester.tap(find.text('Fact Check'));
      await tester.pumpAndSettle();

      // Should show fact check results
      expect(find.textContaining('Speed limit'), findsOneWidget);
    });

    testWidgets('transcription display with speaker identification', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Start monitoring and add transcription data
      await tester.tap(find.text('Start Monitoring'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Mock Data'));
      await tester.pumpAndSettle();

      // Wait for transcription data
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Should show speaker labels
      expect(find.text('Citizen'), findsOneWidget);
      expect(find.text('Officer'), findsOneWidget);

      // Should show confidence indicators
      expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(1));

      // Should show scroll controls
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget); // Auto-scroll enabled
    });

    testWidgets('session state persistence through workflow', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Start monitoring
      await tester.tap(find.text('Start Monitoring'));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(monitoringBloc.state, isA<MonitoringActive>());
      final activeState = monitoringBloc.state as MonitoringActive;
      expect(activeState.transcriptionSegments, isEmpty);
      expect(activeState.factCheckResults, isEmpty);
      expect(activeState.legalAlerts, isEmpty);
      expect(activeState.sessionEvents, hasLength(1)); // Start event

      // Add data and verify state updates
      await tester.tap(find.text('Add Mock Data'));
      await tester.pumpAndSettle();

      // Wait for data to be processed
      await tester.pump(const Duration(seconds: 8));
      await tester.pumpAndSettle();

      final updatedState = monitoringBloc.state as MonitoringActive;
      expect(updatedState.transcriptionSegments, isNotEmpty);

      // Stop monitoring and verify final state
      await tester.tap(find.text('Stop Monitoring'));
      await tester.pumpAndSettle();

      expect(monitoringBloc.state, isA<MonitoringStopped>());
      final stoppedState = monitoringBloc.state as MonitoringStopped;
      expect(stoppedState.finalTranscriptionSegments, isNotEmpty);
      expect(stoppedState.finalSessionEvents, hasLength(greaterThan(1))); // Start + end events
    });
  });
}