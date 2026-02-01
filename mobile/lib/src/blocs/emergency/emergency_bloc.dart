import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/location_service.dart';
import 'package:mobile/src/services/navigation_service.dart';
import 'package:mobile/src/services/background_emergency_service.dart';
import 'package:mobile/src/blocs/navigation/navigation_event.dart';
import 'emergency_event.dart';
import 'emergency_state.dart';

/// BLoC for managing emergency mode state and actions
class EmergencyBloc extends Bloc<EmergencyEvent, EmergencyState> {
  final RecordingService _recordingService;
  final LocationService _locationService;
  final NavigationService _navigationService;
  final BackgroundEmergencyService _backgroundService;

  EmergencyBloc({
    required RecordingService recordingService,
    required LocationService locationService,
    required NavigationService navigationService,
  })  : _recordingService = recordingService,
        _locationService = locationService,
        _navigationService = navigationService,
        _backgroundService = BackgroundEmergencyService(
          recordingService: recordingService,
          locationService: locationService,
        ),
        super(const EmergencyState.initial()) {
    on<EmergencyModeActivated>(_onEmergencyModeActivated);
    on<EmergencyModeDeactivated>(_onEmergencyModeDeactivated);
    on<EmergencyRecordingStarted>(_onEmergencyRecordingStarted);
    on<EmergencyRecordingStopped>(_onEmergencyRecordingStopped);
    on<EmergencyLocationShared>(_onEmergencyLocationShared);
    on<EmergencyLegalHelpRequested>(_onEmergencyLegalHelpRequested);
    on<EmergencyServicesContacted>(_onEmergencyServicesContacted);
    on<EmergencyStopConfirmationRequested>(_onEmergencyStopConfirmationRequested);
    on<EmergencyStopConfirmationDismissed>(_onEmergencyStopConfirmationDismissed);
  }

  /// Handle emergency mode activation
  Future<void> _onEmergencyModeActivated(
    EmergencyModeActivated event,
    Emitter<EmergencyState> emit,
  ) async {
    try {
      // Activate emergency mode
      emit(state.copyWith(
        isEmergencyModeActive: true,
        emergencyStartTime: DateTime.now(),
        errorMessage: null,
      ));

      // Start background emergency service
      await _backgroundService.startEmergencyMode();
      
      emit(state.copyWith(
        isLocationShared: true,
        isMonitoring: true,
      ));

      // Navigate to monitor tab for emergency interface
      _navigationService.navigateToTab(NavigationTab.monitor);
    } catch (error) {
      emit(state.copyWith(
        errorMessage: 'Failed to activate emergency mode: $error',
      ));
    }
  }

  /// Handle emergency mode deactivation
  Future<void> _onEmergencyModeDeactivated(
    EmergencyModeDeactivated event,
    Emitter<EmergencyState> emit,
  ) async {
    if (!event.confirmed) {
      // Show confirmation dialog first
      emit(state.copyWith(showStopConfirmation: true));
      return;
    }

    try {
      // Stop background emergency service
      await _backgroundService.stopEmergencyMode();

      // Reset emergency state
      emit(const EmergencyState.initial());
    } catch (error) {
      emit(state.copyWith(
        errorMessage: 'Failed to deactivate emergency mode: $error',
      ));
    }
  }

  /// Handle emergency recording start
  Future<void> _onEmergencyRecordingStarted(
    EmergencyRecordingStarted event,
    Emitter<EmergencyState> emit,
  ) async {
    try {
      await _recordingService.startAudioVideoRecording();
      emit(state.copyWith(isRecording: true));
    } catch (error) {
      emit(state.copyWith(
        errorMessage: 'Failed to start emergency recording: $error',
      ));
    }
  }

  /// Handle emergency recording stop
  Future<void> _onEmergencyRecordingStopped(
    EmergencyRecordingStopped event,
    Emitter<EmergencyState> emit,
  ) async {
    try {
      await _recordingService.stopAudioVideoRecording();
      emit(state.copyWith(isRecording: false));
    } catch (error) {
      emit(state.copyWith(
        errorMessage: 'Failed to stop emergency recording: $error',
      ));
    }
  }

  /// Handle emergency location sharing
  Future<void> _onEmergencyLocationShared(
    EmergencyLocationShared event,
    Emitter<EmergencyState> emit,
  ) async {
    try {
      await _shareLocationWithEmergencyContacts();
      emit(state.copyWith(isLocationShared: true));
    } catch (error) {
      emit(state.copyWith(
        errorMessage: 'Failed to share location: $error',
      ));
    }
  }

  /// Handle legal help request
  Future<void> _onEmergencyLegalHelpRequested(
    EmergencyLegalHelpRequested event,
    Emitter<EmergencyState> emit,
  ) async {
    try {
      // TODO: Implement legal help request functionality
      // This would typically open a legal hotline or send an emergency message
    } catch (error) {
      emit(state.copyWith(
        errorMessage: 'Failed to request legal help: $error',
      ));
    }
  }

  /// Handle emergency services contact
  Future<void> _onEmergencyServicesContacted(
    EmergencyServicesContacted event,
    Emitter<EmergencyState> emit,
  ) async {
    try {
      // TODO: Implement emergency services contact functionality
      // This would typically dial emergency services or send location
    } catch (error) {
      emit(state.copyWith(
        errorMessage: 'Failed to contact emergency services: $error',
      ));
    }
  }

  /// Handle stop confirmation request
  Future<void> _onEmergencyStopConfirmationRequested(
    EmergencyStopConfirmationRequested event,
    Emitter<EmergencyState> emit,
  ) async {
    emit(state.copyWith(showStopConfirmation: true));
  }

  /// Handle stop confirmation dismissal
  Future<void> _onEmergencyStopConfirmationDismissed(
    EmergencyStopConfirmationDismissed event,
    Emitter<EmergencyState> emit,
  ) async {
    emit(state.copyWith(showStopConfirmation: false));
  }

  /// Share location with emergency contacts
  Future<void> _shareLocationWithEmergencyContacts() async {
    try {
      final hasPermission = await _locationService.hasLocationPermission();
      if (!hasPermission) {
        final granted = await _locationService.requestLocationPermission();
        if (!granted) {
          throw Exception('Location permission denied');
        }
      }

      await _locationService.getCurrentLocation();
      // TODO: Send location to emergency contacts
      // This would typically send SMS or push notifications with location
    } catch (error) {
      throw Exception('Failed to share location: $error');
    }
  }
}

