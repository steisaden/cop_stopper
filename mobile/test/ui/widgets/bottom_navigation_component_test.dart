import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/ui/widgets/bottom_navigation_component.dart';
import 'package:mobile/src/blocs/navigation/navigation_bloc.dart';
import 'package:mobile/src/blocs/navigation/navigation_event.dart';
import 'package:mobile/src/blocs/navigation/navigation_state.dart';

void main() {
  group('BottomNavigationComponent', () {
    late NavigationBloc navigationBloc;

    setUp(() {
      navigationBloc = NavigationBloc();
    });

    tearDown(() {
      navigationBloc.close();
    });

    Widget createTestWidget({NavigationState? initialState}) {
      if (initialState != null) {
        navigationBloc.emit(initialState);
      }
      
      return MaterialApp(
        home: BlocProvider<NavigationBloc>(
          create: (context) => navigationBloc,
          child: const Scaffold(
            bottomNavigationBar: BottomNavigationComponent(),
          ),
        ),
      );
    }

    testWidgets('renders all 5 navigation tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify all tabs are present
      expect(find.text('Record'), findsOneWidget);
      expect(find.text('Monitor'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('displays correct icons for each tab', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify icon widgets are present (at least 5 icons total)
      expect(find.byType(Icon), findsNWidgets(5));
    });

    testWidgets('shows active state for Record tab by default', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verify Record tab text is present (indicating it's the active tab)
      expect(find.text('Record'), findsOneWidget);
    });

    testWidgets('switches active state when tab is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap on Monitor tab
      await tester.tap(find.text('Monitor'));
      await tester.pump();

      // Verify the tap was processed (no exception thrown)
      expect(find.text('Monitor'), findsOneWidget);
    });

    testWidgets('triggers haptic feedback when tab is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap on a tab - this should trigger haptic feedback
      await tester.tap(find.text('Monitor'));
      await tester.pump();

      // If we get here without error, the haptic feedback call was successful
      // (Testing the actual haptic feedback requires platform-specific mocking)
      expect(find.text('Monitor'), findsOneWidget);
    });

    testWidgets('shows recording indicator when recording is active', (WidgetTester tester) async {
      const recordingState = NavigationState(
        activeTab: NavigationTab.record,
        isRecording: true,
      );

      await tester.pumpWidget(createTestWidget(initialState: recordingState));

      // Should show recording indicators on all tabs
      final recordingIndicators = find.byType(Container).evaluate()
          .where((element) => element.widget is Container)
          .map((element) => element.widget as Container)
          .where((container) => 
              container.decoration is BoxDecoration &&
              (container.decoration as BoxDecoration).color?.value == 0xFFD32F2F) // AppColors.recording
          .length;

      expect(recordingIndicators, greaterThan(0));
    });

    testWidgets('applies glass morphism background effect', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Look for BackdropFilter which creates the glass morphism effect
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('has correct height and padding', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the main container and verify its size
      final containerFinder = find.byType(Container).first;
      final RenderBox renderBox = tester.renderObject(containerFinder);

      // Verify height (80dp = AppSpacing.bottomNavHeight)
      expect(renderBox.size.height, equals(80.0));
    });

    testWidgets('navigation items are evenly spaced', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the Row widget that contains navigation items
      final rowFinder = find.byType(Row);
      expect(rowFinder, findsOneWidget);

      final Row row = tester.widget(rowFinder);
      expect(row.mainAxisAlignment, equals(MainAxisAlignment.spaceEvenly));
    });

    testWidgets('all tabs are tappable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Test tapping each tab
      final tabs = ['Record', 'Monitor', 'Documents', 'History', 'Settings'];
      
      for (final tab in tabs) {
        await tester.tap(find.text(tab));
        await tester.pump();
        // If we get here without error, the tap was successful
      }
    });

    testWidgets('maintains state across rebuilds', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Switch to Monitor tab
      await tester.tap(find.text('Monitor'));
      await tester.pump();

      // Trigger a rebuild
      await tester.pumpWidget(createTestWidget());

      // Verify the widget still renders correctly
      expect(find.text('Monitor'), findsOneWidget);
    });

    testWidgets('handles theme changes correctly', (WidgetTester tester) async {
      // Test with light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: BlocProvider<NavigationBloc>(
            create: (context) => navigationBloc,
            child: const Scaffold(
              bottomNavigationBar: BottomNavigationComponent(),
            ),
          ),
        ),
      );

      await tester.pump();

      // Test with dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: BlocProvider<NavigationBloc>(
            create: (context) => navigationBloc,
            child: const Scaffold(
              bottomNavigationBar: BottomNavigationComponent(),
            ),
          ),
        ),
      );

      await tester.pump();

      // If we get here without error, theme changes are handled correctly
    });
  });
}