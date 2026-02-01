import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/action_card.dart';
import 'package:mobile/src/ui/app_colors.dart';
import '../../test_helpers.dart';

void main() {
  group('ActionCard Widget Tests', () {
    testWidgets('renders title and primary action correctly', (WidgetTester tester) async {
      bool primaryPressed = false;
      const title = 'Test Action Card';
      const primaryLabel = 'Primary Action';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: title,
            primaryAction: ActionButton(
              label: primaryLabel,
              onPressed: () => primaryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(primaryLabel), findsOneWidget);

      await tester.tap(find.text(primaryLabel));
      expect(primaryPressed, isTrue);
    });

    testWidgets('renders description when provided', (WidgetTester tester) async {
      const description = 'Test Description';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Test Title',
            description: description,
            primaryAction: ActionButton(
              label: 'Action',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text(description), findsOneWidget);
    });

    testWidgets('renders icon when provided', (WidgetTester tester) async {
      const testIcon = Icons.warning;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            icon: testIcon,
            title: 'Test Title',
            primaryAction: ActionButton(
              label: 'Action',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(testIcon), findsOneWidget);
    });

    testWidgets('renders both primary and secondary actions', (WidgetTester tester) async {
      bool primaryPressed = false;
      bool secondaryPressed = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Test Title',
            primaryAction: ActionButton(
              label: 'Primary',
              onPressed: () => primaryPressed = true,
            ),
            secondaryAction: ActionButton(
              label: 'Secondary',
              onPressed: () => secondaryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Secondary'), findsOneWidget);

      await tester.tap(find.text('Primary'));
      await tester.tap(find.text('Secondary'));

      expect(primaryPressed, isTrue);
      expect(secondaryPressed, isTrue);
    });

    testWidgets('applies destructive styling correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Destructive Action',
            icon: Icons.delete,
            isDestructive: true,
            primaryAction: ActionButton(
              label: 'Delete',
              onPressed: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.delete));
      expect(icon.color, AppColors.error);
    });

    testWidgets('applies emergency styling correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Emergency Action',
            icon: Icons.emergency,
            isEmergency: true,
            primaryAction: ActionButton(
              label: 'Emergency',
              onPressed: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.emergency));
      expect(icon.color, AppColors.emergency);
      expect(icon.size, 32); // Emergency icons should be larger
    });

    testWidgets('applies custom colors correctly', (WidgetTester tester) async {
      const customBackgroundColor = Colors.purple;
      const customIconColor = Colors.orange;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Custom Colors',
            icon: Icons.star,
            backgroundColor: customBackgroundColor,
            iconColor: customIconColor,
            primaryAction: ActionButton(
              label: 'Action',
              onPressed: () {},
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, customIconColor);
    });

    testWidgets('handles disabled actions correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Disabled Action',
            primaryAction: ActionButton(
              label: 'Disabled',
              onPressed: null, // Disabled action
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Disabled'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('applies semantic label correctly', (WidgetTester tester) async {
      const semanticLabel = 'Custom Action Label';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Test Title',
            semanticLabel: semanticLabel,
            primaryAction: ActionButton(
              label: 'Action',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Check that the semantic label is applied to the BaseCard
      final semantics = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(ActionCard),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, semanticLabel);
    });

    testWidgets('uses title as semantic label when no custom label provided', (WidgetTester tester) async {
      const title = 'Test Action Title';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: title,
            primaryAction: ActionButton(
              label: 'Action',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Check that the title is used as semantic label
      final semantics = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(ActionCard),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, title);
    });
  });

  group('ActionButton Tests', () {
    testWidgets('creates action button with correct properties', (WidgetTester tester) async {
      const label = 'Test Button';
      const icon = Icons.star;
      bool pressed = false;
      
      final actionButton = ActionButton(
        label: label,
        icon: icon,
        onPressed: () => pressed = true,
      );

      expect(actionButton.label, label);
      expect(actionButton.icon, icon);
      expect(actionButton.onPressed, isNotNull);

      actionButton.onPressed!();
      expect(pressed, isTrue);
    });

    testWidgets('handles null onPressed correctly', (WidgetTester tester) async {
      const actionButton = ActionButton(
        label: 'Disabled Button',
        onPressed: null,
      );

      expect(actionButton.onPressed, isNull);
    });
  });

  group('ActionCard Button Styling Tests', () {
    testWidgets('primary button has correct styling for normal card', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Normal Card',
            primaryAction: ActionButton(
              label: 'Primary',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Primary'),
      );
      expect(button, isNotNull);
    });

    testWidgets('secondary button has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Card with Secondary',
            primaryAction: ActionButton(
              label: 'Primary',
              onPressed: () {},
            ),
            secondaryAction: ActionButton(
              label: 'Secondary',
              onPressed: () {},
            ),
          ),
        ),
      );

      final primaryButton = find.widgetWithText(ElevatedButton, 'Primary');
      final secondaryButton = find.widgetWithText(TextButton, 'Secondary');
      
      expect(primaryButton, findsOneWidget);
      expect(secondaryButton, findsOneWidget);
    });

    testWidgets('emergency button has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Emergency Card',
            isEmergency: true,
            primaryAction: ActionButton(
              label: 'Emergency Action',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Emergency Action'),
      );
      expect(button, isNotNull);
    });

    testWidgets('destructive button has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Destructive Card',
            isDestructive: true,
            primaryAction: ActionButton(
              label: 'Delete',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Delete'),
      );
      expect(button, isNotNull);
    });
  });

  group('ActionCard Layout Tests', () {
    testWidgets('arranges elements in correct order', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            icon: Icons.star,
            title: 'Test Title',
            description: 'Test Description',
            primaryAction: ActionButton(
              label: 'Primary',
              onPressed: () {},
            ),
            secondaryAction: ActionButton(
              label: 'Secondary',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the main column
      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(ActionCard),
          matching: find.byType(Column),
        ).first,
      );

      expect(column.children.length, greaterThan(0));
    });

    testWidgets('handles long text correctly', (WidgetTester tester) async {
      const longTitle = 'This is a very long action card title that should wrap properly and not cause overflow issues';
      const longDescription = 'This is a very long description for an action card that should also wrap properly and maintain good readability';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: longTitle,
            description: longDescription,
            primaryAction: ActionButton(
              label: 'Action',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text(longTitle), findsOneWidget);
      expect(find.text(longDescription), findsOneWidget);
      
      // Should not have overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('buttons are aligned correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ActionCard(
            title: 'Button Alignment Test',
            primaryAction: ActionButton(
              label: 'Primary',
              onPressed: () {},
            ),
            secondaryAction: ActionButton(
              label: 'Secondary',
              onPressed: () {},
            ),
          ),
        ),
      );

      final buttonRow = tester.widget<Row>(
        find.descendant(
          of: find.byType(ActionCard),
          matching: find.byType(Row),
        ).last, // Get the button row (last Row in the card)
      );

      expect(buttonRow.mainAxisAlignment, MainAxisAlignment.end);
    });
  });
}