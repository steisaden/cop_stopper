import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/error_card.dart';
import 'package:mobile/src/ui/widgets/storage_warning_banner.dart';
import 'package:mobile/src/ui/widgets/network_error_component.dart';
import 'package:mobile/src/ui/widgets/accessibility_support.dart';
import 'package:mobile/src/ui/widgets/theme_switcher.dart';

void main() {
  group('UI Performance Tests', () {
    testWidgets('error card should build quickly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorCard(
            title: 'Test Error',
            message: 'This is a test error message',
          ),
        ),
      );

      final duration = tester.binding.clock.now();
      await tester.pumpAndSettle();
      final buildTime = tester.binding.clock.now().difference(duration);

      // Should build in less than 16ms (60fps)
      expect(buildTime.inMilliseconds, lessThan(16));
    });

    testWidgets('storage warning banner should build quickly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StorageWarningBanner(
            usagePercentage: 75.0,
            availableSpace: '2.5 GB',
          ),
        ),
      );

      final duration = tester.binding.clock.now();
      await tester.pumpAndSettle();
      final buildTime = tester.binding.clock.now().difference(duration);

      // Should build in less than 16ms (60fps)
      expect(buildTime.inMilliseconds, lessThan(16));
    });

    testWidgets('network error component should build quickly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: NetworkErrorComponent(
            message: 'No internet connection',
          ),
        ),
      );

      final duration = tester.binding.clock.now();
      await tester.pumpAndSettle();
      final buildTime = tester.binding.clock.now().difference(duration);

      // Should build in less than 16ms (60fps)
      expect(buildTime.inMilliseconds, lessThan(16));
    });

    testWidgets('accessibility settings panel should build quickly', (tester) async {
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

      final duration = tester.binding.clock.now();
      await tester.pumpAndSettle();
      final buildTime = tester.binding.clock.now().difference(duration);

      // Should build in less than 16ms (60fps)
      expect(buildTime.inMilliseconds, lessThan(16));
    });

    testWidgets('theme switcher should build quickly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeSwitcher(
            currentTheme: ThemeMode.system,
            onThemeChanged: null,
          ),
        ),
      );

      final duration = tester.binding.clock.now();
      await tester.pumpAndSettle();
      final buildTime = tester.binding.clock.now().difference(duration);

      // Should build in less than 16ms (60fps)
      expect(buildTime.inMilliseconds, lessThan(16));
    });

    testWidgets('theme customization panel should build quickly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeCustomizationPanel(
            currentAccentColor: Colors.blue,
            onAccentColorChanged: null,
          ),
        ),
      );

      final duration = tester.binding.clock.now();
      await tester.pumpAndSettle();
      final buildTime = tester.binding.clock.now().difference(duration);

      // Should build in less than 16ms (60fps)
      expect(buildTime.inMilliseconds, lessThan(16));
    });
  });
}