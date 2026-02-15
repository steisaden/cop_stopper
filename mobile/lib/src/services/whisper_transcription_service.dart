import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:whisper_ggml/whisper_ggml.dart';
import 'package:mobile/src/models/transcription_result_model.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'dart:math' as split;
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/whisper_model_manager.dart';
import 'package:mobile/src/services/transcription_storage_service.dart';

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

  static const int _audioChunkDurationMs =
      10000; // REDUCED TO 10s FOR DEBUGGING (was 45s)

  // Audio processing
  final List<double> _audioBuffer = [];
  int _lastProcessedSample = 0;
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  bool _isProcessingChunk = false;

  final TranscriptionStorageService _storageService;

  WhisperTranscriptionService(this._recordingService, this._storageService);

  /// Stream of transcription segments
  Stream<TranscriptionSegment> get transcriptionStream =>
      _transcriptionController.stream;

  /// Whether the Whisper model is loaded
  bool get isModelLoaded => _isModelLoaded;

  /// Whether transcription is currently active
  bool get isTranscribing => _isTranscribing;

  /// Initialize Whisper model
  Future<void> initializeWhisper() async {
    if (_isModelLoaded && _whisper != null) return;

    try {
      debugPrint('Initializing Whisper...');
      // Ensure model is downloaded
      if (!await WhisperModelManager.isModelDownloaded()) {
        debugPrint('Model not downloaded. Need to download first.');
        // We might want to trigger download here or expect it to be done
      }

      // Initialize Whisper instance with the enum corresponding to our model
      _whisper = Whisper(
        model: WhisperModel.tiny,
      );

      _isModelLoaded = true;
      _lastInitError = null;
      debugPrint('Whisper initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Whisper: $e');
      _isModelLoaded = false;
      _lastInitError = e.toString();
      _whisper = null;
    }
  }

  // ... (existing code)

  // Accumulate segments for persistence
  final List<TranscriptionSegment> _sessionSegments = [];

  // ... (existing code)

  /// Start real-time transcription for a session
  Future<void> startTranscription(String sessionId) async {
    if (_isTranscribing) {
      debugPrint(
          'Transcription already active for session: $_currentSessionId');
      return;
    }

    // Ensure model is loaded
    if (!_isModelLoaded) {
      await initializeWhisper();
    }

    _currentSessionId = sessionId;
    _isTranscribing = true;
    _audioBuffer.clear();
    _lastProcessedSample = 0;
    _sessionSegments.clear(); // Clear previous session segments

    // Connect to audio stream
    await _connectToAudioStream();

    // Start processing timer
    _transcriptionTimer?.cancel();
    _transcriptionTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => _processAudioChunk());

    debugPrint('Whisper transcription started for session: $sessionId');
  }

  /// Stop transcription
  Future<void> stopTranscription() async {
    debugPrint(
        'Stop transcription requested. Waiting for active processing...');

    // Wait for ongoing processing to complete (up to 30 seconds)
    int waitAttempts = 0;
    while (_isProcessingChunk && waitAttempts < 150) {
      // Increased to 150 attempts (30s)
      await Future.delayed(const Duration(milliseconds: 200));
      waitAttempts++;
    }

    if (_isProcessingChunk) {
      debugPrint('Warning: Transcription processing timed out during stop.');
    }

    // Process any remaining audio in the buffer before stopping
    if (_audioBuffer.isNotEmpty) {
      debugPrint('Processing final audio chunk before stopping...');
      await _processAudioChunk(isFinal: true);
    }

    // Save accumulated segments to storage
    if (_sessionSegments.isNotEmpty && _currentSessionId.isNotEmpty) {
      debugPrint('Saving transcription for session: $_currentSessionId');
      try {
        await _storageService.saveTranscription(
            _currentSessionId, List.from(_sessionSegments));
      } catch (e) {
        debugPrint('Failed to save transcription: $e');
      }
    }

    _isTranscribing = false;
    _transcriptionTimer?.cancel();
    _transcriptionTimer = null;
    _currentSessionId = '';
    _audioBuffer.clear();
    _lastProcessedSample = 0;
    _sessionSegments.clear();

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

    // Keep buffer size manageable (last 60 seconds of audio to accommodate 45s chunks)
    const maxBufferSize = 16000 * 60; // 60 seconds at 16kHz
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
  Future<void> _processAudioChunk({bool isFinal = false}) async {
    if (_isProcessingChunk ||
        (!_isTranscribing && !isFinal) ||
        _audioBuffer.isEmpty) {
      return;
    }

    try {
      _isProcessingChunk = true;
      // Get audio chunk from buffer (based on duration)
      const int sampleRate = 16000;
      final int targetChunkSize = (sampleRate * _audioChunkDurationMs) ~/ 1000;

      // If final, process whatever we have (min 1 sec to be worth it)
      // If not final, wait for full chunk
      int chunkSize = targetChunkSize;

      if (isFinal) {
        if (_audioBuffer.length < 16000) {
          debugPrint('Final chunk too small (< 1s), skipping');
          return;
        }
        chunkSize = _audioBuffer.length;
      } else if (_audioBuffer.length < targetChunkSize) {
        return; // Not enough audio data yet
      }

      // Extract chunk from START of buffer
      final audioChunk = _audioBuffer.sublist(0, chunkSize);

      // Remove processed samples from buffer
      // If final, we can just clear it, but specific range removal is safer
      if (chunkSize <= _audioBuffer.length) {
        _audioBuffer.removeRange(0, chunkSize);
      } else {
        _audioBuffer.clear();
      }

      _lastProcessedSample += chunkSize;

      debugPrint(
          'Processing audio chunk: ${audioChunk.length} samples (Final: $isFinal)');

      // Calculate RMS (Root Mean Square) for VAD
      double sumSquares = 0.0;
      for (final sample in audioChunk) {
        sumSquares += sample * sample;
      }
      final rms = split.sqrt(sumSquares / audioChunk.length);

      // Skip if audio is too quiet (silence)
      // Lower threshold significantly to ensure capture during testing
      if (rms < 0.001) {
        debugPrint('Skipping silent chunk (RMS: ${rms.toStringAsFixed(4)})');
        return;
      }

      // Process with Whisper
      final transcriptionText =
          await _transcribeWithWhisper(Float32List.fromList(audioChunk));

      if (transcriptionText != null && transcriptionText.trim().isNotEmpty) {
        final segment = TranscriptionSegment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: transcriptionText.trim(),
          timestamp: DateTime.now(),
          confidence: 0.9,
          speakerLabel: 'user',
          startTime:
              Duration(seconds: (_lastProcessedSample - chunkSize) ~/ 16000),
          endTime: Duration(seconds: _lastProcessedSample ~/ 16000),
          isComplete: true,
        );

        _transcriptionController.add(segment);
        debugPrint('Whisper transcription segment: ${segment.text}');
      }
    } catch (e) {
      debugPrint('Error processing audio chunk: $e');
    } finally {
      _isProcessingChunk = false;
    }
  }

  /// Transcribe audio data with Whisper
  Future<String?> _transcribeWithWhisper(Float32List audioData) async {
    try {
      if (!_isModelLoaded || _whisper == null) {
        debugPrint('Whisper not initialized, skipping transcription');
        return null;
      }

      // Skip if audio data is too small (less than 1 second)
      if (audioData.length < 16000) {
        debugPrint(
            'Audio chunk too small (${audioData.length} samples), skipping');
        return null;
      }

      // Convert audio to WAV format
      final modelPath = await WhisperModelManager.getModelPath();
      final tempFile = await _saveAudioToTempFile(audioData);

      // Verify file was created with actual audio data
      final fileExists = await tempFile.exists();
      final fileSize = fileExists ? await tempFile.length() : 0;
      debugPrint('WAV file: ${tempFile.path}, Size: $fileSize bytes');

      // Skip if file is just a header (44 bytes) with no audio data
      if (!fileExists || fileSize <= 44) {
        debugPrint('Skipping empty WAV file (size: $fileSize)');
        try {
          await tempFile.delete();
        } catch (_) {}
        return null;
      }

      debugPrint(
          'Whisper: invoking native transcribe... (Audio file: ${tempFile.path})');
      final stopwatch = Stopwatch()..start();

      final response = await _whisper!.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: tempFile.path,
          language: 'en',
        ),
        modelPath: modelPath,
      );

      stopwatch.stop();
      debugPrint(
          'Whisper: native transcribe completed in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('Whisper: result text length: ${response.text.length}');

      // Clean up temp file
      try {
        await tempFile.delete();
      } catch (e) {
        debugPrint('Failed to delete temp file: $e');
      }

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

      return TranscriptionResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recordingId: 'whisper_${DateTime.now().millisecondsSinceEpoch}',
        transcriptionText: text,
        timestamp: DateTime.now(),
        confidence: 0.9,
      );

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

  /// Save audio data to temporary WAV file
  Future<File> _saveAudioToTempFile(Float32List audioData) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File(path.join(tempDir.path,
        'whisper_audio_${DateTime.now().millisecondsSinceEpoch}.wav'));

    final wavBytes = _encodeWavPcm16(audioData);
    await tempFile.writeAsBytes(wavBytes, flush: true);
    return tempFile;
  }

  /// Encode Float32 audio samples into a 16-bit PCM WAV file (mono, 16 kHz).
  Uint8List _encodeWavPcm16(
    Float32List samples, {
    int sampleRate = 16000,
    int numChannels = 1,
  }) {
    final bytesPerSample = 2;
    final dataLength = samples.length * bytesPerSample;
    final byteRate = sampleRate * numChannels * bytesPerSample;
    final blockAlign = numChannels * bytesPerSample;

    final header = ByteData(44);
    int offset = 0;

    void writeString(String value) {
      for (int i = 0; i < value.length; i++) {
        header.setUint8(offset + i, value.codeUnitAt(i));
      }
      offset += value.length;
    }

    writeString('RIFF');
    header.setUint32(offset, 36 + dataLength, Endian.little);
    offset += 4;
    writeString('WAVE');
    writeString('fmt ');
    header.setUint32(offset, 16, Endian.little); // PCM header size
    offset += 4;
    header.setUint16(offset, 1, Endian.little); // PCM format
    offset += 2;
    header.setUint16(offset, numChannels, Endian.little);
    offset += 2;
    header.setUint32(offset, sampleRate, Endian.little);
    offset += 4;
    header.setUint32(offset, byteRate, Endian.little);
    offset += 4;
    header.setUint16(offset, blockAlign, Endian.little);
    offset += 2;
    header.setUint16(offset, 16, Endian.little); // bits per sample
    offset += 2;
    writeString('data');
    header.setUint32(offset, dataLength, Endian.little);

    final pcmBytes = Uint8List(dataLength);
    final pcmView = ByteData.view(pcmBytes.buffer);
    for (int i = 0; i < samples.length; i++) {
      final clamped = samples[i].clamp(-1.0, 1.0);
      final intSample = (clamped * 32767).round();
      pcmView.setInt16(i * 2, intSample, Endian.little);
    }

    final builder = BytesBuilder(copy: false);
    builder.add(header.buffer.asUint8List());
    builder.add(pcmBytes);
    return builder.toBytes();
  }

  /// Get model information
  Future<Map<String, dynamic>> getModelInfo() async {
    return await WhisperModelManager.getModelInfo('small.en');
  }

  /// Dispose resources
  void dispose() {
    _transcriptionTimer?.cancel();
    _transcriptionController.close();
    _audioBuffer.clear();
  }
}
