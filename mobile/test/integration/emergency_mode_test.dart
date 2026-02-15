import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/blocs/emergency/emergency_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_event.dart';
import 'package:mobile/src/blocs/emergency/emergency_state.dart';
import 'package:mobile/src/blocs/navigation/navigation_event.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/location_service.dart';
import 'package:mobile/src/services/navigation_service.dart';
import 'package:mobile/src/ui/widgets/emergency_button.dart';
import 'package:mobile/src/ui/widgets/emergency_mode_interface.dart';
import 'package:mobile/src/ui/widgets/emergency_stop_confirmation_dialog.dart';

// Simple mock implementations for testing
class MockRecordingService extends Mock implements RecordingService {
  @override
  bool get isRecording => false;
}

class MockLocationService extends Mock implements LocationService {}
class MockNavigationService extends Mock implements NavigationService {}

void main() {
  group('Emergency Mode Integration Tests', () {
    late MockRecordingService mockRecordingService;
    late MockLocationService mockLocationService;
    late MockNavigationService mockNavigationService;
    late EmergencyBloc emergencyBloc;

    setUp(() {
      mockRecordingService = MockRecordingService();
      mockLocationService = MockLocationService();
      mockNavigationService = MockNavigationService();
      
      emergencyBloc = EmergencyBloc(
        recordingService: mockRecordingService,
        locationService: mockLocationService,
        navigationService: mockNavigationService,
      );

      // Setup default mock behaviors
      when(mockRecordingService.isRecording).thenReturn(false);
      when(mockRecordingService.startAudioVideoRecording())
          .thenAnswer((_) async {});
      when(mockRecordingService.stopAudioVideoRecording())
          .thenAnswer((_) async => 'test_recording.mp4');
      when(mockLocationService.hasLocationPermission())
          .thenAnswer((_) async => true);
      // Simplified mock setup
      when(mockLocationService.getCurrentLocation())
          .thenAnswer((_) async => throw UnimplementedError('Mock not implemented'));
    });

    tearDown(() {
      emergencyBloc.close();
    });

    testWidgets('Emergency button activates emergency mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EmergencyBloc>(
            create: (_) => emergencyBloc,
            child: const Scaffold(
              body: Center(
                child: EmergencyButton(),
              ),
            ),
          ),
        ),
      );

      // Find and tap the emergency button
      final emergencyButton = find.byType(EmergencyButton);
      expect(emergencyButton, findsOneWidget);

      await tester.tap(emergencyButton);
      await tester.pump();

      // Verify emergency mode is activated
      expect(emergencyBloc.state.isEmergencyModeActive, isTrue);
      expect(emergencyBloc.state.emergencyStartTime, isNotNull);
    });

    testWidgets('Emergency mode interface shows correct status', (tester) async {
      // Activate emergency mode
      emergencyBloc.add(const EmergencyModeActivated());
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EmergencyBloc>(
            create: (_) => emergencyBloc,
            child: const Scaffold(
              body: EmergencyModeInterface(),
            ),
          ),
        ),
      );

      // Verify emergency mode interface is displayed
      expect(find.text('EMERGENCY MODE ACTIVE'), findsOneWidget);
      expect(find.text('Duration:'), findsOneWidget);
      expect(find.byIcon(Icons.emergency), findsWidgets);
    });

    testWidgets('Emergency mode starts recording and monitoring', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EmergencyBloc>(
            create: (_) => emergencyBloc,
            child: const Scaffold(
              body: EmergencyButton(),
            ),
          ),
        ),
      );

      // Tap emergency button
      await tester.tap(find.byType(EmergencyButton));
      await tester.pumpAndSettle();

      // Verify recording service was called
      verify(mockRecordingService.startAudioVideoRecording()).called(1);
      
      // Verify navigation service was called to switch to monitor tab
      verify(mockNavigationService.navigateToTab(NavigationTab.monitor)).called(1);
      
      // Verify location service was called
      verify(mockLocationService.hasLocationPermission()).called(1);
      verify(mockLocationService.getCurrentLocation()).called(1);
    });

    testWidgets('Emergency mode action buttons work correctly', (tester) async {
      // Start with emergency mode active
      emergencyBloc.add(const EmergencyModeActivated());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EmergencyBloc>(
            create: (_) => emergencyBloc,
            child: const Scaffold(
              body: EmergencyModeInterface(),
            ),
          ),
        ),
      );

      // Test recording button
      final recordingButton = find.text('STOP\nRECORDING');
      expect(recordingButton, findsOneWidget);
      
      await tester.tap(recordingButton);
      await tester.pump();
      
      verify(mockRecordingService.stopAudioVideoRecording()).called(1);

      // Test location sharing button
      final locationButton = find.text('SHARE\nLOCATION');
      expect(locationButton, findsOneWidget);
      
      await tester.tap(locationButton);
      await tester.pump();
      
      // Location should already be shared from initial activation
      verify(mockLocationService.getCurrentLocation()).called(2);
    });

    testWidgets('Stop confirmation dialog prevents accidental stopping', (tester) async {
      // Start with emergency mode active
      emergencyBloc.add(const EmergencyModeActivated());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EmergencyBloc>(
            create: (_) => emergencyBloc,
            child: const Scaffold(
              body: EmergencyModeInterface(),
            ),
          ),
        ),
      );

      // Tap stop emergency mode button
      final stopButton = find.text('STOP EMERGENCY MODE');
      expect(stopButton, findsOneWidget);
      
      await tester.tap(stopButton);
      await tester.pump();

      // Verify confirmation dialog is requested
      expect(emergencyBloc.state.showStopConfirmation, isTrue);
    });

    testWidgets('Stop confirmation dialog shows countdown', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EmergencyBloc>(
            create: (_) => emergencyBloc,
            child: const Scaffold(
              body: EmergencyStopConfirmationDialog(),
            ),
          ),
        ),
      );

      // Verify dialog elements
      expect(find.text('Stop Emergency Mode?'), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('STOP'), findsOneWidget);

      // Verify countdown is shown
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Please wait to prevent accidental stopping'), findsOneWidget);

      // Wait for countdown to complete
      await tester.pump(const Duration(seconds: 4));

      // Verify stop button is now enabled
      final stopButton = find.text('STOP');
      expect(tester.widget<ElevatedButton>(stopButton).enabled, isTrue);
    });

    testWidgets('Emergency mode can be stopped after confirmation', (tester) async {
      // Start with emergency mode active
      emergencyBloc.add(const EmergencyModeActivated());
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EmergencyBloc>(
            create: (_) => emergencyBloc,
            child: const Scaffold(
              body: EmergencyStopConfirmationDialog(),
            ),
          ),
        ),
      );

      // Wait for countdown to complete
      await tester.pump(const Duration(seconds: 4));

      // Tap stop button
      final stopButton = find.text('STOP');
      await tester.tap(stopButton);
      await tester.pump();

      // Verify emergency mode is deactivated
      expect(emergencyBloc.state.isEmergencyModeActive, isFalse);
      verify(mockRecordingService.stopAudioVideoRecording()).called(1);
    });

    testWidgets('Emergency mode handles errors gracefully', (tester) async {
      // Setup recording service to throw error
      when(mockRecordingService.startAudioVideoRecording())
          .thenThrow(Exception('Recording failed'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EmergencyBloc>(
            create: (_) => emergencyBloc,
            child: const Scaffold(
              body: EmergencyButton(),
            ),
          ),
        ),
      );

      // Tap emergency button
      await tester.tap(find.byType(EmergencyButton));
      await tester.pumpAndSettle();

      // Verify error is handled
      expect(emergencyBloc.state.errorMessage, contains('Failed to activate emergency mode'));
    });

    testWidgets('Floating emergency button can be positioned', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Center(child: Text('Main Content')),
                FloatingEmergencyButton(
                  alignment: Alignment.bottomLeft,
                  margin: EdgeInsets.all(20),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify floating button is present
      expect(find.byType(FloatingEmergencyButton), findsOneWidget);
      expect(find.byType(EmergencyButton), findsOneWidget);
    });

    testWidgets('Emergency mode overlay shows over content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<EmergencyBloc>(
            create: (_) => emergencyBloc,
            child: const EmergencyModeOverlay(
              child: Scaffold(
                body: Center(child: Text('Main Content')),
              ),
            ),
          ),
        ),
      );

      // Initially, only main content should be visible
      expect(find.text('Main Content'), findsOneWidget);
      expect(find.text('EMERGENCY MODE ACTIVE'), findsNothing);

      // Activate emergency mode
      emergencyBloc.add(const EmergencyModeActivated());
      await tester.pumpAndSettle();

      // Now emergency interface should be visible
      expect(find.text('EMERGENCY MODE ACTIVE'), findsOneWidget);
    });
  });
}

