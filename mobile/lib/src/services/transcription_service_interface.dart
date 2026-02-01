import 'dart:async';
import 'package:mobile/src/models/transcription_result_model.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';

/// Interface for transcription services
abstract class TranscriptionServiceInterface {
  /// Stream of transcription segments
  Stream<TranscriptionSegment> get transcriptionStream;
  
  /// Whether transcription is currently active
  bool get isTranscribing;
  
  /// Start real-time transcription for a session
  Future<void> startTranscription(String sessionId);
  
  /// Stop transcription
  Future<void> stopTranscription();
  
  /// Initialize transcription engine
  Future<void> initializeWhisper();
  
  /// Check if transcription engine is ready
  bool get isWhisperReady;
  
  /// Get model information
  Future<Map<String, dynamic>> getModelInfo();
  
  /// Process transcription
  Future<TranscriptionResult?> transcribeAudio(String audioFilePath);
  
  /// Submit transcription segment to collaborative session
  Future<void> submitTranscriptionSegment(TranscriptionSegment segment);
  
  /// Dispose resources
  void dispose();
}
