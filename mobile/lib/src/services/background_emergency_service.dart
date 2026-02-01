import 'dart:async';
import 'package:flutter/services.dart';
import 'recording_service_interface.dart';
import 'location_service.dart';

/// Service to handle emergency mode operations in the background
class BackgroundEmergencyService {
  static const MethodChannel _channel = MethodChannel('cop_stopper/background_emergency');
  
  final RecordingService _recordingService;
  final LocationService _locationService;
  
  Timer? _locationUpdateTimer;
  bool _isEmergencyModeActive = false;
  
  BackgroundEmergencyService({
    required RecordingService recordingService,
    required LocationService locationService,
  }) : _recordingService = recordingService,
       _locationService = locationService;

  /// Start emergency mode with background operations
  Future<void> startEmergencyMode() async {
    if (_isEmergencyModeActive) return;
    
    _isEmergencyModeActive = true;
    
    try {
      // Note: Recording is now manually controlled by user
      // Emergency mode only handles location sharing and notifications
      
      // Setup periodic location updates (every 30 seconds)
      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _updateEmergencyContacts(),
      );
      
      // Enable background mode
      await _enableBackgroundMode();
      
      // Send initial emergency notification
      await _sendEmergencyNotification();
      
    } catch (e) {
      _isEmergencyModeActive = false;
      rethrow;
    }
  }

  /// Stop emergency mode and cleanup
  Future<void> stopEmergencyMode() async {
    if (!_isEmergencyModeActive) return;
    
    _isEmergencyModeActive = false;
    
    try {
      // Note: Recording is now manually controlled by user
      // Emergency mode only handles location sharing and notifications
      
      // Cancel location updates
      _locationUpdateTimer?.cancel();
      _locationUpdateTimer = null;
      
      // Disable background mode
      await _disableBackgroundMode();
      
      // Send emergency stopped notification
      await _sendEmergencyStoppedNotification();
      
    } catch (e) {
      // Log error but don't rethrow to ensure cleanup continues
      print('Error stopping emergency mode: $e');
    }
  }

  /// Enable background execution mode
  Future<void> _enableBackgroundMode() async {
    try {
      await _channel.invokeMethod('enableBackgroundMode', {
        'title': 'Emergency Mode Active',
        'description': 'Recording and location sharing in progress',
        'showMinimizedButton': true,
      });
    } on PlatformException catch (e) {
      print('Failed to enable background mode: ${e.message}');
    }
  }

  /// Disable background execution mode
  Future<void> _disableBackgroundMode() async {
    try {
      await _channel.invokeMethod('disableBackgroundMode');
    } on PlatformException catch (e) {
      print('Failed to disable background mode: ${e.message}');
    }
  }

  /// Update emergency contacts with current location
  Future<void> _updateEmergencyContacts() async {
    if (!_isEmergencyModeActive) return;
    
    try {
      final locationResult = await _locationService.getCurrentLocation();
      
      // Send location update to emergency contacts
      await _channel.invokeMethod('updateEmergencyContacts', {
        'latitude': locationResult.position.latitude,
        'longitude': locationResult.position.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'accuracy': locationResult.accuracy.name,
      });
    } catch (e) {
      print('Failed to update emergency contacts: $e');
    }
  }

  /// Send initial emergency notification
  Future<void> _sendEmergencyNotification() async {
    try {
      await _channel.invokeMethod('sendEmergencyNotification', {
        'type': 'emergency_started',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to send emergency notification: $e');
    }
  }

  /// Send emergency stopped notification
  Future<void> _sendEmergencyStoppedNotification() async {
    try {
      await _channel.invokeMethod('sendEmergencyNotification', {
        'type': 'emergency_stopped',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print('Failed to send emergency stopped notification: $e');
    }
  }

  /// Check if emergency mode is currently active
  bool get isEmergencyModeActive => _isEmergencyModeActive;

  /// Check if recording is active
  bool get isRecording => _recordingService.isRecording;

  /// Dispose of resources
  void dispose() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }
}