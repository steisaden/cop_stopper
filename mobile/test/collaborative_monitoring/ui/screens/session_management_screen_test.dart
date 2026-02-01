import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/screens/session_management_screen.dart';

void main() {
  testWidgets('SessionManagementScreen has a title and message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SessionManagementScreen()));
    final titleFinder = find.text('Session Management');
    final messageFinder = find.text('Session Management Screen');
    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}
