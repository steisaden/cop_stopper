import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/models/legal_advice_model.dart';

void main() {
  group('LegalAdvice', () {
    test('fromJson creates a valid LegalAdvice object', () {
      final json = {
        'id': 'advice123',
        'jurisdiction': 'California',
        'adviceText': 'You have the right to remain silent.',
        'relevantStatutes': ['CA Penal Code 123', 'CA Civil Code 456'],
        'timestamp': '2025-08-16T11:00:00.000Z',
      };
      final legalAdvice = LegalAdvice.fromJson(json);

      expect(legalAdvice.id, 'advice123');
      expect(legalAdvice.jurisdiction, 'California');
      expect(legalAdvice.adviceText, 'You have the right to remain silent.');
      expect(legalAdvice.relevantStatutes, ['CA Penal Code 123', 'CA Civil Code 456']);
      expect(legalAdvice.timestamp, DateTime.parse('2025-08-16T11:00:00.000Z'));
    });

    test('toJson converts LegalAdvice object to JSON', () {
      final legalAdvice = LegalAdvice(
        id: 'advice123',
        jurisdiction: 'California',
        adviceText: 'You have the right to remain silent.',
        relevantStatutes: ['CA Penal Code 123', 'CA Civil Code 456'],
        timestamp: DateTime.parse('2025-08-16T11:00:00.000Z'),
      );
      final json = legalAdvice.toJson();

      expect(json['id'], 'advice123');
      expect(json['jurisdiction'], 'California');
      expect(json['adviceText'], 'You have the right to remain silent.');
      expect(json['relevantStatutes'], ['CA Penal Code 123', 'CA Civil Code 456']);
      expect(json['timestamp'], '2025-08-16T11:00:00.000Z');
    });

    test('validate throws ArgumentError for empty jurisdiction', () {
      final legalAdvice = LegalAdvice(
        id: 'advice123',
        jurisdiction: '',
        adviceText: 'Test',
        relevantStatutes: [],
        timestamp: DateTime.now(),
      );
      expect(() => legalAdvice.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate throws ArgumentError for empty adviceText', () {
      final legalAdvice = LegalAdvice(
        id: 'advice123',
        jurisdiction: 'California',
        adviceText: '',
        relevantStatutes: [],
        timestamp: DateTime.now(),
      );
      expect(() => legalAdvice.validate(), throwsA(isA<ArgumentError>()));
    });

    test('validate does not throw for valid LegalAdvice', () {
      final legalAdvice = LegalAdvice(
        id: 'advice123',
        jurisdiction: 'California',
        adviceText: 'Test',
        relevantStatutes: [],
        timestamp: DateTime.now(),
      );
      expect(() => legalAdvice.validate(), returnsNormally);
    });
  });
}