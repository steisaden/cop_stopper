import 'dart:async';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/widgets.dart';
import 'package:mobile/src/services/storage_service.dart';
import 'package:mobile/src/services/recording_service_interface.dart';

/// Web-compatible recording service using MediaRecorder API
class WebRecordingService implements RecordingService {
  final StorageService _storageService;

  // Recording state
  bool _isRecordingAudio = false;
  bool _isRecordingVideo = false;
  String? _currentRecordingId;

  // Web MediaRecorder
  html.MediaRecorder? _mediaRecorder;
  html.MediaStream? _mediaStream;
  Timer? _audioSimulationTimer;

  // Audio stream for real-time processing
  final StreamController<Uint8List> _audioStreamController =
      StreamController<Uint8List>.broadcast();

  // State management
  final ValueNotifier<bool> _isRecordingNotifier = ValueNotifier<bool>(false);

  WebRecordingService(this._storageService);

  @override
  bool get isRecording => _isRecordingNotifier.value;

  @override
  String? get currentRecordingId => _currentRecordingId;

  @override
  void setCameraController(dynamic controller) {
    // Web version doesn't use camera controller, so this is a no-op
    // In a real implementation, this would handle web camera setup
  }

  @override
  Stream<Uint8List>? get audioStream => _audioStreamController.stream;

  void _updateRecordingState() {
    final isNowRecording = _isRecordingAudio || _isRecordingVideo;
    _isRecordingNotifier.value = isNowRecording;
  }

  @override
  Future<void> startAudioRecording({String? recordingId}) async {
    try {
      _currentRecordingId =
          recordingId ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Request microphone permission
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'audio': true,
      });

      _mediaRecorder = html.MediaRecorder(_mediaStream!);

      // Start recording
      _mediaRecorder!.start();
      _isRecordingAudio = true;
      _updateRecordingState();

      // Start simulating audio stream data for transcription
      _audioSimulationTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!_isRecordingAudio) {
          timer.cancel();
          return;
        }
        _simulateAudioStream();
      });

      debugPrint('Web audio recording started with ID: $_currentRecordingId');
    } catch (e) {
      _isRecordingAudio = false;
      _currentRecordingId = null;
      throw Exception('Failed to start web audio recording: $e');
    }
  }

  @override
  Future<String?> stopAudioRecording() async {
    try {
      if (_isRecordingAudio && _mediaRecorder != null) {
        _mediaRecorder!.stop();
        _mediaStream?.getTracks().forEach((track) => track.stop());
        _audioSimulationTimer?.cancel();

        _isRecordingAudio = false;

        if (!_isRecordingVideo) {
          _currentRecordingId = null;
        }

        _updateRecordingState();

        debugPrint('Web audio recording stopped');

        // Return a simulated file path
        return 'web_audio_${DateTime.now().millisecondsSinceEpoch}.webm';
      }
      return null;
    } catch (e) {
      _isRecordingAudio = false;
      throw Exception('Failed to stop web audio recording: $e');
    }
  }

  @override
  Future<void> startVideoRecording() async {
    try {
      // Request camera and microphone permission
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': true,
        'audio': true,
      });

      _mediaRecorder = html.MediaRecorder(_mediaStream!);

      _mediaRecorder!.start();
      _isRecordingVideo = true;
      _updateRecordingState();

      debugPrint('Web video recording started');
    } catch (e) {
      _isRecordingVideo = false;
      throw Exception('Failed to start web video recording: $e');
    }
  }

  @override
  Future<String?> stopVideoRecording() async {
    try {
      if (_isRecordingVideo && _mediaRecorder != null) {
        _mediaRecorder!.stop();
        _mediaStream?.getTracks().forEach((track) => track.stop());

        _isRecordingVideo = false;
        _updateRecordingState();

        debugPrint('Web video recording stopped');

        // Return a simulated file path
        return 'web_video_${DateTime.now().millisecondsSinceEpoch}.webm';
      }
      return null;
    } catch (e) {
      _isRecordingVideo = false;
      throw Exception('Failed to stop web video recording: $e');
    }
  }

  @override
  Future<void> startAudioVideoRecording({String? recordingId}) async {
    try {
      _currentRecordingId =
          recordingId ?? DateTime.now().millisecondsSinceEpoch.toString();

      // Request camera and microphone permission
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({
        'video': true,
        'audio': true,
      });

      _mediaRecorder = html.MediaRecorder(_mediaStream!);

      _mediaRecorder!.start();
      _isRecordingAudio = true;
      _isRecordingVideo = true;
      _updateRecordingState();

      // Start simulating audio stream data for transcription
      _audioSimulationTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!_isRecordingAudio && !_isRecordingVideo) {
          timer.cancel();
          return;
        }
        _simulateAudioStream();
      });

      debugPrint(
          'Web audio/video recording started with ID: $_currentRecordingId');
    } catch (e) {
      _isRecordingAudio = false;
      _isRecordingVideo = false;
      _currentRecordingId = null;
      throw Exception('Failed to start web audio/video recording: $e');
    }
  }

  @override
  Future<String?> stopAudioVideoRecording() async {
    try {
      if ((_isRecordingAudio || _isRecordingVideo) && _mediaRecorder != null) {
        _mediaRecorder!.stop();
        _mediaStream?.getTracks().forEach((track) => track.stop());
        _audioSimulationTimer?.cancel();

        _isRecordingAudio = false;
        _isRecordingVideo = false;
        _updateRecordingState();

        debugPrint('Web audio/video recording stopped');

        // Return a simulated file path
        return 'web_recording_${DateTime.now().millisecondsSinceEpoch}.webm';
      }
      return null;
    } catch (e) {
      _isRecordingAudio = false;
      _isRecordingVideo = false;
      throw Exception('Failed to stop web recording: $e');
    }
  }

  /// Simulate audio stream data for transcription service
  void _simulateAudioStream() {
    // Generate some dummy audio data for the transcription service
    final dummyAudioData =
        Uint8List.fromList(List.generate(1024, (index) => (index % 256)));

    if (!_audioStreamController.isClosed) {
      _audioStreamController.add(dummyAudioData);
    }
  }

  /// Dispose of all resources
  Future<void> dispose() async {
    _audioSimulationTimer?.cancel();

    if (_mediaRecorder != null) {
      _mediaRecorder!.stop();
    }

    _mediaStream?.getTracks().forEach((track) => track.stop());

    if (!_audioStreamController.isClosed) {
      _audioStreamController.close();
    }

    _isRecordingNotifier.dispose();
  }
}
