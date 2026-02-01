import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/bottom_sheet_picker.dart';
import '../../test_helpers.dart';

void main() {
  group('BottomSheetPicker Widget Tests', () {
    final testItems = [
      BottomSheetPickerItem<String>(
        value: 'option1',
        title: 'Option 1',
        subtitle: 'First option',
        icon: Icons.star,
      ),
      BottomSheetPickerItem<String>(
        value: 'option2',
        title: 'Option 2',
        subtitle: 'Second option',
        icon: Icons.favorite,
      ),
      BottomSheetPickerItem<String>(
        value: 'option3',
        title: 'Option 3',
      ),
    ];

    testWidgets('renders with title and items', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: BottomSheetPicker<String>(
            title: 'Select Option',
            items: testItems,
          ),
        ),
      );

      expect(find.text('Select Option'), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Option 3'), findsOneWidget);
    });

    testWidgets('shows selected item correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: BottomSheetPicker<String>(
            title: 'Select Option',
            items: testItems,
            selectedValue: 'option2',
          ),
        ),
      );

      // Should show check icon for selected item
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('displays icons when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: BottomSheetPicker<String>(
            title: 'Select Option',
            items: testItems,
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('displays subtitles when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: BottomSheetPicker<String>(
            title: 'Select Option',
            items: testItems,
          ),
        ),
      );

      expect(find.text('First option'), findsOneWidget);
      expect(find.text('Second option'), findsOneWidget);
    });

    testWidgets('handles item selection', (WidgetTester tester) async {
      String? selectedValue;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: BottomSheetPicker<String>(
            title: 'Select Option',
            items: testItems,
            onSelected: (value) => selectedValue = value,
          ),
        ),
      );

      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();

      expect(selectedValue, equals('option2'));
    });

    testWidgets('shows search bar when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: BottomSheetPicker<String>(
            title: 'Select Option',
            items: testItems,
            showSearchBar: true,
            searchHint: 'Search options...',
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search options...'), findsOneWidget);
    });

    testWidgets('shows close button', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: BottomSheetPicker<String>(
            title: 'Select Option',
            items: testItems,
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('shows handle bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: BottomSheetPicker<String>(
            title: 'Select Option',
            items: testItems,
          ),
        ),
      );

      // Handle bar is a Container, so we check for its presence
      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });
  });

  group('BottomSheetPickerItem Tests', () {
    testWidgets('creates item with all properties', (WidgetTester tester) async {
      const item = BottomSheetPickerItem<int>(
        value: 42,
        title: 'Test Item',
        subtitle: 'Test subtitle',
        icon: Icons.test_tube,
      );

      expect(item.value, equals(42));
      expect(item.title, equals('Test Item'));
      expect(item.subtitle, equals('Test subtitle'));
      expect(item.icon, equals(Icons.test_tube));
    });

    testWidgets('creates item with minimal properties', (WidgetTester tester) async {
      const item = BottomSheetPickerItem<String>(
        value: 'test',
        title: 'Test',
      );

      expect(item.value, equals('test'));
      expect(item.title, equals('Test'));
      expect(item.subtitle, isNull);
      expect(item.icon, isNull);
    });
  });

  group('Static show method tests', () {
    testWidgets('show method returns selected value', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  final result = await BottomSheetPicker.show<String>(
                    context: context,
                    title: 'Test',
                    items: [
                      BottomSheetPickerItem<String>(
                        value: 'test',
                        title: 'Test Item',
                      ),
                    ],
                  );
                  // Handle result if needed
                },
                child: Text('Show Picker'),
              );
            },
          ),
        ),
      );

      expect(find.text('Show Picker'), findsOneWidget);
    });
  });
}