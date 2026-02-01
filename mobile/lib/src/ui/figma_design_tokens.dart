import 'package:flutter/material.dart';

/// FigmaDesignTokens contains the exact design specifications from Figma
/// to ensure pixel-perfect implementation across all components and screens.
/// All values are derived directly from the Figma design system.
class FigmaDesignTokens {
  // Private constructor to prevent instantiation
  FigmaDesignTokens._();

  // EXACT FIGMA COLOR VALUES
  // Primary colors from Figma CSS specifications
  static const Color primary = Color(0xFF030213); // #030213 - exact Figma primary
  static const Color background = Color(0xFFFFFFFF); // #ffffff - exact Figma background
  static const Color inputBackground = Color(0xFFF3F3F5); // #f3f3f5 - exact Figma input bg
  static const Color switchBackground = Color(0xFFCBCED4); // #cbced4 - exact Figma switch bg
  static const Color muted = Color(0xFFECECF0); // #ececf0 - exact Figma muted
  static const Color mutedForeground = Color(0xFF717182); // #717182 - exact Figma muted fg

  // Dark mode colors from Figma (oklch values converted to RGB)
  // oklch(0.145 0 0) = #252525
  static const Color darkBackground = Color(0xFF252525);
  // oklch(0.205 0 0) = #343434  
  static const Color darkSurface = Color(0xFF343434);
  // oklch(0.269 0 0) = #454545
  static const Color darkCard = Color(0xFF454545);

  // Complete color token map with exact Figma values
  static const Map<String, Color> colors = {
    // Light theme colors
    'primary': primary,
    'background': background,
    'inputBackground': inputBackground,
    'switchBackground': switchBackground,
    'muted': muted,
    'mutedForeground': mutedForeground,
    
    // Dark theme colors (oklch converted)
    'darkBackground': darkBackground,
    'darkSurface': darkSurface,
    'darkCard': darkCard,
    
    // Additional Figma colors
    'accent': Color(0xFFE9EBEF), // Figma accent color
    'accentForeground': Color(0xFF030213), // Figma accent foreground
    'border': Color(0x1A000000), // rgba(0, 0, 0, 0.1) - Figma border
  };

  // EXACT FIGMA TYPOGRAPHY VALUES
  // Font sizes from Figma design system
  static const Map<String, double> fontSizes = {
    'xs': 12.0,    // Figma xs
    'sm': 14.0,    // Figma sm
    'base': 16.0,  // Figma base (16px)
    'lg': 18.0,    // Figma lg
    'xl': 20.0,    // Figma xl
    '2xl': 24.0,   // Figma 2xl
  };

  // Font weights from Figma specifications
  static const Map<String, FontWeight> fontWeights = {
    'normal': FontWeight.w400,  // Exact Figma normal weight
    'medium': FontWeight.w500,  // Exact Figma medium weight
  };

  // Line height from Figma
  static const double lineHeight = 1.5; // Exact Figma line height

  // EXACT FIGMA SPACING VALUES
  // Spacing scale from Figma design system
  static const Map<String, double> spacing = {
    'xs': 4.0,   // Figma xs spacing
    'sm': 8.0,   // Figma sm spacing
    'md': 16.0,  // Figma md spacing
    'lg': 24.0,  // Figma lg spacing
    'xl': 32.0,  // Figma xl spacing
  };

  // EXACT FIGMA BORDER RADIUS
  // Border radius from Figma (10px = 0.625rem)
  static const double radius = 10.0; // Exact Figma border radius

  // Border radius map for consistency
  static const Map<String, double> borderRadius = {
    'default': radius,
    'card': radius,
    'button': radius,
    'input': radius,
  };

  // FIGMA COMPONENT SPECIFICATIONS
  
  // Button specifications from Figma
  static const Map<String, dynamic> button = {
    'borderRadius': radius,
    'paddingHorizontal': 16.0,
    'paddingVertical': 12.0,
    'fontWeight': FontWeight.w500,
    'fontSize': 16.0,
  };

  // Card specifications from Figma
  static const Map<String, dynamic> card = {
    'borderRadius': radius,
    'padding': 24.0, // Exact Figma card padding
    'backgroundColor': background,
    'borderColor': Color(0x1A000000), // rgba(0, 0, 0, 0.1)
  };

