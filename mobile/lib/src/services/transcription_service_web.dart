import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mobile/src/models/transcription_result_model.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/services/api_service.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';

/// Web-compatible transcription service using Web Speech API or cloud services
class WebTranscriptionService implements TranscriptionServiceInterface {
  final ApiService _apiService;
  final RecordingService _recordingService;
  
  final StreamController<TranscriptionSegment> _transcriptionController = 
      StreamController<TranscriptionSegment>.broadcast();
  
  bool _isTranscribing = false;
  String _currentSessionId = '';
  Timer? _simulationTimer;
  
  WebTranscriptionService(this._apiService, this._recordingService);
  
  /// Stream of transcription segments
  Stream<TranscriptionSegment> get transcriptionStream => 
      _transcriptionController.stream;
  
  /// Whether transcription is currently active
  bool get isTranscribing => _isTranscribing;
  
  /// Start real-time transcription for a session
  Future<void> startTranscription(String sessionId) async {
    if (_isTranscribing) {
      await stopTranscription();
    }
    
    _currentSessionId = sessionId;
    _isTranscribing = true;
    
    // Start simulated transcription for web demo
    _startSimulatedTranscription();
    
    debugPrint('Web transcription started for session: $sessionId');
  }
  
  /// Stop transcription
  Future<void> stopTranscription() async {
    _isTranscribing = false;
    _currentSessionId = '';
    
    _simulationTimer?.cancel();
    _simulationTimer = null;
    
    debugPrint('Web transcription stopped');
  }
  
  /// Initialize transcription (no-op for web)
  Future<void> initializeWhisper() async {
    // No initialization needed for web
    debugPrint('Web transcription initialized');
  }
  
  /// Check if transcription is ready
  bool get isWhisperReady => true; // Always ready for web
  
  /// Get model information
  Map<String, dynamic> getModelInfo() {
    return {
      'model_name': 'web_speech_api',
      'is_loaded': true,
      'processing_interval_ms': 3000,
      'chunk_duration_ms': 3000,
      'sample_rate': 16000,
      'language': 'en',
      'platform': 'web',
    };
  }
  
  /// Process transcription (simulated for web)
  Future<TranscriptionResult?> transcribeAudio(String audioFilePath) async {
    try {
      // Simulate processing delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return simulated transcription result
      return TranscriptionResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recordingId: 'web_${DateTime.now().millisecondsSinceEpoch}',
        transcriptionText: _getSimulatedTranscription() ?? 'No transcription available',
        timestamp: DateTime.now(),
        confidence: 0.85,
      );
      
    } catch (e) {
      debugPrint('Web transcription error: $e');
      return null;
    }
  }
  
  /// Submit transcription segment to collaborative session
  Future<void> submitTranscriptionSegment(TranscriptionSegment segment) async {
    if (_currentSessionId.isEmpty) return;
    
    try {
      await _apiService.post('/sessions/$_currentSessionId/transcription', {
        'segment_id': segment.id,
        'text': segment.text,
        'timestamp': segment.timestamp.toIso8601String(),
        'confidence': segment.confidence,
        'speaker': segment.speakerLabel ?? 'unknown',
        'language': 'en',
      });
    } catch (e) {
      debugPrint('Failed to submit transcription segment: $e');
    }
  }
  
  /// Start simulated transcription for web demo
  void _startSimulatedTranscription() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isTranscribing) {
        timer.cancel();
        return;
      }
      
      final transcriptionText = _getSimulatedTranscription();
      if (transcriptionText != null) {
        final segment = TranscriptionSegment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: transcriptionText,
          timestamp: DateTime.now(),
          confidence: 0.85,
          speakerLabel: 'user',
          startTime: Duration(seconds: timer.tick * 5),
          endTime: Duration(seconds: (timer.tick * 5) + 3),
          isComplete: true,
        );
        
        _transcriptionController.add(segment);
        debugPrint('Web transcription: ${segment.text}');
      }
    });
  }
  
  /// Get simulated transcription for web demo
  String? _getSimulatedTranscription() {
    final transcriptions = [
      'I understand my rights.',
      'Am I free to go?',
      'I do not consent to any searches.',
      'I would like to speak to a lawyer.',
      'I am exercising my right to remain silent.',
      'Can you please tell me why I was stopped?',
      'I do not answer questions without my attorney present.',
      'I am recording this interaction for my safety.',
      'What is your badge number?',
      'I need to see your identification.',
    ];
    
    // Return a random transcription occasionally
    if (DateTime.now().millisecond % 3 == 0) {
      final index = DateTime.now().millisecond % transcriptions.length;
      return transcriptions[index];
    }
    
    return null;
  }
  
  /// Dispose resources
  void dispose() {
    _simulationTimer?.cancel();
    _transcriptionController.close();
  }
}