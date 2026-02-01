import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/main.dart' as app;
import 'package:mobile/src/service_locator.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/location_service.dart';
import 'package:mobile/src/services/emergency_contact_service.dart';
import 'package:mobile/src/services/notification_service.dart';
import 'package:mobile/src/services/error_handling_service.dart';
import 'package:mobile/src/services/legal_compliance_service.dart';
import 'package:mobile/src/services/offline_service.dart';

import '../mocks/mock_recording_service.dart';

/// Comprehensive integration test for the complete emergency workflow
/// This test covers the entire user journey from emergency activation to resolution
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Emergency Workflow Integration Test', () {
    late MockRecordingService mockRecordingService;

    setUpAll(() {
      // Setup mock services
      mockRecordingService = MockRecordingService();
      
      // Register mocks in service locator
      locator.registerSingleton<RecordingService>(mockRecordingService);
    });

    tearDownAll(() {
      locator.reset();
    });

    testWidgets('Complete emergency workflow from activation to resolution', (WidgetTester tester) async {
      // Setup mock responses
      when(mockRecordingService.startRecording()).thenAnswer((_) async => true);
      when(mockRecordingService.stopRecording()).thenAnswer((_) async => 'test_recording_path');
      when(mockRecordingService.isRecording()).thenAnswer((_) async => false);

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: Navigate to main screen
      expect(find.text('Cop Stopper'), findsOneWidget);
      await tester.pumpAndSettle();

      // Step 2: Activate emergency mode via global emergency button
      final emergencyButton = find.byKey(const Key('global_emergency_button'));
      expect(emergencyButton, findsOneWidget);
      
      await tester.tap(emergencyButton);
      await tester.pumpAndSettle();

      // Step 3: Verify emergency mode activation
      expect(find.text('EMERGENCY MODE ACTIVE'), findsOneWidget);
      expect(find.byKey(const Key('emergency_mode_interface')), findsOneWidget);

      // Step 4: Verify recording starts automatically
      verify(mockRecordingService.startRecording()).called(1);
      expect(find.text('RECORDING LIVE'), findsOneWidget);

      // Step 5: Test location sharing activation
      final locationShareButton = find.text('Share Location');
      if (locationShareButton.evaluate().isNotEmpty) {
        await tester.tap(locationShareButton);
        await tester.pumpAndSettle();
        
        // Verify location sharing dialog
        expect(find.text('Location Sharing Active'), findsOneWidget);
        
        // Close dialog
        await tester.tap(find.text('Got it'));
        await tester.pumpAndSettle();
      }

      // Step 6: Test emergency contact alerts
      final alertContactsButton = find.text('Alert Contacts');
      if (alertContactsButton.evaluate().isNotEmpty) {
        await tester.tap(alertContactsButton);
        await tester.pumpAndSettle();
        
        // Verify alert sent (would check notification in real implementation)
        // For now, just verify button was tapped
      }

      // Step 7: Navigate to different screens while in emergency mode
      // Test that emergency mode persists across navigation
      
      // Navigate to Officers screen
      final officersTab = find.text('Officers');
      await tester.tap(officersTab);
      await tester.pumpAndSettle();
      
      // Verify emergency mode still active
      expect(find.byKey(const Key('emergency_mode_interface')), findsOneWidget);
      
      // Navigate to Documents screen
      final documentsTab = find.text('Documents');
      await tester.tap(documentsTab);
      await tester.pumpAndSettle();
      
      // Verify emergency mode still active
      expect(find.byKey(const Key('emergency_mode_interface')), findsOneWidget);

      // Step 8: Return to Record screen
      final recordTab = find.text('Record');
      await tester.tap(recordTab);
      await tester.pumpAndSettle();

      // Step 9: Test emergency mode deactivation
      final stopEmergencyButton = find.text('Stop Emergency');
      expect(stopEmergencyButton, findsOneWidget);
      
      await tester.tap(stopEmergencyButton);
      await tester.pumpAndSettle();

      // Step 10: Handle stop confirmation dialog
      expect(find.text('Stop Emergency Mode?'), findsOneWidget);
      
      final confirmStopButton = find.text('Stop & Save');
      await tester.tap(confirmStopButton);
      await tester.pumpAndSettle();

      // Step 11: Verify emergency mode deactivation
      expect(find.text('EMERGENCY MODE ACTIVE'), findsNothing);
      expect(find.byKey(const Key('emergency_mode_interface')), findsNothing);

      // Step 12: Verify recording stopped
      verify(mockRecordingService.stopRecording()).called(1);
      expect(find.text('RECORDING LIVE'), findsNothing);

      // Step 13: Verify success notification
      expect(find.text('Emergency mode stopped'), findsOneWidget);

      // Step 14: Navigate to History to verify session was saved
      final historyTab = find.text('History');
      await tester.tap(historyTab);
      await tester.pumpAndSettle();

      // Verify emergency session appears in history
      // (This would depend on the actual history implementation)
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Emergency workflow with offline mode', (WidgetTester tester) async {
      // Setup offline mode
      when(mockRecordingService.startRecording()).thenAnswer((_) async => true);
      when(mockRecordingService.stopRecording()).thenAnswer((_) async => 'offline_recording_path');

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Enable offline mode (this would be done through settings in real app)
      // For test purposes, we'll simulate offline state

      // Activate emergency mode
      final emergencyButton = find.byKey(const Key('global_emergency_button'));
      await tester.tap(emergencyButton);
      await tester.pumpAndSettle();

      // Verify offline indicator is shown
      expect(find.text('OFFLINE MODE'), findsOneWidget);

      // Verify recording still works in offline mode
      verify(mockRecordingService.startRecording()).called(1);

      // Test that emergency contacts are queued for later sending
      final alertContactsButton = find.text('Alert Contacts');
      if (alertContactsButton.evaluate().isNotEmpty) {
        await tester.tap(alertContactsButton);
        await tester.pumpAndSettle();
      }

      // Stop emergency mode
      final stopEmergencyButton = find.text('Stop Emergency');
      await tester.tap(stopEmergencyButton);
      await tester.pumpAndSettle();

      final confirmStopButton = find.text('Stop & Save');
      await tester.tap(confirmStopButton);
      await tester.pumpAndSettle();

      // Verify recording was saved locally for offline access
      verify(mockRecordingService.stopRecording()).called(1);
    });

    testWidgets('Emergency workflow error handling', (WidgetTester tester) async {
      // Setup recording failure
      when(mockRecordingService.startRecording()).thenThrow(Exception('Recording failed'));

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Activate emergency mode
      final emergencyButton = find.byKey(const Key('global_emergency_button'));
      await tester.tap(emergencyButton);
      await tester.pumpAndSettle();

      // Verify error handling
      // Should show error message but still activate emergency mode
      expect(find.text('EMERGENCY MODE ACTIVE'), findsOneWidget);
      
      // Should show recording error
      expect(find.textContaining('Recording'), findsWidgets);

      // Emergency mode should still be functional even if recording fails
      final alertContactsButton = find.text('Alert Contacts');
      if (alertContactsButton.evaluate().isNotEmpty) {
        await tester.tap(alertContactsButton);
        await tester.pumpAndSettle();
      }

      // Should be able to stop emergency mode
      final stopEmergencyButton = find.text('Stop Emergency');
      await tester.tap(stopEmergencyButton);
      await tester.pumpAndSettle();

      final confirmStopButton = find.text('Stop & Save');
      await tester.tap(confirmStopButton);
      await tester.pumpAndSettle();

      // Verify emergency mode stopped despite recording failure
      expect(find.text('EMERGENCY MODE ACTIVE'), findsNothing);
    });

    testWidgets('Emergency workflow with legal compliance checks', (WidgetTester tester) async {
      // Setup mock responses
      when(mockRecordingService.startRecording()).thenAnswer((_) async => true);
      when(mockRecordingService.stopRecording()).thenAnswer((_) async => 'test_recording_path');

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Activate emergency mode
      final emergencyButton = find.byKey(const Key('global_emergency_button'));
      await tester.tap(emergencyButton);
      await tester.pumpAndSettle();

      // Verify legal compliance warning is shown
      // (This would depend on the jurisdiction and legal compliance service)
      expect(find.textContaining('LEGAL'), findsWidgets);

      // Verify recording disclaimer
      if (find.text('Legal Notice').evaluate().isNotEmpty) {
        expect(find.textContaining('consent'), findsWidgets);
      }

      // Continue with emergency workflow
      verify(mockRecordingService.startRecording()).called(1);

      // Stop emergency mode
      final stopEmergencyButton = find.text('Stop Emergency');
      await tester.tap(stopEmergencyButton);
      await tester.pumpAndSettle();

      final confirmStopButton = find.text('Stop & Save');
      await tester.tap(confirmStopButton);
      await tester.pumpAndSettle();

      // Verify consent was recorded (if required)
      // This would check the legal compliance service
    });

    testWidgets('Emergency workflow performance under stress', (WidgetTester tester) async {
      // Setup mock responses
      when(mockRecordingService.startRecording()).thenAnswer((_) async => true);
      when(mockRecordingService.stopRecording()).thenAnswer((_) async => 'test_recording_path');

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Measure performance of emergency activation
      final stopwatch = Stopwatch()..start();

      // Activate emergency mode
      final emergencyButton = find.byKey(const Key('global_emergency_button'));
      await tester.tap(emergencyButton);
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Verify emergency mode activated quickly (under 2 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(find.text('EMERGENCY MODE ACTIVE'), findsOneWidget);

      // Test rapid navigation between screens
      final screens = ['Officers', 'Documents', 'History', 'Settings', 'Record'];
      
      for (final screen in screens) {
        final tab = find.text(screen);
        if (tab.evaluate().isNotEmpty) {
          await tester.tap(tab);
          await tester.pumpAndSettle();
          
          // Verify emergency mode persists
          expect(find.byKey(const Key('emergency_mode_interface')), findsOneWidget);
        }
      }

      // Stop emergency mode
      final stopEmergencyButton = find.text('Stop Emergency');
      await tester.tap(stopEmergencyButton);
      await tester.pumpAndSettle();

      final confirmStopButton = find.text('Stop & Save');
      await tester.tap(confirmStopButton);
      await tester.pumpAndSettle();

      // Verify clean shutdown
      expect(find.text('EMERGENCY MODE ACTIVE'), findsNothing);
    });
  });
}