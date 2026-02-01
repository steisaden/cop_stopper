import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/error_card.dart';
import 'package:mobile/src/ui/widgets/storage_warning_banner.dart';
import 'package:mobile/src/ui/widgets/network_error_component.dart';
import 'package:mobile/src/ui/widgets/accessibility_support.dart';
import 'package:mobile/src/ui/widgets/theme_switcher.dart';

void main() {
  group('UI Component Integration', () {
    testWidgets('should display error card with actions', (tester) async {
      bool retryPressed = false;
      bool cancelPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorCard(
            title: 'Connection Failed',
            message: 'Unable to connect to the server. Please check your internet connection.',
            actions: [
              ErrorAction(
                label: 'Retry',
                onPressed: () => retryPressed = true,
                isPrimary: true,
              ),
              ErrorAction(
                label: 'Cancel',
                onPressed: () => cancelPressed = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Connection Failed'), findsOneWidget);
      expect(find.text('Unable to connect to the server. Please check your internet connection.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retryPressed, isTrue);
    });

    testWidgets('should display storage warning banner', (tester) async {
      bool cleanPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StorageWarningBanner(
            usagePercentage: 85.5,
            availableSpace: '1.2 GB',
            cleanupOptions: [
              CleanupOption(
                label: 'Clean Storage',
                icon: Icons.cleaning_services,
                onPressed: () => cleanPressed = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Storage Warning'), findsOneWidget);
      expect(find.text('Usage: 85.5% (1.2 GB remaining)'), findsOneWidget);
      expect(find.text('Clean Storage'), findsOneWidget);

      await tester.tap(find.text('Clean Storage'));
      await tester.pumpAndSettle();

      expect(cleanPressed, isTrue);
    });

    testWidgets('should display network error component', (tester) async {
      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: NetworkErrorComponent(
            message: 'No internet connection available',
            onRetry: () => retryPressed = true,
            showOfflineMode: true,
          ),
        ),
      );

      expect(find.text('Network Error'), findsOneWidget);
      expect(find.text('No internet connection available'), findsOneWidget);
      expect(find.text('Offline mode enabled. Some features may be limited.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(retryPressed, isTrue);
    });

    testWidgets('should display accessibility settings panel', (tester) async {
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

      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('High Contrast Mode'), findsOneWidget);
      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('Reduce Motion'), findsOneWidget);
      expect(find.text('Voice Control'), findsOneWidget);
    });

    testWidgets('should display theme switcher', (tester) async {
      ThemeMode? selectedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: ThemeSwitcher(
            currentTheme: ThemeMode.system,
            onThemeChanged: (theme) => selectedTheme = theme,
          ),
        ),
      );

      expect(find.text('Theme'), findsOneWidget);
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.byIcon(Icons.nights_stay), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });
  });
}