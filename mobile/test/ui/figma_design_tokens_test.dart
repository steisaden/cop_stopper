import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/figma_design_tokens.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/app_text_styles.dart';
import 'package:mobile/src/ui/app_spacing.dart';

void main() {
  group('Figma Design Tokens Validation', () {
    group('Color Validation', () {
      test('Primary color matches exact Figma specification', () {
        expect(
          FigmaDesignTokens.validateColor(AppColors.primary, 'primary'),
          isTrue,
          reason: 'Primary color should match #030213 from Figma',
        );
      });

      test('Input background matches exact Figma specification', () {
        expect(
          FigmaDesignTokens.validateColor(AppColors.inputBackground, 'inputBackground'),
          isTrue,
          reason: 'Input background should match #f3f3f5 from Figma',
        );
      });

      test('Switch background matches exact Figma specification', () {
        expect(
          FigmaDesignTokens.validateColor(AppColors.switchBackground, 'switchBackground'),
          isTrue,
          reason: 'Switch background should match #cbced4 from Figma',
        );
      });

      test('Muted color matches exact Figma specification', () {
        expect(
          FigmaDesignTokens.validateColor(AppColors.muted, 'muted'),
          isTrue,
          reason: 'Muted color should match #ececf0 from Figma',
        );
      });

      test('Muted foreground matches exact Figma specification', () {
        expect(
          FigmaDesignTokens.validateColor(AppColors.mutedForeground, 'mutedForeground'),
          isTrue,
          reason: 'Muted foreground should match #717182 from Figma',
        );
      });

      test('Dark background matches exact Figma oklch specification', () {
        expect(
          FigmaDesignTokens.validateColor(AppColors.darkBackground, 'darkBackground'),
          isTrue,
          reason: 'Dark background should match oklch(0.145 0 0) = #252525 from Figma',
        );
      });

      test('Dark surface matches exact Figma oklch specification', () {
        expect(
          FigmaDesignTokens.validateColor(AppColors.darkSurface, 'darkSurface'),
          isTrue,
          reason: 'Dark surface should match oklch(0.205 0 0) = #343434 from Figma',
        );
      });

      test('Dark card matches exact Figma oklch specification', () {
        expect(
          FigmaDesignTokens.validateColor(AppColors.darkCardBackground, 'darkCard'),
          isTrue,
          reason: 'Dark card should match oklch(0.269 0 0) = #454545 from Figma',
        );
      });
    });

    group('Typography Validation', () {
      test('Medium font weight matches exact Figma specification', () {
        expect(
          FigmaDesignTokens.validateFontWeight(FontWeight.w500, 'medium'),
          isTrue,
          reason: 'Medium font weight should be exactly 500 from Figma',
        );
      });

      test('Normal font weight matches exact Figma specification', () {
        expect(
          FigmaDesignTokens.validateFontWeight(FontWeight.w400, 'normal'),
          isTrue,
          reason: 'Normal font weight should be exactly 400 from Figma',
        );
      });

      test('Base font size matches exact Figma specification', () {
        expect(
          FigmaDesignTokens.validateFontSize(16.0, 'base'),
          isTrue,
          reason: 'Base font size should be exactly 16px from Figma',
        );
      });

      test('Title medium uses correct Figma font weight', () {
        expect(
          AppTextStyles.titleMedium.fontWeight,
          equals(FontWeight.w500),
          reason: 'Title medium should use font weight 500 from Figma',
        );
      });

      test('Body large uses correct Figma font weight', () {
        expect(
          AppTextStyles.bodyLarge.fontWeight,
          equals(FontWeight.w400),
          reason: 'Body large should use font weight 400 from Figma',
        );
      });

      test('All text styles use correct Figma line height', () {
        expect(AppTextStyles.titleMedium.height, equals(1.5));
        expect(AppTextStyles.bodyLarge.height, equals(1.5));
        expect(AppTextStyles.headlineLarge.height, equals(1.5));
      });
    });

    group('Border Radius Validation', () {
      test('Figma radius matches exact specification', () {
        expect(
          FigmaDesignTokens.validateBorderRadius(AppSpacing.figmaRadius),
          isTrue,
          reason: 'Figma radius should be exactly 10px (0.625rem)',
        );
      });

      test('Card border radius matches Figma specification', () {
        expect(
          AppSpacing.cardRadius,
          equals(10.0),
          reason: 'Card radius should be exactly 10px from Figma',
        );
      });

      test('Button border radius matches Figma specification', () {
        expect(
          AppSpacing.buttonRadius,
          equals(10.0),
          reason: 'Button radius should be exactly 10px from Figma',
        );
      });

      test('All border radius values use Figma specification', () {
        expect(AppSpacing.cardBorderRadius.topLeft.x, equals(10.0));
        expect(AppSpacing.buttonBorderRadius.topLeft.x, equals(10.0));
        expect(AppSpacing.radiusFigma.topLeft.x, equals(10.0));
      });
    });

    group('Spacing Validation', () {
      test('Card padding matches Figma specification', () {
        expect(
          FigmaDesignTokens.validateSpacing(AppSpacing.cardPadding, 'lg'),
          isTrue,
          reason: 'Card padding should be 24px from Figma',
        );
      });

      test('Medium spacing matches Figma specification', () {
        expect(
          FigmaDesignTokens.validateSpacing(AppSpacing.md, 'md'),
          isTrue,
          reason: 'Medium spacing should be 16px from Figma',
        );
      });
    });

    group('Component Specifications', () {
      test('Button style matches Figma specifications', () {
        final buttonStyle = FigmaDesignTokens.getButtonStyle(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
        );

        // Test button styling properties
        expect(buttonStyle, isNotNull);
        expect(buttonStyle.backgroundColor?.resolve({}), equals(AppColors.primary));
        expect(buttonStyle.foregroundColor?.resolve({}), equals(AppColors.onPrimary));
      });

      test('Card decoration matches Figma specifications', () {
        final cardDecoration = FigmaDesignTokens.getCardDecoration();

        expect(cardDecoration.color, equals(AppColors.background));
        expect(cardDecoration.borderRadius, isA<BorderRadius>());
        expect(cardDecoration.border, isNotNull);
      });

      test('Input decoration matches Figma specifications', () {
        final inputDecoration = FigmaDesignTokens.getInputDecoration(
          labelText: 'Test Label',
        );

        expect(inputDecoration.filled, isTrue);
        expect(inputDecoration.fillColor, equals(AppColors.inputBackground));
        expect(inputDecoration.labelText, equals('Test Label'));
      });
    });

    group('Design System Compliance', () {
      test('Color compliance report validates correctly', () {
        final colorsToCheck = [
          AppColors.primary,
          AppColors.inputBackground,
          AppColors.switchBackground,
        ];

        final report = FigmaDesignTokens.generateComplianceReport(
          colorsToCheck: colorsToCheck,
          borderRadiiToCheck: [10.0, 10.0],
          fontWeightsToCheck: [FontWeight.w400, FontWeight.w500],
        );

        expect(report['color_0'], isTrue, reason: 'Primary color should be compliant');
        expect(report['color_1'], isTrue, reason: 'Input background should be compliant');
        expect(report['color_2'], isTrue, reason: 'Switch background should be compliant');
        expect(report['borderRadius_0'], isTrue, reason: 'Border radius should be compliant');
        expect(report['fontWeight_0'], isTrue, reason: 'Normal font weight should be compliant');
        expect(report['fontWeight_1'], isTrue, reason: 'Medium font weight should be compliant');
      });

      test('Non-compliant values are detected', () {
        final nonCompliantColors = [
          const Color(0xFF123456), // Random color not in Figma
        ];

        final report = FigmaDesignTokens.generateComplianceReport(
          colorsToCheck: nonCompliantColors,
          borderRadiiToCheck: [8.0], // Wrong radius
          fontWeightsToCheck: [FontWeight.w600], // Wrong weight
        );

        expect(report['color_0'], isFalse, reason: 'Non-Figma color should not be compliant');
        expect(report['borderRadius_0'], isFalse, reason: 'Wrong radius should not be compliant');
        expect(report['fontWeight_0'], isFalse, reason: 'Wrong font weight should not be compliant');
      });
    });

    group('Dark Mode Validation', () {
      test('Dark mode colors match exact Figma oklch values', () {
        // Test that dark mode colors are correctly converted from oklch
        expect(AppColors.darkBackground, equals(const Color(0xFF252525)));
        expect(AppColors.darkSurface, equals(const Color(0xFF343434)));
        expect(AppColors.darkCardBackground, equals(const Color(0xFF454545)));
      });

      test('Dark mode input decoration uses correct colors', () {
        final darkInputDecoration = FigmaDesignTokens.getInputDecoration(
          isDark: true,
        );

        expect(darkInputDecoration.fillColor, equals(FigmaDesignTokens.darkSurface));
      });

      test('Dark mode card decoration uses correct colors', () {
        final darkCardDecoration = FigmaDesignTokens.getCardDecoration(
          isDark: true,
        );

        expect(darkCardDecoration.color, equals(FigmaDesignTokens.darkCard));
      });
    });
  });
}