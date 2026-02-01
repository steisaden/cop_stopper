import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/app_text_styles.dart';
import 'package:mobile/src/ui/app_colors.dart';

void main() {
  group('AppTextStyles', () {
    group('Typography Scale', () {
      test('should have correct display styles', () {
        expect(AppTextStyles.displayLarge.fontSize, 57);
        expect(AppTextStyles.displayLarge.fontWeight, FontWeight.w400);
        expect(AppTextStyles.displayLarge.letterSpacing, -0.25);
        expect(AppTextStyles.displayLarge.height, 1.12);

        expect(AppTextStyles.displayMedium.fontSize, 45);
        expect(AppTextStyles.displayMedium.fontWeight, FontWeight.w400);
        expect(AppTextStyles.displayMedium.letterSpacing, 0);
        expect(AppTextStyles.displayMedium.height, 1.16);

        expect(AppTextStyles.displaySmall.fontSize, 36);
        expect(AppTextStyles.displaySmall.fontWeight, FontWeight.w400);
        expect(AppTextStyles.displaySmall.letterSpacing, 0);
        expect(AppTextStyles.displaySmall.height, 1.22);
      });

      test('should have correct headline styles', () {
        expect(AppTextStyles.headlineLarge.fontSize, 32);
        expect(AppTextStyles.headlineLarge.fontWeight, FontWeight.w400);
        expect(AppTextStyles.headlineLarge.letterSpacing, 0);
        expect(AppTextStyles.headlineLarge.height, 1.25);

        expect(AppTextStyles.headlineMedium.fontSize, 28);
        expect(AppTextStyles.headlineMedium.fontWeight, FontWeight.w400);
        expect(AppTextStyles.headlineMedium.letterSpacing, 0);
        expect(AppTextStyles.headlineMedium.height, 1.29);

        expect(AppTextStyles.headlineSmall.fontSize, 24);
        expect(AppTextStyles.headlineSmall.fontWeight, FontWeight.w400);
        expect(AppTextStyles.headlineSmall.letterSpacing, 0);
        expect(AppTextStyles.headlineSmall.height, 1.33);
      });

      test('should have correct title styles', () {
        expect(AppTextStyles.titleLarge.fontSize, 22);
        expect(AppTextStyles.titleLarge.fontWeight, FontWeight.w400);
        expect(AppTextStyles.titleLarge.letterSpacing, 0);
        expect(AppTextStyles.titleLarge.height, 1.27);

        expect(AppTextStyles.titleMedium.fontSize, 16);
        expect(AppTextStyles.titleMedium.fontWeight, FontWeight.w500);
        expect(AppTextStyles.titleMedium.letterSpacing, 0.15);
        expect(AppTextStyles.titleMedium.height, 1.50);

        expect(AppTextStyles.titleSmall.fontSize, 14);
        expect(AppTextStyles.titleSmall.fontWeight, FontWeight.w500);
        expect(AppTextStyles.titleSmall.letterSpacing, 0.1);
        expect(AppTextStyles.titleSmall.height, 1.43);
      });

      test('should have correct label styles', () {
        expect(AppTextStyles.labelLarge.fontSize, 14);
        expect(AppTextStyles.labelLarge.fontWeight, FontWeight.w500);
        expect(AppTextStyles.labelLarge.letterSpacing, 0.1);
        expect(AppTextStyles.labelLarge.height, 1.43);

        expect(AppTextStyles.labelMedium.fontSize, 12);
        expect(AppTextStyles.labelMedium.fontWeight, FontWeight.w500);
        expect(AppTextStyles.labelMedium.letterSpacing, 0.5);
        expect(AppTextStyles.labelMedium.height, 1.33);

        expect(AppTextStyles.labelSmall.fontSize, 11);
        expect(AppTextStyles.labelSmall.fontWeight, FontWeight.w500);
        expect(AppTextStyles.labelSmall.letterSpacing, 0.5);
        expect(AppTextStyles.labelSmall.height, 1.45);
      });

      test('should have correct body styles', () {
        expect(AppTextStyles.bodyLarge.fontSize, 16);
        expect(AppTextStyles.bodyLarge.fontWeight, FontWeight.w400);
        expect(AppTextStyles.bodyLarge.letterSpacing, 0.5);
        expect(AppTextStyles.bodyLarge.height, 1.50);

        expect(AppTextStyles.bodyMedium.fontSize, 14);
        expect(AppTextStyles.bodyMedium.fontWeight, FontWeight.w400);
        expect(AppTextStyles.bodyMedium.letterSpacing, 0.25);
        expect(AppTextStyles.bodyMedium.height, 1.43);

        expect(AppTextStyles.bodySmall.fontSize, 12);
        expect(AppTextStyles.bodySmall.fontWeight, FontWeight.w400);
        expect(AppTextStyles.bodySmall.letterSpacing, 0.4);
        expect(AppTextStyles.bodySmall.height, 1.33);
      });
    });

    group('Police Interaction Specific Styles', () {
      test('should have emergency button style', () {
        expect(AppTextStyles.emergencyButton.fontSize, 18);
        expect(AppTextStyles.emergencyButton.fontWeight, FontWeight.w600);
        expect(AppTextStyles.emergencyButton.letterSpacing, 0.1);
        expect(AppTextStyles.emergencyButton.height, 1.22);
      });

      test('should have recording timer style', () {
        expect(AppTextStyles.recordingTimer.fontSize, 24);
        expect(AppTextStyles.recordingTimer.fontWeight, FontWeight.w600);
        expect(AppTextStyles.recordingTimer.letterSpacing, 0);
        expect(AppTextStyles.recordingTimer.height, 1.17);
        expect(AppTextStyles.recordingTimer.fontFeatures, contains(const FontFeature.tabularFigures()));
      });

      test('should have transcription text style', () {
        expect(AppTextStyles.transcriptionText.fontSize, 16);
        expect(AppTextStyles.transcriptionText.fontWeight, FontWeight.w400);
        expect(AppTextStyles.transcriptionText.letterSpacing, 0.15);
        expect(AppTextStyles.transcriptionText.height, 1.50);
      });

      test('should have speaker label style', () {
        expect(AppTextStyles.speakerLabel.fontSize, 12);
        expect(AppTextStyles.speakerLabel.fontWeight, FontWeight.w600);
        expect(AppTextStyles.speakerLabel.letterSpacing, 0.4);
        expect(AppTextStyles.speakerLabel.height, 1.33);
      });

      test('should have fact check label style', () {
        expect(AppTextStyles.factCheckLabel.fontSize, 11);
        expect(AppTextStyles.factCheckLabel.fontWeight, FontWeight.w500);
        expect(AppTextStyles.factCheckLabel.letterSpacing, 0.5);
        expect(AppTextStyles.factCheckLabel.height, 1.45);
      });

      test('should have navigation label style', () {
        expect(AppTextStyles.navigationLabel.fontSize, 12);
        expect(AppTextStyles.navigationLabel.fontWeight, FontWeight.w500);
        expect(AppTextStyles.navigationLabel.letterSpacing, 0.4);
        expect(AppTextStyles.navigationLabel.height, 1.33);
      });

      test('should have settings styles', () {
        expect(AppTextStyles.settingsLabel.fontSize, 16);
        expect(AppTextStyles.settingsLabel.fontWeight, FontWeight.w500);
        expect(AppTextStyles.settingsLabel.letterSpacing, 0.15);
        expect(AppTextStyles.settingsLabel.height, 1.50);

        expect(AppTextStyles.settingsDescription.fontSize, 14);
        expect(AppTextStyles.settingsDescription.fontWeight, FontWeight.w400);
        expect(AppTextStyles.settingsDescription.letterSpacing, 0.25);
        expect(AppTextStyles.settingsDescription.height, 1.43);
      });
    });

    group('Font Family Consistency', () {
      test('should use consistent font family', () {
        expect(AppTextStyles.displayLarge.fontFamily, 'Roboto');
        expect(AppTextStyles.headlineLarge.fontFamily, 'Roboto');
        expect(AppTextStyles.titleLarge.fontFamily, 'Roboto');
        expect(AppTextStyles.labelLarge.fontFamily, 'Roboto');
        expect(AppTextStyles.bodyLarge.fontFamily, 'Roboto');
        expect(AppTextStyles.emergencyButton.fontFamily, 'Roboto');
        expect(AppTextStyles.recordingTimer.fontFamily, 'Roboto');
        expect(AppTextStyles.transcriptionText.fontFamily, 'Roboto');
      });
    });

    group('Responsive Text Scaling', () {
      testWidgets('should calculate scale factor correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final scaleFactor = AppTextStyles.getScaleFactor(context);
                expect(scaleFactor, greaterThanOrEqualTo(0.8));
                expect(scaleFactor, lessThanOrEqualTo(2.0));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should scale text styles correctly', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final originalStyle = AppTextStyles.bodyLarge;
                final scaledStyle = AppTextStyles.scaled(originalStyle, context);
                
                expect(scaledStyle.fontFamily, originalStyle.fontFamily);
                expect(scaledStyle.fontWeight, originalStyle.fontWeight);
                expect(scaledStyle.letterSpacing, originalStyle.letterSpacing);
                expect(scaledStyle.height, originalStyle.height);
                
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Text Theme Generation', () {
      test('should generate complete text theme', () {
        const colorScheme = AppColors.lightColorScheme;
        final textTheme = AppTextStyles.textTheme(colorScheme);
        
        expect(textTheme.displayLarge, isNotNull);
        expect(textTheme.displayMedium, isNotNull);
        expect(textTheme.displaySmall, isNotNull);
        expect(textTheme.headlineLarge, isNotNull);
        expect(textTheme.headlineMedium, isNotNull);
        expect(textTheme.headlineSmall, isNotNull);
        expect(textTheme.titleLarge, isNotNull);
        expect(textTheme.titleMedium, isNotNull);
        expect(textTheme.titleSmall, isNotNull);
        expect(textTheme.labelLarge, isNotNull);
        expect(textTheme.labelMedium, isNotNull);
        expect(textTheme.labelSmall, isNotNull);
        expect(textTheme.bodyLarge, isNotNull);
        expect(textTheme.bodyMedium, isNotNull);
        expect(textTheme.bodySmall, isNotNull);
      });

      test('should apply correct colors to text theme', () {
        const colorScheme = AppColors.lightColorScheme;
        final textTheme = AppTextStyles.textTheme(colorScheme);
        
        expect(textTheme.displayLarge!.color, colorScheme.onSurface);
        expect(textTheme.headlineLarge!.color, colorScheme.onSurface);
        expect(textTheme.titleLarge!.color, colorScheme.onSurface);
        expect(textTheme.bodyLarge!.color, colorScheme.onSurface);
        expect(textTheme.labelMedium!.color, colorScheme.onSurfaceVariant);
        expect(textTheme.bodySmall!.color, colorScheme.onSurfaceVariant);
      });

      test('should generate high contrast text theme', () {
        const colorScheme = AppColors.lightColorScheme;
        final highContrastTheme = AppTextStyles.highContrastTextTheme(colorScheme);
        
        // High contrast theme should have bolder font weights
        expect(highContrastTheme.displayLarge!.fontWeight, FontWeight.w500);
        expect(highContrastTheme.headlineLarge!.fontWeight, FontWeight.w600);
        expect(highContrastTheme.titleLarge!.fontWeight, FontWeight.w600);
        expect(highContrastTheme.bodyLarge!.fontWeight, FontWeight.w500);
      });
    });

    group('Accessibility Compliance', () {
      test('should validate text contrast correctly', () {
        // Test high contrast (should pass)
        expect(AppTextStyles.hasValidTextContrast(Colors.black, Colors.white), isTrue);
        expect(AppTextStyles.hasValidTextContrast(Colors.white, Colors.black), isTrue);
        
        // Test low contrast (should fail)
        expect(AppTextStyles.hasValidTextContrast(
          const Color(0xFF888888), 
          const Color(0xFF999999)
        ), isFalse);
      });

      test('should validate large text contrast correctly', () {
        // Test high contrast (should pass)
        expect(AppTextStyles.hasValidLargeTextContrast(Colors.black, Colors.white), isTrue);
        expect(AppTextStyles.hasValidLargeTextContrast(Colors.white, Colors.black), isTrue);
        
        // Test medium contrast (should pass for large text)
        expect(AppTextStyles.hasValidLargeTextContrast(
          const Color(0xFF666666), 
          const Color(0xFFFFFFFF)
        ), isTrue);
        
        // Test low contrast (should fail)
        expect(AppTextStyles.hasValidLargeTextContrast(
          const Color(0xFFCCCCCC), 
          const Color(0xFFFFFFFF)
        ), isFalse);
      });

      test('should have valid contrast for police interaction colors', () {
        const lightColorScheme = AppColors.lightColorScheme;
        const darkColorScheme = AppColors.darkColorScheme;
        
        // Test emergency button text contrast
        expect(AppTextStyles.hasValidTextContrast(
          AppColors.onEmergency, 
          AppColors.emergency
        ), isTrue);
        
        // Test recording timer contrast on light background
        expect(AppTextStyles.hasValidTextContrast(
          lightColorScheme.onSurface, 
          lightColorScheme.surface
        ), isTrue);
        
        // Test recording timer contrast on dark background
        expect(AppTextStyles.hasValidTextContrast(
          darkColorScheme.onSurface, 
          darkColorScheme.surface
        ), isTrue);
      });
    });

    group('Typography Hierarchy', () {
      test('should maintain proper size hierarchy', () {
        // Display styles should be largest
        expect(AppTextStyles.displayLarge.fontSize! > AppTextStyles.headlineLarge.fontSize!, isTrue);
        expect(AppTextStyles.displayMedium.fontSize! > AppTextStyles.headlineMedium.fontSize!, isTrue);
        expect(AppTextStyles.displaySmall.fontSize! > AppTextStyles.headlineSmall.fontSize!, isTrue);
        
        // Headlines should be larger than titles
        expect(AppTextStyles.headlineLarge.fontSize! > AppTextStyles.titleLarge.fontSize!, isTrue);
        expect(AppTextStyles.headlineMedium.fontSize! > AppTextStyles.titleMedium.fontSize!, isTrue);
        expect(AppTextStyles.headlineSmall.fontSize! > AppTextStyles.titleSmall.fontSize!, isTrue);
        
        // Titles should be larger than or equal to body text
        expect(AppTextStyles.titleLarge.fontSize! > AppTextStyles.bodyLarge.fontSize!, isTrue);
        expect(AppTextStyles.titleMedium.fontSize! >= AppTextStyles.bodyMedium.fontSize!, isTrue);
        expect(AppTextStyles.titleSmall.fontSize! >= AppTextStyles.bodySmall.fontSize!, isTrue);
        
        // Body text should be larger than labels
        expect(AppTextStyles.bodyLarge.fontSize! > AppTextStyles.labelLarge.fontSize!, isTrue);
        expect(AppTextStyles.bodyMedium.fontSize! > AppTextStyles.labelMedium.fontSize!, isTrue);
        expect(AppTextStyles.bodySmall.fontSize! > AppTextStyles.labelSmall.fontSize!, isTrue);
      });

      test('should have appropriate font weights for hierarchy', () {
        // Titles should be medium weight
        expect(AppTextStyles.titleMedium.fontWeight, FontWeight.w500);
        expect(AppTextStyles.titleSmall.fontWeight, FontWeight.w500);
        
        // Labels should be medium weight
        expect(AppTextStyles.labelLarge.fontWeight, FontWeight.w500);
        expect(AppTextStyles.labelMedium.fontWeight, FontWeight.w500);
        expect(AppTextStyles.labelSmall.fontWeight, FontWeight.w500);
        
        // Body text should be regular weight
        expect(AppTextStyles.bodyLarge.fontWeight, FontWeight.w400);
        expect(AppTextStyles.bodyMedium.fontWeight, FontWeight.w400);
        expect(AppTextStyles.bodySmall.fontWeight, FontWeight.w400);
        
        // Emergency and recording styles should be bold
        expect(AppTextStyles.emergencyButton.fontWeight, FontWeight.w600);
        expect(AppTextStyles.recordingTimer.fontWeight, FontWeight.w600);
        expect(AppTextStyles.speakerLabel.fontWeight, FontWeight.w600);
      });
    });
  });
}