  // Input specifications from Figma
  static const Map<String, dynamic> input = {
    'backgroundColor': inputBackground,
    'borderRadius': radius,
    'borderColor': Color(0xFFE5E7EB), // Figma input border
    'focusBorderColor': primary,
    'padding': 16.0,
  };

  // Switch specifications from Figma
  static const Map<String, dynamic> switchComponent = {
    'backgroundColor': switchBackground,
    'activeColor': primary,
    'thumbColor': Color(0xFFFFFFFF),
  };

  // VALIDATION METHODS
  
  /// Validates if a color matches the exact Figma specification
  static bool validateColor(Color color, String tokenName) {
    final Color? expectedColor = colors[tokenName];
    return expectedColor != null && color == expectedColor;
  }

  /// Validates if border radius matches Figma specification
  static bool validateBorderRadius(double radiusValue) {
    return radiusValue == radius;
  }

  /// Validates if font weight matches Figma specification
  static bool validateFontWeight(FontWeight weight, String weightName) {
    final FontWeight? expectedWeight = fontWeights[weightName];
    return expectedWeight != null && weight == expectedWeight;
  }

  /// Validates if font size matches Figma specification
  static bool validateFontSize(double size, String sizeName) {
    final double? expectedSize = fontSizes[sizeName];
    return expectedSize != null && size == expectedSize;
  }

  /// Validates if spacing matches Figma specification
  static bool validateSpacing(double spacingValue, String spacingName) {
    final double? expectedSpacing = spacing[spacingName];
    return expectedSpacing != null && spacingValue == expectedSpacing;
  }

  // HELPER METHODS FOR COMPONENT CREATION

  /// Returns exact Figma button styling
  static ButtonStyle getButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: button['paddingHorizontal'] as double,
        vertical: button['paddingVertical'] as double,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(button['borderRadius'] as double),
      ),
      textStyle: TextStyle(
        fontWeight: button['fontWeight'] as FontWeight,
        fontSize: button['fontSize'] as double,
      ),
    );
  }

  /// Returns exact Figma card decoration
  static BoxDecoration getCardDecoration({bool isDark = false}) {
    return BoxDecoration(
      color: isDark ? darkCard : (card['backgroundColor'] as Color),
      borderRadius: BorderRadius.circular(card['borderRadius'] as double),
      border: Border.all(
        color: card['borderColor'] as Color,
        width: 1.0,
      ),
    );
  }

  /// Returns exact Figma input decoration
  static InputDecoration getInputDecoration({
    String? labelText,
    String? hintText,
    bool isDark = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: isDark ? darkSurface : (input['backgroundColor'] as Color),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(input['borderRadius'] as double),
        borderSide: BorderSide(color: input['borderColor'] as Color),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(input['borderRadius'] as double),
        borderSide: BorderSide(color: input['borderColor'] as Color),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(input['borderRadius'] as double),
        borderSide: BorderSide(
          color: input['focusBorderColor'] as Color,
          width: 2.0,
        ),
      ),
      contentPadding: EdgeInsets.all(input['padding'] as double),
    );
  }

  // DESIGN SYSTEM COMPLIANCE REPORT

  /// Generates a compliance report for design system validation
  static Map<String, bool> generateComplianceReport({
    required List<Color> colorsToCheck,
    required List<double> borderRadiiToCheck,
    required List<FontWeight> fontWeightsToCheck,
  }) {
    final Map<String, bool> report = {};

    // Check colors
    for (int i = 0; i < colorsToCheck.length; i++) {
      final Color color = colorsToCheck[i];
      bool isCompliant = false;
      for (final String tokenName in colors.keys) {
        if (validateColor(color, tokenName)) {
          isCompliant = true;
          break;
        }
      }
      report['color_$i'] = isCompliant;
    }

    // Check border radii
    for (int i = 0; i < borderRadiiToCheck.length; i++) {
      report['borderRadius_$i'] = validateBorderRadius(borderRadiiToCheck[i]);
    }

    // Check font weights
    for (int i = 0; i < fontWeightsToCheck.length; i++) {
      final FontWeight weight = fontWeightsToCheck[i];
      bool isCompliant = false;
      for (final String weightName in fontWeights.keys) {
        if (validateFontWeight(weight, weightName)) {
          isCompliant = true;
          break;
        }
      }
      report['fontWeight_$i'] = isCompliant;
    }

    return report;
  }
}