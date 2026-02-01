import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/app_spacing.dart';

void main() {
  group('AppSpacing', () {
    group('8pt Grid System', () {
      test('should follow 8pt grid methodology', () {
        expect(AppSpacing.none, 0.0);
        expect(AppSpacing.xs, 4.0); // 8 * 0.5
        expect(AppSpacing.sm, 8.0); // 8 * 1
        expect(AppSpacing.md, 16.0); // 8 * 2
        expect(AppSpacing.lg, 24.0); // 8 * 3
        expect(AppSpacing.xl, 32.0); // 8 * 4
        expect(AppSpacing.xxl, 48.0); // 8 * 6
        expect(AppSpacing.xxxl, 64.0); // 8 * 8
      });

      test('should validate spacing consistency', () {
        expect(AppSpacing.isValidSpacing(AppSpacing.xs), isTrue);
        expect(AppSpacing.isValidSpacing(AppSpacing.sm), isTrue);
        expect(AppSpacing.isValidSpacing(AppSpacing.md), isTrue);
        expect(AppSpacing.isValidSpacing(AppSpacing.lg), isTrue);
        expect(AppSpacing.isValidSpacing(AppSpacing.xl), isTrue);
        expect(AppSpacing.isValidSpacing(AppSpacing.xxl), isTrue);
        expect(AppSpacing.isValidSpacing(AppSpacing.xxxl), isTrue);
        
        // Invalid spacing (not following 4pt grid)
        expect(AppSpacing.isValidSpacing(5.0), isFalse);
        expect(AppSpacing.isValidSpacing(13.0), isFalse);
        expect(AppSpacing.isValidSpacing(25.0), isFalse);
      });

      test('should snap values to grid', () {
        expect(AppSpacing.snapToGrid(5.0), 4.0);
        expect(AppSpacing.snapToGrid(13.0), 12.0);
        expect(AppSpacing.snapToGrid(25.0), 24.0);
        expect(AppSpacing.snapToGrid(30.0), 32.0);
        expect(AppSpacing.snapToGrid(8.0), 8.0); // Already on grid
      });
    });

    group('Component-Specific Spacing', () {
      test('should have appropriate card spacing', () {
        expect(AppSpacing.cardPadding, AppSpacing.md);
        expect(AppSpacing.cardMargin, AppSpacing.sm);
        expect(AppSpacing.cardRadius, AppSpacing.sm);
      });

      test('should have appropriate button spacing', () {
        expect(AppSpacing.buttonPadding, AppSpacing.md);
        expect(AppSpacing.buttonRadius, AppSpacing.sm);
      });

      test('should have appropriate navigation spacing', () {
        expect(AppSpacing.bottomNavHeight, 80.0); // 8 * 10
        expect(AppSpacing.bottomNavPadding, AppSpacing.sm);
        expect(AppSpacing.tabIconSize, 24.0); // 8 * 3
        expect(AppSpacing.tabLabelSpacing, AppSpacing.xs);
      });

      test('should have appropriate recording interface spacing', () {
        expect(AppSpacing.recordButtonSize, 80.0); // 8 * 10
        expect(AppSpacing.recordButtonMargin, AppSpacing.lg);
        expect(AppSpacing.cameraPreviewRadius, AppSpacing.md);
        expect(AppSpacing.controlsSpacing, AppSpacing.md);
        expect(AppSpacing.statusBarHeight, 56.0); // 8 * 7
      });

      test('should have appropriate settings spacing', () {
        expect(AppSpacing.settingsCardSpacing, AppSpacing.md);
        expect(AppSpacing.settingsItemSpacing, AppSpacing.lg);
        expect(AppSpacing.settingsSectionSpacing, AppSpacing.xl);
        expect(AppSpacing.toggleSwitchPadding, AppSpacing.sm);
      });

      test('should have appropriate emergency spacing', () {
        expect(AppSpacing.emergencyButtonSize, 96.0); // 8 * 12
        expect(AppSpacing.emergencyButtonMargin, AppSpacing.xl);
        expect(AppSpacing.emergencySpacing, AppSpacing.lg);
      });
    });

    group('Responsive Breakpoints', () {
      test('should have valid breakpoint values', () {
        expect(AppSpacing.mobileBreakpoint, 600.0);
        expect(AppSpacing.tabletBreakpoint, 900.0);
        expect(AppSpacing.desktopBreakpoint, 1200.0);
        
        // Breakpoints should be in ascending order
        expect(AppSpacing.mobileBreakpoint < AppSpacing.tabletBreakpoint, isTrue);
        expect(AppSpacing.tabletBreakpoint < AppSpacing.desktopBreakpoint, isTrue);
      });

      testWidgets('should return correct responsive spacing', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                // Test mobile spacing (default)
                final mobileSpacing = AppSpacing.responsive(
                  context,
                  mobile: 16.0,
                  tablet: 24.0,
                  desktop: 32.0,
                );
                expect(mobileSpacing, 16.0);
                
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should scale spacing for accessibility', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final scaledSpacing = AppSpacing.scaled(context, 16.0);
                expect(scaledSpacing, greaterThanOrEqualTo(16.0));
                expect(scaledSpacing, lessThanOrEqualTo(24.0)); // Max 1.5x scaling
                
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Spacing Widgets', () {
      test('should provide horizontal spacing widgets', () {
        expect(AppSpacing.horizontalSpaceXS, isA<SizedBox>());
        expect(AppSpacing.horizontalSpaceSM, isA<SizedBox>());
        expect(AppSpacing.horizontalSpaceMD, isA<SizedBox>());
        expect(AppSpacing.horizontalSpaceLG, isA<SizedBox>());
        expect(AppSpacing.horizontalSpaceXL, isA<SizedBox>());
        expect(AppSpacing.horizontalSpaceXXL, isA<SizedBox>());
        
        expect((AppSpacing.horizontalSpaceXS as SizedBox).width, AppSpacing.xs);
        expect((AppSpacing.horizontalSpaceSM as SizedBox).width, AppSpacing.sm);
        expect((AppSpacing.horizontalSpaceMD as SizedBox).width, AppSpacing.md);
        expect((AppSpacing.horizontalSpaceLG as SizedBox).width, AppSpacing.lg);
        expect((AppSpacing.horizontalSpaceXL as SizedBox).width, AppSpacing.xl);
        expect((AppSpacing.horizontalSpaceXXL as SizedBox).width, AppSpacing.xxl);
      });

      test('should provide vertical spacing widgets', () {
        expect(AppSpacing.verticalSpaceXS, isA<SizedBox>());
        expect(AppSpacing.verticalSpaceSM, isA<SizedBox>());
        expect(AppSpacing.verticalSpaceMD, isA<SizedBox>());
        expect(AppSpacing.verticalSpaceLG, isA<SizedBox>());
        expect(AppSpacing.verticalSpaceXL, isA<SizedBox>());
        expect(AppSpacing.verticalSpaceXXL, isA<SizedBox>());
        
        expect((AppSpacing.verticalSpaceXS as SizedBox).height, AppSpacing.xs);
        expect((AppSpacing.verticalSpaceSM as SizedBox).height, AppSpacing.sm);
        expect((AppSpacing.verticalSpaceMD as SizedBox).height, AppSpacing.md);
        expect((AppSpacing.verticalSpaceLG as SizedBox).height, AppSpacing.lg);
        expect((AppSpacing.verticalSpaceXL as SizedBox).height, AppSpacing.xl);
        expect((AppSpacing.verticalSpaceXXL as SizedBox).height, AppSpacing.xxl);
      });
    });

    group('Edge Insets', () {
      test('should provide consistent padding values', () {
        expect(AppSpacing.paddingXS, const EdgeInsets.all(AppSpacing.xs));
        expect(AppSpacing.paddingSM, const EdgeInsets.all(AppSpacing.sm));
        expect(AppSpacing.paddingMD, const EdgeInsets.all(AppSpacing.md));
        expect(AppSpacing.paddingLG, const EdgeInsets.all(AppSpacing.lg));
        expect(AppSpacing.paddingXL, const EdgeInsets.all(AppSpacing.xl));
      });

      test('should provide horizontal padding values', () {
        expect(AppSpacing.horizontalPaddingXS, const EdgeInsets.symmetric(horizontal: AppSpacing.xs));
        expect(AppSpacing.horizontalPaddingSM, const EdgeInsets.symmetric(horizontal: AppSpacing.sm));
        expect(AppSpacing.horizontalPaddingMD, const EdgeInsets.symmetric(horizontal: AppSpacing.md));
        expect(AppSpacing.horizontalPaddingLG, const EdgeInsets.symmetric(horizontal: AppSpacing.lg));
        expect(AppSpacing.horizontalPaddingXL, const EdgeInsets.symmetric(horizontal: AppSpacing.xl));
      });

      test('should provide vertical padding values', () {
        expect(AppSpacing.verticalPaddingXS, const EdgeInsets.symmetric(vertical: AppSpacing.xs));
        expect(AppSpacing.verticalPaddingSM, const EdgeInsets.symmetric(vertical: AppSpacing.sm));
        expect(AppSpacing.verticalPaddingMD, const EdgeInsets.symmetric(vertical: AppSpacing.md));
        expect(AppSpacing.verticalPaddingLG, const EdgeInsets.symmetric(vertical: AppSpacing.lg));
        expect(AppSpacing.verticalPaddingXL, const EdgeInsets.symmetric(vertical: AppSpacing.xl));
      });

      testWidgets('should provide safe area padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final screenPadding = AppSpacing.screenPaddingWithSafeArea(context);
                expect(screenPadding.left, AppSpacing.screenPadding);
                expect(screenPadding.right, AppSpacing.screenPadding);
                expect(screenPadding.top, greaterThanOrEqualTo(AppSpacing.screenPadding));
                expect(screenPadding.bottom, greaterThanOrEqualTo(AppSpacing.screenPadding));
                
                final bottomNavPadding = AppSpacing.bottomNavPaddingWithSafeArea(context);
                expect(bottomNavPadding.left, AppSpacing.bottomNavPadding);
                expect(bottomNavPadding.right, AppSpacing.bottomNavPadding);
                expect(bottomNavPadding.top, AppSpacing.bottomNavPadding);
                expect(bottomNavPadding.bottom, greaterThanOrEqualTo(AppSpacing.bottomNavPadding));
                
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should provide responsive card padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final cardPadding = AppSpacing.cardPaddingResponsive(context);
                expect(cardPadding.left, greaterThanOrEqualTo(AppSpacing.cardPadding));
                expect(cardPadding.right, greaterThanOrEqualTo(AppSpacing.cardPadding));
                expect(cardPadding.top, greaterThanOrEqualTo(AppSpacing.cardPadding));
                expect(cardPadding.bottom, greaterThanOrEqualTo(AppSpacing.cardPadding));
                
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should provide scaled list item padding', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                final listItemPadding = AppSpacing.listItemPaddingScaled(context);
                expect(listItemPadding.left, greaterThanOrEqualTo(AppSpacing.listItemPadding));
                expect(listItemPadding.right, greaterThanOrEqualTo(AppSpacing.listItemPadding));
                expect(listItemPadding.top, greaterThanOrEqualTo(AppSpacing.listItemPadding));
                expect(listItemPadding.bottom, greaterThanOrEqualTo(AppSpacing.listItemPadding));
                
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Border Radius', () {
      test('should provide consistent border radius values', () {
        expect(AppSpacing.radiusXS, const BorderRadius.all(Radius.circular(AppSpacing.xs)));
        expect(AppSpacing.radiusSM, const BorderRadius.all(Radius.circular(AppSpacing.sm)));
        expect(AppSpacing.radiusMD, const BorderRadius.all(Radius.circular(AppSpacing.md)));
        expect(AppSpacing.radiusLG, const BorderRadius.all(Radius.circular(AppSpacing.lg)));
        expect(AppSpacing.radiusXL, const BorderRadius.all(Radius.circular(AppSpacing.xl)));
      });

      test('should provide component-specific border radius', () {
        expect(AppSpacing.cardBorderRadius, AppSpacing.radiusSM);
        expect(AppSpacing.buttonBorderRadius, AppSpacing.radiusSM);
        expect(AppSpacing.cameraPreviewBorderRadius, AppSpacing.radiusMD);
      });
    });

    group('Animation Durations', () {
      test('should provide Material Design compliant durations', () {
        expect(AppSpacing.animationDurationShort, const Duration(milliseconds: 150));
        expect(AppSpacing.animationDurationMedium, const Duration(milliseconds: 300));
        expect(AppSpacing.animationDurationLong, const Duration(milliseconds: 500));
        
        // Durations should be in ascending order
        expect(AppSpacing.animationDurationShort < AppSpacing.animationDurationMedium, isTrue);
        expect(AppSpacing.animationDurationMedium < AppSpacing.animationDurationLong, isTrue);
      });
    });

    group('Elevation Values', () {
      test('should provide Material Design 3 elevation values', () {
        expect(AppSpacing.elevationNone, 0.0);
        expect(AppSpacing.elevationLow, 1.0);
        expect(AppSpacing.elevationMedium, 3.0);
        expect(AppSpacing.elevationHigh, 6.0);
        expect(AppSpacing.elevationVeryHigh, 12.0);
        
        // Elevations should be in ascending order
        expect(AppSpacing.elevationNone < AppSpacing.elevationLow, isTrue);
        expect(AppSpacing.elevationLow < AppSpacing.elevationMedium, isTrue);
        expect(AppSpacing.elevationMedium < AppSpacing.elevationHigh, isTrue);
        expect(AppSpacing.elevationHigh < AppSpacing.elevationVeryHigh, isTrue);
      });
    });

    group('Spacing Relationships', () {
      test('should maintain logical spacing relationships', () {
        // Each step should be larger than the previous
        expect(AppSpacing.xs < AppSpacing.sm, isTrue);
        expect(AppSpacing.sm < AppSpacing.md, isTrue);
        expect(AppSpacing.md < AppSpacing.lg, isTrue);
        expect(AppSpacing.lg < AppSpacing.xl, isTrue);
        expect(AppSpacing.xl < AppSpacing.xxl, isTrue);
        expect(AppSpacing.xxl < AppSpacing.xxxl, isTrue);
      });

      test('should have appropriate component size relationships', () {
        // Emergency button should be larger than record button
        expect(AppSpacing.emergencyButtonSize > AppSpacing.recordButtonSize, isTrue);
        
        // Bottom nav should be taller than status bar
        expect(AppSpacing.bottomNavHeight > AppSpacing.statusBarHeight, isTrue);
        
        // Tab icon should fit within bottom nav height
        expect(AppSpacing.tabIconSize < AppSpacing.bottomNavHeight, isTrue);
      });
    });
  });
}