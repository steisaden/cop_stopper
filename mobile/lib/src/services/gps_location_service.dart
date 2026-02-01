import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'location_service.dart';
import 'jurisdiction_resolver.dart';
import 'api_service.dart';

/// Exception thrown when location operations fail
class LocationException implements Exception {
  final String message;
  final String? code;
  
  const LocationException(this.message, {this.code});
  
  @override
  String toString() => 'LocationException: $message';
}

/// GPS-based implementation of LocationService
class GPSLocationService implements LocationService {
  static const String _lastLocationKey = 'last_known_location';
  static const String _manualJurisdictionKey = 'manual_jurisdiction';
  
  final FlutterSecureStorage _storage;
  final JurisdictionResolver _jurisdictionResolver;
  
  Position? _lastKnownPosition;
  Jurisdiction? _manualJurisdiction;
  StreamController<LocationResult>? _locationStreamController;
  StreamSubscription<Position>? _positionStreamSubscription;
  
  GPSLocationService({
    FlutterSecureStorage? storage,
    JurisdictionResolver? jurisdictionResolver,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _jurisdictionResolver =
          jurisdictionResolver ?? JurisdictionResolver(ApiService()) {
    _loadCachedLocation();
  }

  /// Load cached location data on service initialization
  Future<void> _loadCachedLocation() async {
    try {
      final cachedLocationJson = await _storage.read(key: _lastLocationKey);
      if (cachedLocationJson != null) {
        final locationData = json.decode(cachedLocationJson);
        _lastKnownPosition = Position(
          longitude: locationData['longitude'],
          latitude: locationData['latitude'],
          timestamp: DateTime.parse(locationData['timestamp']),
          accuracy: locationData['accuracy'],
          altitude: locationData['altitude'],
          altitudeAccuracy: locationData['altitudeAccuracy'] ?? 0.0,
          heading: locationData['heading'],
          headingAccuracy: locationData['headingAccuracy'] ?? 0.0,
          speed: locationData['speed'],
          speedAccuracy: locationData['speedAccuracy'],
        );
      }
      
      final manualJurisdictionJson = await _storage.read(key: _manualJurisdictionKey);
      if (manualJurisdictionJson != null) {
        final jurisdictionData = json.decode(manualJurisdictionJson);
        _manualJurisdiction = Jurisdiction.fromJson(jurisdictionData);
      }
    } catch (e) {
      debugPrint('Failed to load cached location data: $e');
    }
  }

  /// Cache location data for offline use
  Future<void> _cacheLocation(Position position) async {
    try {
      final locationData = {
        'longitude': position.longitude,
        'latitude': position.latitude,
        'timestamp': position.timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'altitudeAccuracy': position.altitudeAccuracy,
        'heading': position.heading,
        'headingAccuracy': position.headingAccuracy,
        'speed': position.speed,
        'speedAccuracy': position.speedAccuracy,
      };
      
      await _storage.write(
        key: _lastLocationKey,
        value: json.encode(locationData),
      );
      
      _lastKnownPosition = position;
    } catch (e) {
      debugPrint('Failed to cache location: $e');
    }
  }

  @override
  Future<LocationResult> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      if (!await isLocationServiceEnabled()) {
        if (_lastKnownPosition != null) {
          return LocationResult(
            position: _lastKnownPosition!,
            accuracy: LocationAccuracyLevel.low,
            timestamp: DateTime.now(),
            warning: 'Location services disabled. Using cached location.',
          );
        }
        throw const LocationException(
          'Location services are disabled and no cached location available.',
          code: 'SERVICE_DISABLED',
        );
      }

      // Check permissions
      if (!await hasLocationPermission()) {
        if (_lastKnownPosition != null) {
          return LocationResult(
            position: _lastKnownPosition!,
            accuracy: LocationAccuracyLevel.low,
            timestamp: DateTime.now(),
            warning: 'Location permission denied. Using cached location.',
          );
        }
        throw const LocationException(
          'Location permission denied and no cached location available.',
          code: 'PERMISSION_DENIED',
        );
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: geolocator.LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      // Cache the new position
      await _cacheLocation(position);

      // Determine accuracy based on GPS accuracy
      LocationAccuracyLevel accuracy;
      if (position.accuracy <= 10) {
        accuracy = LocationAccuracyLevel.high;
      } else if (position.accuracy <= 50) {
        accuracy = LocationAccuracyLevel.medium;
      } else {
        accuracy = LocationAccuracyLevel.low;
      }

      return LocationResult(
        position: position,
        accuracy: accuracy,
        timestamp: DateTime.now(),
      );
      
    } catch (e) {
      // Return cached location if available
      if (_lastKnownPosition != null) {
        return LocationResult(
          position: _lastKnownPosition!,
          accuracy: LocationAccuracyLevel.low,
          timestamp: DateTime.now(),
          warning: 'Failed to get current location. Using cached location.',
        );
      }
      
      throw LocationException(
        'Failed to get current location: ${e.toString()}',
        code: 'LOCATION_FAILED',
      );
    }
  }

  @override
  Future<Jurisdiction> getJurisdiction(Position position) async {
    try {
      return await _jurisdictionResolver.resolveJurisdiction(position);
    } catch (e) {
      throw LocationException(
        'Failed to resolve jurisdiction: ${e.toString()}',
        code: 'JURISDICTION_FAILED',
      );
    }
  }

  @override
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      return permission == LocationPermission.always || 
             permission == LocationPermission.whileInUse;
    } catch (e) {
      debugPrint('Failed to request location permission: $e');
      return false;
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<Position?> getLastKnownLocation() async {
    if (_lastKnownPosition != null) {
      return _lastKnownPosition;
    }
    
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('Failed to get last known position: $e');
      return null;
    }
  }

