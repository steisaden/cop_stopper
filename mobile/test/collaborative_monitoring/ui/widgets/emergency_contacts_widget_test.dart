import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/emergency_contacts_widget.dart';

void main() {
  testWidgets('EmergencyContactsWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: EmergencyContactsWidget()));
    final messageFinder = find.text('Emergency Contacts Widget');
    expect(messageFinder, findsOneWidget);
  });
}
