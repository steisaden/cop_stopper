import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/storage_service.dart';
import 'package:mobile/src/services/history_service.dart';
import 'package:mobile/src/services/transcription_storage_service.dart';
import 'package:mobile/src/models/recording_model.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/service_locator.dart'
    if (dart.library.html) 'package:mobile/src/service_locator_web.dart';
import 'recording_event.dart';
import 'recording_state.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';

/// BLoC for managing camera controller and recording state
class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final RecordingService _recordingService;
  final StorageService _storageService;
  final HistoryService _historyService;
  final TranscriptionStorageService _transcriptionStorageService;
  final TranscriptionServiceInterface _transcriptionService;

  // Track transcription segments during recording
  final List<TranscriptionSegment> _currentTranscriptionSegments = [];
  StreamSubscription<TranscriptionSegment>? _transcriptionSubscription;

  Timer? _durationTimer;
  Timer? _storageMonitorTimer;
  Timer? _audioLevelTimer;
  StreamSubscription? _recordingEventsSubscription;
  DateTime? _recordingStartTime;
  Duration _pausedDuration = Duration.zero;

  RecordingBloc()
      : _recordingService = locator<RecordingService>(),
        _storageService = locator<StorageService>(),
        _historyService = locator<HistoryService>(),
        _transcriptionStorageService = locator<TranscriptionStorageService>(),
        _transcriptionService = locator<TranscriptionServiceInterface>(),
        super(const RecordingState.initial()) {
    // Register event handlers
    on<CameraInitializeRequested>(_onCameraInitializeRequested);
    on<CameraSwitchRequested>(_onCameraSwitchRequested);
    on<RecordingStartRequested>(_onRecordingStartRequested);
    on<RecordingStopRequested>(_onRecordingStopRequested);
    on<RecordingPauseRequested>(_onRecordingPauseRequested);
    on<RecordingResumeRequested>(_onRecordingResumeRequested);
    on<AudioOnlyModeToggled>(_onAudioOnlyModeToggled);
    on<FlashToggled>(_onFlashToggled);
    on<ZoomLevelChanged>(_onZoomLevelChanged);
    on<FocusPointSet>(_onFocusPointSet);
    on<StorageStatusUpdated>(_onStorageStatusUpdated);
    on<RecordingDurationUpdated>(_onRecordingDurationUpdated);
    on<AudioLevelUpdated>(_onAudioLevelUpdated);
    on<RecordingErrorOccurred>(_onRecordingErrorOccurred);
    on<RecordingErrorCleared>(_onRecordingErrorCleared);
    on<RecordingSaveRequested>(_onRecordingSaveRequested);
    on<LowStorageWarningShown>(_onLowStorageWarningShown);
    on<LowStorageWarningDismissed>(_onLowStorageWarningDismissed);

    // Listen to recording service events (commented out until interface is updated)
    // _recordingEventsSubscription = _recordingService.recordingEvents.listen(
    //   _handleRecordingServiceEvent,
    // );

    // Initialize storage monitoring
    _startStorageMonitoring();
  }

  /// Handle camera initialization
  Future<void> _onCameraInitializeRequested(
    CameraInitializeRequested event,
    Emitter<RecordingState> emit,
  ) async {
    debugPrint('RecordingBloc: CameraInitializeRequested received');
    try {
      emit(state.copyWith(status: RecordingStatus.cameraInitializing));
      debugPrint('RecordingBloc: calling availableCameras()');

      // Get available cameras with timeout
      final cameras = await availableCameras().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('RecordingBloc: availableCameras timed out');
          return [];
        },
      );
      debugPrint(
          'RecordingBloc: availableCameras returned ${cameras.length} cameras');

      if (cameras.isEmpty) {
        emit(state.copyWith(
          status: RecordingStatus.cameraError,
          errorMessage: 'No cameras available on this device',
          errorCode: 'NO_CAMERAS',
        ));
        return;
      }

      // Select camera (prefer specified camera or default to first)
      int cameraIndex = 0;
      if (event.preferredCamera != null) {
        cameraIndex = cameras.indexWhere(
          (camera) =>
              camera.lensDirection == event.preferredCamera!.lensDirection,
        );
        if (cameraIndex == -1) cameraIndex = 0;
      }

      // Initialize camera controller
      debugPrint(
          'RecordingBloc: Creating CameraController for camera index $cameraIndex');
      final controller = CameraController(
        cameras[cameraIndex],
        ResolutionPreset.high,
        enableAudio: true,
      );

      debugPrint('RecordingBloc: calling controller.initialize()');
      await controller.initialize();
      debugPrint('RecordingBloc: controller.initialize() completed');

      // Check if current camera has flash
      final hasFlash =
          cameras[cameraIndex].lensDirection == CameraLensDirection.back;

      emit(state.copyWith(
        cameraController: controller,
        availableCameras: cameras,
        activeCameraIndex: cameraIndex,
        hasFlash: hasFlash,
        isFlashOn: false, // Reset flash state when initializing
        status: RecordingStatus.cameraReady,
        clearError: true,
      ));

      // Share the camera controller with the recording service
      debugPrint(
          'RecordingBloc: Setting camera controller on service. Controller initialized: ${controller.value.isInitialized}');
      _recordingService.setCameraController(controller);
    } catch (e) {
      emit(state.copyWith(
        status: RecordingStatus.cameraError,
        errorMessage: 'Failed to initialize camera: ${e.toString()}',
        errorCode: 'CAMERA_INIT_FAILED',
      ));
    }
  }

  /// Handle camera switch
  Future<void> _onCameraSwitchRequested(
    CameraSwitchRequested event,
    Emitter<RecordingState> emit,
  ) async {
    if (!state.hasMultipleCameras || state.isRecording) return;

    try {
      final newIndex =
          (state.activeCameraIndex + 1) % state.availableCameras.length;
      final newCamera = state.availableCameras[newIndex];

      // Dispose current controller
      await state.cameraController?.dispose();

      // Initialize new controller
      final controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await controller.initialize();

      // Check if new camera has flash
      final hasFlash = newCamera.lensDirection == CameraLensDirection.back;

      emit(state.copyWith(
        cameraController: controller,
        activeCameraIndex: newIndex,
        hasFlash: hasFlash,
        isFlashOn: false, // Reset flash state when switching cameras
        zoomLevel: 1.0, // Reset zoom when switching cameras
        clearError: true,
      ));

      // Share the new camera controller with the recording service
      _recordingService.setCameraController(controller);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to switch camera: ${e.toString()}',
        errorCode: 'CAMERA_SWITCH_FAILED',
      ));
    }
  }

  /// Handle recording start
  Future<void> _onRecordingStartRequested(
    RecordingStartRequested event,
    Emitter<RecordingState> emit,
  ) async {
    debugPrint('RecordingBloc: RecordingStartRequested received');
    if (state.isRecording) {
      debugPrint('RecordingBloc: Already recording, ignoring request');
      return;
    }

    try {
      debugPrint('RecordingBloc: Emitting recordingStarting state');
      emit(state.copyWith(status: RecordingStatus.recordingStarting));

      // Check storage before starting
      if (state.isLowStorage) {
        debugPrint('RecordingBloc: Storage is low, showing warning');
        emit(state.copyWith(showLowStorageWarning: true));
        return;
      }

      // Generate recording ID
      final recordingId = DateTime.now().millisecondsSinceEpoch.toString();
      debugPrint('RecordingBloc: Generated recording ID: $recordingId');

      debugPrint(
          'RecordingBloc: Calling _recordingService.startAudioVideoRecording (audioOnly=${state.isAudioOnly})');
      // Start recording based on mode
      if (state.isAudioOnly) {
        await _recordingService.startAudioRecording(recordingId: recordingId);
      } else {
        // Ensure service has the latest controller if we have one
        if (state.cameraController != null) {
          debugPrint(
              'RecordingBloc: Re-asserting camera controller before start');
          _recordingService.setCameraController(state.cameraController);
        }
        await _recordingService.startAudioVideoRecording(
            recordingId: recordingId);
      }

      debugPrint('RecordingBloc: Recording started successfully in service');
      // Reset timing variables for new recording
      _recordingStartTime = DateTime.now();
      _pausedDuration = Duration.zero;

      emit(state.copyWith(
        isRecording: true,
        status: RecordingStatus.recording,
        recordingDuration: Duration.zero,
        clearError: true,
        recordingId: recordingId, // Store ID in state
      ));

      // Start duration timer
      _startDurationTimer();
      _startAudioLevelMonitoring();

      // Start transcription with the generated ID
      debugPrint('RecordingBloc: Starting transcription with ID: $recordingId');
      _transcriptionService.startTranscription(recordingId);

      // Subscribe to transcription stream to collect segments
      _subscribeToTranscriptionStream();
    } catch (e, stackTrace) {
      debugPrint('RecordingBloc: Error starting recording: $e');
      debugPrint('RecordingBloc: StackTrace: $stackTrace');
      emit(state.copyWith(
        status: RecordingStatus.error,
        errorMessage: 'Failed to start recording: ${e.toString()}',
        errorCode: 'RECORDING_START_FAILED',
      ));
    }
  }

  /// Handle recording stop
  Future<void> _onRecordingStopRequested(
    RecordingStopRequested event,
    Emitter<RecordingState> emit,
  ) async {
    if (!state.isRecording) return;

    try {
      debugPrint('RecordingBloc: Starting to stop recording...');
      emit(state.copyWith(status: RecordingStatus.recordingStopping));

      // Stop timers
      _stopDurationTimer();
      _stopAudioLevelMonitoring();

      // Stop recording
      String? savedPath;
      debugPrint('RecordingBloc: Audio only mode: ${state.isAudioOnly}');

      if (state.isAudioOnly) {
        debugPrint('RecordingBloc: Stopping audio recording...');
        savedPath = await _recordingService.stopAudioRecording();
      } else {
        debugPrint('RecordingBloc: Stopping audio/video recording...');
        savedPath = await _recordingService.stopAudioVideoRecording();
      }

      // Stop transcription
      debugPrint('RecordingBloc: Stopping transcription...');
      await _transcriptionService.stopTranscription();

      debugPrint('RecordingBloc: Recording stopped, saved path: $savedPath');

      // Reset timing variables
      _recordingStartTime = null;
      _pausedDuration = Duration.zero;

      emit(state.copyWith(
        isRecording: false,
        isPaused: false,
        status: RecordingStatus.recordingSaved,
        lastSavedVideoPath: state.isAudioOnly ? null : savedPath,
        lastSavedAudioPath: state.isAudioOnly ? savedPath : null,
        audioLevel: 0.0,
        clearError: true,
        // Keep recordingId in state for save step
      ));

      debugPrint(
          'RecordingBloc: State updated, triggering save confirmation...');

      // Trigger save confirmation with correct file type detection
      if (!state.isAudioOnly &&
          savedPath != null &&
          savedPath.endsWith('.m4a')) {
        // Fallback to audio detected
        debugPrint('RecordingBloc: Detected audio-only fallback file');
        add(RecordingSaveRequested(
          audioPath: savedPath,
          videoPath: null,
        ));
      } else {
        add(RecordingSaveRequested(
          audioPath: state.isAudioOnly ? savedPath : null,
          videoPath: state.isAudioOnly ? null : savedPath,
        ));
      }
    } catch (e) {
      debugPrint('RecordingBloc: Error stopping recording: $e');
      emit(state.copyWith(
        status: RecordingStatus.error,
        errorMessage: 'Failed to stop recording: ${e.toString()}',
        errorCode: 'RECORDING_STOP_FAILED',
      ));
    }
  }

  /// Handle recording pause
  Future<void> _onRecordingPauseRequested(
    RecordingPauseRequested event,
    Emitter<RecordingState> emit,
  ) async {
    if (!state.isRecording || state.isPaused) return;

    // Calculate and store the duration up to this point
    if (_recordingStartTime != null) {
      final currentDuration =
          DateTime.now().difference(_recordingStartTime!) - _pausedDuration;
      _pausedDuration = _pausedDuration + currentDuration;
    }

    emit(state.copyWith(
      isPaused: true,
      status: RecordingStatus.recordingPaused,
    ));

    _stopDurationTimer();
    _stopAudioLevelMonitoring();
  }

  /// Handle recording resume
  Future<void> _onRecordingResumeRequested(
    RecordingResumeRequested event,
    Emitter<RecordingState> emit,
  ) async {
    if (!state.isRecording || !state.isPaused) return;

    // Reset the start time for resume
    _recordingStartTime = DateTime.now();

    emit(state.copyWith(
      isPaused: false,
      status: RecordingStatus.recording,
    ));

    _startDurationTimer();
    _startAudioLevelMonitoring();
  }

  /// Handle audio-only mode toggle
  void _onAudioOnlyModeToggled(
    AudioOnlyModeToggled event,
    Emitter<RecordingState> emit,
  ) {
    if (state.isRecording) return; // Can't change mode while recording

    emit(state.copyWith(isAudioOnly: !state.isAudioOnly));
  }

  /// Handle flash toggle
  Future<void> _onFlashToggled(
    FlashToggled event,
    Emitter<RecordingState> emit,
  ) async {
    if (state.cameraController?.value.isInitialized != true) return;

    // Check if flash is available on current camera
    if (!state.hasFlash) {
      emit(state.copyWith(
        errorMessage: 'Flash is not available on this camera',
        errorCode: 'FLASH_NOT_AVAILABLE',
      ));
      return;
    }

    try {
      final controller = state.cameraController!;

      // Toggle flash mode
      final newFlashMode = state.isFlashOn ? FlashMode.off : FlashMode.torch;
      await controller.setFlashMode(newFlashMode);

      emit(state.copyWith(isFlashOn: !state.isFlashOn));
    } catch (e) {
      // Handle specific flash-related errors
      String errorMessage = 'Failed to toggle flash';
      String errorCode = 'FLASH_TOGGLE_FAILED';

      if (e.toString().contains('not supported') ||
          e.toString().contains('not available') ||
          e.toString().contains('torch')) {
        errorMessage = 'Flash is not supported on this device';
        errorCode = 'FLASH_NOT_SUPPORTED';
      }

      emit(state.copyWith(
        errorMessage: '$errorMessage: ${e.toString()}',
        errorCode: errorCode,
      ));
    }
  }

  /// Handle zoom level change
  Future<void> _onZoomLevelChanged(
    ZoomLevelChanged event,
    Emitter<RecordingState> emit,
  ) async {
    if (state.cameraController?.value.isInitialized != true) return;

    try {
      await state.cameraController!.setZoomLevel(event.zoomLevel);
      emit(state.copyWith(zoomLevel: event.zoomLevel));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to set zoom level: ${e.toString()}',
        errorCode: 'ZOOM_FAILED',
      ));
    }
  }

  /// Handle focus point set
  Future<void> _onFocusPointSet(
    FocusPointSet event,
    Emitter<RecordingState> emit,
  ) async {
    if (state.cameraController?.value.isInitialized != true) return;

    try {
      await state.cameraController!.setFocusPoint(event.focusPoint);
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to set focus point: ${e.toString()}',
        errorCode: 'FOCUS_FAILED',
      ));
    }
  }

  /// Handle storage status update
  void _onStorageStatusUpdated(
    StorageStatusUpdated event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(
      availableStorageGB: event.availableSpaceGB,
      isLowStorage: event.isLowStorage,
    ));

    // Show warning if storage becomes low during recording
    if (event.isLowStorage &&
        state.isRecording &&
        !state.showLowStorageWarning) {
      emit(state.copyWith(showLowStorageWarning: true));
    }
  }

  /// Handle recording duration update
  void _onRecordingDurationUpdated(
    RecordingDurationUpdated event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(recordingDuration: event.duration));
  }

  /// Handle audio level update
  void _onAudioLevelUpdated(
    AudioLevelUpdated event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(audioLevel: event.level));
  }

  /// Handle recording error
  void _onRecordingErrorOccurred(
    RecordingErrorOccurred event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(
      status: RecordingStatus.error,
      errorMessage: event.error,
      errorCode: event.errorCode,
    ));
  }

  /// Handle error clearing
  void _onRecordingErrorCleared(
    RecordingErrorCleared event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(clearError: true));
  }

  /// Handle recording save
  void _onRecordingSaveRequested(
    RecordingSaveRequested event,
    Emitter<RecordingState> emit,
  ) async {
    // This would typically trigger UI feedback showing save confirmation
    // For now, just update the state and save to history
    emit(state.copyWith(
      lastSavedAudioPath: event.audioPath,
      lastSavedVideoPath: event.videoPath,
    ));

    // Save to history if there's a valid path
    if ((event.videoPath != null && event.videoPath!.isNotEmpty) ||
        (event.audioPath != null && event.audioPath!.isNotEmpty)) {
      try {
        // Determine file path to use
        String? filePath = event.videoPath ?? event.audioPath;
        if (filePath != null) {
          // Use stored recordingId, or fallback to new one if missing (shouldn't happen in normal flow)
          final recordingId = state.recordingId ??
              DateTime.now().millisecondsSinceEpoch.toString();
          debugPrint('RecordingBloc: Saving recording with ID: $recordingId');

          // Save transcription segments if any were captured
          String? transcriptionFilePath;
          int transcriptionSegmentCount = 0;
          bool hasTranscription = false;

          debugPrint(
              '📝 Checking transcription segments: ${_currentTranscriptionSegments.length} collected');

          // Also check storage service for existing file (WhisperTranscriptionService saves it)
          final storedTranscriptionPath = await _transcriptionStorageService
              .getTranscriptionFilePath(recordingId);
          final bool storageHasFile =
              await File(storedTranscriptionPath).exists();

          if (storageHasFile) {
            debugPrint(
                '✅ Found existing transcription file at $storedTranscriptionPath');
            transcriptionFilePath = storedTranscriptionPath;
            hasTranscription = true;
            // We could load count, but maybe not strictly necessary for the model count field right now
            // Or we can trust _currentTranscriptionSegments if we were listening?
          }

          // If we have segments in memory but no file (e.g. storage save failed?), try saving again?
          // WhisperTranscriptionService should have saved it.
          // But if we have segments here, we can try to ensure it's saved.
          if (_currentTranscriptionSegments.isNotEmpty) {
            transcriptionSegmentCount = _currentTranscriptionSegments.length;
            if (!hasTranscription) {
              try {
                debugPrint(
                    '💾 Saving ${_currentTranscriptionSegments.length} transcription segments (fallback)...');
                await _transcriptionStorageService.saveTranscription(
                  recordingId,
                  _currentTranscriptionSegments,
                );
                transcriptionFilePath = await _transcriptionStorageService
                    .getTranscriptionFilePath(recordingId);
                hasTranscription = true;
                debugPrint('✅ Saved transcription segments (fallback)');
              } catch (e) {
                debugPrint('⚠️ Failed to save transcription (fallback): $e');
              }
            }
          }

          // Create a new Recording instance with transcription metadata
          final recording = Recording(
            id: recordingId,
            filePath: filePath,
            timestamp: DateTime.now(),
            durationSeconds: state.recordingDuration.inSeconds,
            fileType: event.videoPath != null
                ? RecordingFileType.video
                : RecordingFileType.audio,
            transcriptionFilePath: transcriptionFilePath,
            transcriptionSegmentCount: transcriptionSegmentCount,
            hasTranscription: hasTranscription,
          );

          // Save to history service
          await _historyService.saveRecordingToHistory(recording);
          debugPrint('Recording saved to history: ${recording.id}');

          // Clear transcription segments for next recording
          _currentTranscriptionSegments.clear();
        }
      } catch (e) {
        debugPrint('Failed to save recording to history: $e');
      }
    }
  }

  /// Handle low storage warning shown
  void _onLowStorageWarningShown(
    LowStorageWarningShown event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(showLowStorageWarning: true));
  }

  /// Handle low storage warning dismissed
  void _onLowStorageWarningDismissed(
    LowStorageWarningDismissed event,
    Emitter<RecordingState> emit,
  ) {
    emit(state.copyWith(showLowStorageWarning: false));
  }

  /// Handle recording service events
  void _handleRecordingServiceEvent(dynamic event) {
    // Convert recording service events to bloc events
    // This would be expanded based on the recording service event types
  }

  /// Start duration timer
  void _startDurationTimer() {
    _durationTimer?.cancel();

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isRecording || state.isPaused) {
        timer.cancel();
        return;
      }

      // Calculate total duration: time since start + any previous paused duration
      if (_recordingStartTime != null) {
        final currentSessionDuration =
            DateTime.now().difference(_recordingStartTime!);
        final totalDuration = _pausedDuration + currentSessionDuration;
        add(RecordingDurationUpdated(totalDuration));
      }
    });
  }

  /// Stop duration timer
  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  /// Start audio level monitoring
  void _startAudioLevelMonitoring() {
    _audioLevelTimer?.cancel();

    _audioLevelTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!state.isRecording || state.isPaused) {
        timer.cancel();
        return;
      }

      // Simulate audio level (in real implementation, this would come from the recording service)
      final level = (DateTime.now().millisecondsSinceEpoch % 1000) / 1000.0;
      add(AudioLevelUpdated(level));
    });
  }

  /// Stop audio level monitoring
  void _stopAudioLevelMonitoring() {
    _audioLevelTimer?.cancel();
    _audioLevelTimer = null;
  }

  /// Start storage monitoring
  void _startStorageMonitoring() {
    _storageMonitorTimer?.cancel();

    _storageMonitorTimer =
        Timer.periodic(const Duration(minutes: 1), (timer) async {
      try {
        final isLow = await _storageService.isStorageLow();
        final availableGB = await _getAvailableStorageGB();

        add(StorageStatusUpdated(
          availableSpaceGB: availableGB,
          isLowStorage: isLow,
        ));
      } catch (e) {
        // Handle storage monitoring error silently
      }
    });

    // Initial storage check
    _checkInitialStorage();
  }

  /// Check initial storage
  Future<void> _checkInitialStorage() async {
    try {
      final isLow = await _storageService.isStorageLow();
      final availableGB = await _getAvailableStorageGB();

      add(StorageStatusUpdated(
        availableSpaceGB: availableGB,
        isLowStorage: isLow,
      ));
    } catch (e) {
      // Handle initial storage check error silently
    }
  }

  /// Get available storage in GB
  Future<double> _getAvailableStorageGB() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // This is a simplified implementation
        // In reality, you'd need to use platform channels or a storage plugin
        return 5.0; // Placeholder
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // This is a simplified implementation
        return 5.0; // Placeholder
      }
      return 5.0;
    } catch (e) {
      return 5.0; // Default fallback
    }
  }

  @override
  Future<void> close() async {
    // Clean up resources
    _durationTimer?.cancel();
    _storageMonitorTimer?.cancel();
    _audioLevelTimer?.cancel();
    await _recordingEventsSubscription?.cancel();
    await _transcriptionSubscription?.cancel();

    // Reset timing variables
    _pausedDuration = Duration.zero;

    // Dispose camera controller
    await state.cameraController?.dispose();

    return super.close();
  }

  /// Subscribe to transcription stream to collect segments during recording
  void _subscribeToTranscriptionStream() {
    try {
      debugPrint('🎤 Attempting to subscribe to transcription stream...');
      _transcriptionSubscription?.cancel();
      _currentTranscriptionSegments.clear();

      _transcriptionSubscription =
          _transcriptionService.transcriptionStream.listen(
        (segment) {
          debugPrint(
              '📝 Collected transcription segment: "${segment.text}" (total: ${_currentTranscriptionSegments.length + 1})');
          _currentTranscriptionSegments.add(segment);
        },
        onError: (error) {
          debugPrint('⚠️ Transcription stream error: $error');
        },
      );

      debugPrint('✅ Transcription subscription initialized');
    } catch (e) {
      debugPrint('⚠️ Could not subscribe to transcription stream: $e');
    }
  }
}
