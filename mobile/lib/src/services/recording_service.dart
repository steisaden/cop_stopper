import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/services/storage_service.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/models/recording_model.dart';

/// Exception thrown when recording operations fail
class RecordingException implements Exception {
  final String message;
  final String? code;

  const RecordingException(this.message, {this.code});

  @override
  String toString() => 'RecordingException: $message';
}

/// Enhanced recording service with background recording, file management, and segmentation
class AudioVideoRecordingService implements RecordingService {
  final _audioRecorder = AudioRecorder();
  final StorageService _storageService;

  // Recording state
  bool _isRecordingAudio = false;
  bool _isRecordingVideo = false;
  String? _currentAudioPath;
  String? _currentVideoPath;

  // Camera management
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;

  // Advanced features
  DateTime? _recordingStartTime;
  Timer? _segmentationTimer;
  Timer? _storageMonitorTimer;

  // State management
  final ValueNotifier<bool> _isRecordingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> _recordingStatusNotifier =
      ValueNotifier<String>('Ready');
  final StreamController<RecordingEvent> _recordingEventController =
      StreamController<RecordingEvent>.broadcast();

  // Audio stream for real-time processing
  final StreamController<Uint8List> _audioStreamController =
      StreamController<Uint8List>.broadcast();
  StreamSubscription<Uint8List>? _audioDataSubscription;

  // Configuration
  static const Duration _maxSegmentDuration = Duration(hours: 2);
  static const Duration _storageCheckInterval = Duration(minutes: 1);
  static const int _minStorageThresholdMB = 100;

  AudioVideoRecordingService(this._storageService);

  @override
  bool get isRecording => _isRecordingNotifier.value;

  @override
  Stream<Uint8List>? get audioStream => _audioStreamController.stream;

  /// Stream of recording events for real-time status updates
  Stream<RecordingEvent> get recordingEvents =>
      _recordingEventController.stream;

  /// Current recording status as a notifier
  ValueNotifier<String> get recordingStatusNotifier => _recordingStatusNotifier;

  /// Recording state notifier for UI updates
  ValueNotifier<bool> get isRecordingNotifier => _isRecordingNotifier;

  void _updateRecordingState() {
    final wasRecording = _isRecordingNotifier.value;
    final isNowRecording = _isRecordingAudio || _isRecordingVideo;

    _isRecordingNotifier.value = isNowRecording;

    if (wasRecording != isNowRecording) {
      _recordingEventController.add(RecordingEvent(
        type: isNowRecording
            ? RecordingEventType.started
            : RecordingEventType.stopped,
        timestamp: DateTime.now(),
        message: isNowRecording ? 'Recording started' : 'Recording stopped',
      ));
    }
  }

  void _updateStatus(String status) {
    _recordingStatusNotifier.value = status;
    debugPrint('Recording Status: $status');
  }

