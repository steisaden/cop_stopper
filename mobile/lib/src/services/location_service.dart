
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a jurisdiction with detailed information
class Jurisdiction {
  final String city;
  final String county;
  final String state;
  final String country;
  final String fullName;
  final DateTime lastUpdated;

  const Jurisdiction({
    required this.city,
    required this.county,
    required this.state,
    required this.country,
    required this.fullName,
    required this.lastUpdated,
  });

  @override
  String toString() => fullName;

  Map<String, dynamic> toJson() => {
    'city': city,
    'county': county,
    'state': state,
    'country': country,
    'fullName': fullName,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory Jurisdiction.fromJson(Map<String, dynamic> json) => Jurisdiction(
    city: json['city'] ?? '',
    county: json['county'] ?? '',
    state: json['state'] ?? '',
    country: json['country'] ?? '',
    fullName: json['fullName'] ?? '',
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );
}

/// Service for managing jurisdiction data with local caching
class JurisdictionService {
  static const String _cachedJurisdictionKey = 'cached_jurisdiction';
  static const String _lastUpdatedKey = 'jurisdiction_last_updated';

  final SharedPreferences _prefs;
  Jurisdiction? _cachedJurisdiction;

  JurisdictionService(this._prefs) {
    _loadCachedJurisdiction();
  }

  /// Load cached jurisdiction from local storage
  void _loadCachedJurisdiction() {
    final jsonString = _prefs.getString(_cachedJurisdictionKey);
    final lastUpdatedString = _prefs.getString(_lastUpdatedKey);

    if (jsonString != null && lastUpdatedString != null) {
      try {
        final jsonString = _prefs.getString(_cachedJurisdictionKey);
        if (jsonString != null) {
          final json = jsonDecode(jsonString);
          _cachedJurisdiction = Jurisdiction.fromJson(json);
        }
      } catch (e) {
        // If parsing fails, clear the cached data
        clearCachedJurisdiction();
      }
    }
  }

  /// Get cached jurisdiction if available
  Jurisdiction? getCachedJurisdiction() {
    return _cachedJurisdiction;
  }

  /// Cache jurisdiction data locally
  Future<void> cacheJurisdiction(Jurisdiction jurisdiction) async {
    try {
      final jsonString = jurisdiction.toJson();
      await _prefs.setString(_cachedJurisdictionKey, jsonString.toString());
      await _prefs.setString(_lastUpdatedKey, jurisdiction.lastUpdated.toIso8601String());
      _cachedJurisdiction = jurisdiction;
    } catch (e) {
      print('Error caching jurisdiction: $e');
    }
  }

  /// Check if cached jurisdiction is still valid (less than 24 hours old)
  bool isCachedJurisdictionValid() {
    if (_cachedJurisdiction == null) return false;
    
    final jsonString = _prefs.getString(_lastUpdatedKey);
    if (jsonString == null) return false;

    try {
      final lastUpdated = DateTime.parse(jsonString);
      final now = DateTime.now();
      final difference = now.difference(lastUpdated);
      return difference.inHours < 24; // Valid for 24 hours
    } catch (e) {
      return false;
    }
  }

  /// Clear cached jurisdiction
  Future<void> clearCachedJurisdiction() async {
    await _prefs.remove(_cachedJurisdictionKey);
    await _prefs.remove(_lastUpdatedKey);
    _cachedJurisdiction = null;
  }
}

/// Location accuracy levels for different use cases
enum LocationAccuracyLevel {
  high,     // GPS with high accuracy
  medium,   // Network-based location
  low,      // Cached or approximate location
  unknown   // Location unavailable
}

/// Location result with accuracy information
class LocationResult {
  final Position position;
  final LocationAccuracyLevel accuracy;
  final DateTime timestamp;
  final String? warning;

  const LocationResult({
    required this.position,
    required this.accuracy,
    required this.timestamp,
    this.warning,
  });
}

/// Abstract interface for location services
abstract class LocationService {
  /// Get current location with accuracy information
  Future<LocationResult> getCurrentLocation();
  
  /// Get jurisdiction information for a position
  Future<Jurisdiction> getJurisdiction(Position position);
  
  /// Check if location permissions are granted
  Future<bool> hasLocationPermission();
  
  /// Request location permissions with user-friendly explanation
  Future<bool> requestLocationPermission();
  
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled();
  
  /// Get last known location from cache
  Future<Position?> getLastKnownLocation();
  
  /// Start monitoring location changes for jurisdiction boundary detection
  Stream<LocationResult> watchLocation();
  
  /// Search for jurisdictions by name (for manual selection)
  Future<List<Jurisdiction>> searchJurisdictions(String query);
  
  /// Set manual jurisdiction (when GPS is unavailable)
  Future<void> setManualJurisdiction(Jurisdiction jurisdiction);
  
  /// Get current jurisdiction (from GPS or manual selection)
  Future<Jurisdiction?> getCurrentJurisdiction();
}
