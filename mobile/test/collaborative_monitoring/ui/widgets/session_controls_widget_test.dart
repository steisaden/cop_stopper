import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/session_controls_widget.dart';

void main() {
  testWidgets('SessionControlsWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SessionControlsWidget()));
    final messageFinder = find.text('Session Controls Widget');
    expect(messageFinder, findsOneWidget);
  });
}
