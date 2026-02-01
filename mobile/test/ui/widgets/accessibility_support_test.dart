import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/accessibility_support.dart';

void main() {
  group('AccessibilitySupport', () {
    test('should provide semantic labels', () {
      final widget = AccessibilitySupport.withSemanticLabel(
        child: const Text('Test'),
        label: 'Test Label',
      );

      expect(widget, isA<Semantics>());
    });

    test('should create focusable widgets', () {
      bool focused = false;
      bool blurred = false;

      final widget = AccessibilitySupport.focusable(
        child: const Text('Test'),
        onFocus: () => focused = true,
        onBlur: () => blurred = true,
      );

      expect(widget, isA<Focus>());
    });
  });

  group('HighContrastMode', () {
    testWidgets('should provide inherited high contrast mode', (tester) async {
      late BuildContext savedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: HighContrastMode(
            isEnabled: true,
            child: Builder(
              builder: (context) {
                savedContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      final highContrastMode = HighContrastMode.of(savedContext);
      expect(highContrastMode, isNotNull);
      expect(highContrastMode!.isEnabled, isTrue);
    });

    testWidgets('should notify when value changes', (tester) async {
      bool notified = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return HighContrastMode(
                isEnabled: notified,
                child: TextButton(
                  onPressed: () => setState(() => notified = !notified),
                  child: const Text('Toggle'),
                ),
              );
            },
          ),
        ),
      );

      expect(find.byType(HighContrastMode), findsOneWidget);

      await tester.tap(find.text('Toggle'));
      await tester.pump();

      expect(notified, isTrue);
    });
  });

  group('TextSizeScaler', () {
    testWidgets('should provide inherited text size scale', (tester) async {
      late BuildContext savedContext;

      await tester.pumpWidget(
        MaterialApp(
          home: TextSizeScaler(
            scaleFactor: 1.5,
            child: Builder(
              builder: (context) {
                savedContext = context;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      final textSizeScaler = TextSizeScaler.of(savedContext);
      expect(textSizeScaler, isNotNull);
      expect(textSizeScaler!.scaleFactor, 1.5);
    });
  });

  group('AccessibilitySettingsPanel', () {
    testWidgets('should display all settings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AccessibilitySettingsPanel(
            isHighContrastEnabled: false,
            textSizeScale: 1.0,
            isReduceMotionEnabled: false,
            isVoiceControlEnabled: false,
            onHighContrastChanged: null,
            onTextSizeScaleChanged: null,
            onReduceMotionChanged: null,
            onVoiceControlChanged: null,
          ),
        ),
      );

      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('High Contrast Mode'), findsOneWidget);
      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('Reduce Motion'), findsOneWidget);
      expect(find.text('Voice Control'), findsOneWidget);
    });

    testWidgets('should update settings when toggled', (tester) async {
      bool highContrastChanged = false;
      double textSizeScaleChanged = 1.0;
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
            onTextSizeScaleChanged: (value) => textSizeScaleChanged = value,
            onReduceMotionChanged: (value) => reduceMotionChanged = value,
            onVoiceControlChanged: (value) => voiceControlChanged = value,
          ),
        ),
      );

      // Test high contrast toggle
      final highContrastSwitch = find.byWidgetPredicate(
        (widget) => widget is Switch && widget.value == false,
      ).at(0);
      await tester.tap(highContrastSwitch);
      expect(highContrastChanged, isTrue);

      // Test voice control toggle
      final voiceControlSwitch = find.byWidgetPredicate(
        (widget) => widget is Switch && widget.value == false,
      ).at(1);
      await tester.tap(voiceControlSwitch);
      expect(voiceControlChanged, isTrue);
    });
  });

  group('VoiceCommandOverlay', () {
    testWidgets('should be invisible when not visible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VoiceCommandOverlay(
            isVisible: false,
            onClose: null,
          ),
        ),
      );

      expect(find.text('Voice Commands'), findsNothing);
    });

    testWidgets('should display when visible', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VoiceCommandOverlay(
            isVisible: true,
            onClose: null,
          ),
        ),
      );

      expect(find.text('Voice Commands'), findsOneWidget);
      expect(find.text('Listening...'), findsOneWidget);
    });

    testWidgets('should call onClose when close button pressed', (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCommandOverlay(
            isVisible: true,
            onClose: () => closed = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(closed, isTrue);
    });
  });
}