import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/blocs/recording/recording_state.dart';

void main() {

  group('RecordingState', () {
    test('initial state has correct default values', () {
      const state = RecordingState.initial();
      
      expect(state.cameraController, isNull);
      expect(state.isRecording, isFalse);
      expect(state.isAudioOnly, isFalse);
      expect(state.isFlashOn, isFalse);
      expect(state.hasFlash, isFalse);
      expect(state.isPaused, isFalse);
      expect(state.recordingDuration, equals(Duration.zero));
      expect(state.audioLevel, equals(0.0));
      expect(state.zoomLevel, equals(1.0));
      expect(state.availableStorageGB, equals(0.0));
      expect(state.isLowStorage, isFalse);
      expect(state.showLowStorageWarning, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.errorCode, isNull);
      expect(state.status, equals(RecordingStatus.initial));
      expect(state.availableCameras, isEmpty);
      expect(state.activeCameraIndex, equals(0));
    });

    test('copyWith works correctly', () {
      const initialState = RecordingState.initial();
      final updatedState = initialState.copyWith(
        isRecording: true,
        isAudioOnly: true,
        recordingDuration: const Duration(minutes: 1),
      );

      expect(updatedState.isRecording, isTrue);
      expect(updatedState.isAudioOnly, isTrue);
      expect(updatedState.recordingDuration, equals(const Duration(minutes: 1)));
      expect(updatedState.isFlashOn, equals(initialState.isFlashOn));
      expect(updatedState.zoomLevel, equals(initialState.zoomLevel));
    });

    test('formattedDuration works correctly', () {
      const state1 = RecordingState(recordingDuration: Duration(minutes: 1, seconds: 30));
      const state2 = RecordingState(recordingDuration: Duration(minutes: 10, seconds: 5));
      const state3 = RecordingState(recordingDuration: Duration(hours: 1, minutes: 5, seconds: 9));

      expect(state1.formattedDuration, equals('01:30'));
      expect(state2.formattedDuration, equals('10:05'));
      expect(state3.formattedDuration, equals('65:09'));
    });

    test('storageInfo works correctly', () {
      const state1 = RecordingState(availableStorageGB: 2.5);
      const state2 = RecordingState(availableStorageGB: 0.5);
      const state3 = RecordingState(availableStorageGB: 0.1);

      expect(state1.storageInfo, equals('2.5 GB free'));
      expect(state2.storageInfo, equals('512 MB free'));
      expect(state3.storageInfo, equals('102 MB free'));
    });
  });
}