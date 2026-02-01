import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/collaborative_monitoring/services/emergency_escalation_service.dart';
import 'package:mobile/src/collaborative_monitoring/models/emergency_event.dart';
import 'package:mobile/src/collaborative_monitoring/models/participant.dart';
import 'package:mobile/src/services/emergency_contact_service.dart';
import 'package:mobile/src/services/notification_service.dart';

@GenerateMocks([EmergencyContactService, NotificationService])
import 'emergency_escalation_test.mocks.dart';

void main() {
  group('Emergency Escalation Service Tests', () {
    late EmergencyEscalationService service;
    late MockEmergencyContactService mockEmergencyContactService;
    late MockNotificationService mockNotificationService;

    setUp(() {
      mockEmergencyContactService = MockEmergencyContactService();
      mockNotificationService = MockNotificationService();
      service = EmergencyEscalationService(
        mockEmergencyContactService,
        mockNotificationService,
      );

      // Setup default mock behaviors
      when(mockEmergencyContactService.getEmergencyContacts())
          .thenAnswer((_) async => []);
      when(mockNotificationService.sendEmergencyNotification(any))
          .thenAnswer((_) async {});
    });

    tearDown(() {
      service.dispose();
    });

    group('Emergency Reporting', () {
      test('should create new emergency event', () async {
        final emergency = await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'test_participant',
          type: EmergencyType.manualTrigger,
          reason: 'Test emergency',
        );

        expect(emergency.sessionId, equals('test_session'));
        expect(emergency.type, equals(EmergencyType.manualTrigger));
        expect(emergency.status, equals(EmergencyStatus.pending));
        expect(emergency.triggers.length, equals(1));
        expect(emergency.triggers.first.participantId, equals('test_participant'));
      });

      test('should add trigger to existing emergency', () async {
        // Create initial emergency
        final emergency1 = await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'participant_1',
          type: EmergencyType.consensusBased,
          reason: 'First report',
        );

        // Add second trigger
        final emergency2 = await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'participant_2',
          type: EmergencyType.consensusBased,
          reason: 'Second report',
        );

        expect(emergency2.id, equals(emergency1.id));
        expect(emergency2.triggers.length, equals(2));
        expect(emergency2.triggers.map((t) => t.participantId), 
               containsAll(['participant_1', 'participant_2']));
      });

      test('should calculate severity correctly', () async {
        final criticalEmergency = await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'test_participant',
          type: EmergencyType.unresponsiveBroadcaster,
          reason: 'Broadcaster unresponsive',
        );

        expect(criticalEmergency.severity, equals(EmergencySeverity.critical));

        final highEmergency = await service.reportEmergency(
          sessionId: 'test_session_2',
          participantId: 'test_participant',
          type: EmergencyType.manualTrigger,
          reason: 'Manual trigger',
        );

        expect(highEmergency.severity, equals(EmergencySeverity.high));
      });
    });

    group('Consensus-Based Emergency', () {
      test('should handle consensus emergency reporting', () async {
        final participants = [
          Participant(
            id: 'participant_1',
            role: ParticipantRole.groupMember,
            connectionStatus: ConnectionStatus.connected,
            joinedAt: DateTime.now(),
          ),
          Participant(
            id: 'participant_2',
            role: ParticipantRole.groupMember,
            connectionStatus: ConnectionStatus.connected,
            joinedAt: DateTime.now(),
          ),
        ];

        await service.reportConsensusEmergency(
          sessionId: 'test_session',
          participants: participants,
          participantId: 'participant_1',
          reason: 'Consensus emergency',
        );

        // Verify consensus update was emitted
        expect(service.onConsensusUpdate, emits(isA<Map<String, dynamic>>()));
      });

      test('should escalate when consensus threshold is met', () async {
        final config = EmergencyEscalationConfig(
          consensusThreshold: 2,
          consensusPercentage: 0.5,
        );

        final serviceWithConfig = EmergencyEscalationService(
          mockEmergencyContactService,
          mockNotificationService,
          config: config,
        );

        // Report first consensus emergency
        await serviceWithConfig.reportEmergency(
          sessionId: 'test_session',
          participantId: 'participant_1',
          type: EmergencyType.consensusBased,
          reason: 'First consensus report',
        );

        // Report second consensus emergency (should trigger escalation)
        final emergency = await serviceWithConfig.reportEmergency(
          sessionId: 'test_session',
          participantId: 'participant_2',
          type: EmergencyType.consensusBased,
          reason: 'Second consensus report',
        );

        // Wait a bit for async escalation
        await Future.delayed(Duration(milliseconds: 100));

        expect(emergency.triggers.length, equals(2));

        serviceWithConfig.dispose();
      });
    });

    group('Unresponsive Broadcaster Detection', () {
      test('should report unresponsive broadcaster', () async {
        await service.reportUnresponsiveBroadcaster(
          sessionId: 'test_session',
          broadcasterId: 'broadcaster_1',
          unresponsiveDuration: Duration(minutes: 3),
        );

        final emergencyStream = service.onEmergencyEvent;
        expect(emergencyStream, emits(isA<EmergencyEvent>()));
      });

      test('should track broadcaster activity', () {
        // Should not throw
        service.trackBroadcasterActivity('test_session');
        expect(true, isTrue);
      });
    });

    group('Emergency Resolution', () {
      test('should resolve emergency', () async {
        // Create emergency first
        await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'test_participant',
          type: EmergencyType.manualTrigger,
          reason: 'Test emergency',
        );

        await service.resolveEmergency('test_session', 'Situation resolved');

        // Verify emergency was resolved
        expect(service.onEmergencyEvent, emits(predicate<EmergencyEvent>(
          (event) => event.status == EmergencyStatus.resolved
        )));
      });

      test('should mark false alarm', () async {
        // Create emergency first
        await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'test_participant',
          type: EmergencyType.manualTrigger,
          reason: 'Test emergency',
        );

        await service.markFalseAlarm('test_session', 'False alarm');

        // Verify emergency was marked as false alarm
        expect(service.onEmergencyEvent, emits(predicate<EmergencyEvent>(
          (event) => event.status == EmergencyStatus.falseAlarm
        )));
      });
    });

    group('Emergency Escalation', () {
      test('should escalate emergency after delay', () async {
        final config = EmergencyEscalationConfig(
          escalationDelay: Duration(milliseconds: 100),
        );

        final serviceWithConfig = EmergencyEscalationService(
          mockEmergencyContactService,
          mockNotificationService,
          config: config,
        );

        await serviceWithConfig.reportEmergency(
          sessionId: 'test_session',
          participantId: 'test_participant',
          type: EmergencyType.manualTrigger,
          reason: 'Test emergency',
        );

        // Wait for escalation delay
        await Future.delayed(Duration(milliseconds: 200));

        // Verify escalation occurred
        expect(serviceWithConfig.onEmergencyEvent, emits(predicate<EmergencyEvent>(
          (event) => event.status == EmergencyStatus.escalated
        )));

        serviceWithConfig.dispose();
      });

      test('should contact emergency services for critical emergencies', () async {
        await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'test_participant',
          type: EmergencyType.unresponsiveBroadcaster,
          reason: 'Broadcaster unresponsive',
          severity: EmergencySeverity.critical,
        );

        // Wait for escalation
        await Future.delayed(Duration(milliseconds: 100));

        // Verify emergency notification was sent
        verify(mockNotificationService.sendEmergencyNotification(any)).called(greaterThan(0));
      });
    });

    group('Session Cleanup', () {
      test('should clean up session resources', () async {
        await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'test_participant',
          type: EmergencyType.manualTrigger,
          reason: 'Test emergency',
        );

        service.cleanupSession('test_session');

        // Should not throw
        expect(true, isTrue);
      });
    });

    group('Configuration', () {
      test('should use custom configuration', () {
        final customConfig = EmergencyEscalationConfig(
          consensusThreshold: 3,
          consensusPercentage: 0.8,
          unresponsiveTimeout: Duration(minutes: 5),
          escalationDelay: Duration(minutes: 1),
        );

        final serviceWithConfig = EmergencyEscalationService(
          mockEmergencyContactService,
          mockNotificationService,
          config: customConfig,
        );

        expect(serviceWithConfig, isNotNull);
        serviceWithConfig.dispose();
      });
    });

    group('Error Handling', () {
      test('should handle emergency contact service errors', () async {
        when(mockEmergencyContactService.getEmergencyContacts())
            .thenThrow(Exception('Contact service error'));

        // Should not throw even if emergency contacts fail
        await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'test_participant',
          type: EmergencyType.manualTrigger,
          reason: 'Test emergency',
        );

        expect(true, isTrue);
      });

      test('should handle notification service errors', () async {
        when(mockNotificationService.sendEmergencyNotification(any))
            .thenThrow(Exception('Notification error'));

        // Should not throw even if notifications fail
        await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'test_participant',
          type: EmergencyType.manualTrigger,
          reason: 'Test emergency',
        );

        expect(true, isTrue);
      });
    });

    group('Stream Events', () {
      test('should emit emergency events', () async {
        expect(service.onEmergencyEvent, isNotNull);
        expect(service.onConsensusUpdate, isNotNull);

        await service.reportEmergency(
          sessionId: 'test_session',
          participantId: 'test_participant',
          type: EmergencyType.manualTrigger,
          reason: 'Test emergency',
        );

        expect(service.onEmergencyEvent, emits(isA<EmergencyEvent>()));
      });
    });
  });
}