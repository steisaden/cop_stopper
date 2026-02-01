import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'location_service.dart';

/// Service for monitoring location boundaries and jurisdiction changes
class LocationBoundaryService {
  final LocationService _locationService;
  
  StreamSubscription<LocationResult>? _locationSubscription;
  StreamController<JurisdictionChangeEvent>? _jurisdictionChangeController;
  
  Jurisdiction? _currentJurisdiction;
  Position? _lastPosition;
  
  // Minimum distance (in meters) to trigger jurisdiction check
  static const double _minimumDistanceThreshold = 1000; // 1 km
  
  LocationBoundaryService(this._locationService);

  /// Start monitoring for jurisdiction boundary changes
  Stream<JurisdictionChangeEvent> watchJurisdictionChanges() {
    _jurisdictionChangeController?.close();
    _jurisdictionChangeController = StreamController<JurisdictionChangeEvent>.broadcast();
    
    _locationSubscription?.cancel();
    _locationSubscription = _locationService.watchLocation().listen(
      _handleLocationUpdate,
      onError: (error) {
        debugPrint('Location boundary monitoring error: $error');
        _jurisdictionChangeController?.addError(error);
      },
    );
    
    return _jurisdictionChangeController!.stream;
  }

  /// Handle location updates and check for jurisdiction changes
  Future<void> _handleLocationUpdate(LocationResult locationResult) async {
    try {
      final newPosition = locationResult.position;
      
      // Check if we've moved far enough to warrant a jurisdiction check
      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          newPosition.latitude,
          newPosition.longitude,
        );
        
        if (distance < _minimumDistanceThreshold) {
          return; // Not far enough to check jurisdiction
        }
      }
      
      _lastPosition = newPosition;
      
      // Get jurisdiction for new position
      final newJurisdiction = await _locationService.getJurisdiction(newPosition);
      
      // Check if jurisdiction has changed
      if (_currentJurisdiction == null) {
        // First jurisdiction detection
        _currentJurisdiction = newJurisdiction;
        _jurisdictionChangeController?.add(JurisdictionChangeEvent(
          type: JurisdictionChangeType.initial,
          newJurisdiction: newJurisdiction,
          position: newPosition,
          timestamp: DateTime.now(),
        ));
      } else if (_hasJurisdictionChanged(_currentJurisdiction!, newJurisdiction)) {
        // Jurisdiction has changed
        final oldJurisdiction = _currentJurisdiction;
        _currentJurisdiction = newJurisdiction;
        
        final changeType = _determineChangeType(oldJurisdiction!, newJurisdiction);
        
        _jurisdictionChangeController?.add(JurisdictionChangeEvent(
          type: changeType,
          oldJurisdiction: oldJurisdiction,
          newJurisdiction: newJurisdiction,
          position: newPosition,
          timestamp: DateTime.now(),
          distance: _lastPosition != null 
            ? Geolocator.distanceBetween(
                _lastPosition!.latitude,
                _lastPosition!.longitude,
                newPosition.latitude,
                newPosition.longitude,
              )
            : null,
        ));
      }
      
    } catch (e) {
      debugPrint('Error handling location update: $e');
      _jurisdictionChangeController?.addError(e);
    }
  }

  /// Check if jurisdiction has significantly changed
  bool _hasJurisdictionChanged(Jurisdiction old, Jurisdiction new_) {
    // Consider it a change if any major component differs
    return old.city != new_.city ||
           old.county != new_.county ||
           old.state != new_.state ||
           old.country != new_.country;
  }

  /// Determine the type of jurisdiction change
  JurisdictionChangeType _determineChangeType(Jurisdiction old, Jurisdiction new_) {
    if (old.country != new_.country) {
      return JurisdictionChangeType.country;
    } else if (old.state != new_.state) {
      return JurisdictionChangeType.state;
    } else if (old.county != new_.county) {
      return JurisdictionChangeType.county;
    } else if (old.city != new_.city) {
      return JurisdictionChangeType.city;
    } else {
      return JurisdictionChangeType.minor;
    }
  }

  /// Get current jurisdiction
  Jurisdiction? get currentJurisdiction => _currentJurisdiction;

  /// Stop monitoring jurisdiction changes
  void stopMonitoring() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _jurisdictionChangeController?.close();
    _jurisdictionChangeController = null;
  }

  /// Calculate approximate distance to jurisdiction boundary
  /// This is a simplified implementation - in practice, you'd need
  /// detailed boundary data from a GIS service
  Future<double?> getDistanceToBoundary(Position position) async {
    try {
      // This is a placeholder implementation
      // In a real app, you'd query a boundary service or local database
      
      // For now, we'll estimate based on typical jurisdiction sizes
      final jurisdiction = await _locationService.getJurisdiction(position);
      
      // Rough estimates for different jurisdiction types
      if (jurisdiction.city.contains('Unknown')) {
        return null; // Can't estimate for unknown jurisdictions
      }
      
      // Very rough approximation - in reality you'd need actual boundary data
      double estimatedRadius;
      if (jurisdiction.city.toLowerCase().contains('city')) {
        estimatedRadius = 10000; // 10km for cities
      } else if (jurisdiction.city.toLowerCase().contains('town')) {
        estimatedRadius = 5000; // 5km for towns
      } else {
        estimatedRadius = 15000; // 15km default
      }
      
      // Return a random distance within the estimated radius
      // This is just for demonstration - real implementation would be much more sophisticated
      return estimatedRadius * 0.3 + (estimatedRadius * 0.7 * Random().nextDouble());
      
    } catch (e) {
      debugPrint('Error calculating distance to boundary: $e');
      return null;
    }
  }

  /// Dispose of resources
  void dispose() {
    stopMonitoring();
  }
}

