import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/trusted_contacts_widget.dart';

void main() {
  testWidgets('TrustedContactsWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: TrustedContactsWidget()));
    final messageFinder = find.text('Trusted Contacts Widget');
    expect(messageFinder, findsOneWidget);
  });
}