  @override
  Stream<LocationResult> watchLocation() {
    _locationStreamController?.close();
    _locationStreamController = StreamController<LocationResult>.broadcast();
    
    const locationSettings = LocationSettings(
      accuracy: geolocator.LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );
    
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (position) async {
        await _cacheLocation(position);
        
        final result = LocationResult(
          position: position,
          accuracy: position.accuracy <= 10 
            ? LocationAccuracyLevel.high 
            : position.accuracy <= 50 
              ? LocationAccuracyLevel.medium 
              : LocationAccuracyLevel.low,
          timestamp: DateTime.now(),
        );
        
        _locationStreamController?.add(result);
      },
      onError: (error) {
        _locationStreamController?.addError(
          LocationException('Location stream error: ${error.toString()}'),
        );
      },
    );
    
    return _locationStreamController!.stream;
  }

  @override
  Future<List<Jurisdiction>> searchJurisdictions(String query) async {
    return await _jurisdictionResolver.searchJurisdictions(query);
  }

  @override
  Future<void> setManualJurisdiction(Jurisdiction jurisdiction) async {
    try {
      _manualJurisdiction = jurisdiction;
      await _storage.write(
        key: _manualJurisdictionKey,
        value: json.encode(jurisdiction.toJson()),
      );
    } catch (e) {
      throw LocationException(
        'Failed to set manual jurisdiction: ${e.toString()}',
        code: 'MANUAL_JURISDICTION_FAILED',
      );
    }
  }

  @override
  Future<Jurisdiction?> getCurrentJurisdiction() async {
    // Return manual jurisdiction if set
    if (_manualJurisdiction != null) {
      return _manualJurisdiction;
    }
    
    try {
      // Try to get current location and resolve jurisdiction
      final locationResult = await getCurrentLocation();
      return await getJurisdiction(locationResult.position);
    } catch (e) {
      debugPrint('Failed to get current jurisdiction: $e');
      return null;
    }
  }

  /// Clean up resources
  void dispose() {
    _positionStreamSubscription?.cancel();
    _locationStreamController?.close();
  }
}
