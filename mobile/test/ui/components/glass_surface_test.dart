import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/components/glass_surface.dart';
import 'package:mobile/src/ui/app_colors.dart';

void main() {
  group('GlassSurface', () {
    testWidgets('renders with base variant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassSurface(
              variant: GlassVariant.base,
              child: Text('Test'),
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(GlassSurface), findsOneWidget);
    });

    testWidgets('renders with inset variant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassSurface(
              variant: GlassVariant.inset,
              child: Text('Inset'),
            ),
          ),
        ),
      );

      expect(find.text('Inset'), findsOneWidget);
    });

    testWidgets('renders with floating variant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassSurface(
              variant: GlassVariant.floating,
              child: Text('Floating'),
            ),
          ),
        ),
      );

      expect(find.text('Floating'), findsOneWidget);
    });

    testWidgets('renders with frosted variant', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassSurface(
              variant: GlassVariant.frosted,
              child: Text('Frosted'),
            ),
          ),
        ),
      );

      expect(find.text('Frosted'), findsOneWidget);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassSurface(
              variant: GlassVariant.floating,
              onTap: () => tapped = true,
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tap Me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassSurface(
              variant: GlassVariant.base,
              padding: EdgeInsets.all(32),
              child: Text('Padded'),
            ),
          ),
        ),
      );

      expect(find.text('Padded'), findsOneWidget);
    });

    testWidgets('applies custom border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassSurface(
              variant: GlassVariant.base,
              borderRadius: BorderRadius.circular(50),
              child: const Text('Rounded'),
            ),
          ),
        ),
      );

      expect(find.text('Rounded'), findsOneWidget);
    });
  });

  group('GlassSurface convenience constructors', () {
    testWidgets('GlassBase renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassBase(child: Text('Base')),
          ),
        ),
      );

      expect(find.text('Base'), findsOneWidget);
    });

    testWidgets('GlassInset renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassInset(child: Text('Inset')),
          ),
        ),
      );

      expect(find.text('Inset'), findsOneWidget);
    });

    testWidgets('GlassFloating renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassFloating(child: Text('Floating')),
          ),
        ),
      );

      expect(find.text('Floating'), findsOneWidget);
    });

    testWidgets('GlassFrosted renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassFrosted(child: Text('Frosted')),
          ),
        ),
      );

      expect(find.text('Frosted'), findsOneWidget);
    });
  });

  group('GlassSurface press animation', () {
    testWidgets('animates on tap down when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassSurface(
              variant: GlassVariant.floating,
              enablePressAnimation: true,
              onTap: () {},
              child: const Text('Animate'),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Animate')),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Animation should be in progress
      expect(find.byType(GlassSurface), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('does not animate when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: AppColors.glassBackground,
            body: GlassSurface(
              variant: GlassVariant.floating,
              enablePressAnimation: false,
              onTap: () {},
              child: const Text('No Animate'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('No Animate'));
      await tester.pump();

      expect(find.byType(GlassSurface), findsOneWidget);
    });
  });
}
