part of 'location_bloc.dart';

import '../../models/jurisdiction_info.dart';
import '../../services/location_service.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationReady extends LocationState {}

class LocationLoading extends LocationState {}

class LocationError extends LocationState {
  final String errorMessage;

  LocationError(this.errorMessage);
}

class CurrentLocationAcquired extends LocationState {
  final LocationData location;
  final JurisdictionInfo jurisdiction;

  CurrentLocationAcquired(this.location, this.jurisdiction);
}

class LocationWatchStarted extends LocationState {}

class LocationWatchStopped extends LocationState {}

class JurisdictionInfoLoaded extends LocationState {
  final JurisdictionInfo jurisdiction;

  JurisdictionInfoLoaded(this.jurisdiction);
}

class LocationPermissionGranted extends LocationState {}

class LocationPermissionDenied extends LocationState {}