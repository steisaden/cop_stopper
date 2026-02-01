import 'package:flutter/material.dart';

/// AppTextStyles defines the complete typography system for the Police Interaction Assistant app
/// following Material Design 3 typography scale with responsive sizing and proper font weights.
/// Supports accessibility features including dynamic text sizing and high contrast modes.
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Base font family - System fonts like Figma design
  static const String fontFamily = 'System'; // Use system font for better consistency

  // Display styles - Large, prominent text (Figma design system)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48, // Reduced from 57 for better mobile experience
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: -0.25,
    height: 1.5, // EXACT Figma line height
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 36, // Reduced from 45
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 28, // Reduced from 36
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  // Headline styles - High-emphasis text (Figma design system)
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24, // 2xl from Figma - EXACT
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20, // xl from Figma - EXACT
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 18, // lg from Figma - EXACT
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  // Title styles - Medium-emphasis text (Figma design system)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18, // lg from Figma - EXACT
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16, // base from Figma - EXACT
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14, // sm from Figma - EXACT
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  // Label styles - Text for components (Figma design system)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14, // sm from Figma - EXACT
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12, // xs from Figma - EXACT
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500, // EXACT Figma medium weight (500)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  // Body styles - Regular text content (Figma design system)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, // base from Figma - EXACT
    fontWeight: FontWeight.w400, // EXACT Figma normal weight (400)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, // sm from Figma - EXACT
    fontWeight: FontWeight.w400, // EXACT Figma normal weight (400)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12, // xs from Figma - EXACT
    fontWeight: FontWeight.w400, // EXACT Figma normal weight (400)
    letterSpacing: 0,
    height: 1.5, // EXACT Figma line height
  );

  // Police interaction specific styles
  static const TextStyle emergencyButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.22,
  );

  static const TextStyle recordingTimer = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.17,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle transcriptionText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static const TextStyle speakerLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.33,
  );

  static const TextStyle factCheckLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  static const TextStyle navigationLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
    height: 1.33,
  );

  static const TextStyle settingsLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.50,
  );

  static const TextStyle settingsDescription = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  // Legacy style aliases for backward compatibility
  static const TextStyle headline1 = displayLarge;
  static const TextStyle headline2 = headlineLarge;
  static const TextStyle headline3 = headlineMedium;
  static const TextStyle headline4 = headlineSmall;
  static const TextStyle body1 = bodyLarge;
  static const TextStyle body2 = bodyMedium;
  static const TextStyle caption = bodySmall;
  static const TextStyle button = labelLarge;

  // Responsive text scaling
  static double getScaleFactor(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double textScaleFactor = mediaQuery.textScaleFactor;
    
    // Clamp text scale factor to prevent UI breaking
    return textScaleFactor.clamp(0.8, 2.0);
  }

  /// Returns a scaled version of the given text style based on device settings
  static TextStyle scaled(TextStyle style, BuildContext context) {
    final double scaleFactor = getScaleFactor(context);
    return style.copyWith(fontSize: style.fontSize! * scaleFactor);
  }

  /// Returns the complete text theme for Material Design 3
  static TextTheme textTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: colorScheme.onSurface),
      displayMedium: displayMedium.copyWith(color: colorScheme.onSurface),
      displaySmall: displaySmall.copyWith(color: colorScheme.onSurface),
      headlineLarge: headlineLarge.copyWith(color: colorScheme.onSurface),
      headlineMedium: headlineMedium.copyWith(color: colorScheme.onSurface),
      headlineSmall: headlineSmall.copyWith(color: colorScheme.onSurface),
      titleLarge: titleLarge.copyWith(color: colorScheme.onSurface),
      titleMedium: titleMedium.copyWith(color: colorScheme.onSurface),
      titleSmall: titleSmall.copyWith(color: colorScheme.onSurface),
      labelLarge: labelLarge.copyWith(color: colorScheme.onSurface),
      labelMedium: labelMedium.copyWith(color: colorScheme.onSurfaceVariant),
      labelSmall: labelSmall.copyWith(color: colorScheme.onSurfaceVariant),
      bodyLarge: bodyLarge.copyWith(color: colorScheme.onSurface),
      bodyMedium: bodyMedium.copyWith(color: colorScheme.onSurface),
      bodySmall: bodySmall.copyWith(color: colorScheme.onSurfaceVariant),
    );
  }

  /// High contrast text theme for accessibility
  static TextTheme highContrastTextTheme(ColorScheme colorScheme) {
    return textTheme(colorScheme).copyWith(
      displayLarge: displayLarge.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      displayMedium: displayMedium.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      displaySmall: displaySmall.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      headlineLarge: headlineLarge.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: headlineMedium.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: headlineSmall.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: titleLarge.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: titleMedium.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: titleSmall.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: bodyLarge.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: bodyMedium.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: bodySmall.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Validates text contrast for accessibility compliance
  static bool hasValidTextContrast(Color textColor, Color backgroundColor) {
    final double luminance1 = textColor.computeLuminance();
    final double luminance2 = backgroundColor.computeLuminance();
    final double ratio = (luminance1 > luminance2)
        ? (luminance1 + 0.05) / (luminance2 + 0.05)
        : (luminance2 + 0.05) / (luminance1 + 0.05);
    return ratio >= 4.5; // WCAG AA standard for normal text
  }

  /// Validates large text contrast for accessibility compliance
  static bool hasValidLargeTextContrast(Color textColor, Color backgroundColor) {
    final double luminance1 = textColor.computeLuminance();
    final double luminance2 = backgroundColor.computeLuminance();
    final double ratio = (luminance1 > luminance2)
        ? (luminance1 + 0.05) / (luminance2 + 0.05)
        : (luminance2 + 0.05) / (luminance1 + 0.05);
    return ratio >= 3.0; // WCAG AA standard for large text (18pt+ or 14pt+ bold)
  }
}