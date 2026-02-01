import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/spectator_mode_settings_widget.dart';

void main() {
  testWidgets('SpectatorModeSettingsWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: SpectatorModeSettingsWidget()));
    final messageFinder = find.text('Spectator Mode Settings Widget');
    expect(messageFinder, findsOneWidget);
  });
}
