import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/fact_checking_panel.dart';

void main() {
  testWidgets('FactCheckingPanel has a message', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FactCheckingPanel()));
    final messageFinder = find.text('Fact Checking Panel');
    expect(messageFinder, findsOneWidget);
  });
}
