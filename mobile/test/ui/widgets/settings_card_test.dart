import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/settings_card.dart';
import 'package:mobile/src/ui/app_colors.dart';
import '../../test_helpers.dart';

void main() {
  group('SettingsCard Widget Tests', () {
    testWidgets('renders with title and icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsCard(
            title: 'Test Settings',
            icon: Icons.settings,
            children: [],
          ),
        ),
      );

      expect(find.text('Test Settings'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('renders with subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsCard(
            title: 'Test Settings',
            subtitle: 'Test subtitle',
            icon: Icons.settings,
            children: [],
          ),
        ),
      );

      expect(find.text('Test Settings'), findsOneWidget);
      expect(find.text('Test subtitle'), findsOneWidget);
    });

    testWidgets('renders children when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsCard(
            title: 'Test Settings',
            icon: Icons.settings,
            children: [
              Text('Child 1'),
              Text('Child 2'),
            ],
          ),
        ),
      );

      expect(find.text('Child 1'), findsOneWidget);
      expect(find.text('Child 2'), findsOneWidget);
    });

    testWidgets('handles tap when onTap is provided', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsCard(
            title: 'Test Settings',
            icon: Icons.settings,
            children: [],
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(SettingsCard));
      expect(tapped, isTrue);
    });

    testWidgets('uses correct colors from theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsCard(
            title: 'Test Settings',
            icon: Icons.settings,
            children: [],
          ),
        ),
      );

      final cardWidget = tester.widget<Card>(find.byType(Card));
      expect(cardWidget.elevation, equals(1.0)); // AppSpacing.elevationLow

      final iconContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(SettingsCard),
          matching: find.byType(Container),
        ).first,
      );
      
      final decoration = iconContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(AppColors.primaryContainer));
    });

    testWidgets('has proper accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsCard(
            title: 'Test Settings',
            subtitle: 'Test subtitle',
            icon: Icons.settings,
            children: [],
            onTap: () {},
          ),
        ),
      );

      // Verify the card is tappable
      final inkWell = find.byType(InkWell);
      expect(inkWell, findsOneWidget);
      
      // Verify semantic structure
      expect(find.text('Test Settings'), findsOneWidget);
      expect(find.text('Test subtitle'), findsOneWidget);
    });
  });

  group('SettingsItem Widget Tests', () {
    testWidgets('renders with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsItem(
            title: 'Test Item',
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
    });

    testWidgets('renders with subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsItem(
            title: 'Test Item',
            subtitle: 'Test subtitle',
          ),
        ),
      );

      expect(find.text('Test Item'), findsOneWidget);
      expect(find.text('Test subtitle'), findsOneWidget);
    });

    testWidgets('renders trailing widget when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsItem(
            title: 'Test Item',
            trailing: Icon(Icons.arrow_forward),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('handles tap when enabled and onTap provided', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsItem(
            title: 'Test Item',
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(SettingsItem));
      expect(tapped, isTrue);
    });

    testWidgets('does not handle tap when disabled', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsItem(
            title: 'Test Item',
            enabled: false,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(SettingsItem));
      expect(tapped, isFalse);
    });

    testWidgets('shows disabled state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsItem(
            title: 'Test Item',
            subtitle: 'Test subtitle',
            enabled: false,
          ),
        ),
      );

      // Find the text widgets and verify they have reduced opacity
      final titleText = tester.widget<Text>(find.text('Test Item'));
      final subtitleText = tester.widget<Text>(find.text('Test subtitle'));
      
      // The text should have reduced opacity when disabled
      expect(titleText.style?.color?.opacity, lessThan(1.0));
      expect(subtitleText.style?.color?.opacity, lessThan(1.0));
    });
  });

  group('Responsive Behavior Tests', () {
    testWidgets('adapts to different screen sizes', (WidgetTester tester) async {
      // Test mobile size
      await tester.binding.setSurfaceSize(Size(400, 800));
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsCard(
            title: 'Test Settings',
            icon: Icons.settings,
            children: [Text('Test child')],
          ),
        ),
      );

      expect(find.text('Test Settings'), findsOneWidget);
      expect(find.text('Test child'), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(Size(800, 1200));
      await tester.pumpAndSettle();

      expect(find.text('Test Settings'), findsOneWidget);
      expect(find.text('Test child'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('maintains layout integrity with long text', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: SettingsCard(
            title: 'Very Long Settings Title That Should Wrap Properly',
            subtitle: 'This is a very long subtitle that should also wrap properly and not overflow the container boundaries',
            icon: Icons.settings,
            children: [
              SettingsItem(
                title: 'Very Long Settings Item Title That Should Wrap',
                subtitle: 'Another very long subtitle for the settings item that should wrap properly',
              ),
            ],
          ),
        ),
      );

      // Verify no overflow
      expect(tester.takeException(), isNull);
      
      // Verify text is still visible
      expect(find.textContaining('Very Long Settings Title'), findsOneWidget);
      expect(find.textContaining('This is a very long subtitle'), findsOneWidget);
    });
  });
}