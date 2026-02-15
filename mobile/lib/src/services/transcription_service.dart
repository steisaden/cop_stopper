import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile/src/models/transcription_result_model.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/services/api_service.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';
import 'package:mobile/src/services/whisper_transcription_service.dart';
import 'package:mobile/src/services/transcription_storage_service.dart';

/// Service for real-time audio transcription using Whisper on-device
class TranscriptionService implements TranscriptionServiceInterface {
  final ApiService _apiService;
  final RecordingService _recordingService;
  final TranscriptionStorageService _storageService;
  late final WhisperTranscriptionService _whisperService;

  final StreamController<TranscriptionSegment> _transcriptionController =
      StreamController<TranscriptionSegment>.broadcast();

  bool _isTranscribing = false;
  String _currentSessionId = '';

  TranscriptionService(
    this._apiService,
    this._recordingService,
    this._storageService,
  ) {
    _whisperService = WhisperTranscriptionService(
      _recordingService,
      _storageService,
    );

    // Forward Whisper transcription segments
    _whisperService.transcriptionStream.listen((segment) {
      debugPrint(
          '🔄 TranscriptionService: Forwarding segment: "${segment.text}"');
      _transcriptionController.add(segment);
    });
  }

  /// Stream of transcription segments
  @override
  Stream<TranscriptionSegment> get transcriptionStream =>
      _transcriptionController.stream;

  /// Whether transcription is currently active
  @override
  bool get isTranscribing => _isTranscribing;

  /// Start real-time transcription for a session
  @override
  Future<void> startTranscription(String sessionId) async {
    if (_isTranscribing) {
      await stopTranscription();
    }

    _currentSessionId = sessionId;
    _isTranscribing = true;

    // Start Whisper transcription
    await _whisperService.startTranscription(sessionId);

    debugPrint('Whisper transcription started for session: $sessionId');
  }

  /// Stop transcription
  @override
  Future<void> stopTranscription() async {
    _isTranscribing = false;
    _currentSessionId = '';

    // Stop Whisper transcription
    await _whisperService.stopTranscription();

    debugPrint('Whisper transcription stopped');
  }

  /// Initialize Whisper model
  @override
  Future<void> initializeWhisper() async {
    await _whisperService.initializeWhisper();
  }

  /// Check if Whisper model is loaded
  @override
  bool get isWhisperReady => _whisperService.isModelLoaded;

  /// Get Whisper model information
  @override
  Future<Map<String, dynamic>> getModelInfo() {
    return _whisperService.getModelInfo();
  }

  /// Process transcription with Whisper on-device
  @override
  Future<TranscriptionResult?> transcribeAudio(String audioFilePath) async {
    try {
      // Use Whisper on-device transcription
      return await _whisperService.transcribeAudioFile(audioFilePath);
    } catch (e) {
      debugPrint('Whisper transcription error: $e');
      return null;
    }
  }

  /// Submit transcription segment to collaborative session
  @override
  Future<void> submitTranscriptionSegment(TranscriptionSegment segment) async {
    if (_currentSessionId.isEmpty) return;

    try {
      await _apiService.post('/sessions/$_currentSessionId/transcription', {
        'segment_id': segment.id,
        'text': segment.text,
        'timestamp': segment.timestamp.toIso8601String(),
        'confidence': segment.confidence,
        'speaker': segment.speakerLabel ?? 'unknown',
        'language': 'en', // Default language
      });
    } catch (e) {
      debugPrint('Failed to submit transcription segment: $e');
    }
  }

  /// Dispose resources
  @override
  void dispose() {
    _whisperService.dispose();
    _transcriptionController.close();
  }
}
