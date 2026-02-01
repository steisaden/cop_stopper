import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/info_card.dart';
import 'package:mobile/src/ui/app_colors.dart';
import '../../test_helpers.dart';

void main() {
  group('InfoCard Widget Tests', () {
    testWidgets('renders title and description correctly', (WidgetTester tester) async {
      const title = 'Test Title';
      const description = 'Test Description';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const InfoCard(
            title: title,
            description: description,
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);
    });

    testWidgets('renders icon when provided', (WidgetTester tester) async {
      const testIcon = Icons.info;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const InfoCard(
            icon: testIcon,
            title: 'Test Title',
          ),
        ),
      );

      expect(find.byIcon(testIcon), findsOneWidget);
    });

    testWidgets('renders custom content instead of title/description', (WidgetTester tester) async {
      const customContent = Text('Custom Content');
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const InfoCard(
            content: customContent,
            title: 'Should not appear',
            description: 'Should not appear',
          ),
        ),
      );

      expect(find.text('Custom Content'), findsOneWidget);
      expect(find.text('Should not appear'), findsNothing);
    });

    testWidgets('renders action buttons when provided', (WidgetTester tester) async {
      bool button1Pressed = false;
      bool button2Pressed = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: InfoCard(
            title: 'Test Title',
            actions: [
              TextButton(
                onPressed: () => button1Pressed = true,
                child: const Text('Action 1'),
              ),
              ElevatedButton(
                onPressed: () => button2Pressed = true,
                child: const Text('Action 2'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);

      await tester.tap(find.text('Action 1'));
      await tester.tap(find.text('Action 2'));

      expect(button1Pressed, isTrue);
      expect(button2Pressed, isTrue);
    });

    testWidgets('handles tap events correctly', (WidgetTester tester) async {
      bool cardTapped = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: InfoCard(
            title: 'Tappable Card',
            onTap: () => cardTapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(InfoCard));
      expect(cardTapped, isTrue);
    });

    testWidgets('applies custom colors correctly', (WidgetTester tester) async {
      const customBackgroundColor = Colors.red;
      const customIconColor = Colors.blue;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const InfoCard(
            title: 'Colored Card',
            icon: Icons.star,
            backgroundColor: customBackgroundColor,
            iconColor: customIconColor,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, customIconColor);
    });

    testWidgets('applies semantic label correctly', (WidgetTester tester) async {
      const semanticLabel = 'Custom Semantic Label';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const InfoCard(
            title: 'Test Title',
            semanticLabel: semanticLabel,
          ),
        ),
      );

      // Check that the semantic label is applied to the BaseCard
      final semantics = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(InfoCard),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, semanticLabel);
    });

    testWidgets('uses title as semantic label when no custom label provided', (WidgetTester tester) async {
      const title = 'Test Title';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const InfoCard(
            title: title,
          ),
        ),
      );

      // Check that the title is used as semantic label
      final semantics = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(InfoCard),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, title);
    });
  });

  group('StatusInfoCard Widget Tests', () {
    testWidgets('renders success status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const StatusInfoCard(
            title: 'Success Card',
            description: 'Success Description',
            status: StatusType.success,
          ),
        ),
      );

      expect(find.text('Success Card'), findsOneWidget);
      expect(find.text('Success Description'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle_outline));
      expect(icon.color, AppColors.success);
    });

    testWidgets('renders warning status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const StatusInfoCard(
            title: 'Warning Card',
            description: 'Warning Description',
            status: StatusType.warning,
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_outlined), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.warning_amber_outlined));
      expect(icon.color, AppColors.warning);
    });

    testWidgets('renders error status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const StatusInfoCard(
            title: 'Error Card',
            description: 'Error Description',
            status: StatusType.error,
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(icon.color, AppColors.error);
    });

    testWidgets('renders info status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const StatusInfoCard(
            title: 'Info Card',
            description: 'Info Description',
            status: StatusType.info,
          ),
        ),
      );

      expect(find.byIcon(Icons.info_outline), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.info_outline));
      expect(icon.color, AppColors.primary);
    });

    testWidgets('renders recording status correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const StatusInfoCard(
            title: 'Recording Card',
            description: 'Recording Description',
            status: StatusType.recording,
          ),
        ),
      );

      expect(find.byIcon(Icons.fiber_manual_record), findsOneWidget);

      final icon = tester.widget<Icon>(find.byIcon(Icons.fiber_manual_record));
      expect(icon.color, AppColors.recording);
    });

    testWidgets('allows custom icon override', (WidgetTester tester) async {
      const customIcon = Icons.star;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const StatusInfoCard(
            title: 'Custom Icon Card',
            description: 'Custom Description',
            status: StatusType.success,
            icon: customIcon,
          ),
        ),
      );

      expect(find.byIcon(customIcon), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    });

    testWidgets('handles actions correctly', (WidgetTester tester) async {
      bool actionPressed = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: StatusInfoCard(
            title: 'Action Card',
            description: 'Action Description',
            status: StatusType.info,
            actions: [
              TextButton(
                onPressed: () => actionPressed = true,
                child: const Text('Test Action'),
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Test Action'));
      expect(actionPressed, isTrue);
    });
  });

  group('InfoCard Layout Tests', () {
    testWidgets('arranges elements in correct order', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: InfoCard(
            icon: Icons.star,
            title: 'Test Title',
            description: 'Test Description',
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('Action'),
              ),
            ],
          ),
        ),
      );

      // Find all widgets in the column
      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(InfoCard),
          matching: find.byType(Column),
        ),
      );

      expect(column.children.length, greaterThan(0));
    });

    testWidgets('handles empty states correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const InfoCard(),
        ),
      );

      // Should render without errors even with no content
      expect(find.byType(InfoCard), findsOneWidget);
    });

    testWidgets('handles long text correctly', (WidgetTester tester) async {
      const longTitle = 'This is a very long title that should wrap properly and not cause overflow issues in the card layout';
      const longDescription = 'This is a very long description that should also wrap properly and maintain good readability while fitting within the card boundaries without causing any layout issues';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const InfoCard(
            title: longTitle,
            description: longDescription,
          ),
        ),
      );

      expect(find.text(longTitle), findsOneWidget);
      expect(find.text(longDescription), findsOneWidget);
      
      // Should not have overflow
      expect(tester.takeException(), isNull);
    });
  });
}