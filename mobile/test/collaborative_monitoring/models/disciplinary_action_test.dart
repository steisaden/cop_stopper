import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/disciplinary_action.dart';

void main() {
  group('DisciplinaryAction', () {
    test('can be instantiated', () {
      final action = DisciplinaryAction(
        id: '1',
        date: DateTime(2023),
        description: 'description',
        outcome: 'outcome',
      );
      expect(action, isA<DisciplinaryAction>());
      expect(action.id, '1');
      expect(action.date, DateTime(2023));
      expect(action.description, 'description');
      expect(action.outcome, 'outcome');
    });
  });
}
