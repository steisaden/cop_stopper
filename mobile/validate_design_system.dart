import 'package:flutter/material.dart';
import 'lib/src/ui/figma_design_tokens.dart';
import 'lib/src/ui/app_colors.dart';
import 'lib/src/ui/app_text_styles.dart';
import 'lib/src/ui/app_spacing.dart';
import 'lib/src/ui/design_system_validator.dart';

void main() {
  print('=== Figma Design System Validation ===\n');

  // Test color validation
  print('1. Color Validation:');
  print('   Primary color: ${AppColors.primary == const Color(0xFF030213) ? "✓" : "✗"} (${AppColors.primary})');
  print('   Input background: ${AppColors.inputBackground == const Color(0xFFF3F3F5) ? "✓" : "✗"} (${AppColors.inputBackground})');
  print('   Switch background: ${AppColors.switchBackground == const Color(0xFFCBCED4) ? "✓" : "✗"} (${AppColors.switchBackground})');
  print('   Dark background: ${AppColors.darkBackground == const Color(0xFF252525) ? "✓" : "✗"} (${AppColors.darkBackground})');
  print('   Dark surface: ${AppColors.darkSurface == const Color(0xFF343434) ? "✓" : "✗"} (${AppColors.darkSurface})');
  print('   Dark card: ${AppColors.darkCardBackground == const Color(0xFF454545) ? "✓" : "✗"} (${AppColors.darkCardBackground})');

  // Test typography validation
  print('\n2. Typography Validation:');
  print('   Title medium font weight: ${AppTextStyles.titleMedium.fontWeight == FontWeight.w500 ? "✓" : "✗"} (${AppTextStyles.titleMedium.fontWeight})');
  print('   Body large font weight: ${AppTextStyles.bodyLarge.fontWeight == FontWeight.w400 ? "✓" : "✗"} (${AppTextStyles.bodyLarge.fontWeight})');
  print('   Title medium line height: ${AppTextStyles.titleMedium.height == 1.5 ? "✓" : "✗"} (${AppTextStyles.titleMedium.height})');
  print('   Body large line height: ${AppTextStyles.bodyLarge.height == 1.5 ? "✓" : "✗"} (${AppTextStyles.bodyLarge.height})');

  // Test spacing validation
  print('\n3. Spacing Validation:');
  print('   Figma radius: ${AppSpacing.figmaRadius == 10.0 ? "✓" : "✗"} (${AppSpacing.figmaRadius})');
  print('   Card radius: ${AppSpacing.cardRadius == 10.0 ? "✓" : "✗"} (${AppSpacing.cardRadius})');
  print('   Button radius: ${AppSpacing.buttonRadius == 10.0 ? "✓" : "✗"} (${AppSpacing.buttonRadius})');
  print('   Card padding: ${AppSpacing.cardPadding == 24.0 ? "✓" : "✗"} (${AppSpacing.cardPadding})');

  // Test FigmaDesignTokens validation methods
  print('\n4. FigmaDesignTokens Validation:');
  print('   Primary color validation: ${FigmaDesignTokens.validateColor(AppColors.primary, 'primary') ? "✓" : "✗"}');
  print('   Input background validation: ${FigmaDesignTokens.validateColor(AppColors.inputBackground, 'inputBackground') ? "✓" : "✗"}');
  print('   Border radius validation: ${FigmaDesignTokens.validateBorderRadius(10.0) ? "✓" : "✗"}');
  print('   Medium font weight validation: ${FigmaDesignTokens.validateFontWeight(FontWeight.w500, 'medium') ? "✓" : "✗"}');
  print('   Normal font weight validation: ${FigmaDesignTokens.validateFontWeight(FontWeight.w400, 'normal') ? "✓" : "✗"}');

  // Test DesignSystemValidator
  print('\n5. Complete Design System Validation:');
  final results = DesignSystemValidator.validateAll();
  results.forEach((key, value) {
    print('   $key: ${value ? "✓" : "✗"}');
  });

  // Summary
  final allPassed = results.values.every((result) => result);
  print('\n=== Summary ===');
  print('Design System Compliance: ${allPassed ? "✓ PASSED" : "✗ FAILED"}');
  
  if (allPassed) {
    print('All Figma design specifications have been successfully implemented!');
  } else {
    print('Some design specifications need attention.');
  }
}