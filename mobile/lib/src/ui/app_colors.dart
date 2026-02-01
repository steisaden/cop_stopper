
import 'package:flutter/material.dart';

/// AppColors defines the complete color system for the Police Interaction Assistant app
/// following Material Design 3 principles with custom police-interaction specific colors.
/// Supports both light and dark themes with proper contrast ratios for accessibility.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary palette - Figma design system colors
  static const Color primary = Color(0xFF030213); // Very dark blue/black from Figma
  static const Color primaryVariant = Color(0xFF1a1a1a);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFF1F2F6); // Light blue-gray
  static const Color onPrimaryContainer = Color(0xFF030213);

  // Secondary palette - Light gray theme from Figma
  static const Color secondary = Color(0xFFF1F2F6); // Light grayish blue
  static const Color secondaryVariant = Color(0xFFE9EBEF);
  static const Color onSecondary = Color(0xFF030213);
  static const Color secondaryContainer = Color(0xFFECECF0);
  static const Color onSecondaryContainer = Color(0xFF717182);

  // Status colors for different states - using high contrast colors
  static const Color success = Color(0xFF2E7D32); // Green 800 for good contrast
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFE8F5E8);
  static const Color onSuccessContainer = Color(0xFF1B5E20);

  static const Color warning = Color(0xFFEF6C00); // Orange 800 for good contrast
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color onWarningContainer = Color(0xFFE65100);

  static const Color error = Color(0xFFD32F2F); // Red 700 for good contrast
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onErrorContainer = Color(0xFFB71C1C);

  // Recording specific colors
  static const Color recording = Color(0xFFD32F2F); // Same as error for consistency
  static const Color onRecording = Color(0xFFFFFFFF);
  static const Color recordingContainer = Color(0xFFFFEBEE);
  static const Color onRecordingContainer = Color(0xFFB71C1C);

  // Surface colors for cards and backgrounds - Figma design system
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF030213);
  static const Color surfaceVariant = Color(0xFFF3F3F5); // Input background from Figma - EXACT
  static const Color onSurfaceVariant = Color(0xFF717182); // Muted foreground from Figma - EXACT
  static const Color surfaceTint = primary;

  // Background colors - Figma design system
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF030213);

  // Card and container colors - Figma design system
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color onCard = Color(0xFF030213);

  // Outline colors for borders and dividers - Figma design system
  static const Color outline = Color(0x1A000000); // rgba(0, 0, 0, 0.1) from Figma
  static const Color outlineVariant = Color(0xFFECECF0); // Muted color from Figma

  // Dark theme colors - Figma design system (oklch values converted to RGB)
  static const Color darkPrimary = Color(0xFFFFFFFF); // White in dark mode
  static const Color darkOnPrimary = Color(0xFF252525); // oklch(0.145 0 0) - EXACT Figma
  static const Color darkPrimaryContainer = Color(0xFF454545); // oklch(0.269 0 0) - EXACT Figma
  static const Color darkOnPrimaryContainer = Color(0xFFFFFFFF);

  static const Color darkSecondary = Color(0xFF454545); // oklch(0.269 0 0) - EXACT Figma
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkSecondaryContainer = Color(0xFF343434); // oklch(0.205 0 0) - EXACT Figma
  static const Color darkOnSecondaryContainer = Color(0xFFFFFFFF);

  static const Color darkSurface = Color(0xFF343434); // oklch(0.205 0 0) - EXACT Figma
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkSurfaceVariant = Color(0xFF454545); // oklch(0.269 0 0) - EXACT Figma
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);

  static const Color darkBackground = Color(0xFF252525); // oklch(0.145 0 0) - EXACT Figma
  static const Color darkOnBackground = Color(0xFFFFFFFF);

  static const Color darkCardBackground = Color(0xFF454545); // oklch(0.269 0 0) - EXACT Figma
  static const Color darkOnCard = Color(0xFFFFFFFF);

  static const Color darkOutline = Color(0xFF454545); // oklch(0.269 0 0) - EXACT Figma
  static const Color darkOutlineVariant = Color(0xFF343434); // oklch(0.205 0 0) - EXACT Figma

  // Emergency and critical colors
  static const Color emergency = Color(0xFFD32F2F);
  static const Color onEmergency = Color(0xFFFFFFFF);
  static const Color emergencyContainer = Color(0xFFFFCDD2);
  static const Color onEmergencyContainer = Color(0xFF8B0000);

  // Fact-checking colors
  static const Color factCheckTrue = success;
  static const Color factCheckQuestionable = warning;
  static const Color factCheckFalse = error;
  static const Color factCheckUnverified = Color(0xFF9E9E9E);

  // Glass morphism effect colors - Figma design system
  static const Color glassMorphismBackground = Color(0xB3FFFFFF); // 70% white opacity
  static const Color darkGlassMorphismBackground = Color(0xB31a1a1a); // 70% dark opacity
  
  // Additional Figma design system colors - EXACT VALUES
  static const Color inputBackground = Color(0xFFF3F3F5); // #f3f3f5 - EXACT Figma input bg
  static const Color switchBackground = Color(0xFFCBCED4); // #cbced4 - EXACT Figma switch bg
  static const Color muted = Color(0xFFECECF0); // #ececf0 - EXACT Figma muted
  static const Color mutedForeground = Color(0xFF717182); // #717182 - EXACT Figma muted fg
  static const Color accent = Color(0xFFE9EBEF); // Accent color from Figma
  static const Color accentForeground = Color(0xFF030213); // Accent foreground from Figma

  /// Returns the appropriate color scheme for the given brightness
  static ColorScheme colorScheme(Brightness brightness) {
    return brightness == Brightness.light ? lightColorScheme : darkColorScheme;
  }

  /// Light theme color scheme - Figma design system
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    tertiary: warning,
    onTertiary: onWarning,
    tertiaryContainer: warningContainer,
    onTertiaryContainer: onWarningContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceVariant,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: darkSurface,
    onInverseSurface: darkOnSurface,
    inversePrimary: darkPrimary,
    surfaceTint: primary,
  );

  /// Dark theme color scheme - Figma design system
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: darkPrimary,
    onPrimary: darkOnPrimary,
    primaryContainer: darkPrimaryContainer,
    onPrimaryContainer: darkOnPrimaryContainer,
    secondary: darkSecondary,
    onSecondary: darkOnSecondary,
    secondaryContainer: darkSecondaryContainer,
    onSecondaryContainer: darkOnSecondaryContainer,
    tertiary: warning,
    onTertiary: onWarning,
    tertiaryContainer: warningContainer,
    onTertiaryContainer: onWarningContainer,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceContainerHighest: darkSurfaceVariant,
    onSurfaceVariant: darkOnSurfaceVariant,
    outline: darkOutline,
    outlineVariant: darkOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: surface,
    onInverseSurface: onSurface,
    inversePrimary: primary,
    surfaceTint: darkPrimary,
  );

  /// Validates color contrast ratios for accessibility compliance
  static bool hasValidContrast(Color foreground, Color background) {
    final double luminance1 = foreground.computeLuminance();
    final double luminance2 = background.computeLuminance();
    final double ratio = (luminance1 > luminance2)
        ? (luminance1 + 0.05) / (luminance2 + 0.05)
        : (luminance2 + 0.05) / (luminance1 + 0.05);
    return ratio >= 4.5; // WCAG AA standard
  }
}
