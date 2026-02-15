import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/ui/widgets/global_emergency_button.dart';
import 'package:mobile/src/blocs/emergency/emergency_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_state.dart';
import 'package:mobile/src/blocs/emergency/emergency_event.dart';
import 'package:mobile/src/blocs/recording/recording_bloc.dart';
import 'package:mobile/src/blocs/recording/recording_state.dart';

class MockEmergencyBloc extends Mock implements EmergencyBloc {}
class MockRecordingBloc extends Mock implements RecordingBloc {}

void main() {
  group('GlobalEmergencyButton', () {
    late MockEmergencyBloc mockEmergencyBloc;
    late MockRecordingBloc mockRecordingBloc;

    setUp(() {
      mockEmergencyBloc = MockEmergencyBloc();
      mockRecordingBloc = MockRecordingBloc();
    });

    Widget createTestWidget({EmergencyState? emergencyState}) {
      when(mockEmergencyBloc.state).thenReturn(
        emergencyState ?? const EmergencyState.initial(),
      );
      when(mockRecordingBloc.state).thenReturn(
        const RecordingState.initial(),
      );

      return MaterialApp(
        home: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider<EmergencyBloc>.value(value: mockEmergencyBloc),
              BlocProvider<RecordingBloc>.value(value: mockRecordingBloc),
            ],
            child: const GlobalEmergencyButton(),
          ),
        ),
      );
    }

    testWidgets('displays SOS text when emergency mode is inactive', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('SOS'), findsOneWidget);
      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('displays STOP text when emergency mode is active', (tester) async {
      const activeState = EmergencyState(
        isEmergencyModeActive: true,
        emergencyStartTime: null,
        isRecording: true,
        isLocationShared: true,
        isMonitoring: true,
        showStopConfirmation: false,
        errorMessage: null,
      );

      await tester.pumpWidget(createTestWidget(emergencyState: activeState));

      expect(find.text('STOP'), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });

    testWidgets('triggers emergency activation when tapped and inactive', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byType(GlobalEmergencyButton));
      await tester.pump();

      verify(mockEmergencyBloc.add(const EmergencyModeActivated())).called(1);
    });

    testWidgets('triggers emergency stop confirmation when tapped and active', (tester) async {
      const activeState = EmergencyState(
        isEmergencyModeActive: true,
        emergencyStartTime: null,
        isRecording: true,
        isLocationShared: true,
        isMonitoring: true,
        showStopConfirmation: false,
        errorMessage: null,
      );

      await tester.pumpWidget(createTestWidget(emergencyState: activeState));

      await tester.tap(find.byType(GlobalEmergencyButton));
      await tester.pump();

      verify(mockEmergencyBloc.add(const EmergencyStopConfirmationRequested())).called(1);
    });

    testWidgets('can be dragged to different positions', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final buttonFinder = find.byType(GlobalEmergencyButton);
      expect(buttonFinder, findsOneWidget);

      // Get initial position
      final initialPosition = tester.getCenter(buttonFinder);

      // Drag the button
      await tester.drag(buttonFinder, const Offset(100, 100));
      await tester.pumpAndSettle();

      // Verify button moved (position should be different)
      final newPosition = tester.getCenter(buttonFinder);
      expect(newPosition, isNot(equals(initialPosition)));
    });

    testWidgets('shows emergency status indicator when active', (tester) async {
      const activeState = EmergencyState(
        isEmergencyModeActive: true,
        emergencyStartTime: null,
        isRecording: true,
        isLocationShared: true,
        isMonitoring: true,
        showStopConfirmation: false,
        errorMessage: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<EmergencyBloc>.value(value: mockEmergencyBloc),
                BlocProvider<RecordingBloc>.value(value: mockRecordingBloc),
              ],
              child: const Stack(
                children: [
                  GlobalEmergencyButton(),
                  EmergencyStatusIndicator(),
                ],
              ),
            ),
          ),
        ),
      );

      when(mockEmergencyBloc.state).thenReturn(activeState);
      await tester.pump();

      expect(find.text('EMERGENCY MODE ACTIVE'), findsOneWidget);
      expect(find.byIcon(Icons.emergency), findsOneWidget);
    });
  });
}