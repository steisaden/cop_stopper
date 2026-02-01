import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/screens/collaborative_settings_screen.dart';

void main() {
  testWidgets('CollaborativeSettingsScreen has a title and message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: CollaborativeSettingsScreen()));
    final titleFinder = find.text('Collaborative Settings');
    final messageFinder = find.text('Collaborative Settings Screen');
    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}
