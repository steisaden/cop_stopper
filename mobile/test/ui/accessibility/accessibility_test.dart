import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/accessibility_support.dart';
import 'package:mobile/src/ui/widgets/error_card.dart';

void main() {
  group('Accessibility Tests', () {
    testWidgets('should have proper semantic labels for screen readers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibilitySupport.withSemanticLabel(
              label: 'Emergency record button',
              hint: 'Double tap to start emergency recording',
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Record'),
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(ElevatedButton));
      expect(semantics.label, equals('Emergency record button'));
      expect(semantics.hint, equals('Double tap to start emergency recording'));
    });

    testWidgets('should handle focus management properly', (tester) async {
      bool focusCalled = false;
      bool blurCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AccessibilitySupport.focusable(
              onFocus: () => focusCalled = true,
              onBlur: () => blurCalled = true,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Test Button'),
              ),
            ),
          ),
        ),
      );

      // Simulate focus
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(focusCalled, isTrue);
    });

    testWidgets('should provide proper navigation order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('First Button'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Second Button'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Third Button'),
                ),
              ],
            ),
          ),
        ),
      );

      // Test tab navigation order
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      final firstButton = find.text('First Button');
      expect(tester.binding.focusManager.primaryFocus?.context?.widget,
          isA<ElevatedButton>());
    });

    testWidgets('should support high contrast mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HighContrastMode(
            isEnabled: true,
            child: Scaffold(
              body: ErrorCard(
                title: 'Test Error',
                message: 'This is a test error message',
                severity: ErrorSeverity.error,
              ),
            ),
          ),
        ),
      );

      final highContrastMode = HighContrastMode.of(
          tester.element(find.byType(ErrorCard)));
      expect(highContrastMode?.isEnabled, isTrue);
    });

    testWidgets('should support dynamic text sizing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TextSizeScaler(
            scaleFactor: 1.5,
            child: Scaffold(
              body: ErrorCard(
                title: 'Test Error',
                message: 'This is a test error message',
              ),
            ),
          ),
        ),
      );

      final textSizeScaler = TextSizeScaler.of(
          tester.element(find.byType(ErrorCard)));
      expect(textSizeScaler?.scaleFactor, equals(1.5));
    });

    testWidgets('should display voice command overlay', (tester) async {
      final commands = [
        VoiceCommand(
          label: 'Start Recording',
          description: 'Begin audio/video recording',
          icon: Icons.record_voice_over,
          onExecute: () {},
        ),
        VoiceCommand(
          label: 'Stop Recording',
          description: 'End current recording session',
          icon: Icons.stop,
          onExecute: () {},
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCommandOverlay(
            isVisible: true,
            listeningText: 'Listening for commands...',
            availableCommands: commands,
            onClose: () {},
          ),
        ),
      );

      expect(find.text('Voice Commands'), findsOneWidget);
      expect(find.text('Listening for commands...'), findsOneWidget);
      expect(find.text('Start Recording'), findsOneWidget);
      expect(find.text('Stop Recording'), findsOneWidget);
      expect(find.text('Begin audio/video recording'), findsOneWidget);
    });

    testWidgets('should handle accessibility settings changes', (tester) async {
      bool highContrastChanged = false;
      double textSizeChanged = 1.0;
      bool reduceMotionChanged = false;
      bool voiceControlChanged = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AccessibilitySettingsPanel(
            isHighContrastEnabled: false,
            textSizeScale: 1.0,
            isReduceMotionEnabled: false,
            isVoiceControlEnabled: false,
            onHighContrastChanged: (value) => highContrastChanged = value,
            onTextSizeScaleChanged: (value) => textSizeChanged = value,
            onReduceMotionChanged: (value) => reduceMotionChanged = value,
            onVoiceControlChanged: (value) => voiceControlChanged = value,
          ),
        ),
      );

      // Test high contrast toggle
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();
      expect(highContrastChanged, isTrue);

      // Test text size slider
      await tester.drag(find.byType(Slider), const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(textSizeChanged, greaterThan(1.0));
    });

    testWidgets('should meet minimum touch target sizes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text('Test Button'),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.record_voice_over),
                ),
              ],
            ),
          ),
        ),
      );

      // Check button sizes meet accessibility guidelines (minimum 44x44)
      final buttonSize = tester.getSize(find.byType(ElevatedButton));
      expect(buttonSize.height, greaterThanOrEqualTo(44));

      final iconButtonSize = tester.getSize(find.byType(IconButton));
      expect(iconButtonSize.height, greaterThanOrEqualTo(44));
      expect(iconButtonSize.width, greaterThanOrEqualTo(44));
    });

    testWidgets('should provide proper color contrast', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: ErrorCard(
              title: 'Error Title',
              message: 'Error message content',
              severity: ErrorSeverity.error,
            ),
          ),
        ),
      );

      // Verify error card uses proper contrast colors
      final errorCard = tester.widget<Card>(find.byType(Card));
      expect(errorCard.color, isNotNull);
    });
  });
}