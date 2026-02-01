import 'dart:async';
import 'dart:math';

import 'package:mobile/src/collaborative_monitoring/models/emergency_event.dart';
import 'package:mobile/src/collaborative_monitoring/models/participant.dart';
import 'package:mobile/src/services/emergency_contact_service.dart';
import 'package:mobile/src/services/notification_service.dart';

class EmergencyEscalationConfig {
  final int consensusThreshold; // Minimum participants needed for consensus
  final double consensusPercentage; // Percentage of participants needed to agree
  final Duration unresponsiveTimeout; // Time before considering broadcaster unresponsive
  final Duration escalationDelay; // Delay before automatic escalation
  final bool enableAudioAnalysis; // Whether to use audio analysis for emergency detection
  final bool enableLocationAnalysis; // Whether to use location-based emergency detection

  const EmergencyEscalationConfig({
    this.consensusThreshold = 2,
    this.consensusPercentage = 0.6, // 60%
    this.unresponsiveTimeout = const Duration(minutes: 2),
    this.escalationDelay = const Duration(seconds: 30),
    this.enableAudioAnalysis = true,
    this.enableLocationAnalysis = true,
  });
}

class EmergencyEscalationService {
  final EmergencyContactService _emergencyContactService;
  final NotificationService _notificationService;
  final EmergencyEscalationConfig _config;

  final Map<String, EmergencyEvent> _activeEmergencies = {};
  final Map<String, Timer> _escalationTimers = {};
  final Map<String, Timer> _unresponsiveTimers = {};
  final Map<String, DateTime> _lastBroadcasterActivity = {};

  final _emergencyEventsController = StreamController<EmergencyEvent>.broadcast();
  final _consensusUpdatesController = StreamController<Map<String, dynamic>>.broadcast();

  EmergencyEscalationService(
    this._emergencyContactService,
    this._notificationService, {
    EmergencyEscalationConfig? config,
  }) : _config = config ?? const EmergencyEscalationConfig();

  Stream<EmergencyEvent> get onEmergencyEvent => _emergencyEventsController.stream;
  Stream<Map<String, dynamic>> get onConsensusUpdate => _consensusUpdatesController.stream;

  Future<EmergencyEvent> reportEmergency({
    required String sessionId,
    required String participantId,
    required EmergencyType type,
    required String reason,
    EmergencySeverity? severity,
    Map<String, dynamic>? evidence,
    Map<String, dynamic>? location,
  }) async {
    final trigger = EmergencyTrigger(
      participantId: participantId,
      type: type,
      reason: reason,
      timestamp: DateTime.now(),
      evidence: evidence,
    );

    // Check if there's already an active emergency for this session
    final existingEmergency = _activeEmergencies[sessionId];
    
    if (existingEmergency != null) {
      // Add trigger to existing emergency
      final updatedEmergency = existingEmergency.copyWith(
        triggers: [...existingEmergency.triggers, trigger],
      );
      
      _activeEmergencies[sessionId] = updatedEmergency;
      _emergencyEventsController.add(updatedEmergency);
      
      // Check if consensus is reached
      await _checkConsensus(sessionId, updatedEmergency);
      
      return updatedEmergency;
    } else {
      // Create new emergency event
      final emergency = EmergencyEvent(
        id: _generateEmergencyId(),
        sessionId: sessionId,
        type: type,
        status: EmergencyStatus.pending,
        severity: severity ?? _calculateSeverity(type, evidence),
        timestamp: DateTime.now(),
        description: reason,
        triggers: [trigger],
        responses: [],
        location: location,
      );

      _activeEmergencies[sessionId] = emergency;
      _emergencyEventsController.add(emergency);

      // Start escalation timer for non-consensus emergencies
      if (type != EmergencyType.consensusBased) {
        await _startEscalationTimer(sessionId, emergency);
      } else {
        // For consensus-based emergencies, check if we have enough triggers
        await _checkConsensus(sessionId, emergency);
      }

      return emergency;
    }
  }

