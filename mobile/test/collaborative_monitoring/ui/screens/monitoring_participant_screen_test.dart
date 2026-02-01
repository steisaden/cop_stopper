import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/screens/monitoring_participant_screen.dart';

void main() {
  testWidgets('MonitoringParticipantScreen has a title and message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: MonitoringParticipantScreen()));
    final titleFinder = find.text('Monitoring Participant');
    final messageFinder = find.text('Monitoring Participant Screen');
    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}
