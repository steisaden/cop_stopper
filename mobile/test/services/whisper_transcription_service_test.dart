import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/whisper_transcription_service.dart';

void main() {
  group('WhisperTranscriptionService', () {
    late WhisperTranscriptionService whisperService;

    setUp(() {
      whisperService = WhisperTranscriptionService();
    });

    tearDown(() {
      whisperService.dispose();
    });

    test('can initialize Whisper model', () async {
      // This test verifies that the Whisper model can be initialized
      // In a real test environment, this would actually load the model
      expect(whisperService.isModelLoaded, isFalse);
      
      // Initialize the model
      await whisperService.initializeWhisper();
      
      // Verify that the model is now loaded
      expect(whisperService.isModelLoaded, isTrue);
    });

    test('can get model info', () {
      // Test that we can get model information
      final modelInfo = whisperService.getModelInfo();
      
      expect(modelInfo, isNotNull);
      expect(modelInfo['model_name'], isNotNull);
      expect(modelInfo['is_loaded'], isFalse); // Not loaded yet
      
      // After initialization
      whisperService.initializeWhisper();
      final modelInfoAfterInit = whisperService.getModelInfo();
      expect(modelInfoAfterInit['is_loaded'], isTrue);
    });
  });
}