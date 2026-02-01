import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:whisper_ggml/whisper_ggml.dart';
import 'package:mobile/src/models/transcription_result_model.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/whisper_model_manager.dart';

/// On-device Whisper transcription service for real-time speech recognition
class WhisperTranscriptionService {
  final RecordingService _recordingService;
  
  final StreamController<TranscriptionSegment> _transcriptionController = 
      StreamController<TranscriptionSegment>.broadcast();
  
  bool _isTranscribing = false;
  bool _isModelLoaded = false;
  String? _lastInitError;
  Timer? _transcriptionTimer;
  String _currentSessionId = '';
  
  // Whisper controller (initialized once the model is available)
  Whisper? _whisper;
  
  static const Duration _processingInterval = Duration(seconds: 2);
  static const int _audioChunkDurationMs = 2000; // 2 seconds for more responsive transcription
  
  // Audio processing
  final List<double> _audioBuffer = [];
  int _lastProcessedSample = 0;
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  
  WhisperTranscriptionService(this._recordingService);
  
  /// Stream of transcription segments
  Stream<TranscriptionSegment> get transcriptionStream => 
      _transcriptionController.stream;
  
  /// Whether transcription is currently active
  bool get isTranscribing => _isTranscribing;
  
  /// Whether Whisper model is loaded and ready
  bool get isModelLoaded => _isModelLoaded;
  String? get lastInitError => _lastInitError;
  
  /// Initialize Whisper model for on-device processing
  Future<void> initializeWhisper() async {
    if (_isModelLoaded) return;
    
    try {
      _lastInitError = null;
      debugPrint('Initializing Whisper model...');
      
      // Ensure model is downloaded
      if (!await WhisperModelManager.isModelDownloaded()) {
        await WhisperModelManager.downloadModel('base.en');
      }
      
      final modelPath = await WhisperModelManager.getModelPath();
      _whisper = const Whisper(model: WhisperModel.baseEn);
      
      _isModelLoaded = true;
      debugPrint('Whisper model initialized successfully at $modelPath');
      
    } catch (e) {
      // If download failed and no model is present, fail gracefully with a clear message.
      final hasModel = await WhisperModelManager.isModelDownloaded();
      _isModelLoaded = false;
      _lastInitError = hasModel
          ? 'Failed to initialize Whisper engine. Please restart the app.'
          : 'Whisper model not available offline. Connect to the internet once to download the model.';
      debugPrint('Failed to initialize Whisper model: $e');
      throw Exception(_lastInitError);
    }
  }
  
  /// Start real-time transcription for a session
  Future<void> startTranscription(String sessionId) async {
    if (!_isModelLoaded || _whisper == null) {
      final reason = _lastInitError ??
          'Whisper model not initialized. Connect to the internet once to download the model.';
      throw Exception(reason);
    }

    if (_isTranscribing) {
      await stopTranscription();
    }
    
    if (!_isModelLoaded) {
      await initializeWhisper();
    }
    
    _currentSessionId = sessionId;
    _isTranscribing = true;
    _audioBuffer.clear();
    _lastProcessedSample = 0;
    
    // Connect to recording service audio stream
    await _connectToAudioStream();
    
    // Start periodic audio processing
    _transcriptionTimer = Timer.periodic(
      _processingInterval, 
      (_) => _processAudioChunk(),
    );
    
    debugPrint('Whisper transcription started for session: $sessionId');
  }
  
  /// Stop transcription
  Future<void> stopTranscription() async {
    _isTranscribing = false;
    _transcriptionTimer?.cancel();
    _transcriptionTimer = null;
    _currentSessionId = '';
    _audioBuffer.clear();
    _lastProcessedSample = 0;
    
    // Disconnect from audio stream
    await _audioStreamSubscription?.cancel();
    _audioStreamSubscription = null;
    
    debugPrint('Whisper transcription stopped');
  }
  
  /// Connect to recording service audio stream
  Future<void> _connectToAudioStream() async {
    try {
      // Get audio stream from recording service
      final audioStream = _recordingService.audioStream;
      if (audioStream != null) {
        _audioStreamSubscription = audioStream.listen(
          (audioData) => _handleAudioData(audioData),
          onError: (error) => debugPrint('Audio stream error: $error'),
        );
        debugPrint('Connected to audio stream for transcription');
      } else {
        debugPrint('No audio stream available from recording service');
      }
    } catch (e) {
      debugPrint('Failed to connect to audio stream: $e');
    }
  }
  
  /// Handle incoming audio data from stream
  void _handleAudioData(Uint8List audioData) {
    if (!_isTranscribing) return;
    
    // Convert bytes to float samples and add to buffer
    final samples = _convertBytesToFloat32(audioData);
    _audioBuffer.addAll(samples);
    
    // Keep buffer size manageable (last 10 seconds of audio)
    const maxBufferSize = 16000 * 10; // 10 seconds at 16kHz
    if (_audioBuffer.length > maxBufferSize) {
      _audioBuffer.removeRange(0, _audioBuffer.length - maxBufferSize);
    }
  }
  
