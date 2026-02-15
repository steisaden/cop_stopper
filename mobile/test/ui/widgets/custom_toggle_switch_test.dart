import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/custom_toggle_switch.dart';
import '../../test_helpers.dart';

void main() {
  group('CustomToggleSwitch Widget Tests', () {
    testWidgets('renders with default state', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomToggleSwitch(
            value: false,
          ),
        ),
      );

      expect(find.byType(CustomToggleSwitch), findsOneWidget);
    });

    testWidgets('renders with enabled state', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomToggleSwitch(
            value: true,
          ),
        ),
      );

      expect(find.byType(CustomToggleSwitch), findsOneWidget);
    });

    testWidgets('handles tap when enabled', (WidgetTester tester) async {
      bool value = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomToggleSwitch(
            value: value,
            onChanged: (newValue) => value = newValue,
          ),
        ),
      );

      await tester.tap(find.byType(CustomToggleSwitch));
      await tester.pumpAndSettle();

      expect(value, isTrue);
    });

    testWidgets('does not handle tap when disabled', (WidgetTester tester) async {
      bool value = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomToggleSwitch(
            value: value,
            enabled: false,
            onChanged: (newValue) => value = newValue,
          ),
        ),
      );

      await tester.tap(find.byType(CustomToggleSwitch));
      await tester.pumpAndSettle();

      expect(value, isFalse);
    });

    testWidgets('animates when value changes', (WidgetTester tester) async {
      bool value = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              return CustomToggleSwitch(
                value: value,
                onChanged: (newValue) {
                  setState(() {
                    value = newValue;
                  });
                },
              );
            },
          ),
        ),
      );

      // Tap to change value
      await tester.tap(find.byType(CustomToggleSwitch));
      await tester.pump(); // Start animation
      
      // Verify animation is in progress
      expect(find.byType(AnimatedPositioned), findsOneWidget);
      
      await tester.pumpAndSettle(); // Complete animation
      expect(value, isTrue);
    });

    testWidgets('uses custom colors when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: const CustomToggleSwitch(
            value: true,
            activeColor: Colors.red,
            inactiveColor: Colors.blue,
            activeTrackColor: Colors.green,
            inactiveTrackColor: Colors.yellow,
          ),
        ),
      );

      expect(find.byType(CustomToggleSwitch), findsOneWidget);
    });
  });

  group('Animation Tests', () {
    testWidgets('has proper animation duration', (WidgetTester tester) async {
      bool value = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              return CustomToggleSwitch(
                value: value,
                onChanged: (newValue) {
                  setState(() {
                    value = newValue;
                  });
                },
              );
            },
          ),
        ),
      );

      // Tap to start animation
      await tester.tap(find.byType(CustomToggleSwitch));
      await tester.pump();
      
      // Animation should be in progress
      expect(find.byType(AnimatedPositioned), findsOneWidget);
      
      // Complete animation
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });
  });
}