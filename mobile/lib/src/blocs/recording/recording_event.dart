import 'package:equatable/equatable.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Recording events for managing camera controller and recording state
abstract class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize camera
class CameraInitializeRequested extends RecordingEvent {
  final CameraDescription? preferredCamera;

  const CameraInitializeRequested({this.preferredCamera});

  @override
  List<Object?> get props => [preferredCamera];
}

/// Event to switch between front and rear cameras
class CameraSwitchRequested extends RecordingEvent {
  const CameraSwitchRequested();
}

/// Event to start recording (audio and video)
class RecordingStartRequested extends RecordingEvent {
  const RecordingStartRequested();
}

/// Event to stop recording
class RecordingStopRequested extends RecordingEvent {
  const RecordingStopRequested();
}

/// Event to pause recording
class RecordingPauseRequested extends RecordingEvent {
  const RecordingPauseRequested();
}

/// Event to resume recording
class RecordingResumeRequested extends RecordingEvent {
  const RecordingResumeRequested();
}

/// Event to toggle audio-only mode
class AudioOnlyModeToggled extends RecordingEvent {
  const AudioOnlyModeToggled();
}

/// Event to toggle flash
class FlashToggled extends RecordingEvent {
  const FlashToggled();
}

/// Event to set zoom level
class ZoomLevelChanged extends RecordingEvent {
  final double zoomLevel;

  const ZoomLevelChanged(this.zoomLevel);

  @override
  List<Object> get props => [zoomLevel];
}

/// Event to set focus point
class FocusPointSet extends RecordingEvent {
  final Offset focusPoint;

  const FocusPointSet(this.focusPoint);

  @override
  List<Object> get props => [focusPoint];
}

/// Event for storage monitoring updates
class StorageStatusUpdated extends RecordingEvent {
  final double availableSpaceGB;
  final bool isLowStorage;

  const StorageStatusUpdated({
    required this.availableSpaceGB,
    required this.isLowStorage,
  });

  @override
  List<Object> get props => [availableSpaceGB, isLowStorage];
}

/// Event for recording duration updates
class RecordingDurationUpdated extends RecordingEvent {
  final Duration duration;

  const RecordingDurationUpdated(this.duration);

  @override
  List<Object> get props => [duration];
}

/// Event for audio level updates
class AudioLevelUpdated extends RecordingEvent {
  final double level;

  const AudioLevelUpdated(this.level);

  @override
  List<Object> get props => [level];
}

/// Event to handle recording errors
class RecordingErrorOccurred extends RecordingEvent {
  final String error;
  final String? errorCode;

  const RecordingErrorOccurred(this.error, {this.errorCode});

  @override
  List<Object?> get props => [error, errorCode];
}

/// Event to clear errors
class RecordingErrorCleared extends RecordingEvent {
  const RecordingErrorCleared();
}

/// Event to save recording with confirmation
class RecordingSaveRequested extends RecordingEvent {
  final String? audioPath;
  final String? videoPath;

  const RecordingSaveRequested({this.audioPath, this.videoPath});

  @override
  List<Object?> get props => [audioPath, videoPath];
}

/// Event to handle low storage warning
class LowStorageWarningShown extends RecordingEvent {
  const LowStorageWarningShown();
}

/// Event to handle low storage warning dismissed
class LowStorageWarningDismissed extends RecordingEvent {
  const LowStorageWarningDismissed();
}