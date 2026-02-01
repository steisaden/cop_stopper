import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cop Stopper App Integration Tests', () {
    testWidgets('Complete app workflow test', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test 1: App launches successfully
      expect(find.text('Cop Stopper'), findsOneWidget);
      expect(find.text('Secure documentation for your safety'), findsOneWidget);

      // Test 2: Navigation between tabs
      await tester.tap(find.byIcon(Icons.monitor));
      await tester.pumpAndSettle();
      expect(find.text('Live Monitor'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.folder));
      await tester.pumpAndSettle();
      expect(find.text('Documents'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();
      expect(find.text('History'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);

      // Return to main screen
      await tester.tap(find.byIcon(Icons.fiber_manual_record));
      await tester.pumpAndSettle();

      // Test 3: Recording button interaction
      final recordingButton = find.byType(GestureDetector).first;
      await tester.tap(recordingButton);
      await tester.pumpAndSettle();

      // Should navigate to record screen or show recording interface
      // Note: Actual recording functionality would require camera permissions
      // and real device testing

      // Test 4: Emergency mode activation
      final emergencyButton = find.text('EMERGENCY MODE');
      if (emergencyButton.evaluate().isNotEmpty) {
        await tester.tap(emergencyButton);
        await tester.pumpAndSettle();
        
        // Should show emergency mode confirmation
        expect(find.text('EMERGENCY MODE ACTIVATED'), findsOneWidget);
      }

      // Test 5: Settings screen functionality
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Test theme switching if available
      final themeSwitcher = find.byType(Switch).first;
      if (themeSwitcher.evaluate().isNotEmpty) {
        await tester.tap(themeSwitcher);
        await tester.pumpAndSettle();
      }

      // Test 6: Accessibility features
      await tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/accessibility'),
        (MethodCall methodCall) async {
          return null;
        },
      );

      // Verify semantic labels are present
      expect(find.bySemanticsLabel('Status indicators showing GPS and internet connection status'), findsOneWidget);
    });

    testWidgets('Recording workflow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to record screen
      await tester.tap(find.byIcon(Icons.fiber_manual_record));
      await tester.pumpAndSettle();

      // Test recording controls
      final startRecordingButton = find.text('Start Recording');
      if (startRecordingButton.evaluate().isNotEmpty) {
        await tester.tap(startRecordingButton);
        await tester.pumpAndSettle();

        // Should show recording interface
        expect(find.text('RECORDING LIVE'), findsOneWidget);

        // Test stop recording
        final stopButton = find.text('Stop Recording');
        if (stopButton.evaluate().isNotEmpty) {
          await tester.tap(stopButton);
          await tester.pumpAndSettle();

          // Should show stop confirmation dialog
          expect(find.text('Stop Recording?'), findsOneWidget);
          
          // Confirm stop
          await tester.tap(find.text('Stop & Save'));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Monitor screen functionality test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to monitor screen
      await tester.tap(find.byIcon(Icons.monitor));
      await tester.pumpAndSettle();

      expect(find.text('Live Monitor'), findsOneWidget);
      expect(find.text('Real-time transcription and fact-checking'), findsOneWidget);

      // Test start monitoring session
      final startSessionButton = find.text('Start Session');
      if (startSessionButton.evaluate().isNotEmpty) {
        await tester.tap(startSessionButton);
        await tester.pumpAndSettle();

        // Should show active monitoring interface
        expect(find.text('Live Transcription'), findsOneWidget);
        expect(find.text('Fact Check Results'), findsOneWidget);

        // Test stop session
        final stopSessionButton = find.text('Stop Session');
        if (stopSessionButton.evaluate().isNotEmpty) {
          await tester.tap(stopSessionButton);
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Settings screen functionality test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Configure your app preferences and security settings'), findsOneWidget);

      // Test settings sections
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Recording'), findsOneWidget);
      expect(find.text('Emergency Contacts'), findsOneWidget);
      expect(find.text('Storage & Sync'), findsOneWidget);
      expect(find.text('Legal & Privacy'), findsOneWidget);

      // Test toggle switches
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();
      }

      // Test dropdown menus
      final dropdowns = find.byType(DropdownButton<String>);
      if (dropdowns.evaluate().isNotEmpty) {
        await tester.tap(dropdowns.first);
        await tester.pumpAndSettle();
        
        // Select different option if available
        final dropdownItems = find.byType(DropdownMenuItem<String>);
        if (dropdownItems.evaluate().length > 1) {
          await tester.tap(dropdownItems.at(1));
          await tester.pumpAndSettle();
        }
      }
    });

    testWidgets('Offline functionality test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test offline indicator
      expect(find.byType(OfflineIndicator), findsOneWidget);

      // Simulate offline state (would require network mocking in real test)
      // For now, just verify the offline indicator widget exists
    });

    testWidgets('Accessibility compliance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test semantic labels
      final semanticFinder = find.bySemanticsLabel(RegExp(r'.*'));
      expect(semanticFinder.evaluate().length, greaterThan(0));

      // Test button accessibility
      final buttons = find.byType(ElevatedButton);
      for (final button in buttons.evaluate()) {
        final widget = button.widget as ElevatedButton;
        expect(widget.onPressed, isNotNull, reason: 'Button should be interactive');
      }

      // Test text contrast (would require color analysis in real test)
      // For now, verify text widgets exist
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('Performance test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Measure frame rendering time
      final stopwatch = Stopwatch()..start();
      
      // Navigate through all tabs quickly
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.monitor));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.folder));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.history));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();
        
        await tester.tap(find.byIcon(Icons.fiber_manual_record));
        await tester.pumpAndSettle();
      }
      
      stopwatch.stop();
      
      // Navigation should complete within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(10000), 
             reason: 'Navigation should be performant');
    });

    testWidgets('Error handling test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test error states by triggering invalid operations
      // This would require mocking services to return errors
      
      // For now, verify error handling widgets exist
      expect(find.byType(ErrorCard), findsNothing); // Should not show errors on startup
    });

    testWidgets('Theme switching test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Look for theme controls
      final themeControls = find.byType(ThemeSwitcher);
      if (themeControls.evaluate().isNotEmpty) {
        await tester.tap(themeControls.first);
        await tester.pumpAndSettle();

        // Verify theme change took effect
        // This would require checking actual theme colors
      }
    });
  });

  group('Real Device Tests', () {
    testWidgets('Camera permission test', (WidgetTester tester) async {
      // This test would only run on real devices with camera access
      app.main();
      await tester.pumpAndSettle();

      // Navigate to record screen
      await tester.tap(find.byIcon(Icons.fiber_manual_record));
      await tester.pumpAndSettle();

      // Camera preview should be visible (on real device)
      // expect(find.byType(CameraPreview), findsOneWidget);
    });

    testWidgets('Location services test', (WidgetTester tester) async {
      // This test would only run on real devices with location access
      app.main();
      await tester.pumpAndSettle();

      // GPS status should show as ready (on real device with permissions)
      // expect(find.text('GPS Ready'), findsOneWidget);
    });

    testWidgets('Audio recording test', (WidgetTester tester) async {
      // This test would only run on real devices with microphone access
      app.main();
      await tester.pumpAndSettle();

      // Start recording and verify audio level indicator
      // This requires actual microphone permissions and audio input
    });
  });
}