import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/models/officer_record_model.dart';

void main() {
  group('OfficerRecord', () {
    test('fromJson creates a valid OfficerRecord object', () {
      final json = {
        'id': 'officer123',
        'badgeNumber': '12345',
        'name': 'John Doe',
        'agency': 'LAPD',
        'imageUrl': 'http://example.com/john_doe.jpg',
        'lastUpdated': '2025-08-16T13:00:00.000Z',
      };
      final officerRecord = OfficerRecord.fromJson(json);

      expect(officerRecord.id, 'officer123');
      expect(officerRecord.badgeNumber, '12345');
      expect(officerRecord.name, 'John Doe');
      expect(officerRecord.agency, 'LAPD');
      expect(officerRecord.imageUrl, 'http://example.com/john_doe.jpg');
      expect(officerRecord.lastUpdated, DateTime.parse('2025-08-16T13:00:00.000Z'));
    });

    test('toJson converts OfficerRecord object to JSON', () {
      final officerRecord = OfficerRecord(
        id: 'officer123',
        badgeNumber: '12345',
        name: 'John Doe',
        agency: 'LAPD',
        imageUrl: 'http://example.com/john_doe.jpg',
        lastUpdated: DateTime.parse('2025-08-16T13:00:00.000Z'),
      );
      final json = officerRecord.toJson();

      expect(json['id'], 'officer123');
      expect(json['badgeNumber'], '12345');
      expect(json['name'], 'John Doe');
      expect(json['agency'], 'LAPD');
      expect(json['imageUrl'], 'http://example.com/john_doe.jpg');
      expect(json['lastUpdated'], '2025-08-16T13:00:00.000Z');
    });

    test('validate throws ArgumentError for empty badgeNumber', () {
      final officerRecord = OfficerRecord(
        id: 'officer123',
        badgeNumber: '',
        name: 'John Doe',
        agency: 'LAPD',
        lastUpdated: DateTime.now(),
      );
      expect(() => officerRecord.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate throws ArgumentError for empty name', () {
      final officerRecord = OfficerRecord(
        id: 'officer123',
        badgeNumber: '12345',
        name: '',
        agency: 'LAPD',
        lastUpdated: DateTime.now(),
      );
      expect(() => officerRecord.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate throws ArgumentError for empty agency', () {
      final officerRecord = OfficerRecord(
        id: 'officer123',
        badgeNumber: '12345',
        name: 'John Doe',
        agency: '',
        lastUpdated: DateTime.now(),
      );
      expect(() => officerRecord.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate does not throw for valid OfficerRecord', () {
      final officerRecord = OfficerRecord(
        id: 'officer123',
        badgeNumber: '12345',
        name: 'John Doe',
        agency: 'LAPD',
        lastUpdated: DateTime.now(),
      );
      expect(() => officerRecord.validate(), returnsNormally);
    });
  });
}