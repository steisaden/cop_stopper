import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/theme.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/app_text_styles.dart';
import 'package:mobile/src/ui/app_spacing.dart';

void main() {
  group('AppTheme', () {
    group('Light Theme', () {
      late ThemeData lightTheme;

      setUp(() {
        lightTheme = AppTheme.lightTheme;
      });

      test('should use Material Design 3', () {
        expect(lightTheme.useMaterial3, isTrue);
      });

      test('should use correct color scheme', () {
        expect(lightTheme.colorScheme, AppColors.lightColorScheme);
        expect(lightTheme.colorScheme.brightness, Brightness.light);
      });

      test('should have proper app bar theme', () {
        final appBarTheme = lightTheme.appBarTheme;
        expect(appBarTheme.backgroundColor, AppColors.lightColorScheme.surface);
        expect(appBarTheme.foregroundColor, AppColors.lightColorScheme.onSurface);
        expect(appBarTheme.elevation, AppSpacing.elevationNone);
        expect(appBarTheme.centerTitle, isTrue);
      });

      test('should have proper bottom navigation theme', () {
        final bottomNavTheme = lightTheme.bottomNavigationBarTheme;
        expect(bottomNavTheme.backgroundColor, AppColors.glassMorphismBackground);
        expect(bottomNavTheme.selectedItemColor, AppColors.lightColorScheme.primary);
        expect(bottomNavTheme.unselectedItemColor, AppColors.lightColorScheme.onSurfaceVariant);
        expect(bottomNavTheme.type, BottomNavigationBarType.fixed);
        expect(bottomNavTheme.elevation, AppSpacing.elevationMedium);
      });

      test('should have proper card theme', () {
        final cardTheme = lightTheme.cardTheme;
        expect(cardTheme.color, AppColors.cardBackground);
        expect(cardTheme.elevation, AppSpacing.elevationLow);
        expect(cardTheme.shape, isA<RoundedRectangleBorder>());
        expect(cardTheme.margin, const EdgeInsets.all(AppSpacing.cardMargin));
      });

      test('should have proper button themes', () {
        final elevatedButtonTheme = lightTheme.elevatedButtonTheme;
        expect(elevatedButtonTheme.style?.backgroundColor?.resolve({}), AppColors.lightColorScheme.primary);
        expect(elevatedButtonTheme.style?.foregroundColor?.resolve({}), AppColors.lightColorScheme.onPrimary);
        expect(elevatedButtonTheme.style?.elevation?.resolve({}), AppSpacing.elevationLow);

        final outlinedButtonTheme = lightTheme.outlinedButtonTheme;
        expect(outlinedButtonTheme.style?.foregroundColor?.resolve({}), AppColors.lightColorScheme.primary);

        final textButtonTheme = lightTheme.textButtonTheme;
        expect(textButtonTheme.style?.foregroundColor?.resolve({}), AppColors.lightColorScheme.primary);
      });

      test('should have proper floating action button theme', () {
        final fabTheme = lightTheme.floatingActionButtonTheme;
        expect(fabTheme.backgroundColor, AppColors.recording);
        expect(fabTheme.foregroundColor, AppColors.onRecording);
        expect(fabTheme.elevation, AppSpacing.elevationMedium);
        expect(fabTheme.shape, isA<CircleBorder>());
      });

      test('should have proper input decoration theme', () {
        final inputTheme = lightTheme.inputDecorationTheme;
        expect(inputTheme.filled, isTrue);
        expect(inputTheme.fillColor, AppColors.lightColorScheme.surfaceContainerHighest);
        expect(inputTheme.border, isA<OutlineInputBorder>());
        expect(inputTheme.contentPadding, AppSpacing.paddingMD);
      });

      test('should have proper switch theme', () {
        final switchTheme = lightTheme.switchTheme;
        expect(switchTheme.thumbColor?.resolve({WidgetState.selected}), AppColors.lightColorScheme.primary);
        expect(switchTheme.trackColor?.resolve({WidgetState.selected}), AppColors.lightColorScheme.primaryContainer);
      });

      test('should have proper slider theme', () {
        final sliderTheme = lightTheme.sliderTheme;
        expect(sliderTheme.activeTrackColor, AppColors.lightColorScheme.primary);
        expect(sliderTheme.inactiveTrackColor, AppColors.lightColorScheme.surfaceContainerHighest);
        expect(sliderTheme.thumbColor, AppColors.lightColorScheme.primary);
      });

      test('should have proper icon theme', () {
        final iconTheme = lightTheme.iconTheme;
        expect(iconTheme.color, AppColors.lightColorScheme.onSurface);
        expect(iconTheme.size, AppSpacing.tabIconSize);
      });

      test('should have proper divider theme', () {
        final dividerTheme = lightTheme.dividerTheme;
        expect(dividerTheme.color, AppColors.lightColorScheme.outlineVariant);
        expect(dividerTheme.thickness, 1);
        expect(dividerTheme.space, AppSpacing.sm);
      });

      test('should have proper list tile theme', () {
        final listTileTheme = lightTheme.listTileTheme;
        expect(listTileTheme.contentPadding, AppSpacing.horizontalPaddingMD);
        expect(listTileTheme.iconColor, AppColors.lightColorScheme.onSurfaceVariant);
      });

      test('should have proper dialog theme', () {
        final dialogTheme = lightTheme.dialogTheme;
        expect(dialogTheme.backgroundColor, AppColors.lightColorScheme.surface);
        expect(dialogTheme.elevation, AppSpacing.elevationHigh);
        expect(dialogTheme.shape, isA<RoundedRectangleBorder>());
      });

      test('should have proper snack bar theme', () {
        final snackBarTheme = lightTheme.snackBarTheme;
        expect(snackBarTheme.backgroundColor, AppColors.lightColorScheme.inverseSurface);
        expect(snackBarTheme.actionTextColor, AppColors.lightColorScheme.inversePrimary);
        expect(snackBarTheme.behavior, SnackBarBehavior.floating);
        expect(snackBarTheme.shape, isA<RoundedRectangleBorder>());
      });

      test('should have proper progress indicator theme', () {
        final progressTheme = lightTheme.progressIndicatorTheme;
        expect(progressTheme.color, AppColors.lightColorScheme.primary);
        expect(progressTheme.linearTrackColor, AppColors.lightColorScheme.surfaceContainerHighest);
        expect(progressTheme.circularTrackColor, AppColors.lightColorScheme.surfaceContainerHighest);
      });

      test('should have proper chip theme', () {
        final chipTheme = lightTheme.chipTheme;
        expect(chipTheme.backgroundColor, AppColors.lightColorScheme.surfaceContainerHighest);
        expect(chipTheme.side, BorderSide.none);
        expect(chipTheme.shape, isA<RoundedRectangleBorder>());
      });
    });

    group('Dark Theme', () {
      late ThemeData darkTheme;

      setUp(() {
        darkTheme = AppTheme.darkTheme;
      });

      test('should use Material Design 3', () {
        expect(darkTheme.useMaterial3, isTrue);
      });

      test('should use correct color scheme', () {
        expect(darkTheme.colorScheme, AppColors.darkColorScheme);
        expect(darkTheme.colorScheme.brightness, Brightness.dark);
      });

      test('should have proper app bar theme', () {
        final appBarTheme = darkTheme.appBarTheme;
        expect(appBarTheme.backgroundColor, AppColors.darkColorScheme.surface);
        expect(appBarTheme.foregroundColor, AppColors.darkColorScheme.onSurface);
        expect(appBarTheme.elevation, AppSpacing.elevationNone);
        expect(appBarTheme.centerTitle, isTrue);
      });

      test('should have proper bottom navigation theme', () {
        final bottomNavTheme = darkTheme.bottomNavigationBarTheme;
        expect(bottomNavTheme.backgroundColor, AppColors.darkGlassMorphismBackground);
        expect(bottomNavTheme.selectedItemColor, AppColors.darkColorScheme.primary);
        expect(bottomNavTheme.unselectedItemColor, AppColors.darkColorScheme.onSurfaceVariant);
        expect(bottomNavTheme.type, BottomNavigationBarType.fixed);
        expect(bottomNavTheme.elevation, AppSpacing.elevationMedium);
      });

      test('should have proper card theme', () {
        final cardTheme = darkTheme.cardTheme;
        expect(cardTheme.color, AppColors.darkCardBackground);
        expect(cardTheme.elevation, AppSpacing.elevationLow);
        expect(cardTheme.shape, isA<RoundedRectangleBorder>());
        expect(cardTheme.margin, const EdgeInsets.all(AppSpacing.cardMargin));
      });

      test('should have proper button themes', () {
        final elevatedButtonTheme = darkTheme.elevatedButtonTheme;
        expect(elevatedButtonTheme.style?.backgroundColor?.resolve({}), AppColors.darkColorScheme.primary);
        expect(elevatedButtonTheme.style?.foregroundColor?.resolve({}), AppColors.darkColorScheme.onPrimary);
        expect(elevatedButtonTheme.style?.elevation?.resolve({}), AppSpacing.elevationLow);

        final outlinedButtonTheme = darkTheme.outlinedButtonTheme;
        expect(outlinedButtonTheme.style?.foregroundColor?.resolve({}), AppColors.darkColorScheme.primary);

        final textButtonTheme = darkTheme.textButtonTheme;
        expect(textButtonTheme.style?.foregroundColor?.resolve({}), AppColors.darkColorScheme.primary);
      });

      test('should have proper floating action button theme', () {
        final fabTheme = darkTheme.floatingActionButtonTheme;
        expect(fabTheme.backgroundColor, AppColors.recording);
        expect(fabTheme.foregroundColor, AppColors.onRecording);
        expect(fabTheme.elevation, AppSpacing.elevationMedium);
        expect(fabTheme.shape, isA<CircleBorder>());
      });

      test('should have proper input decoration theme', () {
        final inputTheme = darkTheme.inputDecorationTheme;
        expect(inputTheme.filled, isTrue);
        expect(inputTheme.fillColor, AppColors.darkColorScheme.surfaceContainerHighest);
        expect(inputTheme.border, isA<OutlineInputBorder>());
        expect(inputTheme.contentPadding, AppSpacing.paddingMD);
      });

      test('should have proper switch theme', () {
        final switchTheme = darkTheme.switchTheme;
        expect(switchTheme.thumbColor?.resolve({WidgetState.selected}), AppColors.darkColorScheme.primary);
        expect(switchTheme.trackColor?.resolve({WidgetState.selected}), AppColors.darkColorScheme.primaryContainer);
      });

      test('should have proper slider theme', () {
        final sliderTheme = darkTheme.sliderTheme;
        expect(sliderTheme.activeTrackColor, AppColors.darkColorScheme.primary);
        expect(sliderTheme.inactiveTrackColor, AppColors.darkColorScheme.surfaceContainerHighest);
        expect(sliderTheme.thumbColor, AppColors.darkColorScheme.primary);
      });

      test('should have proper icon theme', () {
        final iconTheme = darkTheme.iconTheme;
        expect(iconTheme.color, AppColors.darkColorScheme.onSurface);
        expect(iconTheme.size, AppSpacing.tabIconSize);
      });
    });

    group('High Contrast Themes', () {
      test('should provide high contrast light theme', () {
        final highContrastTheme = AppTheme.highContrastLightTheme;
        expect(highContrastTheme.useMaterial3, isTrue);
        expect(highContrastTheme.colorScheme.brightness, Brightness.light);
        
        // Should have enhanced contrast
        expect(highContrastTheme.colorScheme.outline, Colors.black);
        expect(highContrastTheme.colorScheme.outlineVariant, Colors.black54);
      });

      test('should provide high contrast dark theme', () {
        final highContrastTheme = AppTheme.highContrastDarkTheme;
        expect(highContrastTheme.useMaterial3, isTrue);
        expect(highContrastTheme.colorScheme.brightness, Brightness.dark);
        
        // Should have enhanced contrast
        expect(highContrastTheme.colorScheme.outline, Colors.white);
        expect(highContrastTheme.colorScheme.outlineVariant, Colors.white70);
      });
    });

    group('Theme Selection', () {
      test('should return correct theme for brightness', () {
        final lightTheme = AppTheme.getTheme(brightness: Brightness.light);
        expect(lightTheme.colorScheme.brightness, Brightness.light);
        
        final darkTheme = AppTheme.getTheme(brightness: Brightness.dark);
        expect(darkTheme.colorScheme.brightness, Brightness.dark);
      });

      test('should return high contrast theme when requested', () {
        final highContrastLight = AppTheme.getTheme(
          brightness: Brightness.light,
          highContrast: true,
        );
        expect(highContrastLight.colorScheme.outline, Colors.black);
        
        final highContrastDark = AppTheme.getTheme(
          brightness: Brightness.dark,
          highContrast: true,
        );
        expect(highContrastDark.colorScheme.outline, Colors.white);
      });
    });

    group('Accessibility Validation', () {
      test('should validate light theme accessibility', () {
        final isValid = AppTheme.validateThemeAccessibility(AppTheme.lightTheme);
        expect(isValid, isTrue);
      });

      test('should validate dark theme accessibility', () {
        final isValid = AppTheme.validateThemeAccessibility(AppTheme.darkTheme);
        expect(isValid, isTrue);
      });

      test('should validate high contrast themes accessibility', () {
        final lightValid = AppTheme.validateThemeAccessibility(AppTheme.highContrastLightTheme);
        expect(lightValid, isTrue);
        
        final darkValid = AppTheme.validateThemeAccessibility(AppTheme.highContrastDarkTheme);
        expect(darkValid, isTrue);
      });

      test('should fail validation for poor contrast theme', () {
        final poorContrastTheme = ThemeData(
          colorScheme: const ColorScheme.light().copyWith(
            primary: const Color(0xFFCCCCCC),
            onPrimary: const Color(0xFFDDDDDD), // Poor contrast
          ),
        );
        
        final isValid = AppTheme.validateThemeAccessibility(poorContrastTheme);
        expect(isValid, isFalse);
      });
    });

    group('Text Theme Integration', () {
      test('should use AppTextStyles in light theme', () {
        final textTheme = AppTheme.lightTheme.textTheme;
        expect(textTheme.displayLarge?.fontFamily, AppTextStyles.fontFamily);
        expect(textTheme.headlineLarge?.fontFamily, AppTextStyles.fontFamily);
        expect(textTheme.titleLarge?.fontFamily, AppTextStyles.fontFamily);
        expect(textTheme.bodyLarge?.fontFamily, AppTextStyles.fontFamily);
      });

      test('should use AppTextStyles in dark theme', () {
        final textTheme = AppTheme.darkTheme.textTheme;
        expect(textTheme.displayLarge?.fontFamily, AppTextStyles.fontFamily);
        expect(textTheme.headlineLarge?.fontFamily, AppTextStyles.fontFamily);
        expect(textTheme.titleLarge?.fontFamily, AppTextStyles.fontFamily);
        expect(textTheme.bodyLarge?.fontFamily, AppTextStyles.fontFamily);
      });

      test('should apply correct colors to text styles', () {
        final lightTextTheme = AppTheme.lightTheme.textTheme;
        expect(lightTextTheme.displayLarge?.color, AppColors.lightColorScheme.onSurface);
        expect(lightTextTheme.titleLarge?.color, AppColors.lightColorScheme.onSurface);
        expect(lightTextTheme.bodyLarge?.color, AppColors.lightColorScheme.onSurface);
        
        final darkTextTheme = AppTheme.darkTheme.textTheme;
        expect(darkTextTheme.displayLarge?.color, AppColors.darkColorScheme.onSurface);
        expect(darkTextTheme.titleLarge?.color, AppColors.darkColorScheme.onSurface);
        expect(darkTextTheme.bodyLarge?.color, AppColors.darkColorScheme.onSurface);
      });
    });

    group('Spacing Integration', () {
      test('should use AppSpacing values in theme components', () {
        final lightTheme = AppTheme.lightTheme;
        
        // Card theme should use AppSpacing
        expect(lightTheme.cardTheme.elevation, AppSpacing.elevationLow);
        expect(lightTheme.cardTheme.margin, const EdgeInsets.all(AppSpacing.cardMargin));
        
        // Button themes should use AppSpacing
        expect(lightTheme.elevatedButtonTheme.style?.elevation?.resolve({}), AppSpacing.elevationLow);
        expect(lightTheme.elevatedButtonTheme.style?.padding?.resolve({}), AppSpacing.paddingMD);
        
        // FAB theme should use AppSpacing
        expect(lightTheme.floatingActionButtonTheme.elevation, AppSpacing.elevationMedium);
        
        // Input decoration should use AppSpacing
        expect(lightTheme.inputDecorationTheme.contentPadding, AppSpacing.paddingMD);
        
        // Bottom navigation should use AppSpacing
        expect(lightTheme.bottomNavigationBarTheme.elevation, AppSpacing.elevationMedium);
        
        // Icon theme should use AppSpacing
        expect(lightTheme.iconTheme.size, AppSpacing.tabIconSize);
        
        // Divider theme should use AppSpacing
        expect(lightTheme.dividerTheme.space, AppSpacing.sm);
        
        // List tile theme should use AppSpacing
        expect(lightTheme.listTileTheme.contentPadding, AppSpacing.horizontalPaddingMD);
        
        // Dialog theme should use AppSpacing
        expect(lightTheme.dialogTheme.elevation, AppSpacing.elevationHigh);
      });
    });

    group('Police Interaction Specific Theming', () {
      test('should use recording colors for FAB', () {
        expect(AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor, AppColors.recording);
        expect(AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor, AppColors.onRecording);
        
        expect(AppTheme.darkTheme.floatingActionButtonTheme.backgroundColor, AppColors.recording);
        expect(AppTheme.darkTheme.floatingActionButtonTheme.foregroundColor, AppColors.onRecording);
      });

      test('should use glass morphism for bottom navigation', () {
        expect(AppTheme.lightTheme.bottomNavigationBarTheme.backgroundColor, AppColors.glassMorphismBackground);
        expect(AppTheme.darkTheme.bottomNavigationBarTheme.backgroundColor, AppColors.darkGlassMorphismBackground);
      });

      test('should use appropriate card colors', () {
        expect(AppTheme.lightTheme.cardTheme.color, AppColors.cardBackground);
        expect(AppTheme.darkTheme.cardTheme.color, AppColors.darkCardBackground);
      });
    });
  });
}