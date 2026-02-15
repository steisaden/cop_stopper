import 'dart:async';
import 'package:flutter/services.dart';

/// Power saving mode configuration
class PowerSavingConfig {
  final bool reducedFrameRate;
  final bool disableAnimations;
  final bool reducedVideoQuality;
  final bool backgroundAppRefreshDisabled;
  final bool locationUpdatesReduced;
  final int batteryThresholdPercent;

  const PowerSavingConfig({
    this.reducedFrameRate = true,
    this.disableAnimations = true,
    this.reducedVideoQuality = true,
    this.backgroundAppRefreshDisabled = true,
    this.locationUpdatesReduced = true,
    this.batteryThresholdPercent = 20,
  });

  Map<String, dynamic> toMap() {
    return {
      'reducedFrameRate': reducedFrameRate,
      'disableAnimations': disableAnimations,
      'reducedVideoQuality': reducedVideoQuality,
      'backgroundAppRefreshDisabled': backgroundAppRefreshDisabled,
      'locationUpdatesReduced': locationUpdatesReduced,
      'batteryThresholdPercent': batteryThresholdPercent,
    };
  }

  factory PowerSavingConfig.fromMap(Map<String, dynamic> map) {
    return PowerSavingConfig(
      reducedFrameRate: map['reducedFrameRate'] ?? true,
      disableAnimations: map['disableAnimations'] ?? true,
      reducedVideoQuality: map['reducedVideoQuality'] ?? true,
      backgroundAppRefreshDisabled: map['backgroundAppRefreshDisabled'] ?? true,
      locationUpdatesReduced: map['locationUpdatesReduced'] ?? true,
      batteryThresholdPercent: map['batteryThresholdPercent'] ?? 20,
    );
  }

  PowerSavingConfig copyWith({
    bool? reducedFrameRate,
    bool? disableAnimations,
    bool? reducedVideoQuality,
    bool? backgroundAppRefreshDisabled,
    bool? locationUpdatesReduced,
    int? batteryThresholdPercent,
  }) {
    return PowerSavingConfig(
      reducedFrameRate: reducedFrameRate ?? this.reducedFrameRate,
      disableAnimations: disableAnimations ?? this.disableAnimations,
      reducedVideoQuality: reducedVideoQuality ?? this.reducedVideoQuality,
      backgroundAppRefreshDisabled: backgroundAppRefreshDisabled ?? this.backgroundAppRefreshDisabled,
      locationUpdatesReduced: locationUpdatesReduced ?? this.locationUpdatesReduced,
      batteryThresholdPercent: batteryThresholdPercent ?? this.batteryThresholdPercent,
    );
  }
}

/// Battery status information
class BatteryStatus {
  final int batteryLevel;
  final bool isCharging;
  final bool isLowPowerMode;
  final int estimatedTimeRemaining; // in minutes

  const BatteryStatus({
    required this.batteryLevel,
    required this.isCharging,
    required this.isLowPowerMode,
    required this.estimatedTimeRemaining,
  });

  factory BatteryStatus.fromMap(Map<String, dynamic> map) {
    return BatteryStatus(
      batteryLevel: map['batteryLevel'] ?? 0,
      isCharging: map['isCharging'] ?? false,
      isLowPowerMode: map['isLowPowerMode'] ?? false,
      estimatedTimeRemaining: map['estimatedTimeRemaining'] ?? 0,
    );
  }

  bool get isLowBattery => batteryLevel <= 20;
  bool get isCriticalBattery => batteryLevel <= 10;

  @override
  String toString() {
    return 'BatteryStatus(level: $batteryLevel%, charging: $isCharging, lowPowerMode: $isLowPowerMode)';
  }
}

/// Service for managing power-saving mode during emergency situations
class PowerSavingService {
  static const MethodChannel _channel = MethodChannel('cop_stopper/power_saving');
  static const EventChannel _batteryChannel = EventChannel('cop_stopper/battery_events');
  
  PowerSavingConfig _config = const PowerSavingConfig();
  bool _isPowerSavingActive = false;
  StreamSubscription<BatteryStatus>? _batterySubscription;

  /// Get current power saving configuration
  PowerSavingConfig get config => _config;

  /// Check if power saving mode is active
  bool get isPowerSavingActive => _isPowerSavingActive;

  /// Update power saving configuration
  Future<void> updateConfig(PowerSavingConfig config) async {
    _config = config;
    if (_isPowerSavingActive) {
      await _applyPowerSavingSettings();
    }
  }

  /// Get current battery status
  Future<BatteryStatus> getBatteryStatus() async {
    try {
      final result = await _channel.invokeMethod<Map<String, dynamic>>('getBatteryStatus');
      if (result == null) {
        return const BatteryStatus(
          batteryLevel: 100,
          isCharging: false,
          isLowPowerMode: false,
          estimatedTimeRemaining: 0,
        );
      }
      return BatteryStatus.fromMap(result);
    } on PlatformException catch (e) {
      print('Failed to get battery status: ${e.message}');
      return const BatteryStatus(
        batteryLevel: 100,
        isCharging: false,
        isLowPowerMode: false,
        estimatedTimeRemaining: 0,
      );
    }
  }

