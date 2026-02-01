import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/availability_status_widget.dart';

void main() {
  testWidgets('AvailabilityStatusWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AvailabilityStatusWidget()));
    final messageFinder = find.text('Availability Status Widget');
    expect(messageFinder, findsOneWidget);
  });
}
