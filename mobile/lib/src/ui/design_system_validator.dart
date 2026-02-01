import 'package:flutter/material.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/app_text_styles.dart';
import 'package:mobile/src/ui/app_spacing.dart';

/// DesignSystemValidator provides validation methods to ensure
/// the design system matches Figma specifications exactly.
class DesignSystemValidator {
  DesignSystemValidator._();

  /// Validates all critical design system components against Figma specs
  static Map<String, bool> validateAll() {
    final Map<String, bool> results = {};

    // Validate colors
    results['primary_color'] = _validatePrimaryColor();
    results['input_background'] = _validateInputBackground();
    results['switch_background'] = _validateSwitchBackground();
    results['dark_colors'] = _validateDarkColors();

    // Validate typography
    results['font_weights'] = _validateFontWeights();
    results['line_heights'] = _validateLineHeights();

    // Validate spacing
    results['border_radius'] = _validateBorderRadius();
    results['card_padding'] = _validateCardPadding();

    return results;
  }

  static bool _validatePrimaryColor() {
    return AppColors.primary == const Color(0xFF030213);
  }

  static bool _validateInputBackground() {
    return AppColors.inputBackground == const Color(0xFFF3F3F5);
  }

  static bool _validateSwitchBackground() {
    return AppColors.switchBackground == const Color(0xFFCBCED4);
  }

  static bool _validateDarkColors() {
    return AppColors.darkBackground == const Color(0xFF252525) &&
           AppColors.darkSurface == const Color(0xFF343434) &&
           AppColors.darkCardBackground == const Color(0xFF454545);
  }

  static bool _validateFontWeights() {
    return AppTextStyles.titleMedium.fontWeight == FontWeight.w500 &&
           AppTextStyles.bodyLarge.fontWeight == FontWeight.w400;
  }

  static bool _validateLineHeights() {
    return AppTextStyles.titleMedium.height == 1.5 &&
           AppTextStyles.bodyLarge.height == 1.5;
  }

  static bool _validateBorderRadius() {
    return AppSpacing.figmaRadius == 10.0 &&
           AppSpacing.cardRadius == 10.0 &&
           AppSpacing.buttonRadius == 10.0;
  }

  static bool _validateCardPadding() {
    return AppSpacing.cardPadding == 24.0;
  }
}