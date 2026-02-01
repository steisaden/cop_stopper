import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/commendation.dart';

void main() {
  group('Commendation', () {
    test('can be instantiated', () {
      final commendation = Commendation(
        id: '1',
        date: DateTime(2023),
        description: 'description',
      );
      expect(commendation, isA<Commendation>());
      expect(commendation.id, '1');
      expect(commendation.date, DateTime(2023));
      expect(commendation.description, 'description');
    });
  });
}
