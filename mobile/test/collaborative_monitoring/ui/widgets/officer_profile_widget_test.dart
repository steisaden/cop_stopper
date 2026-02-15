import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/officer_profile_widget.dart';

void main() {
  testWidgets('OfficerProfileWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OfficerProfileWidget()));
    final messageFinder = find.text('Officer Profile Widget');
    expect(messageFinder, findsOneWidget);
  });
}
