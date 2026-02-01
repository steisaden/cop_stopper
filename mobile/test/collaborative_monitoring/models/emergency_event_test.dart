import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/emergency_event.dart';

void main() {
  group('EmergencyEvent', () {
    test('can be instantiated', () {
      final event = EmergencyEvent(
        id: '1',
        timestamp: DateTime(2023),
        description: 'description',
      );
      expect(event, isA<EmergencyEvent>());
      expect(event.id, '1');
      expect(event.timestamp, DateTime(2023));
      expect(event.description, 'description');
    });
  });
}
