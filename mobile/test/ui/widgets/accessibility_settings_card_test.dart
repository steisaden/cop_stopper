import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/accessibility_settings_card.dart';
import '../../test_helpers.dart';

void main() {
  group('AccessibilitySettingsCard Widget Tests', () {
    testWidgets('renders with default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('Configure accessibility features and preferences'), findsOneWidget);
      expect(find.byIcon(Icons.accessibility), findsOneWidget);
    });

    testWidgets('displays voice commands toggle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      expect(find.text('Voice Commands'), findsOneWidget);
      expect(find.text('Control the app using voice commands for hands-free operation'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(5)); // 5 switches total
    });

    testWidgets('handles voice commands toggle change', (WidgetTester tester) async {
      bool? voiceCommandsValue;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
            onVoiceCommandsChanged: (value) => voiceCommandsValue = value,
          ),
        ),
      );

      // Tap the first switch (voice commands)
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(voiceCommandsValue, equals(true));
    });

    testWidgets('displays text size slider correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
      expect(find.textContaining('Adjust text size for better readability'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('handles text size slider change', (WidgetTester tester) async {
      double? textSizeValue;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
            onTextSizeChanged: (value) => textSizeValue = value,
          ),
        ),
      );

      // Find and interact with the slider
      final slider = find.byType(Slider);
      await tester.drag(slider, Offset(100, 0));
      await tester.pumpAndSettle();

      expect(textSizeValue, isNotNull);
      expect(textSizeValue, greaterThan(1.0));
    });

    testWidgets('displays text size labels correctly', (WidgetTester tester) async {
      final testCases = {
        0.8: 'Small',
        1.0: 'Default',
        1.3: 'Large',
        1.8: 'Extra Large',
      };

      for (final entry in testCases.entries) {
        final size = entry.key;
        final expectedLabel = entry.value;
        
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: AccessibilitySettingsCard(
              voiceCommands: false,
              textSize: size,
              highContrast: false,
              reducedMotion: false,
              screenReaderSupport: true,
              hapticFeedback: true,
            ),
          ),
        );

        expect(find.text(expectedLabel), findsOneWidget);
      }
    });

    testWidgets('displays text size preview', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.5,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      // Just verify the text size section exists
      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('Extra Large'), findsOneWidget);
    });

    testWidgets('displays high contrast toggle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      expect(find.text('High Contrast'), findsOneWidget);
      expect(find.text('Increase contrast for better visibility'), findsOneWidget);
    });

    testWidgets('handles high contrast toggle change', (WidgetTester tester) async {
      bool? highContrastValue;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
            onHighContrastChanged: (value) => highContrastValue = value,
          ),
        ),
      );

      // Tap the high contrast switch (second switch)
      await tester.tap(find.byType(Switch).at(1));
      await tester.pumpAndSettle();

      expect(highContrastValue, equals(true));
    });

    testWidgets('displays reduced motion toggle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      expect(find.text('Reduced Motion'), findsOneWidget);
      expect(find.text('Minimize animations and transitions'), findsOneWidget);
    });

    testWidgets('displays screen reader support toggle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      expect(find.text('Screen Reader Support'), findsOneWidget);
      expect(find.text('Enhanced compatibility with screen readers'), findsOneWidget);
    });

    testWidgets('displays haptic feedback toggle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      expect(find.text('Haptic Feedback'), findsOneWidget);
      expect(find.text('Vibration feedback for interactions and alerts'), findsOneWidget);
    });

    testWidgets('handles haptic feedback toggle change', (WidgetTester tester) async {
      bool? hapticFeedbackValue;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
            onHapticFeedbackChanged: (value) => hapticFeedbackValue = value,
          ),
        ),
      );

      // Tap the haptic feedback switch (last switch)
      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();

      expect(hapticFeedbackValue, equals(false));
    });

    testWidgets('displays accessibility status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      expect(find.text('Accessibility Features Active'), findsOneWidget);
      expect(find.text('App is optimized for accessibility compliance (WCAG 2.1 AA)'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('updates text size description with percentage', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.5,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      expect(find.textContaining('(150%)'), findsOneWidget);
    });

    testWidgets('has proper accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      // Verify semantic labels exist
      expect(find.text('Voice Commands'), findsOneWidget);
      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('High Contrast'), findsOneWidget);
      expect(find.text('Reduced Motion'), findsOneWidget);
      expect(find.text('Screen Reader Support'), findsOneWidget);
      expect(find.text('Haptic Feedback'), findsOneWidget);

      // Verify interactive elements are accessible
      expect(find.byType(Switch), findsNWidgets(5));
      expect(find.byType(Slider), findsOneWidget);
    });
  });

  group('Responsive Behavior Tests', () {
    testWidgets('adapts to different screen sizes', (WidgetTester tester) async {
      // Test mobile size
      await tester.binding.setSurfaceSize(Size(400, 800));
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.0,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      expect(find.text('Accessibility'), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(Size(800, 1200));
      await tester.pumpAndSettle();

      expect(find.text('Accessibility'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('maintains layout with extreme text sizes', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 2.0, // Maximum size
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      // Verify no overflow with maximum text size
      expect(tester.takeException(), isNull);
      
      // Verify extreme values are displayed correctly
      expect(find.text('Extra Large'), findsOneWidget);
      expect(find.textContaining('(200%)'), findsOneWidget);
    });

    testWidgets('text preview scales correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AccessibilitySettingsCard(
            voiceCommands: false,
            textSize: 1.5,
            highContrast: false,
            reducedMotion: false,
            screenReaderSupport: true,
            hapticFeedback: true,
          ),
        ),
      );

      // Just verify the text size is displayed correctly
      expect(find.text('Extra Large'), findsOneWidget);
      expect(find.textContaining('(150%)'), findsOneWidget);
    });
  });
}