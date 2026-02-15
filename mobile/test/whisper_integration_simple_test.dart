import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/whisper_transcription_service.dart';
import 'package:mobile/src/services/whisper_model_manager.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/transcription_storage_service.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';

import 'package:whisper_ggml/whisper_ggml.dart';

void main() {
  group('Whisper Integration Simple Tests', () {
    test('WhisperModelManager should provide available models', () {
      final models = WhisperModelManager.availableModels;

      expect(models, isNotEmpty);
      expect(models.containsKey(WhisperModel.tiny), isTrue);
      expect(models.containsKey(WhisperModel.base), isTrue);
      expect(models.containsKey(WhisperModel.small), isTrue);
      expect(models.containsKey(WhisperModel.medium), isTrue);
    });

    test('WhisperModelManager should recommend appropriate model', () async {
      final recommended = await WhisperModelManager.recommendModel();

      expect(recommended, isA<WhisperModel>());
      expect(
          WhisperModelManager.availableModels.containsKey(recommended), isTrue);
    });

    test('WhisperModelManager should get model info', () {
      final modelInfo = WhisperModelManager.getModelInfo(WhisperModel.base);

      expect(modelInfo, isNotNull);
      expect(modelInfo.name, equals('base'));
      expect(modelInfo.size, greaterThan(0));
    });

    test('WhisperTranscriptionService should initialize properly', () {
      final mockRecordingService = MockRecordingService();
      final mockStorageService = MockTranscriptionStorageService();
      final whisperService =
          WhisperTranscriptionService(mockRecordingService, mockStorageService);

      expect(whisperService.isTranscribing, isFalse);
      expect(whisperService.isModelLoaded, isFalse);
      expect(whisperService.transcriptionStream, isNotNull);
    });

    test('WhisperTranscriptionService should provide model info', () async {
      final mockRecordingService = MockRecordingService();
      final mockStorageService = MockTranscriptionStorageService();
      final whisperService =
          WhisperTranscriptionService(mockRecordingService, mockStorageService);

      final modelInfo = await whisperService.getModelInfo();

      expect(modelInfo, isNotNull);
      expect(modelInfo['model_name'], isNotEmpty);
      expect(modelInfo['is_loaded'], isFalse);
      expect(modelInfo['processing_interval_ms'], greaterThan(0));
      expect(modelInfo['sample_rate'], equals(16000));
    });
  });
}

// Simple mock for testing
class MockRecordingService implements RecordingService {
  bool _isRecording = false;
  String? _currentRecordingId;

  @override
  bool get isRecording => _isRecording;

  @override
  String? get currentRecordingId => _currentRecordingId;

  @override
  Stream<Uint8List>? get audioStream => null;

  @override
  void setCameraController(dynamic controller) {}

  @override
  Future<void> startAudioRecording({String? recordingId}) async {
    _isRecording = true;
    _currentRecordingId = recordingId ?? 'mock_id';
  }

  @override
  Future<String?> stopAudioRecording() async {
    _isRecording = false;
    _currentRecordingId = null;
    return 'mock_audio.wav';
  }

  @override
  Future<void> startVideoRecording() async {}

  @override
  Future<String?> stopVideoRecording() async => 'mock_video.mp4';

  @override
  Future<void> startAudioVideoRecording({String? recordingId}) async {
    _isRecording = true;
    _currentRecordingId = recordingId ?? 'mock_id';
  }

  @override
  Future<String?> stopAudioVideoRecording() async {
    _isRecording = false;
    _currentRecordingId = null;
    return 'mock_combined.mp4';
  }

  void setRecording(bool recording) {
    _isRecording = recording;
  }
}

class MockTranscriptionStorageService implements TranscriptionStorageService {
  @override
  Future<void> saveTranscription(
      String recordingId, List<TranscriptionSegment> segments) async {}

  @override
  Future<List<TranscriptionSegment>> loadTranscription(
          String recordingId) async =>
      [];

  @override
  Future<bool> hasTranscription(String recordingId) async => false;

  @override
  Future<void> deleteTranscription(String recordingId) async {}

  @override
  Future<String> getTranscriptionFilePath(String recordingId) async =>
      'mock/path/$recordingId.json';

  @override
  Future<Map<String, dynamic>?> getTranscriptionMetadata(
          String recordingId) async =>
      null;

  @override
  Future<String> getFullText(String recordingId) async => '';

  @override
  Future<void> clearAllTranscriptions() async {}
}
