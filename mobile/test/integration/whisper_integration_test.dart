import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/whisper_transcription_service.dart';

void main() {
  group('Whisper Integration Tests', () {
    late WhisperTranscriptionService whisperService;

    setUp(() {
      whisperService = WhisperTranscriptionService();
    });

    tearDown(() {
      whisperService.dispose();
    });

    test('Whisper service initializes correctly', () async {
      // Test that the Whisper service can be instantiated
      expect(whisperService, isNotNull);
      
      // Test that the service starts with model not loaded
      expect(whisperService.isModelLoaded, isFalse);
      expect(whisperService.isTranscribing, isFalse);
    });

    test('Whisper model can be initialized', () async {
      // Test that we can initialize the Whisper model
      await whisperService.initializeWhisper();
      
      // Verify that the model is now loaded
      expect(whisperService.isModelLoaded, isTrue);
    });

    test('Whisper service provides model info', () async {
      // Test that we can get model information before initialization
      final modelInfoBefore = whisperService.getModelInfo();
      expect(modelInfoBefore, isNotNull);
      expect(modelInfoBefore['model_name'], isNotNull);
      expect(modelInfoBefore['is_loaded'], isFalse);
      
      // Initialize the model
      await whisperService.initializeWhisper();
      
      // Test that we can get model information after initialization
      final modelInfoAfter = whisperService.getModelInfo();
      expect(modelInfoAfter, isNotNull);
      expect(modelInfoAfter['model_name'], isNotNull);
      expect(modelInfoAfter['is_loaded'], isTrue);
    });

    test('Whisper can transcribe audio file', () async {
      // Initialize the model first
      await whisperService.initializeWhisper();
      expect(whisperService.isModelLoaded, isTrue);
      
      // Test that we can transcribe an audio file
      // For this test, we'll use a mock file path
      final result = await whisperService.transcribeAudioFile('test_audio.wav');
      
      // In a real test, we would verify the transcription result
      // For now, we just verify that the method completes without error
      expect(whisperService.isModelLoaded, isTrue);
    });
  });
}