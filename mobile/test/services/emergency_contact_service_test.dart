import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/services/emergency_contact_service.dart';
import 'package:mobile/src/services/location_service.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('EmergencyContact', () {
    test('creates contact from map correctly', () {
      final map = {
        'id': '123',
        'name': 'John Doe',
        'phoneNumber': '+1234567890',
        'email': 'john@example.com',
        'isEnabled': true,
        'type': 'ContactType.personal',
      };

      final contact = EmergencyContact.fromMap(map);

      expect(contact.id, equals('123'));
      expect(contact.name, equals('John Doe'));
      expect(contact.phoneNumber, equals('+1234567890'));
      expect(contact.email, equals('john@example.com'));
      expect(contact.isEnabled, isTrue);
      expect(contact.type, equals(ContactType.personal));
    });

    test('converts contact to map correctly', () {
      const contact = EmergencyContact(
        id: '123',
        name: 'John Doe',
        phoneNumber: '+1234567890',
        email: 'john@example.com',
        isEnabled: true,
        type: ContactType.personal,
      );

      final map = contact.toMap();

      expect(map['id'], equals('123'));
      expect(map['name'], equals('John Doe'));
      expect(map['phoneNumber'], equals('+1234567890'));
      expect(map['email'], equals('john@example.com'));
      expect(map['isEnabled'], isTrue);
      expect(map['type'], equals('ContactType.personal'));
    });

    test('copyWith works correctly', () {
      const contact = EmergencyContact(
        id: '123',
        name: 'John Doe',
        phoneNumber: '+1234567890',
        isEnabled: true,
        type: ContactType.personal,
      );

      final updatedContact = contact.copyWith(
        name: 'Jane Doe',
        isEnabled: false,
      );

      expect(updatedContact.id, equals('123')); // unchanged
      expect(updatedContact.name, equals('Jane Doe')); // changed
      expect(updatedContact.phoneNumber, equals('+1234567890')); // unchanged
      expect(updatedContact.isEnabled, isFalse); // changed
      expect(updatedContact.type, equals(ContactType.personal)); // unchanged
    });

    test('toString returns correct string representation', () {
      const contact = EmergencyContact(
        id: '123',
        name: 'John Doe',
        phoneNumber: '+1234567890',
        isEnabled: true,
        type: ContactType.personal,
      );

      final string = contact.toString();
      expect(string, contains('EmergencyContact'));
      expect(string, contains('John Doe'));
      expect(string, contains('+1234567890'));
    });
  });

  group('EmergencyContactService', () {
    late EmergencyContactService service;
    late MockLocationService mockLocationService;
    late List<MethodCall> methodCalls;

    setUp(() {
      mockLocationService = MockLocationService();
      service = EmergencyContactService(mockLocationService);
      methodCalls = [];

      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('cop_stopper/emergency_contacts'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          
          switch (methodCall.method) {
            case 'getEmergencyContacts':
              return [
                {
                  'id': '1',
                  'name': 'John Doe',
                  'phoneNumber': '+1234567890',
                  'isEnabled': true,
                  'type': 'ContactType.personal',
                }
              ];
            case 'addEmergencyContact':
            case 'updateEmergencyContact':
            case 'removeEmergencyContact':
            case 'sendEmergencyNotification':
            case 'hasSMSPermission':
            case 'requestSMSPermission':
            case 'callEmergencyServices':
            case 'makePhoneCall':
              return true;
            case 'getLegalHotlines':
              return [
                {
                  'id': '2',
                  'name': 'Legal Aid Hotline',
                  'phoneNumber': '+1800LEGAL',
                  'isEnabled': true,
                  'type': 'ContactType.legal',
                }
              ];
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('cop_stopper/emergency_contacts'),
        null,
      );
      service.dispose();
    });

    test('getEmergencyContacts returns list of contacts', () async {
      final contacts = await service.getEmergencyContacts();
      
      expect(contacts.length, equals(1));
      expect(contacts.first.name, equals('John Doe'));
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('getEmergencyContacts'));
    });

    test('addEmergencyContact calls correct method', () async {
      const contact = EmergencyContact(
        id: '123',
        name: 'Jane Doe',
        phoneNumber: '+0987654321',
        isEnabled: true,
        type: ContactType.family,
      );

      final result = await service.addEmergencyContact(contact);
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('addEmergencyContact'));
      expect(methodCalls.first.arguments, equals(contact.toMap()));
    });

    test('updateEmergencyContact calls correct method', () async {
      const contact = EmergencyContact(
        id: '123',
        name: 'Jane Doe Updated',
        phoneNumber: '+0987654321',
        isEnabled: false,
        type: ContactType.family,
      );

      final result = await service.updateEmergencyContact(contact);
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('updateEmergencyContact'));
      expect(methodCalls.first.arguments, equals(contact.toMap()));
    });

    test('removeEmergencyContact calls correct method', () async {
      final result = await service.removeEmergencyContact('123');
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('removeEmergencyContact'));
      expect(methodCalls.first.arguments, equals({'contactId': '123'}));
    });

    test('sendEmergencyNotification calls correct method', () async {
      final result = await service.sendEmergencyNotification(
        message: 'Emergency test message',
        includeLocation: false,
      );
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('sendEmergencyNotification'));
      expect(methodCalls.first.arguments['message'], equals('Emergency test message'));
      expect(methodCalls.first.arguments['includeLocation'], isFalse);
    });

    test('hasSMSPermission calls correct method', () async {
      final result = await service.hasSMSPermission();
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('hasSMSPermission'));
    });

    test('requestSMSPermission calls correct method', () async {
      final result = await service.requestSMSPermission();
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('requestSMSPermission'));
    });

    test('testEmergencyNotification sends test message', () async {
      final result = await service.testEmergencyNotification();
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('sendEmergencyNotification'));
      expect(methodCalls.first.arguments['message'], contains('test'));
      expect(methodCalls.first.arguments['includeLocation'], isFalse);
    });

    test('getLegalHotlines returns list of legal contacts', () async {
      // Mock jurisdiction
      when(mockLocationService.getCurrentJurisdiction())
          .thenAnswer((_) async => null);

      final hotlines = await service.getLegalHotlines();
      
      expect(hotlines.length, equals(1));
      expect(hotlines.first.name, equals('Legal Aid Hotline'));
      expect(hotlines.first.type, equals(ContactType.legal));
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('getLegalHotlines'));
    });

    test('callEmergencyServices calls correct method', () async {
      final result = await service.callEmergencyServices();
      
      expect(result, isTrue);
      expect(methodCalls.length, equals(1));
      expect(methodCalls.first.method, equals('callEmergencyServices'));
    });

    test('handles platform exceptions gracefully', () async {
      // Mock a platform exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('cop_stopper/emergency_contacts'),
        (MethodCall methodCall) async {
          throw PlatformException(
            code: 'TEST_ERROR',
            message: 'Test error message',
          );
        },
      );

      final contacts = await service.getEmergencyContacts();
      expect(contacts, isEmpty);
    });
  });

  group('ContactType', () {
    test('has correct enum values', () {
      expect(ContactType.values.length, equals(4));
      expect(ContactType.values, contains(ContactType.personal));
      expect(ContactType.values, contains(ContactType.legal));
      expect(ContactType.values, contains(ContactType.medical));
      expect(ContactType.values, contains(ContactType.family));
    });
  });
}