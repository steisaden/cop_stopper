import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/blocs/emergency/emergency_state.dart';

// Simple test without complex mocking

void main() {
  group('EmergencyState', () {
    test('initial state is correct', () {
      const state = EmergencyState.initial();
      expect(state.isEmergencyModeActive, isFalse);
      expect(state.isRecording, isFalse);
      expect(state.isMonitoring, isFalse);
      expect(state.isLocationShared, isFalse);
      expect(state.showStopConfirmation, isFalse);
      expect(state.emergencyStartTime, isNull);
      expect(state.errorMessage, isNull);
    });

    test('copyWith works correctly', () {
      const initialState = EmergencyState.initial();
      final updatedState = initialState.copyWith(
        isEmergencyModeActive: true,
        isRecording: true,
        emergencyStartTime: DateTime.now(),
      );

      expect(updatedState.isEmergencyModeActive, isTrue);
      expect(updatedState.isRecording, isTrue);
      expect(updatedState.emergencyStartTime, isNotNull);
      expect(updatedState.isMonitoring, isFalse); // unchanged
    });

    test('emergency duration calculation works correctly', () {
      final startTime = DateTime.now().subtract(const Duration(minutes: 5));
      final state = EmergencyState(
        isEmergencyModeActive: true,
        isRecording: false,
        isMonitoring: false,
        isLocationShared: false,
        showStopConfirmation: false,
        emergencyStartTime: startTime,
      );

      final duration = state.emergencyDuration;
      expect(duration, isNotNull);
      expect(duration!.inMinutes, greaterThanOrEqualTo(4));
      expect(duration.inMinutes, lessThanOrEqualTo(6));
    });

    test('hasActiveActions returns correct value', () {
      const state1 = EmergencyState(
        isEmergencyModeActive: true,
        isRecording: true,
        isMonitoring: false,
        isLocationShared: false,
        showStopConfirmation: false,
      );
      expect(state1.hasActiveActions, isTrue);

      const state2 = EmergencyState(
        isEmergencyModeActive: true,
        isRecording: false,
        isMonitoring: true,
        isLocationShared: false,
        showStopConfirmation: false,
      );
      expect(state2.hasActiveActions, isTrue);

      const state3 = EmergencyState(
        isEmergencyModeActive: true,
        isRecording: false,
        isMonitoring: false,
        isLocationShared: true,
        showStopConfirmation: false,
      );
      expect(state3.hasActiveActions, isTrue);

      const state4 = EmergencyState(
        isEmergencyModeActive: true,
        isRecording: false,
        isMonitoring: false,
        isLocationShared: false,
        showStopConfirmation: false,
      );
      expect(state4.hasActiveActions, isFalse);
    });

    test('clearError removes error message', () {
      const stateWithError = EmergencyState(
        isEmergencyModeActive: false,
        isRecording: false,
        isMonitoring: false,
        isLocationShared: false,
        showStopConfirmation: false,
        errorMessage: 'Test error',
      );

      final clearedState = stateWithError.clearError();
      expect(clearedState.errorMessage, isNull);
      expect(clearedState.isEmergencyModeActive, isFalse); // other properties unchanged
    });

    test('toString returns correct string representation', () {
      const state = EmergencyState.initial();
      final string = state.toString();
      expect(string, contains('EmergencyState'));
      expect(string, contains('isEmergencyModeActive: false'));
      expect(string, contains('isRecording: false'));
    });

    test('equality works correctly', () {
      const state1 = EmergencyState.initial();
      const state2 = EmergencyState.initial();
      final state3 = state1.copyWith(isRecording: true);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });
}