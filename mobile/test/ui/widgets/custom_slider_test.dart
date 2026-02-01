import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/custom_slider.dart';
import '../../test_helpers.dart';

void main() {
  group('CustomSlider Widget Tests', () {
    testWidgets('renders with default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
          ),
        ),
      );

      expect(find.byType(CustomSlider), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('displays min and max values', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
          ),
        ),
      );

      expect(find.text('0.0'), findsOneWidget);
      expect(find.text('100.0'), findsOneWidget);
    });

    testWidgets('displays current value', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomSlider(
            value: 75.0,
            min: 0.0,
            max: 100.0,
          ),
        ),
      );

      expect(find.text('75.0'), findsOneWidget);
    });

    testWidgets('uses custom value formatter', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomSlider(
            value: 128.0,
            min: 64.0,
            max: 320.0,
            valueFormatter: (value) => '${value.round()} kbps',
          ),
        ),
      );

      expect(find.text('128 kbps'), findsOneWidget);
      expect(find.text('64 kbps'), findsOneWidget);
      expect(find.text('320 kbps'), findsOneWidget);
    });

    testWidgets('handles value changes', (WidgetTester tester) async {
      double value = 50.0;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: StatefulBuilder(
            builder: (context, setState) {
              return CustomSlider(
                value: value,
                min: 0.0,
                max: 100.0,
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

      // Find the slider and drag it
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(100, 0));
      await tester.pumpAndSettle();

      // Value should have changed
      expect(value, greaterThan(50.0));
    });

    testWidgets('shows preview when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            showPreview: true,
            previewBuilder: (value) => Text('Preview: $value'),
          ),
        ),
      );

      expect(find.text('Preview: 50.0'), findsOneWidget);
    });

    testWidgets('handles divisions correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomSlider(
            value: 5.0,
            min: 0.0,
            max: 10.0,
            divisions: 10,
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget); // Should show integer when divisions are set
    });

    testWidgets('calls interaction callbacks', (WidgetTester tester) async {
      bool startCalled = false;
      bool endCalled = false;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
            onChangeStart: (value) => startCalled = true,
            onChangeEnd: (value) => endCalled = true,
          ),
        ),
      );

      // Start dragging
      final slider = find.byType(Slider);
      final gesture = await tester.startGesture(tester.getCenter(slider));
      await tester.pump();
      
      expect(startCalled, isTrue);
      
      // End dragging
      await gesture.up();
      await tester.pumpAndSettle();
      
      expect(endCalled, isTrue);
    });
  });

  group('Animation Tests', () {
    testWidgets('animates scale during interaction', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomSlider(
            value: 50.0,
            min: 0.0,
            max: 100.0,
          ),
        ),
      );

      // Start interaction
      final slider = find.byType(Slider);
      await tester.startGesture(tester.getCenter(slider));
      await tester.pump();
      
      // Animation should be running
      expect(find.byType(AnimatedBuilder), findsOneWidget);
      
      await tester.pumpAndSettle();
    });
  });
}