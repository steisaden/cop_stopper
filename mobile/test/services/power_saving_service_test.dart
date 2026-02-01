import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/power_saving_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PowerSavingConfig', () {
    test('creates config with default values', () {
      const config = PowerSavingConfig();
      
      expect(config.reducedFrameRate, isTrue);
      expect(config.disableAnimations, isTrue);
      expect(config.reducedVideoQuality, isTrue);
      expect(config.backgroundAppRefreshDisabled, isTrue);
      expect(config.locationUpdatesReduced, isTrue);
      expect(config.batteryThresholdPercent, equals(20));
    });

    test('creates config from map correctly', () {
      final map = {
        'reducedFrameRate': false,
        'disableAnimations': false,
        'reducedVideoQuality': true,
        'backgroundAppRefreshDisabled': true,
        'locationUpdatesReduced': false,
        'batteryThresholdPercent': 15,
      };

      final config = PowerSavingConfig.fromMap(map);

      expect(config.reducedFrameRate, isFalse);
      expect(config.disableAnimations, isFalse);
      expect(config.reducedVideoQuality, isTrue);
      expect(config.backgroundAppRefreshDisabled, isTrue);
      expect(config.locationUpdatesReduced, isFalse);
      expect(config.batteryThresholdPercent, equals(15));
    });

    test('converts config to map correctly', () {
      const config = PowerSavingConfig(
        reducedFrameRate: false,
        disableAnimations: true,
        batteryThresholdPercent: 25,
      );

      final map = config.toMap();

      expect(map['reducedFrameRate'], isFalse);
      expect(map['disableAnimations'], isTrue);
      expect(map['batteryThresholdPercent'], equals(25));
    });

    test('copyWith works correctly', () {
      const config = PowerSavingConfig();
      
      final updatedConfig = config.copyWith(
        reducedFrameRate: false,
        batteryThresholdPercent: 30,
      );

      expect(updatedConfig.reducedFrameRate, isFalse); // changed
      expect(updatedConfig.disableAnimations, isTrue); // unchanged
      expect(updatedConfig.batteryThresholdPercent, equals(30)); // changed
    });
  });

  group('BatteryStatus', () {
    test('creates status from map correctly', () {
      final map = {
        'batteryLevel': 75,
        'isCharging': true,
        'isLowPowerMode': false,
        'estimatedTimeRemaining': 120,
      };

      final status = BatteryStatus.fromMap(map);

      expect(status.batteryLevel, equals(75));
      expect(status.isCharging, isTrue);
      expect(status.isLowPowerMode, isFalse);
      expect(status.estimatedTimeRemaining, equals(120));
    });

    test('isLowBattery returns correct value', () {
      const lowBattery = BatteryStatus(
        batteryLevel: 15,
        isCharging: false,
        isLowPowerMode: false,
        estimatedTimeRemaining: 30,
      );
      
      const normalBattery = BatteryStatus(
        batteryLevel: 50,
        isCharging: false,
        isLowPowerMode: false,
        estimatedTimeRemaining: 120,
      );

      expect(lowBattery.isLowBattery, isTrue);
      expect(normalBattery.isLowBattery, isFalse);
    });

    test('isCriticalBattery returns correct value', () {
      const criticalBattery = BatteryStatus(
        batteryLevel: 5,
        isCharging: false,
        isLowPowerMode: true,
        estimatedTimeRemaining: 10,
      );
      
      const normalBattery = BatteryStatus(
        batteryLevel: 50,
        isCharging: false,
        isLowPowerMode: false,
        estimatedTimeRemaining: 120,
      );

      expect(criticalBattery.isCriticalBattery, isTrue);
      expect(normalBattery.isCriticalBattery, isFalse);
    });

    test('toString returns correct string representation', () {
      const status = BatteryStatus(
        batteryLevel: 75,
        isCharging: true,
        isLowPowerMode: false,
        estimatedTimeRemaining: 120,
      );

      final string = status.toString();
      expect(string, contains('BatteryStatus'));
      expect(string, contains('75%'));
      expect(string, contains('charging: true'));
    });
  });

  group('PowerSavingService', () {
    late PowerSavingService service;
    late List<MethodCall> methodCalls;

    setUp(() {
      service = PowerSavingService();
      methodCalls = [];

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('cop_stopper/power_saving'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          
          switch (methodCall.method) {
            case 'getBatteryStatus':
              return {
                'batteryLevel': 75,
                'isCharging': false,
                'isLowPowerMode': false,
                'estimatedTimeRemaining': 120,
              };
            case 'applyPowerSavingSettings':
            case 'restoreNormalSettings':
            case 'applyCriticalPowerSaving':
              return null;
            case 'getEstimatedRecordingTime':
              return 90; // 90 minutes
            case 'getOptimizedRecordingSettings':
              return {
                'videoQuality': '720p',
                'frameRate': 24,
                'audioBitrate': 128,
              };
            case 'enableSystemPowerSavingMode':
              return true;
            case 'getSupportedFeatures':
              return {
                'reducedFrameRate': true,
                'disableAnimations': true,
                'reducedVideoQuality': true,
              };
            case 'getPowerConsumptionStats':
              return {
                'screenUsage': 45.5,
                'cameraUsage': 30.2,
                'audioUsage': 15.8,
              };
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('cop_stopper/power_saving'),
        null,
      );
      service.dispose();
    });

    test('initial state is correct', () {
      expect(service.isPowerSavingActive, isFalse);
      expect(service.config.batteryThresholdPercent, equals(20));
    });

    test('updateConfig updates configuration', () async {
      const newConfig = PowerSavingConfig(batteryThresholdPercent: 30);
      
      await service.updateConfig(newConfig);
      
      expect(service.config.batteryThresholdPercent, equals(30));
    });

    test('getBatteryStatus returns battery information', () async {
      final status = await service.getBatteryStatus();
      
      expect(status.batteryLevel, equals(75));
      expect(status.isCharging, isFalse);
      expect(status.estimatedTimeRemaining, equals(120));
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('getBatteryStatus'));
    });

    test('enablePowerSavingMode activates power saving', () async {
      final result = await service.enablePowerSavingMode();
      
      expect(result, isTrue);
      expect(service.isPowerSavingActive, isTrue);
      expect(methodCalls.any((call) => call.method == 'applyPowerSavingSettings'), isTrue);
    });

    test('disablePowerSavingMode deactivates power saving', () async {
      // First enable power saving
      await service.enablePowerSavingMode();
      methodCalls.clear();
      
      final result = await service.disablePowerSavingMode();
      
      expect(result, isTrue);
      expect(service.isPowerSavingActive, isFalse);
      expect(methodCalls.any((call) => call.method == 'restoreNormalSettings'), isTrue);
    });

    test('getEstimatedRecordingTime returns duration', () async {
      final duration = await service.getEstimatedRecordingTime();
      
      expect(duration.inMinutes, equals(90));
      expect(methodCalls.length, equals(2)); // getBatteryStatus + getEstimatedRecordingTime
      expect(methodCalls.last.method, equals('getEstimatedRecordingTime'));
    });

    test('getOptimizedRecordingSettings returns settings map', () async {
      final settings = await service.getOptimizedRecordingSettings();
      
      expect(settings['videoQuality'], equals('720p'));
      expect(settings['frameRate'], equals(24));
      expect(settings['audioBitrate'], equals(128));
      expect(methodCalls.length, equals(2)); // getBatteryStatus + getOptimizedRecordingSettings
    });

    test('enableSystemPowerSavingMode calls correct method', () async {
      final result = await service.enableSystemPowerSavingMode();
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('enableSystemPowerSavingMode'));
    });

    test('getSupportedFeatures returns feature map', () async {
      final features = await service.getSupportedFeatures();
      
      expect(features['reducedFrameRate'], isTrue);
      expect(features['disableAnimations'], isTrue);
      expect(features['reducedVideoQuality'], isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('getSupportedFeatures'));
    });

    test('getPowerConsumptionStats returns stats map', () async {
      final stats = await service.getPowerConsumptionStats();
      
      expect(stats['screenUsage'], equals(45.5));
      expect(stats['cameraUsage'], equals(30.2));
      expect(stats['audioUsage'], equals(15.8));
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('getPowerConsumptionStats'));
    });

    test('handles platform exceptions gracefully', () async {
      // Mock a platform exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('cop_stopper/power_saving'),
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Test error message',
          );
        },
      );

      final status = await service.getBatteryStatus();
      expect(status.batteryLevel, equals(100)); // default value
      expect(status.isCharging, isFalse);
    });
  });
}