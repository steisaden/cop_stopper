import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/whisper_transcription_service.dart';
import 'package:mobile/src/services/whisper_model_manager.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
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
      expect(WhisperModelManager.availableModels.containsKey(recommended), isTrue);
    });
    
    test('WhisperModelManager should get model info', () {
      final modelInfo = WhisperModelManager.getModelInfo(WhisperModel.base);
      
      expect(modelInfo, isNotNull);
      expect(modelInfo.name, equals('base'));
      expect(modelInfo.size, greaterThan(0));
    });
    
    test('WhisperTranscriptionService should initialize properly', () {
      final mockRecordingService = MockRecordingService();
      final whisperService = WhisperTranscriptionService(mockRecordingService);
      
      expect(whisperService.isTranscribing, isFalse);
      expect(whisperService.isModelLoaded, isFalse);
      expect(whisperService.transcriptionStream, isNotNull);
    });
    
    test('WhisperTranscriptionService should provide model info', () {
      final mockRecordingService = MockRecordingService();
      final whisperService = WhisperTranscriptionService(mockRecordingService);
      
      final modelInfo = whisperService.getModelInfo();
      
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
  
  @override
  bool get isRecording => _isRecording;
  
  @override
  Stream<Uint8List>? get audioStream => null;
  
  @override
  Future<void> startAudioRecording() async {
    _isRecording = true;
  }
  
  @override
  Future<String?> stopAudioRecording() async {
    _isRecording = false;
    return 'mock_audio.wav';
  }
  
  @override
  Future<void> startVideoRecording() async {}
  
  @override
  Future<String?> stopVideoRecording() async => 'mock_video.mp4';
  
  @override
  Future<void> startAudioVideoRecording() async {
    _isRecording = true;
  }
  
  @override
  Future<String?> stopAudioVideoRecording() async {
    _isRecording = false;
    return 'mock_combined.mp4';
  }
  
  void setRecording(bool recording) {
    _isRecording = recording;
  }
}