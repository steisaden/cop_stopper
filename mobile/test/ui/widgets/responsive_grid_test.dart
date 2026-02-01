import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/responsive_grid.dart';
import '../../test_helpers.dart';

void main() {
  group('ResponsiveGrid Widget Tests', () {
    testWidgets('renders children correctly', (WidgetTester tester) async {
      final children = [
        const Text('Item 1'),
        const Text('Item 2'),
        const Text('Item 3'),
      ];

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ResponsiveGrid(
            children: children,
            shrinkWrap: true,
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('uses custom cross axis count when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ResponsiveGrid(
            crossAxisCount: 2,
            shrinkWrap: true,
            children: const [
              Text('Item 1'),
              Text('Item 2'),
            ],
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('adapts to different screen sizes', (WidgetTester tester) async {
      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ResponsiveGrid(
            shrinkWrap: true,
            children: const [Text('Item 1')],
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('applies custom spacing correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ResponsiveGrid(
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 30.0,
            shrinkWrap: true,
            children: const [
              Text('Item 1'),
              Text('Item 2'),
            ],
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('applies custom padding correctly', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(32.0);

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ResponsiveGrid(
            padding: customPadding,
            shrinkWrap: true,
            children: const [Text('Item 1')],
          ),
        ),
      );

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(ResponsiveGrid),
          matching: find.byType(Padding),
        ).first,
      );

      expect(padding.padding, customPadding);
    });
  });

  group('ResponsiveLayoutBuilder Widget Tests', () {
    testWidgets('renders mobile layout on small screens', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const ResponsiveLayoutBuilder(
            mobile: Text('Mobile Layout'),
            tablet: Text('Tablet Layout'),
            desktop: Text('Desktop Layout'),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsNothing);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('renders tablet layout on medium screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1200)),
            child: const ResponsiveLayoutBuilder(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsOneWidget);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('renders desktop layout on large screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 1000)),
            child: const ResponsiveLayoutBuilder(
              mobile: Text('Mobile Layout'),
              tablet: Text('Tablet Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsNothing);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsOneWidget);
    });

    testWidgets('falls back to mobile when tablet is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1200)),
            child: const ResponsiveLayoutBuilder(
              mobile: Text('Mobile Layout'),
              desktop: Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Desktop Layout'), findsNothing);
    });
  });

  group('ResponsiveCardGrid Widget Tests', () {
    testWidgets('renders cards correctly', (WidgetTester tester) async {
      final cards = [
        const Card(child: Text('Card 1')),
        const Card(child: Text('Card 2')),
        const Card(child: Text('Card 3')),
      ];

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: ResponsiveCardGrid(
            cards: cards,
            shrinkWrap: true,
          ),
        ),
      );

      expect(find.text('Card 1'), findsOneWidget);
      expect(find.text('Card 2'), findsOneWidget);
      expect(find.text('Card 3'), findsOneWidget);
    });

    testWidgets('uses different layouts for different screen sizes', (WidgetTester tester) async {
      final cards = [
        const Card(child: Text('Card 1')),
        const Card(child: Text('Card 2')),
      ];

      // Test mobile layout (should use ListView)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: ResponsiveCardGrid(
              cards: cards,
              shrinkWrap: true,
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);

      // Test tablet layout (should use GridView)
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1200)),
            child: ResponsiveCardGrid(
              cards: cards,
              shrinkWrap: true,
            ),
          ),
        ),
      );

      expect(find.byType(ResponsiveGrid), findsOneWidget);
    });
  });

  group('ResponsiveContainer Widget Tests', () {
    testWidgets('renders child correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const ResponsiveContainer(
            child: Text('Container Content'),
          ),
        ),
      );

      expect(find.text('Container Content'), findsOneWidget);
    });

    testWidgets('applies custom padding correctly', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(32.0);

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const ResponsiveContainer(
            padding: customPadding,
            child: Text('Container Content'),
          ),
        ),
      );

      expect(find.text('Container Content'), findsOneWidget);
    });

    testWidgets('applies custom margin correctly', (WidgetTester tester) async {
      const customMargin = EdgeInsets.all(16.0);

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const ResponsiveContainer(
            margin: customMargin,
            child: Text('Container Content'),
          ),
        ),
      );

      expect(find.text('Container Content'), findsOneWidget);
    });

    testWidgets('respects max width constraint', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const ResponsiveContainer(
            maxWidth: 500.0,
            child: Text('Container Content'),
          ),
        ),
      );

      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(ResponsiveContainer),
          matching: find.byType(ConstrainedBox),
        ).first,
      );

      expect(constrainedBox.constraints.maxWidth, 500.0);
    });
  });

  group('SafeAreaWrapper Widget Tests', () {
    testWidgets('renders child correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SafeAreaWrapper(
            child: Text('Safe Area Content'),
          ),
        ),
      );

      expect(find.text('Safe Area Content'), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('applies safe area settings correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SafeAreaWrapper(
            top: false,
            bottom: true,
            left: false,
            right: true,
            child: Text('Safe Area Content'),
          ),
        ),
      );

      final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea.top, false);
      expect(safeArea.bottom, true);
      expect(safeArea.left, false);
      expect(safeArea.right, true);
    });

    testWidgets('applies minimum padding correctly', (WidgetTester tester) async {
      const minimumPadding = EdgeInsets.all(8.0);

      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const SafeAreaWrapper(
            minimum: minimumPadding,
            child: Text('Safe Area Content'),
          ),
        ),
      );

      final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea.minimum, minimumPadding);
    });
  });

  group('OrientationAwareLayout Widget Tests', () {
    testWidgets('renders portrait layout by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const OrientationAwareLayout(
            portrait: Text('Portrait Layout'),
            landscape: Text('Landscape Layout'),
          ),
        ),
      );

      expect(find.text('Portrait Layout'), findsOneWidget);
      expect(find.text('Landscape Layout'), findsNothing);
    });

    testWidgets('falls back to portrait when landscape is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const OrientationAwareLayout(
            portrait: Text('Portrait Layout'),
          ),
        ),
      );

      expect(find.text('Portrait Layout'), findsOneWidget);
    });
  });

  group('ResponsiveBreakpoints Tests', () {
    testWidgets('correctly identifies mobile screens', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: Builder(
            builder: (context) {
              final isMobile = ResponsiveBreakpoints.isMobile(context);
              final isTablet = ResponsiveBreakpoints.isTablet(context);
              final isDesktop = ResponsiveBreakpoints.isDesktop(context);
              final screenType = ResponsiveBreakpoints.getScreenType(context);
              
              return Column(
                children: [
                  Text('Mobile: $isMobile'),
                  Text('Tablet: $isTablet'),
                  Text('Desktop: $isDesktop'),
                  Text('Type: $screenType'),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Mobile: true'), findsOneWidget);
      expect(find.text('Tablet: false'), findsOneWidget);
      expect(find.text('Desktop: false'), findsOneWidget);
      expect(find.text('Type: ScreenType.mobile'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('correctly identifies tablet screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1200)),
            child: Builder(
              builder: (context) {
                final isMobile = ResponsiveBreakpoints.isMobile(context);
                final isTablet = ResponsiveBreakpoints.isTablet(context);
                final isDesktop = ResponsiveBreakpoints.isDesktop(context);
                final screenType = ResponsiveBreakpoints.getScreenType(context);
                
                return Column(
                  children: [
                    Text('Mobile: $isMobile'),
                    Text('Tablet: $isTablet'),
                    Text('Desktop: $isDesktop'),
                    Text('Type: $screenType'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Mobile: false'), findsOneWidget);
      expect(find.text('Tablet: true'), findsOneWidget);
      expect(find.text('Desktop: false'), findsOneWidget);
      expect(find.text('Type: ScreenType.tablet'), findsOneWidget);
    });

    testWidgets('correctly identifies desktop screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1400, 1000)),
            child: Builder(
              builder: (context) {
                final isMobile = ResponsiveBreakpoints.isMobile(context);
                final isTablet = ResponsiveBreakpoints.isTablet(context);
                final isDesktop = ResponsiveBreakpoints.isDesktop(context);
                final screenType = ResponsiveBreakpoints.getScreenType(context);
                
                return Column(
                  children: [
                    Text('Mobile: $isMobile'),
                    Text('Tablet: $isTablet'),
                    Text('Desktop: $isDesktop'),
                    Text('Type: $screenType'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Mobile: false'), findsOneWidget);
      expect(find.text('Tablet: false'), findsOneWidget);
      expect(find.text('Desktop: true'), findsOneWidget);
      expect(find.text('Type: ScreenType.desktop'), findsOneWidget);
    });

    testWidgets('getResponsiveValue returns correct values', (WidgetTester tester) async {
      // Test mobile
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final value = ResponsiveBreakpoints.getResponsiveValue<String>(
                  context,
                  mobile: 'Mobile Value',
                  tablet: 'Tablet Value',
                  desktop: 'Desktop Value',
                );
                
                return Text('Value: $value');
              },
            ),
          ),
        ),
      );

      expect(find.text('Value: Mobile Value'), findsOneWidget);

      // Test tablet
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 1200)),
            child: Builder(
              builder: (context) {
                final value = ResponsiveBreakpoints.getResponsiveValue<String>(
                  context,
                  mobile: 'Mobile Value',
                  tablet: 'Tablet Value',
                  desktop: 'Desktop Value',
                );
                
                return Text('Value: $value');
              },
            ),
          ),
        ),
      );

      expect(find.text('Value: Tablet Value'), findsOneWidget);
    });
  });
}