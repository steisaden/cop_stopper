import 'package:flutter/material.dart';

/// AppSpacing defines the complete spacing system for the Police Interaction Assistant app
/// using 8pt grid methodology for consistent and harmonious layouts.
/// Provides responsive spacing that adapts to different screen sizes and accessibility needs.
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  // Base unit - 8pt grid system
  static const double _baseUnit = 8.0;

  // Spacing scale based on 8pt grid
  static const double none = 0.0;
  static const double xs = _baseUnit * 0.5; // 4pt
  static const double sm = _baseUnit * 1.0; // 8pt
  static const double md = _baseUnit * 2.0; // 16pt
  static const double lg = _baseUnit * 3.0; // 24pt
  static const double xl = _baseUnit * 4.0; // 32pt
  static const double xxl = _baseUnit * 6.0; // 48pt
  static const double xxxl = _baseUnit * 8.0; // 64pt

  // Component-specific spacing - EXACT Figma design system values
  static const double cardPadding = lg; // 24pt - EXACT Figma card padding
  static const double cardMargin = sm; // 8pt
  static const double cardRadius = 10.0; // EXACT Figma radius (0.625rem)
  static const double buttonPadding = md; // 16pt
  static const double buttonRadius = 10.0; // EXACT Figma radius (0.625rem)
  static const double iconPadding = sm; // 8pt
  static const double listItemPadding = md; // 16pt
  static const double sectionSpacing = lg; // 24pt
  static const double screenPadding = md; // 16pt

  // Figma-specific spacing values - EXACT VALUES
  static const double figmaRadius = 10.0; // EXACT 0.625rem from Figma
  static const double figmaCardPadding = lg; // EXACT 24pt from Figma

  // Design reference border radius values (Tailwind CSS equivalents)
  static const double radius2XL = 16.0; // rounded-2xl (design ref cards)
  static const double radiusFull = 999.0; // rounded-full (pills/chips)

  // Navigation specific spacing
  static const double bottomNavHeight = _baseUnit * 10.0; // 80pt
  static const double bottomNavPadding = sm; // 8pt
  static const double tabIconSize = _baseUnit * 3.0; // 24pt
  static const double tabLabelSpacing = xs; // 4pt

  // Recording interface spacing
  static const double recordButtonSize = _baseUnit * 10.0; // 80pt
  static const double recordButtonMargin = lg; // 24pt
  static const double cameraPreviewRadius = md; // 16pt
  static const double controlsSpacing = md; // 16pt
  static const double statusBarHeight = _baseUnit * 7.0; // 56pt

  // Settings interface spacing
  static const double settingsCardSpacing = md; // 16pt
  static const double settingsItemSpacing = lg; // 24pt
  static const double settingsSectionSpacing = xl; // 32pt
  static const double toggleSwitchPadding = sm; // 8pt

  // Emergency interface spacing
  static const double emergencyButtonSize = _baseUnit * 12.0; // 96pt
  static const double emergencyButtonMargin = xl; // 32pt
  static const double emergencySpacing = lg; // 24pt

  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  /// Returns responsive spacing based on screen width
  static double responsive(
    BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= desktopBreakpoint && desktop != null) {
      return desktop;
    } else if (screenWidth >= tabletBreakpoint && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }

  /// Returns scaled spacing based on accessibility settings
  static double scaled(BuildContext context, double spacing) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double textScaleFactor = mediaQuery.textScaleFactor;

    // Scale spacing proportionally with text, but with limits
    final double scaleFactor = (textScaleFactor - 1.0) * 0.5 + 1.0;
    return spacing * scaleFactor.clamp(1.0, 1.5);
  }

  /// Horizontal spacing widgets
  static Widget horizontalSpaceXS = const SizedBox(width: xs);
  static Widget horizontalSpaceSM = const SizedBox(width: sm);
  static Widget horizontalSpaceMD = const SizedBox(width: md);
  static Widget horizontalSpaceLG = const SizedBox(width: lg);
  static Widget horizontalSpaceXL = const SizedBox(width: xl);
  static Widget horizontalSpaceXXL = const SizedBox(width: xxl);

  /// Vertical spacing widgets
  static Widget verticalSpaceXS = const SizedBox(height: xs);
  static Widget verticalSpaceSM = const SizedBox(height: sm);
  static Widget verticalSpaceMD = const SizedBox(height: md);
  static Widget verticalSpaceLG = const SizedBox(height: lg);
  static Widget verticalSpaceXL = const SizedBox(height: xl);
  static Widget verticalSpaceXXL = const SizedBox(height: xxl);

  /// Edge insets for common use cases
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  static const EdgeInsets horizontalPaddingXS =
      EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalPaddingSM =
      EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalPaddingMD =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalPaddingLG =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalPaddingXL =
      EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalPaddingXS =
      EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalPaddingSM =
      EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalPaddingMD =
      EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalPaddingLG =
      EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalPaddingXL =
      EdgeInsets.symmetric(vertical: xl);

  /// Screen-specific padding with safe area consideration
  static EdgeInsets screenPaddingWithSafeArea(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      left: screenPadding,
      right: screenPadding,
      top: screenPadding + mediaQuery.padding.top,
      bottom: screenPadding + mediaQuery.padding.bottom,
    );
  }

  /// Bottom navigation safe area padding
  static EdgeInsets bottomNavPaddingWithSafeArea(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      left: bottomNavPadding,
      right: bottomNavPadding,
      top: bottomNavPadding,
      bottom: bottomNavPadding + mediaQuery.padding.bottom,
    );
  }

  /// Card spacing with responsive adjustments
  static EdgeInsets cardPaddingResponsive(BuildContext context) {
    return EdgeInsets.all(responsive(
      context,
      mobile: cardPadding,
      tablet: cardPadding * 1.5,
      desktop: cardPadding * 2.0,
    ));
  }

  /// List item spacing with accessibility scaling
  static EdgeInsets listItemPaddingScaled(BuildContext context) {
    return EdgeInsets.all(scaled(context, listItemPadding));
  }

  /// Border radius values - EXACT Figma design system (all use 10px)
  static const BorderRadius radiusXS =
      BorderRadius.all(Radius.circular(figmaRadius)); // Use Figma radius
  static const BorderRadius radiusSM =
      BorderRadius.all(Radius.circular(figmaRadius)); // Use Figma radius
  static const BorderRadius radiusMD =
      BorderRadius.all(Radius.circular(figmaRadius)); // Use Figma radius
  static const BorderRadius radiusLG =
      BorderRadius.all(Radius.circular(figmaRadius)); // Use Figma radius
  static const BorderRadius radiusXL =
      BorderRadius.all(Radius.circular(figmaRadius)); // Use Figma radius
  static const BorderRadius radiusFigma =
      BorderRadius.all(Radius.circular(figmaRadius)); // EXACT Figma

  /// Card border radius - EXACT Figma design system (10px)
  static const BorderRadius cardBorderRadius = radiusFigma;

  /// Button border radius - EXACT Figma design system (10px)
  static const BorderRadius buttonBorderRadius = radiusFigma;

  /// Camera preview border radius
  static const BorderRadius cameraPreviewBorderRadius = radiusMD;

  /// Validates spacing consistency (for testing)
  static bool isValidSpacing(double spacing) {
    // Check if spacing follows 8pt grid (allowing for 4pt half-steps)
    return (spacing % xs) == 0;
  }

  /// Returns the nearest valid spacing value
  static double snapToGrid(double spacing) {
    return (spacing / xs).round() * xs;
  }

  /// Animation durations following Material Design guidelines
  static const Duration animationDurationShort = Duration(milliseconds: 150);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);

  /// Elevation values for Material Design 3
  static const double elevationNone = 0.0;
  static const double elevationLow = 1.0;
  static const double elevationMedium = 3.0;
  static const double elevationHigh = 6.0;
  static const double elevationVeryHigh = 12.0;
}
