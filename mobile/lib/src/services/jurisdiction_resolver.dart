import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'location_service.dart';

/// Exception thrown when jurisdiction resolution fails
class JurisdictionException implements Exception {
  final String message;
  final String? code;
  
  const JurisdictionException(this.message, {this.code});
  
  @override
  String toString() => 'JurisdictionException: $message';
}

/// Service for resolving geographic coordinates to legal jurisdictions
class JurisdictionResolver {
  static const String _jurisdictionCacheKey = 'jurisdiction_cache';
  static const Duration _cacheExpiration = Duration(hours: 24);
  
  final FlutterSecureStorage _storage;
  final ApiService _apiService;
  final Map<String, Jurisdiction> _memoryCache = {};
  
  JurisdictionResolver(
    ApiService? apiService, {
    FlutterSecureStorage? storage,
  })  : _apiService = apiService ?? ApiService(),
        _storage = storage ?? const FlutterSecureStorage();

  /// Resolve position to jurisdiction using backend API
  Future<Jurisdiction> resolveJurisdiction(Position position) async {
    final cacheKey = '${position.latitude.toStringAsFixed(4)},${position.longitude.toStringAsFixed(4)}';
    
    // Check memory cache first
    if (_memoryCache.containsKey(cacheKey)) {
      final cached = _memoryCache[cacheKey]!;
      if (DateTime.now().difference(cached.lastUpdated) < _cacheExpiration) {
        return cached;
      }
    }
    
    // Check persistent cache
    final cachedJurisdiction = await _getCachedJurisdiction(cacheKey);
    if (cachedJurisdiction != null) {
      _memoryCache[cacheKey] = cachedJurisdiction;
      return cachedJurisdiction;
    }
    
    try {
      final response = await _apiService.post('/location/jurisdiction', {
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      if (response['success'] == true && response['jurisdiction'] != null) {
         final data = response['jurisdiction'];
         final jurisdiction = Jurisdiction(
            city: data['city'] ?? 'Unknown City',
            county: data['county'] ?? 'Unknown County',
            state: data['state'] ?? 'Unknown State',
            country: 'United States', // Backend defaults to US context usually
            fullName: data['name'] ?? 'Unknown Jurisdiction',
            lastUpdated: DateTime.now(),
         );

         // Cache the result
         await _cacheJurisdiction(cacheKey, jurisdiction);
         _memoryCache[cacheKey] = jurisdiction;
         
         return jurisdiction;
      } else {
         throw Exception('Jurisdiction not found in backend');
      }
      
    } catch (e) {
      debugPrint('Failed to resolve jurisdiction via API: $e');
      
      // Fallback to basic valid object if API fails, to prevent app crash
      return Jurisdiction(
        city: 'Unknown',
        county: 'Unknown',
        state: 'Unknown',
        country: 'Unknown',
        fullName: 'Unknown Location (Offline)',
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Search for jurisdictions by name (for manual selection)
  Future<List<Jurisdiction>> searchJurisdictions(String query) async {
    if (query.trim().isEmpty) return [];
    
    // Backend doesn't have a direct search endpoint for jurisdictions exposed yet in the mock location.js 
    // except by code. We'll return empty or implement a search endpoint if needed later.
    // For now, returning empty to avoid misleading mock data.
    return [];
  }

  /// Get cached jurisdiction if available and not expired
  Future<Jurisdiction?> _getCachedJurisdiction(String cacheKey) async {
    try {
      final cachedData = await _storage.read(key: '$_jurisdictionCacheKey:$cacheKey');
      if (cachedData != null) {
        final jurisdictionData = json.decode(cachedData);
        final jurisdiction = Jurisdiction.fromJson(jurisdictionData);
        
        // Check if cache is still valid
        if (DateTime.now().difference(jurisdiction.lastUpdated) < _cacheExpiration) {
          return jurisdiction;
        }
      }
    } catch (e) {
      debugPrint('Failed to read cached jurisdiction: $e');
    }
    
    return null;
  }

  /// Cache jurisdiction data
  Future<void> _cacheJurisdiction(String cacheKey, Jurisdiction jurisdiction) async {
    try {
      await _storage.write(
        key: '$_jurisdictionCacheKey:$cacheKey',
        value: json.encode(jurisdiction.toJson()),
      );
    } catch (e) {
      debugPrint('Failed to cache jurisdiction: $e');
    }
  }

  /// Clear all cached jurisdiction data
  Future<void> clearCache() async {
    try {
      _memoryCache.clear();
      await _storage.deleteAll(); 
    } catch (e) {
      debugPrint('Failed to clear jurisdiction cache: $e');
    }
  }
}
