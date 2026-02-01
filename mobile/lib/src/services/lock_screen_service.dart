import 'dart:async';
import 'package:flutter/services.dart';

/// Service for managing lock screen integration and emergency activation
class LockScreenService {
  static const MethodChannel _channel = MethodChannel('cop_stopper/lock_screen');
  
  /// Initialize lock screen widget for emergency recording activation
  Future<bool> initializeLockScreenWidget() async {
    try {
      final result = await _channel.invokeMethod<bool>('initializeLockScreenWidget');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to initialize lock screen widget: ${e.message}');
      return false;
    }
  }

  /// Update lock screen widget with current emergency status
  Future<void> updateLockScreenWidget({
    required bool isEmergencyActive,
    required bool isRecording,
    String? duration,
  }) async {
    try {
      await _channel.invokeMethod('updateLockScreenWidget', {
        'isEmergencyActive': isEmergencyActive,
        'isRecording': isRecording,
        'duration': duration,
      });
    } on PlatformException catch (e) {
      print('Failed to update lock screen widget: ${e.message}');
    }
  }

  /// Remove lock screen widget
  Future<void> removeLockScreenWidget() async {
    try {
      await _channel.invokeMethod('removeLockScreenWidget');
    } on PlatformException catch (e) {
      print('Failed to remove lock screen widget: ${e.message}');
    }
  }

  /// Create iOS shortcuts for emergency recording
  Future<bool> createIOSShortcuts() async {
    try {
      final result = await _channel.invokeMethod<bool>('createIOSShortcuts');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to create iOS shortcuts: ${e.message}');
      return false;
    }
  }

  /// Create Android quick settings tile
  Future<bool> createAndroidQuickSettingsTile() async {
    try {
      final result = await _channel.invokeMethod<bool>('createAndroidQuickSettingsTile');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to create Android quick settings tile: ${e.message}');
      return false;
    }
  }

  /// Update Android quick settings tile state
  Future<void> updateAndroidQuickSettingsTile({
    required bool isEmergencyActive,
    required bool isRecording,
  }) async {
    try {
      await _channel.invokeMethod('updateAndroidQuickSettingsTile', {
        'isEmergencyActive': isEmergencyActive,
        'isRecording': isRecording,
      });
    } on PlatformException catch (e) {
      print('Failed to update Android quick settings tile: ${e.message}');
    }
  }

  /// Listen for lock screen emergency activation
  Stream<Map<String, dynamic>> get lockScreenActivationStream {
    return _channel.invokeMethod('startListeningForLockScreenActivation')
        .asStream()
        .asyncExpand((dynamic result) {
      return const EventChannel('cop_stopper/lock_screen_events')
          .receiveBroadcastStream()
          .cast<Map<String, dynamic>>();
    });
  }

  /// Check if device supports lock screen widgets
  Future<bool> supportsLockScreenWidgets() async {
    try {
      final result = await _channel.invokeMethod<bool>('supportsLockScreenWidgets');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to check lock screen widget support: ${e.message}');
      return false;
    }
  }

  /// Request necessary permissions for lock screen integration
  Future<bool> requestLockScreenPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestLockScreenPermissions');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to request lock screen permissions: ${e.message}');
      return false;
    }
  }
}

/// Lock screen activation event data
class LockScreenActivationEvent {
  final String action;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const LockScreenActivationEvent({
    required this.action,
    required this.timestamp,
    this.data,
  });

  factory LockScreenActivationEvent.fromMap(Map<String, dynamic> map) {
    return LockScreenActivationEvent(
      action: map['action'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      data: map['data'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'action': action,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'LockScreenActivationEvent(action: $action, timestamp: $timestamp, data: $data)';
  }
}