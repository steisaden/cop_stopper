import 'package:equatable/equatable.dart';

/// Emergency mode events for managing emergency state and actions
abstract class EmergencyEvent extends Equatable {
  const EmergencyEvent();

  @override
  List<Object> get props => [];
}

/// Event to activate emergency mode
class EmergencyModeActivated extends EmergencyEvent {
  const EmergencyModeActivated();
}

/// Event to deactivate emergency mode with confirmation
class EmergencyModeDeactivated extends EmergencyEvent {
  final bool confirmed;

  const EmergencyModeDeactivated({required this.confirmed});

  @override
  List<Object> get props => [confirmed];
}

/// Event to start emergency recording
class EmergencyRecordingStarted extends EmergencyEvent {
  const EmergencyRecordingStarted();
}

/// Event to stop emergency recording
class EmergencyRecordingStopped extends EmergencyEvent {
  const EmergencyRecordingStopped();
}

/// Event to share location with emergency contacts
class EmergencyLocationShared extends EmergencyEvent {
  const EmergencyLocationShared();
}

/// Event to request legal help
class EmergencyLegalHelpRequested extends EmergencyEvent {
  const EmergencyLegalHelpRequested();
}

/// Event to contact emergency services
class EmergencyServicesContacted extends EmergencyEvent {
  const EmergencyServicesContacted();
}

/// Event to show confirmation dialog for stopping emergency mode
class EmergencyStopConfirmationRequested extends EmergencyEvent {
  const EmergencyStopConfirmationRequested();
}

/// Event to dismiss confirmation dialog
class EmergencyStopConfirmationDismissed extends EmergencyEvent {
  const EmergencyStopConfirmationDismissed();
}