  /// Initialize camera for video recording
  Future<void> _initializeCamera() async {
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        throw const RecordingException(
            'Camera controller not provided or not initialized. Please initialize camera from RecordingBloc first.');
      }
      _updateStatus('Camera ready for recording');
    } catch (e) {
      throw RecordingException('Failed to initialize camera: ${e.toString()}');
    }
  }

  /// Check and request recording permissions
  Future<void> _checkPermissions() async {
    // Check microphone permission
    if (!await _audioRecorder.hasPermission()) {
      throw const RecordingException('Microphone permission not granted');
    }

    // Camera permission is handled by the camera plugin
    _updateStatus('Permissions verified');
  }

  /// Monitor storage space during recording
  void _startStorageMonitoring() {
    _storageMonitorTimer?.cancel();
    _storageMonitorTimer = Timer.periodic(_storageCheckInterval, (timer) async {
      try {
        if (await _storageService.isStorageLow()) {
          _recordingEventController.add(RecordingEvent(
            type: RecordingEventType.warning,
            timestamp: DateTime.now(),
            message:
                'Storage space is low. Consider stopping recording or compressing old files.',
          ));

          // Attempt to compress old recordings
          await _storageService.compressOldRecordings();

          // Check again after compression
          if (await _storageService.isStorageLow()) {
            _recordingEventController.add(RecordingEvent(
              type: RecordingEventType.error,
              timestamp: DateTime.now(),
              message:
                  'Critical storage space. Recording may stop automatically.',
            ));
          }
        }
      } catch (e) {
        debugPrint('Storage monitoring error: $e');
      }
    });
  }

  /// Start automatic recording segmentation
  void _startSegmentationTimer() {
    _segmentationTimer?.cancel();
    _segmentationTimer =
        Timer.periodic(const Duration(minutes: 5), (timer) async {
      if (_recordingStartTime != null &&
          DateTime.now().difference(_recordingStartTime!) >=
              _maxSegmentDuration) {
        _recordingEventController.add(RecordingEvent(
          type: RecordingEventType.segmentation,
          timestamp: DateTime.now(),
          message: 'Recording segment reached 2 hours. Creating new segment.',
        ));

        // Stop current recording and start new segment
        await _createNewSegment();
      }
    });
  }

  /// Create a new recording segment
  Future<void> _createNewSegment() async {
    try {
      _updateStatus('Creating new recording segment...');

      // Stop current recordings
      final audioPath = await stopAudioRecording();
      final videoPath = await stopVideoRecording();

      // Save completed segment information
      if (audioPath != null || videoPath != null) {
        final duration = _recordingStartTime != null
            ? DateTime.now().difference(_recordingStartTime!).inSeconds
            : 0;

        // Here you would typically save the recording metadata
        // For now, we'll just log it
        debugPrint(
            'Completed segment - Audio: $audioPath, Video: $videoPath, Duration: ${duration}s');
      }

      // Start new segment
      await startAudioVideoRecording();
    } catch (e) {
      _recordingEventController.add(RecordingEvent(
        type: RecordingEventType.error,
        timestamp: DateTime.now(),
        message: 'Failed to create new segment: ${e.toString()}',
      ));
    }
  }

  @override
  Future<void> startAudioRecording() async {
    try {
      await _checkPermissions();

      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      await recordingsDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentAudioPath = '${recordingsDir.path}/audio_$timestamp.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
        ),
        path: _currentAudioPath!,
      );

      _isRecordingAudio = true;

      // Set recording start time if not already set
      _recordingStartTime ??= DateTime.now();

      _updateRecordingState();
      _updateStatus('Audio recording active');

      // Start audio stream for real-time processing
      await _startAudioStream();

      _recordingEventController.add(RecordingEvent(
        type: RecordingEventType.audioStarted,
        timestamp: DateTime.now(),
        message: 'Audio recording started',
        filePath: _currentAudioPath,
      ));
    } catch (e) {
      _isRecordingAudio = false;
      _currentAudioPath = null;
      _updateStatus('Audio recording failed');
      throw RecordingException(
          'Failed to start audio recording: ${e.toString()}');
    }
  }

  @override
  Future<String?> stopAudioRecording() async {
    try {
      if (_isRecordingAudio) {
        final path = await _audioRecorder.stop();
        _isRecordingAudio = false;

        // Clear recording start time if no other recording is active
        if (!_isRecordingVideo) {
          _recordingStartTime = null;
        }

        _updateRecordingState();
        _updateStatus('Audio recording stopped');

        // Stop audio stream
        await _stopAudioStream();

        _recordingEventController.add(RecordingEvent(
          type: RecordingEventType.audioStopped,
          timestamp: DateTime.now(),
          message: 'Audio recording stopped',
          filePath: path,
        ));

        return path;
      }
      return null;
    } catch (e) {
      _isRecordingAudio = false;
      _currentAudioPath = null;
      _updateStatus('Error stopping audio recording');
      throw RecordingException(
          'Failed to stop audio recording: ${e.toString()}');
    } finally {
      _currentAudioPath = null;
    }
  }

  @override
  Future<void> startVideoRecording() async {
    try {
      debugPrint('RecordingService: Starting video recording...');
      await _initializeCamera();

      if (!_cameraController!.value.isInitialized) {
        throw const RecordingException('Camera not initialized');
      }

      if (_isRecordingVideo) {
        throw const RecordingException('Video recording already in progress');
      }

      final directory = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${directory.path}/recordings');
      await recordingsDir.create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentVideoPath = '${recordingsDir.path}/video_$timestamp.mp4';

      debugPrint('RecordingService: Starting camera video recording...');
      await _cameraController!.startVideoRecording();
      _isRecordingVideo = true;
      _updateRecordingState();
      _updateStatus('Video recording active');

      _recordingEventController.add(RecordingEvent(
        type: RecordingEventType.videoStarted,
        timestamp: DateTime.now(),
        message: 'Video recording started',
        filePath: _currentVideoPath,
      ));
    } catch (e) {
      _isRecordingVideo = false;
      _currentVideoPath = null;
      _updateStatus('Video recording failed');
      throw RecordingException(
          'Failed to start video recording: ${e.toString()}');
    }
  }

  @override
  Future<String?> stopVideoRecording() async {
    try {
      debugPrint('RecordingService: stopVideoRecording called');
      debugPrint('RecordingService: _isRecordingVideo = $_isRecordingVideo');
      debugPrint(
          'RecordingService: _cameraController != null = ${_cameraController != null}');

      if (_isRecordingVideo && _cameraController != null) {
        debugPrint('RecordingService: Stopping camera video recording...');
        final XFile videoFile = await _cameraController!.stopVideoRecording();
        _isRecordingVideo = false;

        debugPrint(
            'RecordingService: Video file saved to temp location: ${videoFile.path}');

        // Save video to permanent location
        final directory = await getApplicationDocumentsDirectory();
        final recordingsDir = Directory('${directory.path}/recordings');
        await recordingsDir.create(recursive: true);

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final permanentPath = '${recordingsDir.path}/video_$timestamp.mp4';

        debugPrint(
            'RecordingService: Copying video to permanent location: $permanentPath');

        // Copy from temporary location to permanent location
        final videoBytes = await videoFile.readAsBytes();
        final permanentFile = File(permanentPath);
        await permanentFile.writeAsBytes(videoBytes);

        debugPrint(
            'RecordingService: Video copied successfully, size: ${videoBytes.length} bytes');

        // Clean up temporary file
        try {
          await File(videoFile.path).delete();
          debugPrint('RecordingService: Temporary file deleted');
        } catch (e) {
          debugPrint('Warning: Could not delete temporary file: $e');
        }

        _currentVideoPath = permanentPath;
        _updateRecordingState();
        _updateStatus('Video recording stopped and saved');

        _recordingEventController.add(RecordingEvent(
          type: RecordingEventType.videoStopped,
          timestamp: DateTime.now(),
          message: 'Video recording stopped and saved',
          filePath: permanentPath,
        ));

        return permanentPath;
      } else {
        debugPrint(
            'RecordingService: Video recording not active or camera controller null');
        return null;
      }
    } catch (e) {
      debugPrint('RecordingService: Error stopping video recording: $e');
      _isRecordingVideo = false;
      _currentVideoPath = null;
      _updateStatus('Error stopping video recording');
      throw RecordingException(
          'Failed to stop video recording: ${e.toString()}');
    } finally {
      if (!_isRecordingVideo) {
        _currentVideoPath = null;
      }
    }
  }

  @override
  Future<void> startAudioVideoRecording() async {
    try {
      _updateStatus('Preparing to start recording...');

      // Check storage space before starting
      if (await _storageService.isStorageLow()) {
        _recordingEventController.add(RecordingEvent(
          type: RecordingEventType.warning,
          timestamp: DateTime.now(),
          message:
              'Storage space is low. Attempting to compress old recordings.',
        ));

        await _storageService.compressOldRecordings();

        // Check again after compression
        if (await _storageService.isStorageLow()) {
          throw const RecordingException(
            'Insufficient storage space for recording. Please free up space and try again.',
            code: 'STORAGE_LOW',
          );
        }
      }

      // Start both audio and video recording
      await startAudioRecording();
      bool videoStarted = false;
      try {
        await startVideoRecording();
        videoStarted = true;
      } catch (e) {
        // If camera/video fails, continue with audio-only to avoid blocking the session.
        _isRecordingVideo = false;
        _currentVideoPath = null;
        _updateStatus(
            'Video unavailable, continuing audio-only. Error: ${e.toString()}');
        debugPrint(
            'RecordingService: Video start failed, proceeding audio-only: $e');
      }

      // Set recording start time and enable advanced features
      _recordingStartTime = DateTime.now();
      _startStorageMonitoring();
      _startSegmentationTimer();

      _updateStatus(videoStarted
          ? 'Recording in progress'
          : 'Audio-only recording in progress');

      _recordingEventController.add(RecordingEvent(
        type: RecordingEventType.started,
        timestamp: DateTime.now(),
        message: videoStarted
            ? 'Audio and video recording started successfully'
            : 'Audio recording started (video unavailable)',
      ));
    } catch (e) {
      // Clean up on failure
      await _stopAllRecording();
      throw RecordingException(
          'Failed to start audio/video recording: ${e.toString()}');
    }
  }

  @override
  Future<String?> stopAudioVideoRecording() async {
    try {
      debugPrint('RecordingService: Starting to stop audio/video recording...');
      _updateStatus('Stopping recording...');

      // Stop timers
      _segmentationTimer?.cancel();
      _segmentationTimer = null;
      _storageMonitorTimer?.cancel();
      _storageMonitorTimer = null;

      // Stop recordings
      debugPrint('RecordingService: Stopping audio recording...');
      final audioPath = await stopAudioRecording();
      debugPrint('RecordingService: Audio stopped, path: $audioPath');

      String? videoPath;
      try {
        debugPrint('RecordingService: Stopping video recording...');
        videoPath = await stopVideoRecording();
        debugPrint('RecordingService: Video stopped, path: $videoPath');
      } catch (e) {
        debugPrint('RecordingService: Failed to stop video recording: $e');
        // Continue with audio-only recording if video fails
        videoPath = null;
      }

      // Calculate recording duration
      final duration = _recordingStartTime != null
          ? DateTime.now().difference(_recordingStartTime!).inSeconds
          : 0;

      _recordingStartTime = null;
      _updateStatus('Recording completed');

      debugPrint(
          'RecordingService: Recording completed, duration: ${duration}s');

      _recordingEventController.add(RecordingEvent(
        type: RecordingEventType.completed,
        timestamp: DateTime.now(),
        message: 'Recording completed successfully (${duration}s)',
        metadata: {
          'audioPath': audioPath,
          'videoPath': videoPath,
          'duration': duration,
        },
      ));

      // Return video path for compatibility, or audio path if video failed
      return videoPath ?? audioPath;
    } catch (e) {
      _updateStatus('Error stopping recording');
      throw RecordingException('Failed to stop recording: ${e.toString()}');
    }
  }

  /// Stop all recording activities (internal cleanup method)
  Future<void> _stopAllRecording() async {
    _segmentationTimer?.cancel();
    _segmentationTimer = null;
    _storageMonitorTimer?.cancel();
    _storageMonitorTimer = null;

    if (_isRecordingAudio) {
      try {
        await stopAudioRecording();
      } catch (e) {
        debugPrint('Error stopping audio during cleanup: $e');
      }
    }

    if (_isRecordingVideo) {
      try {
        await stopVideoRecording();
      } catch (e) {
        debugPrint('Error stopping video during cleanup: $e');
      }
    }

    _recordingStartTime = null;
    _updateStatus('Ready');
  }

  /// Get current recording duration
  Duration? get currentRecordingDuration {
    if (_recordingStartTime != null && isRecording) {
      return DateTime.now().difference(_recordingStartTime!);
    }
    return null;
  }

  /// Get camera controller for UI preview
  CameraController? get cameraController => _cameraController;

  /// Set camera controller from external source (e.g., from RecordingBloc)
  void setCameraController(CameraController? controller) {
    debugPrint(
        'RecordingService: setCameraController called. Controller is null: ${controller == null}');
    if (controller != null) {
      debugPrint(
          'RecordingService: Controller initialized: ${controller.value.isInitialized}');
    }
    _cameraController = controller;
  }

  /// Dispose of all resources
  Future<void> dispose() async {
    await _stopAllRecording();

    if (!_recordingEventController.isClosed) {
      _recordingEventController.close();
    }

    _isRecordingNotifier.dispose();
    _recordingStatusNotifier.dispose();

    _audioRecorder.dispose();
    await _cameraController?.dispose();
    _cameraController = null;
  }

  /// Start audio stream for real-time processing
  Future<void> _startAudioStream() async {
    try {
      // Start recording stream from the audio recorder
      final stream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );

      // Forward audio data to our stream controller
      final subscription = stream.listen(
        (data) {
          if (_isRecordingAudio) {
            _audioStreamController.add(data);
          }
        },
        onError: (error) {
          debugPrint('Audio stream error: $error');
        },
      );
      _audioDataSubscription = subscription;

      debugPrint('Audio stream started');
    } catch (e) {
      debugPrint('Failed to start audio stream: $e');
    }
  }

  /// Stop audio stream
  Future<void> _stopAudioStream() async {
    try {
      await _audioDataSubscription?.cancel();
      debugPrint('Audio stream stopped');
    } catch (e) {
      debugPrint('Error stopping audio stream: $e');
    }
  }
}

/// Recording event types for real-time status updates
enum RecordingEventType {
  started,
  stopped,
  audioStarted,
  audioStopped,
  videoStarted,
  videoStopped,
  segmentation,
  warning,
  error,
  completed,
}

/// Recording event for real-time status updates
class RecordingEvent {
  final RecordingEventType type;
  final DateTime timestamp;
  final String message;
  final String? filePath;
  final Map<String, dynamic>? metadata;

  const RecordingEvent({
    required this.type,
    required this.timestamp,
    required this.message,
    this.filePath,
    this.metadata,
  });

  @override
  String toString() => 'RecordingEvent(${type.name}: $message)';
}
