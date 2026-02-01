import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/participant.dart';

void main() {
  group('Participant', () {
    test('can be instantiated', () {
      final participant = Participant(
        id: '1',
        name: 'John Doe',
        role: ParticipantRole.broadcaster,
        status: ParticipantStatus.connected,
      );
      expect(participant, isA<Participant>());
      expect(participant.id, '1');
      expect(participant.name, 'John Doe');
      expect(participant.role, ParticipantRole.broadcaster);
      expect(participant.status, ParticipantStatus.connected);
    });
  });

  group('ParticipantRole', () {
    test('has three values', () {
      expect(ParticipantRole.values.length, 3);
    });
  });

  group('ParticipantStatus', () {
    test('has two values', () {
      expect(ParticipantStatus.values.length, 2);
    });
  });
}