/// Event fired when jurisdiction changes are detected
class JurisdictionChangeEvent {
  final JurisdictionChangeType type;
  final Jurisdiction? oldJurisdiction;
  final Jurisdiction newJurisdiction;
  final Position position;
  final DateTime timestamp;
  final double? distance; // Distance traveled since last update

  const JurisdictionChangeEvent({
    required this.type,
    this.oldJurisdiction,
    required this.newJurisdiction,
    required this.position,
    required this.timestamp,
    this.distance,
  });

  /// Get a user-friendly description of the change
  String getDescription() {
    switch (type) {
      case JurisdictionChangeType.initial:
        return 'Current location: ${newJurisdiction.fullName}';
      case JurisdictionChangeType.country:
        return 'Entered ${newJurisdiction.country}';
      case JurisdictionChangeType.state:
        return 'Entered ${newJurisdiction.state}';
      case JurisdictionChangeType.county:
        return 'Entered ${newJurisdiction.county}';
      case JurisdictionChangeType.city:
        return 'Entered ${newJurisdiction.city}';
      case JurisdictionChangeType.minor:
        return 'Location updated: ${newJurisdiction.fullName}';
    }
  }

  /// Get the severity level of the change
  JurisdictionChangeSeverity getSeverity() {
    switch (type) {
      case JurisdictionChangeType.initial:
        return JurisdictionChangeSeverity.info;
      case JurisdictionChangeType.country:
        return JurisdictionChangeSeverity.critical;
      case JurisdictionChangeType.state:
        return JurisdictionChangeSeverity.high;
      case JurisdictionChangeType.county:
        return JurisdictionChangeSeverity.medium;
      case JurisdictionChangeType.city:
        return JurisdictionChangeSeverity.low;
      case JurisdictionChangeType.minor:
        return JurisdictionChangeSeverity.info;
    }
  }
}

/// Types of jurisdiction changes
enum JurisdictionChangeType {
  initial,  // First jurisdiction detection
  country,  // Crossed country boundary
  state,    // Crossed state/province boundary
  county,   // Crossed county boundary
  city,     // Crossed city boundary
  minor,    // Minor boundary change
}

/// Severity levels for jurisdiction changes
enum JurisdictionChangeSeverity {
  info,     // Informational only
  low,      // Minor change
  medium,   // Moderate change
  high,     // Significant change
  critical, // Major change (e.g., country)
}