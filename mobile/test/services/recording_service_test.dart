import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/recording_service.dart';
import 'package:mobile/src/services/storage_service.dart';
import 'package:record/record.dart';

// Simple mock implementations for testing
class MockStorageService implements StorageService {
  bool _isStorageLow = false;
  int _availableSpace = 500 * 1024 * 1024; // 500 MB

  @override
  Future<int> getAvailableSpace() async => _availableSpace;

  @override
  Future<bool> isStorageLow() async => _isStorageLow;

  @override
  Future<void> compressOldRecordings() async {
    _availableSpace += 50 * 1024 * 1024; // Add 50 MB
    _isStorageLow = false;
  }

  // Test helpers
  void setStorageLow(bool isLow) => _isStorageLow = isLow;
  void setAvailableSpace(int bytes) => _availableSpace = bytes;
}

class MockRecord implements Record {
  bool _isRecording = false;
  bool _hasPermission = true;

  @override
  Future<void> start({
    String? path,
    AudioEncoder? encoder,
    int? bitRate,
    int? samplingRate,
    InputDevice? device,
    int? numChannels,
  }) async {
    if (!_hasPermission) throw Exception('Permission denied');
    _isRecording = true;
  }

  @override
  Future<String?> stop() async {
    if (!_isRecording) return null;
    _isRecording = false;
    return '/mock/path/recording.m4a';
  }

  @override
  Future<bool> hasPermission() async => _hasPermission;

  @override
  Future<bool> isRecording() async => _isRecording;

  @override
  Future<void> dispose() async {}

  @override
  Future<Amplitude> getAmplitude() async => Amplitude(current: 0.0, max: 0.0);

  @override
  Future<bool> isEncoderSupported(AudioEncoder encoder) async => true;

  @override
  Future<List<InputDevice>> listInputDevices() async => [];

  // Test helpers
  void setHasPermission(bool hasPermission) => _hasPermission = hasPermission;

  // Unused interface methods
  @override
  Future<void> cancel() async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> resume() async {}

  @override
  Future<bool> isPaused() async => false;

  @override
  Stream<RecordState> onStateChanged() => const Stream.empty();

  @override
  Stream<Amplitude> onAmplitudeChanged(Duration refreshInterval) => const Stream.empty();
}

void main() {
  group('AudioVideoRecordingService', () {
    late MockStorageService mockStorageService;
    late MockRecord mockRecord;
    late AudioVideoRecordingService recordingService;

    setUp(() {
      mockStorageService = MockStorageService();
      mockRecord = MockRecord();
      recordingService = AudioVideoRecordingService(mockStorageService, mockRecord);
    });

    tearDown(() async {
      await recordingService.dispose();
    });

    group('Basic Recording Functionality', () {
      test('should start and stop audio recording', () async {
        expect(recordingService.isRecording, false);

        await recordingService.startAudioRecording();
        expect(recordingService.isRecording, true);

        final path = await recordingService.stopAudioRecording();
        expect(recordingService.isRecording, false);
        expect(path, isNotNull);
      });

      test('should handle permission denied for audio recording', () async {
        mockRecord.setHasPermission(false);

        expect(
          () => recordingService.startAudioRecording(),
          throwsA(isA<RecordingException>()),
        );
      });

      test('should return null when stopping non-active recording', () async {
        final path = await recordingService.stopAudioRecording();
        expect(path, isNull);
      });
    });

    group('Storage Management', () {
      test('should check storage before starting recording', () async {
        mockStorageService.setStorageLow(true);

        // Should not throw - compression should resolve the issue
        await recordingService.startAudioRecording();
        expect(recordingService.isRecording, true);
      });

      test('should throw exception when storage critically low', () async {
        mockStorageService.setStorageLow(true);
        mockStorageService.setAvailableSpace(10 * 1024 * 1024); // 10 MB

        // Mock compression not helping enough
        mockStorageService.setStorageLow(true);

        expect(
          () => recordingService.startAudioVideoRecording(),
          throwsA(isA<RecordingException>()),
        );
      });
    });

    group('Recording Events', () {
      test('should emit recording events', () async {
        final events = <RecordingEvent>[];
        recordingService.recordingEvents.listen(events.add);

        await recordingService.startAudioRecording();
        await recordingService.stopAudioRecording();

        // Allow events to be processed
        await Future.delayed(const Duration(milliseconds: 100));

        expect(events.length, greaterThan(0));
        expect(events.any((e) => e.type == RecordingEventType.audioStarted), true);
        expect(events.any((e) => e.type == RecordingEventType.audioStopped), true);
      });

      test('should update recording status notifier', () async {
        final statuses = <String>[];
        recordingService.recordingStatusNotifier.addListener(() {
          statuses.add(recordingService.recordingStatusNotifier.value);
        });

        await recordingService.startAudioRecording();
        await recordingService.stopAudioRecording();

        expect(statuses, contains('Audio recording active'));
        expect(statuses, contains('Audio recording stopped'));
      });
    });

    group('State Management', () {
      test('should track recording state correctly', () async {
        expect(recordingService.isRecording, false);

        await recordingService.startAudioRecording();
        expect(recordingService.isRecording, true);

        await recordingService.stopAudioRecording();
        expect(recordingService.isRecording, false);
      });

      test('should provide recording duration when active', () async {
        expect(recordingService.currentRecordingDuration, isNull);

        // Start audio recording which sets the recording start time
        await recordingService.startAudioRecording();
        
        // Small delay to ensure duration is measurable
        await Future.delayed(const Duration(milliseconds: 100));
        
        final duration = recordingService.currentRecordingDuration;
        expect(duration, isNotNull);
        expect(duration!.inMilliseconds, greaterThan(0));

        await recordingService.stopAudioRecording();
        expect(recordingService.currentRecordingDuration, isNull);
      });
    });

    group('Error Handling', () {
      test('should handle recording start failure gracefully', () async {
        // Simulate record failure
        mockRecord.setHasPermission(false);

        expect(
          () => recordingService.startAudioRecording(),
          throwsA(isA<RecordingException>()),
        );

        expect(recordingService.isRecording, false);
      });

      test('should clean up on disposal', () async {
        await recordingService.startAudioRecording();
        expect(recordingService.isRecording, true);

        await recordingService.dispose();
        expect(recordingService.isRecording, false);
        
        // Create a new service for the tearDown to avoid double disposal
        recordingService = AudioVideoRecordingService(mockStorageService, mockRecord);
      });
    });

    group('RecordingEvent', () {
      test('should create recording event correctly', () {
        final event = RecordingEvent(
          type: RecordingEventType.started,
          timestamp: DateTime.now(),
          message: 'Test message',
          filePath: '/test/path',
        );

        expect(event.type, RecordingEventType.started);
        expect(event.message, 'Test message');
        expect(event.filePath, '/test/path');
        expect(event.toString(), contains('started'));
        expect(event.toString(), contains('Test message'));
      });
    });

    group('RecordingException', () {
      test('should create recording exception correctly', () {
        const exception = RecordingException('Test error', code: 'TEST_CODE');

        expect(exception.message, 'Test error');
        expect(exception.code, 'TEST_CODE');
        expect(exception.toString(), 'RecordingException: Test error');
      });

      test('should create recording exception without code', () {
        const exception = RecordingException('Test error');

        expect(exception.message, 'Test error');
        expect(exception.code, isNull);
        expect(exception.toString(), 'RecordingException: Test error');
      });
    });
  });
}