  /// Convert audio bytes to Float32 samples
  List<double> _convertBytesToFloat32(Uint8List bytes) {
    final samples = <double>[];
    
    // Assuming 16-bit PCM audio
    for (int i = 0; i < bytes.length - 1; i += 2) {
      final sample = (bytes[i] | (bytes[i + 1] << 8));
      final normalizedSample = sample.toSigned(16) / 32768.0;
      samples.add(normalizedSample);
    }
    
    return samples;
  }

  /// Process audio chunk with Whisper
  Future<void> _processAudioChunk() async {
    if (!_isTranscribing || !_recordingService.isRecording || _audioBuffer.isEmpty) {
      return;
    }
    
    try {
      // Get audio chunk from buffer
      final chunkSize = 16000 * 3; // 3 seconds at 16kHz
      if (_audioBuffer.length < chunkSize) {
        return; // Not enough audio data yet
      }
      
      // Extract chunk from buffer
      final audioChunk = _audioBuffer.sublist(
        _lastProcessedSample,
        (_lastProcessedSample + chunkSize).clamp(0, _audioBuffer.length),
      );
      
      _lastProcessedSample = (_lastProcessedSample + chunkSize).clamp(0, _audioBuffer.length);
      
      // Process with Whisper
      final transcriptionText = await _transcribeWithWhisper(Float32List.fromList(audioChunk));
      
      if (transcriptionText != null && transcriptionText.trim().isNotEmpty) {
        final segment = TranscriptionSegment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: transcriptionText.trim(),
          timestamp: DateTime.now(),
          confidence: 0.9, 
          speakerLabel: 'user',
          startTime: Duration(seconds: _lastProcessedSample ~/ 16000),
          endTime: Duration(seconds: (_lastProcessedSample + chunkSize) ~/ 16000),
          isComplete: true,
        );
        
        _transcriptionController.add(segment);
        debugPrint('Whisper transcription segment: ${segment.text}');
      }
      
    } catch (e) {
      debugPrint('Error processing audio chunk: $e');
    }
  }
  
  
  /// Transcribe audio data with Whisper
  Future<String?> _transcribeWithWhisper(Float32List audioData) async {
    try {
      if (!_isModelLoaded || _whisper == null) return null;

      // Convert audio to the format Whisper expects (16kHz, mono, float32)
      // Note: whisper_ggml might expect specific format.
      // Usually it takes PCM float or 16-bit int.
      final modelPath = await WhisperModelManager.getModelPath();
      final tempFile = await _saveAudioToTempFile(audioData);

      final response = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: tempFile.path,
          language: 'en',
        ),
        modelPath: modelPath,
      );

      return response.text; 
      
    } catch (e) {
      debugPrint('Whisper transcription error: $e');
      return null;
    }
  }
  
  /// Transcribe a complete audio file
  Future<TranscriptionResult?> transcribeAudioFile(String audioFilePath) async {
    try {
      if (!_isModelLoaded || _whisper == null) {
        await initializeWhisper();
      }
      
      final modelPath = await WhisperModelManager.getModelPath();
      final response = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioFilePath,
          language: 'en',
        ),
        modelPath: modelPath,
      );

      final text = response.text;

      if (text != null) {
        return TranscriptionResult(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          recordingId: 'whisper_${DateTime.now().millisecondsSinceEpoch}',
          transcriptionText: text,
          timestamp: DateTime.now(),
          confidence: 0.9,
        );
      }
      
      return null;
      
    } catch (e) {
      debugPrint('File transcription error: $e');
      return null;
    }
  }
  
  /// Preprocess audio for Whisper (16kHz, mono, float32)
  Float32List _preprocessAudio(Float32List audioData) {
    // Whisper expects 16kHz sample rate
    // This is a simplified implementation - in production you'd need proper resampling
    return audioData;
  }
  
  /// Save audio data to temporary file
  Future<File> _saveAudioToTempFile(Float32List audioData) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(path.join(
      tempDir.path, 
      'whisper_audio_${DateTime.now().millisecondsSinceEpoch}.wav'
    ));
    
    // Convert Float32List to bytes and save as WAV
    final bytes = Uint8List.fromList(
      audioData.expand((sample) => [
        (sample * 32767).round() & 0xFF,
        ((sample * 32767).round() >> 8) & 0xFF,
      ]).toList()
    );
    
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }
  
  /// Get model information
  Future<Map<String, dynamic>> getModelInfo() async {
    return await WhisperModelManager.getModelInfo('base.en');
  }
  
  /// Dispose resources
  void dispose() {
    _transcriptionTimer?.cancel();
    _transcriptionController.close();
    _audioBuffer.clear();
  }
}
