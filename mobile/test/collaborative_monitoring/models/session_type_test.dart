import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/session_type.dart';

void main() {
  group('SessionType', () {
    test('has two values', () {
      expect(SessionType.values.length, 2);
    });

    test('has privateGroup value', () {
      expect(SessionType.values, contains(SessionType.privateGroup));
    });

    test('has spectator value', () {
      expect(SessionType.values, contains(SessionType.spectator));
    });
  });
}
