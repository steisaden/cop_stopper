import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:mobile/src/collaborative_monitoring/models/collaborative_session.dart';
import 'package:mobile/src/collaborative_monitoring/models/participant.dart';
import 'package:mobile/src/collaborative_monitoring/models/session_type.dart';
import 'package:mobile/src/collaborative_monitoring/models/privacy_settings.dart';
import 'package:mobile/src/collaborative_monitoring/models/fact_check_entry.dart';
import 'package:mobile/src/collaborative_monitoring/interfaces/screen_sharing_service.dart';
import 'package:mobile/src/services/notification_service.dart';
import 'package:mobile/src/collaborative_monitoring/services/real_time_collaboration_service.dart';
import 'package:mobile/src/collaborative_monitoring/services/emergency_escalation_service.dart';
import 'package:mobile/src/collaborative_monitoring/models/emergency_event.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';

class CollaborativeSessionManager {
  final ScreenSharingService _screenSharingService;
  final NotificationService _notificationService;
  final RealTimeCollaborationService _collaborationService;
  final EmergencyEscalationService _emergencyService;
  final TranscriptionServiceInterface _transcriptionService;
  
  CollaborativeSession? _session;
  bool _audienceAssistEnabled = false;
  final List<String> _spectatorQueue = [];
  
  final _sessionController = StreamController<CollaborativeSession?>.broadcast();
  final _audienceAssistController = StreamController<bool>.broadcast();
  final _spectatorRequestController = StreamController<List<String>>.broadcast();

  CollaborativeSessionManager(
    this._screenSharingService,
    this._notificationService,
    this._collaborationService,
    this._emergencyService,
    this._transcriptionService,
  ) {
    // Listen to transcription segments and forward them to collaboration service
    _transcriptionService.transcriptionStream.listen((segment) {
      _handleTranscriptionSegment(segment);
    });
  }

  Stream<CollaborativeSession?> get onSessionChanged => _sessionController.stream;
  Stream<bool> get onAudienceAssistChanged => _audienceAssistController.stream;
  Stream<List<String>> get onSpectatorRequests => _spectatorRequestController.stream;
  
  // Real-time collaboration streams
  Stream<CollaborationEvent> get onCollaborationEvent => _collaborationService.onCollaborationEvent;
  Stream<List<AggregatedFactCheck>> get onFactChecksUpdated => _collaborationService.onFactChecksUpdated;
  Stream<List<Participant>> get onParticipantsUpdated => _collaborationService.onParticipantsUpdated;
  
  // Emergency escalation streams
  Stream<EmergencyEvent> get onEmergencyEvent => _emergencyService.onEmergencyEvent;
  Stream<Map<String, dynamic>> get onConsensusUpdate => _emergencyService.onConsensusUpdate;

  bool get isAudienceAssistEnabled => _audienceAssistEnabled;
  CollaborativeSession? get currentSession => _session;

  Future<CollaborativeSession> createSession({
    required SessionType type,
    required List<String> invitedParticipants,
    PrivacySettings? privacySettings,
  }) async {
    final session = CollaborativeSession(
      id: _generateSessionId(),
      broadcasterId: 'current_user', // Would come from auth service
      type: type,
      participants: [],
      location: null, // Would come from location service
      startTime: DateTime.now(),
      status: SessionStatus.active,
      privacy: privacySettings ?? PrivacySettings.defaultSettings(),
      factChecks: [],
      emergencyEvents: [],
    );

    _session = session;
    _sessionController.add(_session);

    // Start screen sharing
    await _screenSharingService.startScreenSharing();

    // Connect to real-time collaboration
    await _collaborationService.connectToSession(session.id, 'current_user');

    // Start tracking broadcaster activity for emergency detection
    _emergencyService.trackBroadcasterActivity(session.id);

    // Invite participants for private group sessions
    if (type == SessionType.privateGroup && invitedParticipants.isNotEmpty) {
      await _inviteParticipants(invitedParticipants);
    }

    return session;
  }

  Future<void> toggleAudienceAssist(bool enabled) async {
    if (_session == null) {
      throw Exception('No active session');
    }

    _audienceAssistEnabled = enabled;
    _audienceAssistController.add(enabled);

    // Update screen sharing service
    await _screenSharingService.toggleAudienceAssist(enabled);

    if (enabled) {
      // Notify nearby spectators about the available session
      await _notificationService.broadcastSpectatorOpportunity(_session!);
    } else {
      // Clear spectator queue and notify disconnected spectators
      final disconnectedSpectators = List<String>.from(_spectatorQueue);
      _spectatorQueue.clear();
      _spectatorRequestController.add([]);
      
      for (final spectatorId in disconnectedSpectators) {
        await _notificationService.notifySpectatorDisconnected(spectatorId, _session!.id);
      }
    }

    // Update session
    _session = _session!.copyWith(
      privacy: _session!.privacy.copyWith(audienceAssistEnabled: enabled),
    );
    _sessionController.add(_session);
  }

