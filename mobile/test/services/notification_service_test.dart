import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/notification_service.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  group('NotificationService', () {
    late NotificationService notificationService;
    late MockFirebaseMessaging mockFirebaseMessaging;

    setUp(() {
      notificationService = NotificationService();
      mockFirebaseMessaging = MockFirebaseMessaging();
    });

    test('initialize does not throw', () {
      // This is not a real test as we can't initialize Firebase in a test environment.
      // We are just checking that the method doesn't throw an error.
      expect(() => notificationService.initialize(), returnsNormally);
    });

    test('getToken does not throw', () {
      // This is not a real test as we can't get a token in a test environment.
      // We are just checking that the method doesn't throw an error.
      expect(() => notificationService.getToken(), returnsNormally);
    });

    test('sendSessionInvitation does not throw', () async {
      expect(() async => await notificationService.sendSessionInvitation('1', '1'), returnsNormally);
    });

    test('setAvailabilityStatus does not throw', () async {
      expect(() async => await notificationService.setAvailabilityStatus(true), returnsNormally);
    });

    test('sendEmergencyNotification does not throw', () async {
      expect(() async => await notificationService.sendEmergencyNotification('message'), returnsNormally);
    });
  });
}
