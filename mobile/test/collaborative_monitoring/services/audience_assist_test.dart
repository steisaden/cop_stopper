import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/collaborative_monitoring/services/collaborative_session_manager.dart';
import 'package:mobile/src/collaborative_monitoring/interfaces/screen_sharing_service.dart';
import 'package:mobile/src/services/notification_service.dart';
import 'package:mobile/src/collaborative_monitoring/models/session_type.dart';
import 'package:mobile/src/collaborative_monitoring/models/privacy_settings.dart';
import 'package:mobile/src/collaborative_monitoring/models/participant.dart';

@GenerateMocks([ScreenSharingService, NotificationService])
import 'audience_assist_test.mocks.dart';

void main() {
  group('Audience Assist Functionality Tests', () {
    late CollaborativeSessionManager sessionManager;
    late MockScreenSharingService mockScreenSharingService;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockScreenSharingService = MockScreenSharingService();
      mockNotificationService = MockNotificationService();
      sessionManager = CollaborativeSessionManager(
        mockScreenSharingService,
        mockNotificationService,
      );

      // Setup default mock behaviors
      when(mockScreenSharingService.startScreenSharing())
          .thenAnswer((_) async {
            return null;
          });
      when(mockScreenSharingService.toggleAudienceAssist(any))
          .thenAnswer((_) async {
            return null;
          });
      when(mockScreenSharingService.addParticipant(any))
          .thenAnswer((_) async {
            return null;
          });
      when(mockScreenSharingService.removeParticipant(any))
          .thenAnswer((_) async {
            return null;
          });
    });

    tearDown(() {
      sessionManager.dispose();
    });

    group('Audience Assist Toggle', () {
      test('should enable audience assist and broadcast opportunity', () async {
        // Create a session first
        final session = await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );

        // Enable audience assist
        await sessionManager.toggleAudienceAssist(true);

        // Verify audience assist is enabled
        expect(sessionManager.isAudienceAssistEnabled, isTrue);

        // Verify screen sharing service was called
        verify(mockScreenSharingService.toggleAudienceAssist(true)).called(1);

        // Verify notification was sent
        verify(mockNotificationService.broadcastSpectatorOpportunity(any)).called(1);

        // Verify session was updated
        expect(sessionManager.currentSession?.privacy.audienceAssistEnabled, isTrue);
      });

      test('should disable audience assist and remove spectators', () async {
        // Create session and enable audience assist
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );
        await sessionManager.toggleAudienceAssist(true);

        // Add some spectators to the queue
        await sessionManager.handleSpectatorRequest('spectator_1');
        await sessionManager.handleSpectatorRequest('spectator_2');

        // Disable audience assist
        await sessionManager.toggleAudienceAssist(false);

        // Verify audience assist is disabled
        expect(sessionManager.isAudienceAssistEnabled, isFalse);

        // Verify screen sharing service was called
        verify(mockScreenSharingService.toggleAudienceAssist(false)).called(1);

        // Verify spectator queue is cleared
        final spectatorRequests = await sessionManager.onSpectatorRequests.first;
        expect(spectatorRequests, isEmpty);
      });

      test('should throw exception when no active session', () async {
        expect(
          () => sessionManager.toggleAudienceAssist(true),
          throwsException,
        );
      });
    });

    group('Spectator Request Handling', () {
      test('should add spectator to queue when audience assist enabled', () async {
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );
        await sessionManager.toggleAudienceAssist(true);

        await sessionManager.handleSpectatorRequest('spectator_1');

        final spectatorRequests = await sessionManager.onSpectatorRequests.first;
        expect(spectatorRequests, contains('spectator_1'));
      });

      test('should ignore spectator request when audience assist disabled', () async {
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );
        // Don't enable audience assist

        await sessionManager.handleSpectatorRequest('spectator_1');

        final spectatorRequests = await sessionManager.onSpectatorRequests.first;
        expect(spectatorRequests, isEmpty);
      });

      test('should not add duplicate spectator requests', () async {
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );
        await sessionManager.toggleAudienceAssist(true);

        await sessionManager.handleSpectatorRequest('spectator_1');
        await sessionManager.handleSpectatorRequest('spectator_1'); // Duplicate

        final spectatorRequests = await sessionManager.onSpectatorRequests.first;
        expect(spectatorRequests.length, equals(1));
        expect(spectatorRequests, contains('spectator_1'));
      });
    });

    group('Spectator Approval/Rejection', () {
      test('should approve spectator and add to session', () async {
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );
        await sessionManager.toggleAudienceAssist(true);
        await sessionManager.handleSpectatorRequest('spectator_1');

        await sessionManager.approveSpectator('spectator_1');

        // Verify spectator was added to screen sharing
        verify(mockScreenSharingService.addParticipant('spectator_1')).called(1);

        // Verify spectator was removed from queue
        final spectatorRequests = await sessionManager.onSpectatorRequests.first;
        expect(spectatorRequests, isEmpty);

        // Verify notification was sent
        verify(mockNotificationService.notifySpectatorApproved('spectator_1', any)).called(1);

        // Verify participant was added to session
        final session = sessionManager.currentSession!;
        expect(session.participants.any((p) => p.id == 'spectator_1'), isTrue);
        final spectator = session.participants.firstWhere((p) => p.id == 'spectator_1');
        expect(spectator.role, equals(ParticipantRole.spectator));
      });

      test('should reject spectator and send notification', () async {
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );
        await sessionManager.toggleAudienceAssist(true);
        await sessionManager.handleSpectatorRequest('spectator_1');

        await sessionManager.rejectSpectator('spectator_1');

        // Verify spectator was removed from queue
        final spectatorRequests = await sessionManager.onSpectatorRequests.first;
        expect(spectatorRequests, isEmpty);

        // Verify rejection notification was sent
        verify(mockNotificationService.notifySpectatorRejected(
          'spectator_1',
          any,
          'Request rejected by broadcaster',
        )).called(1);

        // Verify spectator was not added to session
        final session = sessionManager.currentSession!;
        expect(session.participants.any((p) => p.id == 'spectator_1'), isFalse);
      });

      test('should handle approval error gracefully', () async {
        // Setup screen sharing service to throw error
        when(mockScreenSharingService.addParticipant('spectator_1'))
            .thenThrow(Exception('Connection failed'));

        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );
        await sessionManager.toggleAudienceAssist(true);
        await sessionManager.handleSpectatorRequest('spectator_1');

        await sessionManager.approveSpectator('spectator_1');

        // Verify rejection notification was sent due to error
        verify(mockNotificationService.notifySpectatorRejected(
          'spectator_1',
          any,
          'Exception: Connection failed',
        )).called(1);
      });
    });

    group('Spectator Removal', () {
      test('should remove spectator from session and screen sharing', () async {
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );
        await sessionManager.toggleAudienceAssist(true);
        await sessionManager.handleSpectatorRequest('spectator_1');
        await sessionManager.approveSpectator('spectator_1');

        await sessionManager.removeSpectator('spectator_1');

        // Verify spectator was removed from screen sharing
        verify(mockScreenSharingService.removeParticipant('spectator_1')).called(1);

        // Verify disconnection notification was sent
        verify(mockNotificationService.notifySpectatorDisconnected('spectator_1', any)).called(1);

        // Verify participant was removed from session
        final session = sessionManager.currentSession!;
        expect(session.participants.any((p) => p.id == 'spectator_1'), isFalse);
      });
    });

    group('Session State Management', () {
      test('should maintain audience assist state across session updates', () async {
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );

        // Initially disabled
        expect(sessionManager.isAudienceAssistEnabled, isFalse);

        // Enable and verify state
        await sessionManager.toggleAudienceAssist(true);
        expect(sessionManager.isAudienceAssistEnabled, isTrue);
        expect(sessionManager.currentSession?.privacy.audienceAssistEnabled, isTrue);

        // Disable and verify state
        await sessionManager.toggleAudienceAssist(false);
        expect(sessionManager.isAudienceAssistEnabled, isFalse);
        expect(sessionManager.currentSession?.privacy.audienceAssistEnabled, isFalse);
      });

      test('should clear audience assist state on session end', () async {
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );
        await sessionManager.toggleAudienceAssist(true);
        await sessionManager.handleSpectatorRequest('spectator_1');

        await sessionManager.leaveSession();

        expect(sessionManager.isAudienceAssistEnabled, isFalse);
        expect(sessionManager.currentSession, isNull);
        
        final spectatorRequests = await sessionManager.onSpectatorRequests.first;
        expect(spectatorRequests, isEmpty);
      });
    });

    group('Stream Events', () {
      test('should emit audience assist changes', () async {
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );

        final audienceAssistStream = sessionManager.onAudienceAssistChanged;
        
        expectLater(audienceAssistStream, emitsInOrder([true, false]));

        await sessionManager.toggleAudienceAssist(true);
        await sessionManager.toggleAudienceAssist(false);
      });

      test('should emit spectator request changes', () async {
        await sessionManager.createSession(
          type: SessionType.privateGroup,
          invitedParticipants: [],
        );
        await sessionManager.toggleAudienceAssist(true);

        final spectatorRequestStream = sessionManager.onSpectatorRequests;
        
        expectLater(spectatorRequestStream, emitsInOrder([
          ['spectator_1'],
          ['spectator_1', 'spectator_2'],
          ['spectator_2'], // After approving spectator_1
          [], // After rejecting spectator_2
        ]));

        await sessionManager.handleSpectatorRequest('spectator_1');
        await sessionManager.handleSpectatorRequest('spectator_2');
        await sessionManager.approveSpectator('spectator_1');
        await sessionManager.rejectSpectator('spectator_2');
      });
    });
  });
}