  /// Start monitoring battery status
  Stream<BatteryStatus> watchBatteryStatus() {
    return _batteryChannel
        .receiveBroadcastStream()
        .map((dynamic event) => BatteryStatus.fromMap(event.cast<String, dynamic>()));
  }

  /// Enable power saving mode
  Future<bool> enablePowerSavingMode() async {
    try {
      _isPowerSavingActive = true;
      await _applyPowerSavingSettings();
      
      // Start monitoring battery status
      _batterySubscription = watchBatteryStatus().listen(
        (batteryStatus) async {
          if (batteryStatus.isCriticalBattery && !batteryStatus.isCharging) {
            await _enableCriticalPowerSaving();
          }
        },
      );

      return true;
    } catch (e) {
      print('Failed to enable power saving mode: $e');
      _isPowerSavingActive = false;
      return false;
    }
  }

  /// Disable power saving mode
  Future<bool> disablePowerSavingMode() async {
    try {
      _isPowerSavingActive = false;
      await _batterySubscription?.cancel();
      _batterySubscription = null;
      
      await _restoreNormalSettings();
      return true;
    } catch (e) {
      print('Failed to disable power saving mode: $e');
      return false;
    }
  }

  /// Apply power saving settings
  Future<void> _applyPowerSavingSettings() async {
    try {
      await _channel.invokeMethod('applyPowerSavingSettings', _config.toMap());
    } on PlatformException catch (e) {
      print('Failed to apply power saving settings: ${e.message}');
    }
  }

  /// Restore normal settings
  Future<void> _restoreNormalSettings() async {
    try {
      await _channel.invokeMethod('restoreNormalSettings');
    } on PlatformException catch (e) {
      print('Failed to restore normal settings: ${e.message}');
    }
  }

  /// Enable critical power saving for very low battery
  Future<void> _enableCriticalPowerSaving() async {
    try {
      const criticalConfig = PowerSavingConfig(
        reducedFrameRate: true,
        disableAnimations: true,
        reducedVideoQuality: true,
        backgroundAppRefreshDisabled: true,
        locationUpdatesReduced: true,
        batteryThresholdPercent: 5,
      );
      
      await _channel.invokeMethod('applyCriticalPowerSaving', criticalConfig.toMap());
    } on PlatformException catch (e) {
      print('Failed to enable critical power saving: ${e.message}');
    }
  }

  /// Get estimated recording time remaining based on current battery
  Future<Duration> getEstimatedRecordingTime() async {
    try {
      final batteryStatus = await getBatteryStatus();
      final result = await _channel.invokeMethod<int>('getEstimatedRecordingTime', {
        'batteryLevel': batteryStatus.batteryLevel,
        'isCharging': batteryStatus.isCharging,
        'isPowerSavingActive': _isPowerSavingActive,
      });
      
      return Duration(minutes: result ?? 0);
    } on PlatformException catch (e) {
      print('Failed to get estimated recording time: ${e.message}');
      return Duration.zero;
    }
  }

  /// Optimize recording settings for battery life
  Future<Map<String, dynamic>> getOptimizedRecordingSettings() async {
    try {
      final batteryStatus = await getBatteryStatus();
      final result = await _channel.invokeMethod<Map<String, dynamic>>('getOptimizedRecordingSettings', {
        'batteryLevel': batteryStatus.batteryLevel,
        'isCharging': batteryStatus.isCharging,
        'isPowerSavingActive': _isPowerSavingActive,
      });
      
      return result ?? {};
    } on PlatformException catch (e) {
      print('Failed to get optimized recording settings: ${e.message}');
      return {};
    }
  }

  /// Enable system-level power saving mode
  Future<bool> enableSystemPowerSavingMode() async {
    try {
      final result = await _channel.invokeMethod<bool>('enableSystemPowerSavingMode');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to enable system power saving mode: ${e.message}');
      return false;
    }
  }

  /// Check if device supports power saving features
  Future<Map<String, bool>> getSupportedFeatures() async {
    try {
      final result = await _channel.invokeMethod<Map<String, dynamic>>('getSupportedFeatures');
      return result?.cast<String, bool>() ?? {};
    } on PlatformException catch (e) {
      print('Failed to get supported features: ${e.message}');
      return {};
    }
  }

  /// Get power consumption statistics
  Future<Map<String, double>> getPowerConsumptionStats() async {
    try {
      final result = await _channel.invokeMethod<Map<String, dynamic>>('getPowerConsumptionStats');
      return result?.cast<String, double>() ?? {};
    } on PlatformException catch (e) {
      print('Failed to get power consumption stats: ${e.message}');
      return {};
    }
  }

  /// Dispose of resources
  void dispose() {
    _batterySubscription?.cancel();
  }
}