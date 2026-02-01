import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/lock_screen_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('LockScreenService', () {
    late LockScreenService lockScreenService;
    late List<MethodCall> methodCalls;

    setUp(() {
      lockScreenService = LockScreenService();
      methodCalls = [];

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('cop_stopper/lock_screen'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          
          switch (methodCall.method) {
            case 'initializeLockScreenWidget':
              return true;
            case 'updateLockScreenWidget':
              return null;
            case 'removeLockScreenWidget':
              return null;
            case 'createIOSShortcuts':
              return true;
            case 'createAndroidQuickSettingsTile':
              return true;
            case 'updateAndroidQuickSettingsTile':
              return null;
            case 'supportsLockScreenWidgets':
              return true;
            case 'requestLockScreenPermissions':
              return true;
            case 'startListeningForLockScreenActivation':
              return null;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('cop_stopper/lock_screen'),
        null,
      );
    });

    test('initializeLockScreenWidget calls correct method', () async {
      final result = await lockScreenService.initializeLockScreenWidget();
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('initializeLockScreenWidget'));
    });

    test('updateLockScreenWidget calls correct method with parameters', () async {
      await lockScreenService.updateLockScreenWidget(
        isEmergencyActive: true,
        isRecording: true,
        duration: '05:30',
      );
      
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('updateLockScreenWidget'));
      expect(methodCalls.first.arguments, equals({
        'isEmergencyActive': true,
        'isRecording': true,
        'duration': '05:30',
      }));
    });

    test('removeLockScreenWidget calls correct method', () async {
      await lockScreenService.removeLockScreenWidget();
      
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('removeLockScreenWidget'));
    });

    test('createIOSShortcuts calls correct method', () async {
      final result = await lockScreenService.createIOSShortcuts();
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('createIOSShortcuts'));
    });

    test('createAndroidQuickSettingsTile calls correct method', () async {
      final result = await lockScreenService.createAndroidQuickSettingsTile();
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('createAndroidQuickSettingsTile'));
    });

    test('updateAndroidQuickSettingsTile calls correct method with parameters', () async {
      await lockScreenService.updateAndroidQuickSettingsTile(
        isEmergencyActive: true,
        isRecording: false,
      );
      
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('updateAndroidQuickSettingsTile'));
      expect(methodCalls.first.arguments, equals({
        'isEmergencyActive': true,
        'isRecording': false,
      }));
    });

    test('supportsLockScreenWidgets calls correct method', () async {
      final result = await lockScreenService.supportsLockScreenWidgets();
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('supportsLockScreenWidgets'));
    });

    test('requestLockScreenPermissions calls correct method', () async {
      final result = await lockScreenService.requestLockScreenPermissions();
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('requestLockScreenPermissions'));
    });

    test('handles platform exceptions gracefully', () async {
      // Mock a platform exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('cop_stopper/lock_screen'),
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Test error message',
          );
        },
      );

      final result = await lockScreenService.initializeLockScreenWidget();
      expect(result, isFalse);
    });
  });

  group('LockScreenActivationEvent', () {
    test('creates event from map correctly', () {
      final map = {
        'action': 'emergency_activate',
        'timestamp': 1640995200000, // 2022-01-01 00:00:00 UTC
        'data': {'key': 'value'},
      };

      final event = LockScreenActivationEvent.fromMap(map);

      expect(event.action, equals('emergency_activate'));
      expect(event.timestamp, equals(DateTime.fromMillisecondsSinceEpoch(1640995200000)));
      expect(event.data, equals({'key': 'value'}));
    });

    test('converts event to map correctly', () {
      final event = LockScreenActivationEvent(
        action: 'emergency_activate',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1640995200000),
        data: {'key': 'value'},
      );

      final map = event.toMap();

      expect(map['action'], equals('emergency_activate'));
      expect(map['timestamp'], equals(1640995200000));
      expect(map['data'], equals({'key': 'value'}));
    });

    test('toString returns correct string representation', () {
      final event = LockScreenActivationEvent(
        action: 'emergency_activate',
        timestamp: DateTime.fromMillisecondsSinceEpoch(1640995200000),
        data: {'key': 'value'},
      );

      final string = event.toString();
      expect(string, contains('LockScreenActivationEvent'));
      expect(string, contains('emergency_activate'));
    });
  });
}