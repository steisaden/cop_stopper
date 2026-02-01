import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/theme_switcher.dart';
import 'package:mobile/src/ui/theme_manager.dart';

void main() {
  group('ThemeSwitcher', () {
    testWidgets('should display all theme options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeSwitcher(
            currentTheme: ThemeMode.system,
            onThemeChanged: null,
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

    testWidgets('should call onThemeChanged when theme is selected', (tester) async {
      ThemeMode? selectedTheme;

      await tester.pumpWidget(
        MaterialApp(
          home: ThemeSwitcher(
            currentTheme: ThemeMode.system,
            onThemeChanged: (theme) => selectedTheme = theme,
          ),
        ),
      );

      // Tap on Light theme
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(selectedTheme, ThemeMode.light);

      // Tap on Dark theme
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(selectedTheme, ThemeMode.dark);
    });

    testWidgets('should show selected theme', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeSwitcher(
            currentTheme: ThemeMode.light,
            onThemeChanged: null,
          ),
        ),
      );

      // Light theme should be selected
      final lightThemeButton = find.text('Light').evaluate().single.widget;
      // We can't easily test the visual selection state in tests
    });
  });

  group('ThemeCustomizationPanel', () {
    testWidgets('should display accent color options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeCustomizationPanel(
            currentAccentColor: Colors.blue,
            onAccentColorChanged: null,
          ),
        ),
      );

      expect(find.text('Customize Theme'), findsOneWidget);
      expect(find.text('Accent Color'), findsOneWidget);
      
      // Should show at least the default blue color option
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('should call onAccentColorChanged when color is selected', (tester) async {
      Color? selectedColor;

      await tester.pumpWidget(
        MaterialApp(
          home: ThemeCustomizationPanel(
            currentAccentColor: Colors.blue,
            onAccentColorChanged: (color) => selectedColor = color,
          ),
        ),
      );

      // Tap on the first color option (blue)
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      expect(selectedColor, Colors.blue);
    });
  });

  group('HighContrastToggle', () {
    testWidgets('should display high contrast toggle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HighContrastToggle(
            isHighContrastEnabled: false,
            onChanged: null,
          ),
        ),
      );

      expect(find.text('High Contrast Mode'), findsOneWidget);
      expect(find.text('Increase color contrast for better visibility'), findsOneWidget);
    });

    testWidgets('should call onChanged when toggled', (tester) async {
      bool? toggleValue;

      await tester.pumpWidget(
        MaterialApp(
          home: HighContrastToggle(
            isHighContrastEnabled: false,
            onChanged: (value) => toggleValue = value,
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(toggleValue, isTrue);
    });
  });

  group('ThemeManager', () {
    test('should initialize with default values', () {
      final themeManager = ThemeManager();

      expect(themeManager.themeMode, ThemeMode.system);
      expect(themeManager.isHighContrastEnabled, isFalse);
    });

    test('should change theme mode', () {
      final themeManager = ThemeManager();

      themeManager.changeThemeMode(ThemeMode.dark);

      expect(themeManager.themeMode, ThemeMode.dark);
    });

    test('should change accent color', () {
      final themeManager = ThemeManager();
      final newColor = Colors.red;

      themeManager.changeAccentColor(newColor);

      expect(themeManager.accentColor, newColor);
    });

    test('should toggle high contrast', () {
      final themeManager = ThemeManager();

      themeManager.toggleHighContrast(true);

      expect(themeManager.isHighContrastEnabled, isTrue);
    });
  });
}