  Future<void> reportConsensusEmergency({
    required String sessionId,
    required List<Participant> participants,
    required String participantId,
    required String reason,
    Map<String, dynamic>? evidence,
    Map<String, dynamic>? location,
  }) async {
    await reportEmergency(
      sessionId: sessionId,
      participantId: participantId,
      type: EmergencyType.consensusBased,
      reason: reason,
      severity: EmergencySeverity.high,
      evidence: evidence,
      location: location,
    );

    // Update consensus tracking
    _consensusUpdatesController.add({
      'sessionId': sessionId,
      'participantId': participantId,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> reportUnresponsiveBroadcaster({
    required String sessionId,
    required String broadcasterId,
    required Duration unresponsiveDuration,
    Map<String, dynamic>? location,
  }) async {
    await reportEmergency(
      sessionId: sessionId,
      participantId: 'system',
      type: EmergencyType.unresponsiveBroadcaster,
      reason: 'Broadcaster has been unresponsive for ${unresponsiveDuration.inMinutes} minutes',
      severity: EmergencySeverity.critical,
      evidence: {
        'broadcasterId': broadcasterId,
        'unresponsiveDuration': unresponsiveDuration.inSeconds,
        'lastActivity': _lastBroadcasterActivity[sessionId]?.toIso8601String(),
      },
      location: location,
    );
  }

  void trackBroadcasterActivity(String sessionId) {
    _lastBroadcasterActivity[sessionId] = DateTime.now();
    
    // Reset unresponsive timer
    _unresponsiveTimers[sessionId]?.cancel();
    _unresponsiveTimers[sessionId] = Timer(_config.unresponsiveTimeout, () {
      reportUnresponsiveBroadcaster(
        sessionId: sessionId,
        broadcasterId: 'current_user', // Would come from session
        unresponsiveDuration: _config.unresponsiveTimeout,
      );
    });
  }

  Future<void> resolveEmergency(String sessionId, String reason) async {
    final emergency = _activeEmergencies[sessionId];
    if (emergency == null) return;

    final resolvedEmergency = emergency.copyWith(
      status: EmergencyStatus.resolved,
      resolvedAt: DateTime.now(),
      description: '${emergency.description} - Resolved: $reason',
    );

    _activeEmergencies.remove(sessionId);
    _escalationTimers[sessionId]?.cancel();
    _escalationTimers.remove(sessionId);
    _unresponsiveTimers[sessionId]?.cancel();
    _unresponsiveTimers.remove(sessionId);

    _emergencyEventsController.add(resolvedEmergency);

    // Notify all emergency contacts that situation is resolved
    await _notifyEmergencyResolution(resolvedEmergency);
  }

  Future<void> markFalseAlarm(String sessionId, String reason) async {
    final emergency = _activeEmergencies[sessionId];
    if (emergency == null) return;

    final falseAlarmEmergency = emergency.copyWith(
      status: EmergencyStatus.falseAlarm,
      resolvedAt: DateTime.now(),
      description: '${emergency.description} - False Alarm: $reason',
    );

    _activeEmergencies.remove(sessionId);
    _escalationTimers[sessionId]?.cancel();
    _escalationTimers.remove(sessionId);
    _unresponsiveTimers[sessionId]?.cancel();
    _unresponsiveTimers.remove(sessionId);

    _emergencyEventsController.add(falseAlarmEmergency);
  }

  Future<void> _checkConsensus(String sessionId, EmergencyEvent emergency) async {
    if (emergency.type != EmergencyType.consensusBased) return;

    // Get the current participant count from the session
    final totalParticipants = _getCurrentParticipantCount();
    final triggerCount = emergency.triggers.length;
    
    final hasMinimumTriggers = triggerCount >= _config.consensusThreshold;
    final hasPercentageConsensus = triggerCount >= (totalParticipants * _config.consensusPercentage);

    if (hasMinimumTriggers && hasPercentageConsensus) {
      // Consensus reached - escalate immediately
      await _escalateEmergency(sessionId, emergency);
    }
  }

  Future<void> _startEscalationTimer(String sessionId, EmergencyEvent emergency) async {
    _escalationTimers[sessionId] = Timer(_config.escalationDelay, () async {
      await _escalateEmergency(sessionId, emergency);
    });
  }

  Future<void> _escalateEmergency(String sessionId, EmergencyEvent emergency) async {
    final escalatedEmergency = emergency.copyWith(
      status: EmergencyStatus.escalated,
    );

    _activeEmergencies[sessionId] = escalatedEmergency;
    _emergencyEventsController.add(escalatedEmergency);

    // Contact emergency services and emergency contacts
    final responses = <EmergencyResponse>[];

    try {
      // Contact emergency services (911)
      if (emergency.severity == EmergencySeverity.critical || 
          emergency.type == EmergencyType.unresponsiveBroadcaster) {
        final emergencyServiceResponse = await _contactEmergencyServices(emergency);
        responses.add(emergencyServiceResponse);
      }

      // Contact user's emergency contacts
      final emergencyContactResponses = await _contactEmergencyContacts(emergency);
      responses.addAll(emergencyContactResponses);

      // Contact legal aid if appropriate
      if (emergency.type != EmergencyType.unresponsiveBroadcaster) {
        final legalAidResponse = await _contactLegalAid(emergency);
        if (legalAidResponse != null) {
          responses.add(legalAidResponse);
        }
      }

      // Update emergency with responses
      final finalEmergency = escalatedEmergency.copyWith(
        responses: [...escalatedEmergency.responses, ...responses],
      );

      _activeEmergencies[sessionId] = finalEmergency;
      _emergencyEventsController.add(finalEmergency);

    } catch (e) {
      print('Error during emergency escalation: $e');
      // Continue with escalation even if some contacts fail
    }
  }

  Future<EmergencyResponse> _contactEmergencyServices(EmergencyEvent emergency) async {
    final response = EmergencyResponse(
      id: _generateResponseId(),
      contactType: 'emergency_services',
      contactInfo: '911',
      contactedAt: DateTime.now(),
    );

    // In a real implementation, this would integrate with emergency services APIs
    // or use SMS/voice calling services
    print('Contacting emergency services for emergency ${emergency.id}');
    
    return response;
  }

  Future<List<EmergencyResponse>> _contactEmergencyContacts(EmergencyEvent emergency) async {
    final responses = <EmergencyResponse>[];
    
    try {
      final contacts = await _emergencyContactService.getEmergencyContacts();
      
      for (final contact in contacts) {
        final response = EmergencyResponse(
          id: _generateResponseId(),
          contactType: 'emergency_contact',
          contactInfo: contact.phoneNumber,
          contactedAt: DateTime.now(),
        );
        
        // Send emergency notification
        await _notificationService.sendEmergencyNotification(
          'EMERGENCY: Police interaction assistance needed. Location: ${emergency.location?['address'] ?? 'Unknown'}. Reason: ${emergency.description}'
        );
        
        responses.add(response);
      }
    } catch (e) {
      print('Error contacting emergency contacts: $e');
    }
    
    return responses;
  }

  Future<EmergencyResponse?> _contactLegalAid(EmergencyEvent emergency) async {
    try {
      // In a real implementation, this would contact legal aid organizations
      // based on the user's location and the type of emergency
      
      final response = EmergencyResponse(
        id: _generateResponseId(),
        contactType: 'legal_aid',
        contactInfo: 'ACLU Hotline',
        contactedAt: DateTime.now(),
      );
      
      print('Contacting legal aid for emergency ${emergency.id}');
      
      return response;
    } catch (e) {
      print('Error contacting legal aid: $e');
      return null;
    }
  }

  Future<void> _notifyEmergencyResolution(EmergencyEvent emergency) async {
    // Notify all contacts that the emergency has been resolved
    for (final response in emergency.responses) {
      try {
        await _notificationService.sendEmergencyNotification(
          'RESOLVED: Police interaction emergency has been resolved. Session ID: ${emergency.sessionId}'
        );
      } catch (e) {
        print('Error notifying emergency resolution: $e');
      }
    }
  }

  EmergencySeverity _calculateSeverity(EmergencyType type, Map<String, dynamic>? evidence) {
    switch (type) {
      case EmergencyType.unresponsiveBroadcaster:
        return EmergencySeverity.critical;
      case EmergencyType.consensusBased:
        return EmergencySeverity.high;
      case EmergencyType.audioAnalysis:
        // In a real implementation, this would analyze audio evidence
        return EmergencySeverity.medium;
      case EmergencyType.locationBased:
        // In a real implementation, this would analyze location risk factors
        return EmergencySeverity.medium;
      case EmergencyType.manualTrigger:
      case EmergencyType.participantReport:
      default:
        return EmergencySeverity.high;
    }
  }

  String _generateEmergencyId() {
    return 'emergency_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _generateResponseId() {
    return 'response_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  int _getCurrentParticipantCount() {
    // In a real implementation, this would get the count from the session manager
    // For now, return a default value
    return 3;
  }

  void cleanupSession(String sessionId) {
    _activeEmergencies.remove(sessionId);
    _escalationTimers[sessionId]?.cancel();
    _escalationTimers.remove(sessionId);
    _unresponsiveTimers[sessionId]?.cancel();
    _unresponsiveTimers.remove(sessionId);
    _lastBroadcasterActivity.remove(sessionId);
  }

  void dispose() {
    _emergencyEventsController.close();
    _consensusUpdatesController.close();
    
    for (final timer in _escalationTimers.values) {
      timer.cancel();
    }
    for (final timer in _unresponsiveTimers.values) {
      timer.cancel();
    }
    
    _escalationTimers.clear();
    _unresponsiveTimers.clear();
    _activeEmergencies.clear();
    _lastBroadcasterActivity.clear();
  }
}