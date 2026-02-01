part of 'location_bloc.dart';

abstract class LocationEvent {}

class LocationInitialize extends LocationEvent {}

class GetCurrentLocationRequested extends LocationEvent {}

class WatchLocationRequested extends LocationEvent {}

class StopLocationWatchRequested extends LocationEvent {}

class GetJurisdictionInfoRequested extends LocationEvent {
  final double latitude;
  final double longitude;

  GetJurisdictionInfoRequested({
    required this.latitude,
    required this.longitude,
  });
}

class LocationPermissionRequested extends LocationEvent {}