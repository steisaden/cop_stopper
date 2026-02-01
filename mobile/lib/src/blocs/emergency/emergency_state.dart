import 'package:equatable/equatable.dart';

/// Emergency mode state containing activation status and current actions
class EmergencyState extends Equatable {
  final bool isEmergencyModeActive;
  final bool isRecording;
  final bool isMonitoring;
  final bool isLocationShared;
  final bool showStopConfirmation;
  final DateTime? emergencyStartTime;
  final String? errorMessage;

  const EmergencyState({
    required this.isEmergencyModeActive,
    required this.isRecording,
    required this.isMonitoring,
    required this.isLocationShared,
    required this.showStopConfirmation,
    this.emergencyStartTime,
    this.errorMessage,
  });

  /// Initial state with emergency mode inactive
  const EmergencyState.initial()
      : isEmergencyModeActive = false,
        isRecording = false,
        isMonitoring = false,
        isLocationShared = false,
        showStopConfirmation = false,
        emergencyStartTime = null,
        errorMessage = null;

  /// Copy state with optional parameter changes
  EmergencyState copyWith({
    bool? isEmergencyModeActive,
    bool? isRecording,
    bool? isMonitoring,
    bool? isLocationShared,
    bool? showStopConfirmation,
    DateTime? emergencyStartTime,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EmergencyState(
      isEmergencyModeActive: isEmergencyModeActive ?? this.isEmergencyModeActive,
      isRecording: isRecording ?? this.isRecording,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      isLocationShared: isLocationShared ?? this.isLocationShared,
      showStopConfirmation: showStopConfirmation ?? this.showStopConfirmation,
      emergencyStartTime: emergencyStartTime ?? this.emergencyStartTime,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Clear error message
  EmergencyState clearError() {
    return copyWith(clearError: true);
  }

  /// Check if any emergency action is active
  bool get hasActiveActions => isRecording || isMonitoring || isLocationShared;

  /// Get emergency duration if active
  Duration? get emergencyDuration {
    if (emergencyStartTime == null) return null;
    return DateTime.now().difference(emergencyStartTime!);
  }

  @override
  List<Object?> get props => [
        isEmergencyModeActive,
        isRecording,
        isMonitoring,
        isLocationShared,
        showStopConfirmation,
        emergencyStartTime,
        errorMessage,
      ];

  @override
  String toString() {
    return 'EmergencyState('
        'isEmergencyModeActive: $isEmergencyModeActive, '
        'isRecording: $isRecording, '
        'isMonitoring: $isMonitoring, '
        'isLocationShared: $isLocationShared, '
        'showStopConfirmation: $showStopConfirmation, '
        'emergencyStartTime: $emergencyStartTime, '
        'errorMessage: $errorMessage)';
  }
}