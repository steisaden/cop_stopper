import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/complaint_history_widget.dart';

void main() {
  testWidgets('ComplaintHistoryWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ComplaintHistoryWidget()));
    final messageFinder = find.text('Complaint History Widget');
    expect(messageFinder, findsOneWidget);
  });
}
