import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/real_time_transcription_widget.dart';

void main() {
  testWidgets('RealTimeTranscriptionWidget has a message', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RealTimeTranscriptionWidget()));
    final messageFinder = find.text('Real Time Transcription Widget');
    expect(messageFinder, findsOneWidget);
  });
}
