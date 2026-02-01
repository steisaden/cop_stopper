import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/jurisdiction_info.dart';
import '../../services/location_service.dart';
import '../../services/jurisdiction_resolver.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationService _locationService;
  final JurisdictionResolver _jurisdictionResolver;

  LocationBloc({
    required LocationService locationService,
    required JurisdictionResolver jurisdictionResolver,
  }) : _locationService = locationService,
       _jurisdictionResolver = jurisdictionResolver,
       super(LocationInitial()) {
    on<LocationInitialize>(_onInitialize);
    on<GetCurrentLocationRequested>(_onGetCurrentLocation);
    on<WatchLocationRequested>(_onWatchLocation);
    on<StopLocationWatchRequested>(_onStopLocationWatch);
    on<GetJurisdictionInfoRequested>(_onGetJurisdictionInfo);
    on<LocationPermissionRequested>(_onRequestPermission);
  }

  late StreamSubscription<LocationUpdate> _locationSubscription;

  Future<void> _onInitialize(
    LocationInitialize event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationReady());
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      final location = await _locationService.getCurrentLocation();
      final jurisdiction = await _jurisdictionResolver.resolveJurisdiction(
        location.latitude,
        location.longitude,
      );
      
      emit(CurrentLocationAcquired(location, jurisdiction));
    } catch (e) {
      emit(LocationError('Failed to get current location: $e'));
    }
  }

  Future<void> _onWatchLocation(
    WatchLocationRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      _locationSubscription = _locationService.getLocationStream().listen(
        (locationUpdate) async {
          final jurisdiction = await _jurisdictionResolver.resolveJurisdiction(
            locationUpdate.latitude,
            locationUpdate.longitude,
          );
          
          emit(CurrentLocationAcquired(
            locationUpdate.location,
            jurisdiction,
          ));
        },
        onError: (error) {
          add(LocationErrorOccurred(error.toString()));
        },
      );
      
      emit(LocationWatchStarted());
    } catch (e) {
      emit(LocationError('Failed to start location watch: $e'));
    }
  }

  Future<void> _onStopLocationWatch(
    StopLocationWatchRequested event,
    Emitter<LocationState> emit,
  ) async {
    try {
      await _locationSubscription.cancel();
      emit(LocationWatchStopped());
    } catch (e) {
      emit(LocationError('Failed to stop location watch: $e'));
    }
  }

  Future<void> _onGetJurisdictionInfo(
    GetJurisdictionInfoRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      final jurisdiction = await _jurisdictionResolver.resolveJurisdiction(
        event.latitude,
        event.longitude,
      );
      
      emit(JurisdictionInfoLoaded(jurisdiction));
    } catch (e) {
      emit(LocationError('Failed to get jurisdiction info: $e'));
    }
  }

  Future<void> _onRequestPermission(
    LocationPermissionRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    try {
      final permissionGranted = await _locationService.requestPermission();
      
      if (permissionGranted) {
        emit(LocationPermissionGranted());
      } else {
        emit(LocationPermissionDenied());
      }
    } catch (e) {
      emit(LocationError('Failed to request location permission: $e'));
    }
  }

  @override
  Future<void> close() {
    _locationSubscription.cancel();
    return super.close();
  }
}