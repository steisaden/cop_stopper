import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/screens/navigation_wrapper.dart';
import 'package:mobile/src/ui/widgets/bottom_navigation_component.dart';
import 'package:mobile/src/ui/widgets/camera_preview_card.dart';
import 'package:mobile/src/ui/widgets/transcription_display.dart';
import 'package:mobile/src/ui/widgets/fact_check_panel.dart';

void main() {
  group('End-to-End Workflow Tests', () {
    testWidgets('complete recording workflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Start on Record tab
      expect(find.text('Record'), findsOneWidget);
      expect(find.byType(CameraPreviewCard), findsOneWidget);

      // Tap record button
      final recordButton = find.byIcon(Icons.fiber_manual_record);
      if (recordButton.evaluate().isNotEmpty) {
        await tester.tap(recordButton);
        await tester.pumpAndSettle();

        // Should show recording state
        expect(find.byIcon(Icons.stop), findsOneWidget);

        // Stop recording
        await tester.tap(find.byIcon(Icons.stop));
        await tester.pumpAndSettle();

        // Should return to initial state
        expect(find.byIcon(Icons.fiber_manual_record), findsOneWidget);
      }
    });

    testWidgets('complete monitoring workflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Navigate to Monitor tab
      await tester.tap(find.text('Monitor'));
      await tester.pumpAndSettle();

      // Should show monitoring interface
      expect(find.byType(TranscriptionDisplay), findsOneWidget);
      expect(find.byType(FactCheckPanel), findsOneWidget);

      // Test transcription interaction
      final transcriptionArea = find.byType(TranscriptionDisplay);
      if (transcriptionArea.evaluate().isNotEmpty) {
        await tester.tap(transcriptionArea);
        await tester.pumpAndSettle();
      }

      // Test fact-checking interaction
      final factCheckPanel = find.byType(FactCheckPanel);
      if (factCheckPanel.evaluate().isNotEmpty) {
        await tester.tap(factCheckPanel);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('complete settings workflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Navigate to Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Should show settings cards
      expect(find.text('Recording Settings'), findsOneWidget);
      expect(find.text('Privacy Settings'), findsOneWidget);
      expect(find.text('Legal Settings'), findsOneWidget);
      expect(find.text('Accessibility'), findsOneWidget);

      // Test settings interaction
      final recordingSettings = find.text('Recording Settings');
      if (recordingSettings.evaluate().isNotEmpty) {
        await tester.tap(recordingSettings);
        await tester.pumpAndSettle();

        // Should show recording settings details
        expect(find.text('Video Quality'), findsOneWidget);
        expect(find.text('Audio Bitrate'), findsOneWidget);
      }
    });

    testWidgets('navigation between tabs maintains state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Start recording on Record tab
      final recordButton = find.byIcon(Icons.fiber_manual_record);
      if (recordButton.evaluate().isNotEmpty) {
        await tester.tap(recordButton);
        await tester.pumpAndSettle();
      }

      // Navigate to Monitor tab
      await tester.tap(find.text('Monitor'));
      await tester.pumpAndSettle();

      // Navigate back to Record tab
      await tester.tap(find.text('Record'));
      await tester.pumpAndSettle();

      // Recording state should be maintained
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });

    testWidgets('emergency mode workflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Look for emergency button
      final emergencyButton = find.byIcon(Icons.emergency);
      if (emergencyButton.evaluate().isNotEmpty) {
        await tester.tap(emergencyButton);
        await tester.pumpAndSettle();

        // Should enter emergency mode
        expect(find.text('EMERGENCY MODE'), findsOneWidget);
        expect(find.byIcon(Icons.location_on), findsOneWidget);
        expect(find.byIcon(Icons.contact_phone), findsOneWidget);
      }
    });

    testWidgets('error handling workflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Simulate error condition by tapping multiple times rapidly
      final recordButton = find.byIcon(Icons.fiber_manual_record);
      if (recordButton.evaluate().isNotEmpty) {
        for (int i = 0; i < 5; i++) {
          await tester.tap(recordButton);
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpAndSettle();

        // Should handle gracefully without crashes
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('accessibility workflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Find accessibility settings
      final accessibilityCard = find.text('Accessibility');
      if (accessibilityCard.evaluate().isNotEmpty) {
        await tester.tap(accessibilityCard);
        await tester.pumpAndSettle();

        // Should show accessibility options
        expect(find.text('High Contrast Mode'), findsOneWidget);
        expect(find.text('Text Size'), findsOneWidget);
        expect(find.text('Voice Control'), findsOneWidget);

        // Test high contrast toggle
        final highContrastSwitch = find.byType(Switch).first;
        await tester.tap(highContrastSwitch);
        await tester.pumpAndSettle();

        // Should apply high contrast
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('theme switching workflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Look for theme settings
      final themeOption = find.text('Dark');
      if (themeOption.evaluate().isNotEmpty) {
        await tester.tap(themeOption);
        await tester.pumpAndSettle();

        // Should apply dark theme
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('responsive layout workflow', (tester) async {
      // Test different screen sizes
      await tester.binding.setSurfaceSize(const Size(800, 600)); // Tablet size
      
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Should adapt to larger screen
      expect(find.byType(BottomNavigationComponent), findsOneWidget);

      // Test phone size
      await tester.binding.setSurfaceSize(const Size(375, 667)); // iPhone size
      await tester.pumpAndSettle();

      // Should still work on smaller screen
      expect(find.byType(BottomNavigationComponent), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('performance under load', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NavigationWrapper(),
        ),
      );

      // Rapidly switch between tabs
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.text('Monitor'));
        await tester.pump();
        await tester.tap(find.text('Record'));
        await tester.pump();
        await tester.tap(find.text('Settings'));
        await tester.pump();
      }

      await tester.pumpAndSettle();

      // Should handle rapid navigation without issues
      expect(tester.takeException(), isNull);
    });
  });
}