import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/notification_settings_widget.dart';

void main() {
  testWidgets('NotificationSettingsWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: NotificationSettingsWidget()));
    final messageFinder = find.text('Notification Settings Widget');
    expect(messageFinder, findsOneWidget);
  });
}