  Future<void> handleSpectatorRequest(String spectatorId) async {
    if (!_audienceAssistEnabled || _session == null) {
      return;
    }

    // Add to queue if not already present
    if (!_spectatorQueue.contains(spectatorId)) {
      _spectatorQueue.add(spectatorId);
      _spectatorRequestController.add(List.from(_spectatorQueue));
    }
  }

  Future<void> approveSpectator(String spectatorId) async {
    if (!_spectatorQueue.contains(spectatorId) || _session == null) {
      return;
    }

    try {
      // Add participant to screen sharing
      await _screenSharingService.addParticipant(spectatorId);

      // Remove from queue
      _spectatorQueue.remove(spectatorId);
      _spectatorRequestController.add(List.from(_spectatorQueue));

      // Add to session participants
      final participant = Participant(
        id: spectatorId,
        role: ParticipantRole.spectator,
        connectionStatus: ConnectionStatus.connecting,
        joinedAt: DateTime.now(),
      );

      _session = _session!.copyWith(
        participants: [..._session!.participants, participant],
      );
      _sessionController.add(_session);

      // Notify spectator of approval
      await _notificationService.notifySpectatorApproved(spectatorId, _session!.id);
    } catch (e) {
      // Handle error - maybe session is full or other issue
      await _notificationService.notifySpectatorRejected(spectatorId, _session!.id, e.toString());
    }
  }

  Future<void> rejectSpectator(String spectatorId) async {
    if (!_spectatorQueue.contains(spectatorId)) {
      return;
    }

    _spectatorQueue.remove(spectatorId);
    _spectatorRequestController.add(List.from(_spectatorQueue));

    await _notificationService.notifySpectatorRejected(spectatorId, _session?.id ?? '', 'Request rejected by broadcaster');
  }

  Future<void> removeSpectator(String spectatorId) async {
    if (_session == null) return;

    // Remove from screen sharing
    await _screenSharingService.removeParticipant(spectatorId);

    // Remove from session participants
    _session = _session!.copyWith(
      participants: _session!.participants.where((p) => p.id != spectatorId).toList(),
    );
    _sessionController.add(_session);

    // Notify spectator of removal
    await _notificationService.notifySpectatorDisconnected(spectatorId, _session!.id);
  }

  Future<void> joinSession(String sessionId) async {
    // Join an existing session through the collaboration service
    try {
      // For now, create a mock session since joinSession method doesn't exist
      _session = CollaborativeSession(
        id: sessionId,
        broadcasterId: 'other_user',
        type: SessionType.spectator,
        participants: [],
        location: null,
        startTime: DateTime.now(),
        status: SessionStatus.active,
        privacy: PrivacySettings.defaultSettings(),
        factChecks: [],
        emergencyEvents: [],
      );

      _sessionController.add(_session);
    } catch (e) {
      debugPrint('Error joining session: $e');
    }
  }

  Future<void> leaveSession() async {
    if (_session == null) return;

    // Stop screen sharing if we're the broadcaster
    if (_session!.broadcasterId == 'current_user') {
      await _screenSharingService.stopScreenSharing();
      
      // Notify all participants
      for (final participant in _session!.participants) {
        await _notificationService.notifySessionEnded(participant.id, _session!.id);
      }
    }

    // Disconnect from real-time collaboration
    await _collaborationService.disconnect();

    // Clean up emergency service
    if (_session != null) {
      _emergencyService.cleanupSession(_session!.id);
    }

    // Clear session state
    _session = null;
    _audienceAssistEnabled = false;
    _spectatorQueue.clear();
    
    _sessionController.add(null);
    _audienceAssistController.add(false);
    _spectatorRequestController.add([]);
  }

  Future<void> triggerEmergencyEscalation({String? reason}) async {
    if (_session == null) return;

    // Trigger emergency through emergency escalation service
    await _emergencyService.reportEmergency(
      sessionId: _session!.id,
      participantId: 'current_user',
      type: EmergencyType.manualTrigger,
      reason: reason ?? 'Manual emergency trigger by broadcaster',
      severity: EmergencySeverity.high,
      location: _session!.location?.toJson(),
    );

    // Also trigger through real-time collaboration
    await _collaborationService.reportEmergency({
      'type': 'manual_trigger',
      'location': _session!.location?.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
      'reason': reason,
    });

    // Send notifications
    await _notificationService.sendEmergencyAlert(_session!);
  }

