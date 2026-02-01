import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mobile/src/ui/screens/whisper_test_screen.dart';
import 'package:mobile/src/services/offline_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('WhisperTestScreen', () {
    late OfflineService offlineService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      offlineService = OfflineService(prefs);
    });

    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<OfflineService>.value(
            value: offlineService,
            child: const WhisperTestScreen(),
          ),
        ),
      );

      // Verify that the screen renders
      expect(find.text('Whisper Test'), findsOneWidget);
      expect(find.text('Test on-device Whisper transcription'), findsOneWidget);
      
      // Verify that the status message is displayed
      expect(find.text('Ready to test Whisper'), findsOneWidget);
      
      // Verify that the test buttons are present
      expect(find.widgetWithText(ElevatedButton, 'Initialize Whisper Model'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Test Transcription'), findsOneWidget);
    });

    testWidgets('shows offline indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<OfflineService>.value(
            value: offlineService,
            child: const WhisperTestScreen(),
          ),
        ),
      );

      // Verify that the offline indicator is present
      expect(find.byType(OfflineIndicator), findsOneWidget);
    });
  });
}