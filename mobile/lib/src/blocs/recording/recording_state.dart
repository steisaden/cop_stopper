import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';

/// Recording state containing camera controller and recording status
class RecordingState extends Equatable {
  final CameraController? cameraController;
  final bool isRecording;
  final bool isAudioOnly;
  final bool isFlashOn;
  final bool hasFlash;
  final bool isPaused;
  final Duration recordingDuration;
  final double audioLevel;
  final double zoomLevel;
  final double availableStorageGB;
  final bool isLowStorage;
  final bool showLowStorageWarning;
  final String? errorMessage;
  final String? errorCode;
  final RecordingStatus status;
  final String? lastSavedAudioPath;
  final String? lastSavedVideoPath;
  final List<CameraDescription> availableCameras;
  final int activeCameraIndex;
  final String? recordingId;

  const RecordingState({
    this.cameraController,
    this.isRecording = false,
    this.isAudioOnly = false,
    this.isFlashOn = false,
    this.hasFlash = false,
    this.isPaused = false,
    this.recordingDuration = Duration.zero,
    this.audioLevel = 0.0,
    this.zoomLevel = 1.0,
    this.availableStorageGB = 0.0,
    this.isLowStorage = false,
    this.showLowStorageWarning = false,
    this.errorMessage,
    this.errorCode,
    this.status = RecordingStatus.initial,
    this.lastSavedAudioPath,
    this.lastSavedVideoPath,
    this.availableCameras = const [],
    this.activeCameraIndex = 0,
    this.recordingId,
  });

  /// Initial state
  const RecordingState.initial()
      : cameraController = null,
        isRecording = false,
        isAudioOnly = false,
        isFlashOn = false,
        hasFlash = false,
        isPaused = false,
        recordingDuration = Duration.zero,
        audioLevel = 0.0,
        zoomLevel = 1.0,
        availableStorageGB = 0.0,
        isLowStorage = false,
        showLowStorageWarning = false,
        errorMessage = null,
        errorCode = null,
        status = RecordingStatus.initial,
        lastSavedAudioPath = null,
        lastSavedVideoPath = null,
        availableCameras = const [],
        activeCameraIndex = 0,
        recordingId = null;

  /// Copy state with optional parameter changes
  RecordingState copyWith({
    CameraController? cameraController,
    bool? isRecording,
    bool? isAudioOnly,
    bool? isFlashOn,
    bool? hasFlash,
    bool? isPaused,
    Duration? recordingDuration,
    double? audioLevel,
    double? zoomLevel,
    double? availableStorageGB,
    bool? isLowStorage,
    bool? showLowStorageWarning,
    String? errorMessage,
    String? errorCode,
    RecordingStatus? status,
    String? lastSavedAudioPath,
    String? lastSavedVideoPath,
    List<CameraDescription>? availableCameras,
    int? activeCameraIndex,
    bool clearError = false,
    String? recordingId,
  }) {
    return RecordingState(
      cameraController: cameraController ?? this.cameraController,
      isRecording: isRecording ?? this.isRecording,
      isAudioOnly: isAudioOnly ?? this.isAudioOnly,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      hasFlash: hasFlash ?? this.hasFlash,
      isPaused: isPaused ?? this.isPaused,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      audioLevel: audioLevel ?? this.audioLevel,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      availableStorageGB: availableStorageGB ?? this.availableStorageGB,
      isLowStorage: isLowStorage ?? this.isLowStorage,
      showLowStorageWarning:
          showLowStorageWarning ?? this.showLowStorageWarning,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      status: status ?? this.status,
      lastSavedAudioPath: lastSavedAudioPath ?? this.lastSavedAudioPath,
      lastSavedVideoPath: lastSavedVideoPath ?? this.lastSavedVideoPath,
      availableCameras: availableCameras ?? this.availableCameras,
      activeCameraIndex: activeCameraIndex ?? this.activeCameraIndex,
      recordingId: recordingId ?? this.recordingId,
    );
  }

  /// Get current camera description
  CameraDescription? get currentCamera {
    if (availableCameras.isEmpty ||
        activeCameraIndex >= availableCameras.length) {
      return null;
    }
    return availableCameras[activeCameraIndex];
  }

  /// Check if camera is initialized
  bool get isCameraInitialized => cameraController?.value.isInitialized == true;

  /// Check if there are multiple cameras available
  bool get hasMultipleCameras => availableCameras.length > 1;

  /// Get storage info as formatted string
  String get storageInfo {
    if (availableStorageGB > 1.0) {
      return '${availableStorageGB.toStringAsFixed(1)} GB free';
    } else {
      final mb = (availableStorageGB * 1024).round();
      return '$mb MB free';
    }
  }

  /// Check if recording is active (recording and not paused)
  bool get isActivelyRecording => isRecording && !isPaused;

  /// Get formatted recording duration
  String get formattedDuration {
    final minutes = recordingDuration.inMinutes;
    final seconds = recordingDuration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        cameraController,
        isRecording,
        isAudioOnly,
        isFlashOn,
        hasFlash,
        isPaused,
        recordingDuration,
        audioLevel,
        zoomLevel,
        availableStorageGB,
        isLowStorage,
        showLowStorageWarning,
        errorMessage,
        errorCode,
        status,
        lastSavedAudioPath,
        lastSavedVideoPath,
        availableCameras,
        activeCameraIndex,
        recordingId,
      ];

  @override
  String toString() {
    return 'RecordingState('
        'status: $status, '
        'isRecording: $isRecording, '
        'isAudioOnly: $isAudioOnly, '
        'duration: $formattedDuration, '
        'storage: $storageInfo, '
        'error: $errorMessage'
        ')';
  }
}

/// Recording status enumeration
enum RecordingStatus {
  initial,
  cameraInitializing,
  cameraReady,
  cameraError,
  recordingStarting,
  recording,
  recordingPaused,
  recordingStopping,
  recordingSaved,
  error,
}