  Future<void> reportEmergencyByParticipant({
    required String participantId,
    required String reason,
    EmergencySeverity? severity,
    Map<String, dynamic>? evidence,
  }) async {
    if (_session == null) return;

    await _emergencyService.reportEmergency(
      sessionId: _session!.id,
      participantId: participantId,
      type: EmergencyType.participantReport,
      reason: reason,
      severity: severity ?? EmergencySeverity.medium,
      evidence: evidence,
      location: _session!.location?.toJson(),
    );
  }

  Future<void> triggerConsensusEmergency({
    required String participantId,
    required String reason,
    Map<String, dynamic>? evidence,
  }) async {
    if (_session == null) return;

    await _emergencyService.reportConsensusEmergency(
      sessionId: _session!.id,
      participants: _session!.participants,
      participantId: participantId,
      reason: reason,
      evidence: evidence,
      location: _session!.location?.toJson(),
    );
  }

  Future<void> resolveEmergency(String reason) async {
    if (_session == null) return;

    await _emergencyService.resolveEmergency(_session!.id, reason);
  }

  Future<void> markEmergencyFalseAlarm(String reason) async {
    if (_session == null) return;

    await _emergencyService.markFalseAlarm(_session!.id, reason);
  }

  void updateBroadcasterActivity() {
    if (_session == null) return;
    
    _emergencyService.trackBroadcasterActivity(_session!.id);
  }

  // Real-time collaboration methods
  Future<void> submitFactCheck({
    required String claim,
    required String verification,
    required List<String> sources,
    required ConfidenceLevel confidence,
    Map<String, dynamic>? metadata,
  }) async {
    if (_session == null) {
      throw Exception('No active session');
    }

    final factCheck = FactCheckEntry(
      id: _generateFactCheckId(),
      sessionId: _session!.id,
      participantId: 'current_user', // Would come from auth service
      claim: claim,
      verification: verification,
      sources: sources,
      confidence: confidence,
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    await _collaborationService.submitFactCheck(factCheck);

    // Update local session
    _session = _session!.copyWith(
      factChecks: [..._session!.factChecks, factCheck],
    );
    _sessionController.add(_session);
  }

  Future<void> updateTranscription(String transcriptionSegment) async {
    if (_session == null) return;
    
    await _collaborationService.updateTranscription(transcriptionSegment);
  }

  /// Handle transcription segment from transcription service
  void _handleTranscriptionSegment(TranscriptionSegment segment) async {
    if (_session == null) return;
    
    // Forward to collaboration service for real-time sharing
    await _collaborationService.updateTranscription(segment.text);
    
    // Submit to backend for persistence
    await _transcriptionService.submitTranscriptionSegment(segment);
  }

  /// Start transcription for the current session
  Future<void> startTranscription() async {
    if (_session == null) return;
    
    // Initialize Whisper if not already done
    if (!_transcriptionService.isWhisperReady) {
      try {
        await _transcriptionService.initializeWhisper();
      } catch (e) {
        print('Failed to initialize Whisper: $e');
        // Continue without Whisper - could fall back to cloud API
      }
    }
    
    await _transcriptionService.startTranscription(_session!.id);
  }

  /// Stop transcription
  Future<void> stopTranscription() async {
    await _transcriptionService.stopTranscription();
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    if (_session == null) return;
    
    await _collaborationService.updateLocation(latitude, longitude);
    
    // Update local session
    final newLocation = GeoLocation(
      latitude: latitude,
      longitude: longitude,
    );
    
    _session = _session!.copyWith(location: newLocation);
    _sessionController.add(_session);
  }

  Future<void> supportFactCheck(String factCheckId) async {
    if (_session == null) return;

    // In a real implementation, this would send support for a fact check
    // through the collaboration service
    print('Supporting fact check: $factCheckId');
  }

  Future<void> disputeFactCheck(String factCheckId, String reason) async {
    if (_session == null) return;

    // In a real implementation, this would send a dispute for a fact check
    // through the collaboration service
    print('Disputing fact check: $factCheckId, reason: $reason');
  }

  Future<void> _inviteParticipants(List<String> participantIds) async {
    if (_session == null) return;

    for (final participantId in participantIds) {
      await _notificationService.sendGroupInvitation(participantId, _session!);
    }
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateFactCheckId() {
    return 'fact_check_${DateTime.now().millisecondsSinceEpoch}';
  }

  void dispose() {
    _sessionController.close();
    _audienceAssistController.close();
    _spectatorRequestController.close();
    _collaborationService.dispose();
    _emergencyService.dispose();
    _transcriptionService.dispose();
  }
}
