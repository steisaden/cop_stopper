import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/base_card.dart';
import 'package:mobile/src/ui/app_spacing.dart';
import '../../test_helpers.dart';

void main() {
  group('BaseCard Widget Tests', () {
    testWidgets('renders child widget correctly', (WidgetTester tester) async {
      const testText = 'Test Content';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            child: Text(testText),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('applies default styling correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            child: Text('Test'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BaseCard),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.margin, AppSpacing.paddingSM);
      expect(container.decoration, isA<BoxDecoration>());
      
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, AppSpacing.cardBorderRadius);
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
    });

    testWidgets('applies custom padding correctly', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(32.0);
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            padding: customPadding,
            child: Text('Test'),
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(BaseCard),
          matching: find.byType(Padding),
        ).last,
      );

      expect(padding.padding, customPadding);
    });

    testWidgets('applies custom margin correctly', (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(32.0);
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            margin: customMargin,
            child: Text('Test'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BaseCard),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.margin, customMargin);
    });

    testWidgets('handles tap events when onTap is provided', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: BaseCard(
            onTap: () => tapped = true,
            child: const Text('Tappable Card'),
          ),
        ),
      );

      await tester.tap(find.byType(BaseCard));
      expect(tapped, isTrue);
    });

    testWidgets('does not handle tap events when onTap is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            child: Text('Non-tappable Card'),
          ),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('applies semantic label correctly', (WidgetTester tester) async {
      const semanticLabel = 'Test Card Label';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            semanticLabel: semanticLabel,
            child: Text('Test'),
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(BaseCard),
          matching: find.byType(Semantics),
        ).first,
      );

      expect(semantics.properties.label, semanticLabel);
    });

    testWidgets('applies custom background color', (WidgetTester tester) async {
      const customColor = Colors.red;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            backgroundColor: customColor,
            child: Text('Test'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BaseCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, customColor);
    });

    testWidgets('applies custom elevation', (WidgetTester tester) async {
      const customElevation = 10.0;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            elevation: customElevation,
            child: Text('Test'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BaseCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      final shadow = decoration.boxShadow!.first;
      expect(shadow.blurRadius, customElevation);
      expect(shadow.offset.dy, customElevation / 2);
    });

    testWidgets('applies custom border radius', (WidgetTester tester) async {
      const customRadius = BorderRadius.all(Radius.circular(20.0));
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            borderRadius: customRadius,
            child: Text('Test'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BaseCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, customRadius);
    });

    testWidgets('applies custom border', (WidgetTester tester) async {
      const customBorder = Border.fromBorderSide(
        BorderSide(color: Colors.blue, width: 2.0),
      );
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            border: customBorder,
            child: Text('Test'),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(BaseCard),
          matching: find.byType(Container),
        ).first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, customBorder);
    });

    testWidgets('respects clip behavior', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            clipBehavior: Clip.hardEdge,
            child: Text('Test'),
          ),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(BaseCard),
          matching: find.byType(ClipRRect),
        ),
      );

      expect(clipRRect.clipBehavior, Clip.hardEdge);
    });
  });

  group('BaseCard Responsive Behavior Tests', () {
    testWidgets('adapts to different screen sizes', (WidgetTester tester) async {
      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            child: Text('Mobile Test'),
          ),
        ),
      );

      expect(find.text('Mobile Test'), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpAndSettle();

      expect(find.text('Mobile Test'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('maintains aspect ratio on orientation change', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const BaseCard(
            child: Text('Orientation Test'),
          ),
        ),
      );

      expect(find.text('Orientation Test'), findsOneWidget);

      // Simulate orientation change
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pumpAndSettle();

      expect(find.text('Orientation Test'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });
  });
}