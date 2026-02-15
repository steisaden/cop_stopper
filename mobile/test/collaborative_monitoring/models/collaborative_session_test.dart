import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/collaborative_session.dart';
import 'package:mobile/src/collaborative_monitoring/models/participant.dart';
import 'package:mobile/src/collaborative_monitoring/models/privacy_settings.dart';
import 'package:mobile/src/collaborative_monitoring/models/session_type.dart';

void main() {
  group('CollaborativeSession', () {
    test('can be instantiated', () {
      final session = CollaborativeSession(
        id: '1',
        type: SessionType.privateGroup,
        state: CollaborativeSessionState.active,
        participants: [
          Participant(
            id: '1',
            name: 'John Doe',
            role: ParticipantRole.broadcaster,
            status: ParticipantStatus.connected,
          ),
        ],
        privacySettings: const PrivacySettings(
          anonymizeParticipants: true,
          restrictToProAccounts: false,
        ),
      );
      expect(session, isA<CollaborativeSession>());
      expect(session.id, '1');
      expect(session.type, SessionType.privateGroup);
      expect(session.state, CollaborativeSessionState.active);
      expect(session.participants, isNotEmpty);
      expect(session.privacySettings, isA<PrivacySettings>());
    });
  });

  group('CollaborativeSessionState', () {
    test('has four values', () {
      expect(CollaborativeSessionState.values.length, 4);
    });
  });
}
