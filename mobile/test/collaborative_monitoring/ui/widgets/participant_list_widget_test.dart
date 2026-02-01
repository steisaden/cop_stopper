import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/participant_list_widget.dart';

void main() {
  testWidgets('ParticipantListWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ParticipantListWidget()));
    final messageFinder = find.text('Participant List Widget');
    expect(messageFinder, findsOneWidget);
  });
}
