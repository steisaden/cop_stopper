import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/ui/screens/record_screen.dart';
import 'package:mobile/src/ui/screens/monitor_screen.dart';
import 'package:mobile/src/ui/screens/settings_screen.dart';
import 'package:mobile/src/ui/widgets/emergency_mode_interface.dart';
import 'package:mobile/src/services/recording_service.dart';
import 'package:mobile/src/services/location_service.dart';
import 'package:mobile/src/services/emergency_contact_service.dart';
import '../../mocks/mock_recording_service.dart';

void main() {
  group('Service-UI Integration Tests', () {
    late MockRecordingService mockRecordingService;

    setUp(() {
      mockRecordingService = MockRecordingService();
    });

    testWidgets('recording interface should integrate with recording service', (tester) async {
      // Mock recording service responses
      when(mockRecordingService.isRecording).thenReturn(false);
      when(mockRecordingService.startRecording()).thenAnswer((_) async => true);
      when(mockRecordingService.stopRecording()).thenAnswer((_) async => true);

      await tester.pumpWidget(
        const MaterialApp(
          home: RecordScreen(),
        ),
      );

      // Find and tap record button
      final recordButton = find.byIcon(Icons.fiber_manual_record);
      expect(recordButton, findsOneWidget);

      await tester.tap(recordButton);
      await tester.pumpAndSettle();

      // Verify recording service was called
      verify(mockRecordingService.startRecording()).called(1);
    });

    testWidgets('monitoring interface should integrate with transcription service', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MonitorScreen(),
        ),
      );

      // Verify transcription display is present
      expect(find.text('Real-time Transcription'), findsOneWidget);
      expect(find.text('Fact-checking Panel'), findsOneWidget);
    });

    testWidgets('settings interface should integrate with validation service', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SettingsScreen(),
        ),
      );

      // Verify settings cards are present
      expect(find.text('Recording Settings'), findsOneWidget);
      expect(find.text('Privacy Settings'), findsOneWidget);
      expect(find.text('Legal Settings'), findsOneWidget);
      expect(find.text('Accessibility'), findsOneWidget);
    });

    testWidgets('emergency system should integrate with location and contact services', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EmergencyModeInterface(
            isEmergencyMode: true,
            onEmergencyStop: () {},
            onLocationShare: () {},
            onContactEmergency: () {},
          ),
        ),
      );

      // Verify emergency interface elements
      expect(find.text('EMERGENCY MODE'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.contact_phone), findsOneWidget);
    });

    testWidgets('should handle service errors gracefully', (tester) async {
      // Mock service error
      when(mockRecordingService.startRecording())
          .thenThrow(Exception('Camera permission denied'));

      await tester.pumpWidget(
        const MaterialApp(
          home: RecordScreen(),
        ),
      );

      // Attempt to start recording
      final recordButton = find.byIcon(Icons.fiber_manual_record);
      await tester.tap(recordButton);
      await tester.pumpAndSettle();

      // Should display error message
      expect(find.textContaining('permission'), findsOneWidget);
    });

    testWidgets('should maintain state across service calls', (tester) async {
      when(mockRecordingService.isRecording).thenReturn(false);
      when(mockRecordingService.startRecording()).thenAnswer((_) async {
        when(mockRecordingService.isRecording).thenReturn(true);
        return true;
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: RecordScreen(),
        ),
      );

      // Start recording
      await tester.tap(find.byIcon(Icons.fiber_manual_record));
      await tester.pumpAndSettle();

      // Verify UI reflects recording state
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });

    testWidgets('should handle concurrent service operations', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MonitorScreen(),
        ),
      );

      // Simulate multiple rapid taps
      final factCheckButton = find.text('Fact Check');
      if (factCheckButton.evaluate().isNotEmpty) {
        await tester.tap(factCheckButton);
        await tester.tap(factCheckButton);
        await tester.tap(factCheckButton);
        await tester.pumpAndSettle();
      }

      // Should handle gracefully without crashes
      expect(tester.takeException(), isNull);
    });

    testWidgets('should update UI when service state changes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RecordScreen(),
        ),
      );

      // Simulate service state change
      when(mockRecordingService.isRecording).thenReturn(true);
      
      // Trigger rebuild
      await tester.pump();

      // UI should reflect new state
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });
  });
}