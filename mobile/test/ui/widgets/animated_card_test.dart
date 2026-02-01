import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/animated_card.dart';
import '../../test_helpers.dart';

void main() {
  group('AnimatedCard Widget Tests', () {
    testWidgets('renders child widget in normal state', (WidgetTester tester) async {
      const testText = 'Test Content';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.normal,
            child: Text(testText),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('shows loading indicator in loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.loading,
            child: Text('Hidden Content'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows custom loading widget when provided', (WidgetTester tester) async {
      const customLoadingWidget = Text('Custom Loading');
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.loading,
            loadingWidget: customLoadingWidget,
            child: Text('Hidden Content'),
          ),
        ),
      );

      expect(find.text('Custom Loading'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows success state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.success,
            child: Text('Original Content'),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Original Content'), findsNothing);
    });

    testWidgets('shows custom success widget when provided', (WidgetTester tester) async {
      const customSuccessWidget = Text('Custom Success');
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.success,
            successWidget: customSuccessWidget,
            child: Text('Original Content'),
          ),
        ),
      );

      expect(find.text('Custom Success'), findsOneWidget);
      expect(find.text('Success'), findsNothing);
    });

    testWidgets('shows error state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.error,
            child: Text('Original Content'),
          ),
        ),
      );

      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Original Content'), findsNothing);
    });

    testWidgets('shows custom error widget when provided', (WidgetTester tester) async {
      const customErrorWidget = Text('Custom Error');
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.error,
            errorWidget: customErrorWidget,
            child: Text('Original Content'),
          ),
        ),
      );

      expect(find.text('Custom Error'), findsOneWidget);
      expect(find.text('Error'), findsNothing);
    });

    testWidgets('handles tap events in normal state', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AnimatedCard(
            state: CardState.normal,
            onTap: () => tapped = true,
            child: const Text('Tappable Card'),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedCard));
      expect(tapped, isTrue);
    });

    testWidgets('ignores tap events in loading state', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AnimatedCard(
            state: CardState.loading,
            onTap: () => tapped = true,
            child: const Text('Loading Card'),
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedCard));
      expect(tapped, isFalse);
    });

    testWidgets('calls onStateChanged when state changes', (WidgetTester tester) async {
      CardState? changedState;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AnimatedCard(
            state: CardState.normal,
            onStateChanged: (state) => changedState = state,
            child: const Text('State Change Test'),
          ),
        ),
      );

      // Change state
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AnimatedCard(
            state: CardState.loading,
            onStateChanged: (state) => changedState = state,
            child: const Text('State Change Test'),
          ),
        ),
      );

      expect(changedState, CardState.loading);
    });

    testWidgets('applies custom animation duration', (WidgetTester tester) async {
      const customDuration = Duration(milliseconds: 1000);
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.normal,
            animationDuration: customDuration,
            child: Text('Custom Duration'),
          ),
        ),
      );

      // The widget should render without issues
      expect(find.text('Custom Duration'), findsOneWidget);
    });

    testWidgets('applies semantic label correctly', (WidgetTester tester) async {
      const semanticLabel = 'Animated Card Label';
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.normal,
            semanticLabel: semanticLabel,
            child: Text('Test'),
          ),
        ),
      );

      // Check that the semantic label is applied to the BaseCard
      final semantics = tester.widget<Semantics>(
        find.descendant(
          of: find.byType(AnimatedCard),
          matching: find.byType(Semantics),
        ).first,
      );
      expect(semantics.properties.label, semanticLabel);
    });
  });

  group('StatefulAnimatedCard Widget Tests', () {
    testWidgets('renders with initial state', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const StatefulAnimatedCard(
            initialState: CardState.success,
            child: Text('Stateful Card'),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('allows external state control', (WidgetTester tester) async {
      final GlobalKey<StatefulAnimatedCardState> cardKey = 
          GlobalKey<StatefulAnimatedCardState>();
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: StatefulAnimatedCard(
            key: cardKey,
            initialState: CardState.normal,
            child: const Text('Controllable Card'),
          ),
        ),
      );

      expect(find.text('Controllable Card'), findsOneWidget);
      expect(cardKey.currentState?.currentState, CardState.normal);

      // Change state externally
      cardKey.currentState?.setCardState(CardState.loading);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(cardKey.currentState?.currentState, CardState.loading);
    });

    testWidgets('handles tap events correctly', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: StatefulAnimatedCard(
            initialState: CardState.normal,
            onTap: () => tapped = true,
            child: const Text('Tappable Stateful Card'),
          ),
        ),
      );

      await tester.tap(find.byType(StatefulAnimatedCard));
      expect(tapped, isTrue);
    });

    testWidgets('applies custom properties correctly', (WidgetTester tester) async {
      const customPadding = EdgeInsets.all(32.0);
      const customMargin = EdgeInsets.all(16.0);
      const customBackgroundColor = Colors.purple;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const StatefulAnimatedCard(
            initialState: CardState.normal,
            padding: customPadding,
            margin: customMargin,
            backgroundColor: customBackgroundColor,
            child: Text('Custom Properties'),
          ),
        ),
      );

      expect(find.text('Custom Properties'), findsOneWidget);
    });
  });

  group('AnimatedCard Animation Tests', () {
    testWidgets('renders correctly during animations', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: AnimatedCard(
            state: CardState.normal,
            onTap: () {},
            child: const Text('Animation Test'),
          ),
        ),
      );

      expect(find.text('Animation Test'), findsOneWidget);
      
      // Tap the card
      await tester.tap(find.byType(AnimatedCard));
      await tester.pump();
      
      // Should still render correctly
      expect(find.text('Animation Test'), findsOneWidget);
    });

    testWidgets('handles state transitions without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.normal,
            child: Text('State Test'),
          ),
        ),
      );

      expect(find.text('State Test'), findsOneWidget);

      // Change to loading state
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const AnimatedCard(
            state: CardState.loading,
            child: Text('State Test'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}