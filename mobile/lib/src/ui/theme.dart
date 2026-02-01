import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/app_text_styles.dart';
import 'package:mobile/src/ui/app_spacing.dart';

/// AppTheme provides comprehensive Material Design 3 theme configuration
/// for the Police Interaction Assistant app with support for light/dark themes,
/// accessibility features, and custom police-interaction specific styling.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Main theme configuration (defaults to light theme)
  static ThemeData get theme => lightTheme;

  /// Light theme configuration
  static ThemeData get lightTheme {
    const ColorScheme colorScheme = AppColors.lightColorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTextStyles.textTheme(colorScheme),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: AppSpacing.elevationNone,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.glassMorphismBackground,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: AppTextStyles.navigationLabel,
        unselectedLabelStyle: AppTextStyles.navigationLabel.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.elevationMedium,
      ),

      // Card Theme - Figma design system
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: AppSpacing.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardBorderRadius,
        ),
        margin: const EdgeInsets.all(AppSpacing.cardMargin),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: AppSpacing.elevationLow,
          padding: AppSpacing.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonBorderRadius,
          ),
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size(64, 40),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: AppSpacing.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonBorderRadius,
          ),
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size(64, 40),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: AppSpacing.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonBorderRadius,
          ),
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size(64, 40),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.recording,
        foregroundColor: AppColors.onRecording,
        elevation: AppSpacing.elevationMedium,
        shape: const CircleBorder(),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: AppSpacing.paddingMD,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.12),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: AppTextStyles.labelSmall.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: AppSpacing.tabIconSize,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: AppSpacing.sm,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.horizontalPaddingMD,
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        iconColor: colorScheme.onSurfaceVariant,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: AppSpacing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusLG,
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    const ColorScheme colorScheme = AppColors.darkColorScheme;
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: AppTextStyles.textTheme(colorScheme),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: AppSpacing.elevationNone,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkGlassMorphismBackground,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: AppTextStyles.navigationLabel,
        unselectedLabelStyle: AppTextStyles.navigationLabel.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.elevationMedium,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: AppSpacing.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.cardBorderRadius,
        ),
        margin: const EdgeInsets.all(AppSpacing.cardMargin),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: AppSpacing.elevationLow,
          padding: AppSpacing.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonBorderRadius,
          ),
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size(64, 40),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          padding: AppSpacing.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonBorderRadius,
          ),
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size(64, 40),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: AppSpacing.paddingMD,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.buttonBorderRadius,
          ),
          textStyle: AppTextStyles.labelLarge,
          minimumSize: const Size(64, 40),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.recording,
        foregroundColor: AppColors.onRecording,
        elevation: AppSpacing.elevationMedium,
        shape: const CircleBorder(),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: AppSpacing.paddingMD,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.surfaceContainerHighest,
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withOpacity(0.12),
        valueIndicatorColor: colorScheme.primary,
        valueIndicatorTextStyle: AppTextStyles.labelSmall.copyWith(
          color: colorScheme.onPrimary,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: AppSpacing.tabIconSize,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: AppSpacing.sm,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.horizontalPaddingMD,
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        iconColor: colorScheme.onSurfaceVariant,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: AppSpacing.elevationHigh,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.radiusLG,
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
      ),
    );
  }

  /// High contrast theme for accessibility
  static ThemeData get highContrastLightTheme {
    final ThemeData baseTheme = lightTheme;
    const ColorScheme colorScheme = AppColors.lightColorScheme;
    
    return baseTheme.copyWith(
      textTheme: AppTextStyles.highContrastTextTheme(colorScheme),
      colorScheme: colorScheme.copyWith(
        outline: Colors.black,
        outlineVariant: Colors.black54,
      ),
    );
  }

  /// High contrast dark theme for accessibility
  static ThemeData get highContrastDarkTheme {
    final ThemeData baseTheme = darkTheme;
    const ColorScheme colorScheme = AppColors.darkColorScheme;
    
    return baseTheme.copyWith(
      textTheme: AppTextStyles.highContrastTextTheme(colorScheme),
      colorScheme: colorScheme.copyWith(
        outline: Colors.white,
        outlineVariant: Colors.white70,
      ),
    );
  }

  /// Returns the appropriate theme based on brightness and accessibility settings
  static ThemeData getTheme({
    required Brightness brightness,
    bool highContrast = false,
  }) {
    if (brightness == Brightness.dark) {
      return highContrast ? highContrastDarkTheme : darkTheme;
    } else {
      return highContrast ? highContrastLightTheme : lightTheme;
    }
  }

  /// Validates theme accessibility compliance
  static bool validateThemeAccessibility(ThemeData theme) {
    final ColorScheme colorScheme = theme.colorScheme;
    
    // Check primary color contrast
    if (!AppColors.hasValidContrast(colorScheme.onPrimary, colorScheme.primary)) {
      return false;
    }
    
    // Check surface color contrast
    if (!AppColors.hasValidContrast(colorScheme.onSurface, colorScheme.surface)) {
      return false;
    }
    
    // Check background color contrast
    if (!AppColors.hasValidContrast(colorScheme.onSurface, colorScheme.surface)) {
      return false;
    }
    
    return true;
  }

  /// Creates a custom theme with a specific accent color
  static ThemeData createCustomTheme({
    required Color accentColor,
    required Brightness brightness,
    bool highContrast = false,
  }) {
    final ColorScheme baseScheme = brightness == Brightness.light
        ? AppColors.lightColorScheme
        : AppColors.darkColorScheme;

    final ColorScheme customScheme = baseScheme.copyWith(
      primary: accentColor,
      onPrimary: ThemeData.estimateBrightnessForColor(accentColor) == Brightness.light
          ? Colors.black
          : Colors.white,
      primaryContainer: accentColor.withOpacity(0.1),
      onPrimaryContainer: accentColor,
    );

    final ThemeData baseTheme = brightness == Brightness.light
        ? lightTheme.copyWith(colorScheme: customScheme)
        : darkTheme.copyWith(colorScheme: customScheme);

    if (highContrast) {
      return baseTheme.copyWith(
        textTheme: AppTextStyles.highContrastTextTheme(customScheme),
        colorScheme: customScheme.copyWith(
          outline: brightness == Brightness.light ? Colors.black : Colors.white,
          outlineVariant: brightness == Brightness.light
              ? Colors.black54
              : Colors.white70,
        ),
      );
    }

    return baseTheme;
  }

  /// Smoothly animates between themes
  static ThemeData lerp(ThemeData a, ThemeData b, double t) {
    return ThemeData.lerp(a, b, t);
  }
}