import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mobile/src/collaborative_monitoring/models/fact_check_entry.dart';
import 'package:mobile/src/collaborative_monitoring/models/participant.dart';
import 'package:mobile/src/collaborative_monitoring/models/collaborative_session.dart';

enum CollaborationEventType {
  participantJoined,
  participantLeft,
  factCheckSubmitted,
  factCheckAggregated,
  emergencyTriggered,
  sessionStateChanged,
  transcriptionUpdate,
  locationUpdate,
}

class CollaborationEvent {
  final CollaborationEventType type;
  final String sessionId;
  final String? participantId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const CollaborationEvent({
    required this.type,
    required this.sessionId,
    this.participantId,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'sessionId': sessionId,
      'participantId': participantId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CollaborationEvent.fromJson(Map<String, dynamic> json) {
    return CollaborationEvent(
      type: CollaborationEventType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => CollaborationEventType.sessionStateChanged,
      ),
      sessionId: json['sessionId'] as String,
      participantId: json['participantId'] as String?,
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class AggregatedFactCheck {
  final String claim;
  final List<FactCheckEntry> entries;
  final double confidenceScore;
  final String consensus;
  final List<String> sources;
  final DateTime lastUpdated;

  const AggregatedFactCheck({
    required this.claim,
    required this.entries,
    required this.confidenceScore,
    required this.consensus,
    required this.sources,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'claim': claim,
      'entries': entries.map((e) => e.toJson()).toList(),
      'confidenceScore': confidenceScore,
      'consensus': consensus,
      'sources': sources,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory AggregatedFactCheck.fromJson(Map<String, dynamic> json) {
    return AggregatedFactCheck(
      claim: json['claim'] as String,
      entries: (json['entries'] as List<dynamic>)
          .map((e) => FactCheckEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      confidenceScore: json['confidenceScore'] as double,
      consensus: json['consensus'] as String,
      sources: (json['sources'] as List<dynamic>).cast<String>(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

class RealTimeCollaborationService {
  WebSocketChannel? _channel;
  String? _currentSessionId;
  String? _currentParticipantId;
  
  final Map<String, List<FactCheckEntry>> _factChecksByTopic = {};
  final Map<String, AggregatedFactCheck> _aggregatedFactChecks = {};
  
  final _eventsController = StreamController<CollaborationEvent>.broadcast();
  final _factChecksController = StreamController<List<AggregatedFactCheck>>.broadcast();
  final _participantsController = StreamController<List<Participant>>.broadcast();
  
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  Stream<CollaborationEvent> get onCollaborationEvent => _eventsController.stream;
  Stream<List<AggregatedFactCheck>> get onFactChecksUpdated => _factChecksController.stream;
  Stream<List<Participant>> get onParticipantsUpdated => _participantsController.stream;

  Future<void> connectToSession(String sessionId, String participantId, {String? wsUrl}) async {
    _currentSessionId = sessionId;
    _currentParticipantId = participantId;
    
    final url = wsUrl ?? 'wss://api.copstopper.com/ws/collaboration/$sessionId';
    
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Send authentication message
      await _sendMessage({
        'type': 'authenticate',
        'sessionId': sessionId,
        'participantId': participantId,
      });
      
      // Listen for messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );
      
      // Start heartbeat
      _startHeartbeat();
      
      _reconnectAttempts = 0;
      
    } catch (e) {
      throw Exception('Failed to connect to collaboration session: $e');
    }
  }

  Future<void> disconnect() async {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    
    if (_channel != null) {
      await _sendMessage({
        'type': 'disconnect',
        'sessionId': _currentSessionId,
        'participantId': _currentParticipantId,
      });
      
      await _channel!.sink.close();
      _channel = null;
    }
    
    _currentSessionId = null;
    _currentParticipantId = null;
    _factChecksByTopic.clear();
    _aggregatedFactChecks.clear();
  }

  Future<void> submitFactCheck(FactCheckEntry factCheck) async {
    if (_channel == null || _currentSessionId == null) {
      throw Exception('Not connected to a collaboration session');
    }

    await _sendMessage({
      'type': 'fact_check_submission',
      'sessionId': _currentSessionId,
      'participantId': _currentParticipantId,
      'factCheck': factCheck.toJson(),
    });

    // Add to local cache for immediate UI update
    final topic = _extractTopic(factCheck.claim);
    _factChecksByTopic.putIfAbsent(topic, () => []).add(factCheck);
    
    // Trigger local aggregation
    await _aggregateFactChecks(topic);
  }

  Future<void> reportEmergency(Map<String, dynamic> emergencyData) async {
    if (_channel == null || _currentSessionId == null) {
      throw Exception('Not connected to a collaboration session');
    }

    await _sendMessage({
      'type': 'emergency_report',
      'sessionId': _currentSessionId,
      'participantId': _currentParticipantId,
      'emergencyData': emergencyData,
    });
  }

  Future<void> updateTranscription(String transcriptionSegment) async {
    if (_channel == null || _currentSessionId == null) {
      return; // Transcription updates are optional
    }

    await _sendMessage({
      'type': 'transcription_update',
      'sessionId': _currentSessionId,
      'participantId': _currentParticipantId,
      'transcription': transcriptionSegment,
    });
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    if (_channel == null || _currentSessionId == null) {
      return; // Location updates are optional
    }

    await _sendMessage({
      'type': 'location_update',
      'sessionId': _currentSessionId,
      'participantId': _currentParticipantId,
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      },
    });
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = CollaborationEvent.fromJson(data);
      
      _eventsController.add(event);
      
      switch (event.type) {
        case CollaborationEventType.factCheckSubmitted:
          _handleFactCheckSubmission(event);
          break;
        case CollaborationEventType.factCheckAggregated:
          _handleFactCheckAggregation(event);
          break;
        case CollaborationEventType.participantJoined:
        case CollaborationEventType.participantLeft:
          _handleParticipantUpdate(event);
          break;
        case CollaborationEventType.emergencyTriggered:
          _handleEmergencyTrigger(event);
          break;
        case CollaborationEventType.transcriptionUpdate:
          _handleTranscriptionUpdate(event);
          break;
        case CollaborationEventType.locationUpdate:
          _handleLocationUpdate(event);
          break;
        case CollaborationEventType.sessionStateChanged:
          _handleSessionStateChange(event);
          break;
      }
    } catch (e) {
      print('Error handling collaboration message: $e');
    }
  }

  void _handleFactCheckSubmission(CollaborationEvent event) {
    try {
      final factCheckData = event.data['factCheck'] as Map<String, dynamic>;
      final factCheck = FactCheckEntry.fromJson(factCheckData);
      
      final topic = _extractTopic(factCheck.claim);
      _factChecksByTopic.putIfAbsent(topic, () => []).add(factCheck);
      
      // Trigger aggregation
      _aggregateFactChecks(topic);
    } catch (e) {
      print('Error handling fact check submission: $e');
    }
  }

  void _handleFactCheckAggregation(CollaborationEvent event) {
    try {
      final aggregatedData = event.data['aggregatedFactCheck'] as Map<String, dynamic>;
      final aggregated = AggregatedFactCheck.fromJson(aggregatedData);
      
      _aggregatedFactChecks[aggregated.claim] = aggregated;
      _factChecksController.add(_aggregatedFactChecks.values.toList());
    } catch (e) {
      print('Error handling fact check aggregation: $e');
    }
  }

  void _handleParticipantUpdate(CollaborationEvent event) {
    try {
      final participantsData = event.data['participants'] as List<dynamic>;
      final participants = participantsData
          .map((p) => Participant.fromJson(p as Map<String, dynamic>))
          .toList();
      
      _participantsController.add(participants);
    } catch (e) {
      print('Error handling participant update: $e');
    }
  }

  void _handleEmergencyTrigger(CollaborationEvent event) {
    // Emergency events are handled by the main event stream
    // Additional emergency-specific logic could be added here
    print('Emergency triggered in session ${event.sessionId}');
  }

  void _handleTranscriptionUpdate(CollaborationEvent event) {
    // Transcription updates are handled by the main event stream
    // Additional transcription-specific logic could be added here
  }

  void _handleLocationUpdate(CollaborationEvent event) {
    // Location updates are handled by the main event stream
    // Additional location-specific logic could be added here
  }

  void _handleSessionStateChange(CollaborationEvent event) {
    // Session state changes are handled by the main event stream
    // Additional state-specific logic could be added here
  }

  void _handleError(error) {
    print('WebSocket error: $error');
    _attemptReconnection();
  }

  void _handleDisconnection() {
    print('WebSocket disconnected');
    _heartbeatTimer?.cancel();
    _attemptReconnection();
  }

  void _attemptReconnection() {
    if (_reconnectAttempts >= maxReconnectAttempts || _currentSessionId == null) {
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2); // Exponential backoff
    
    _reconnectTimer = Timer(delay, () async {
      try {
        await connectToSession(_currentSessionId!, _currentParticipantId!);
        print('Reconnected to collaboration session');
      } catch (e) {
        print('Reconnection attempt $_reconnectAttempts failed: $e');
        _attemptReconnection();
      }
    });
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_channel != null) {
        try {
          await _sendMessage({
            'type': 'heartbeat',
            'sessionId': _currentSessionId,
            'participantId': _currentParticipantId,
            'timestamp': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('Heartbeat failed: $e');
        }
      }
    });
  }

  Future<void> _sendMessage(Map<String, dynamic> message) async {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  Future<void> _aggregateFactChecks(String topic) async {
    final factChecks = _factChecksByTopic[topic] ?? [];
    if (factChecks.isEmpty) return;

    // Group by claim
    final claimGroups = <String, List<FactCheckEntry>>{};
    for (final factCheck in factChecks) {
      claimGroups.putIfAbsent(factCheck.claim, () => []).add(factCheck);
    }

    final aggregatedList = <AggregatedFactCheck>[];

    for (final entry in claimGroups.entries) {
      final claim = entry.key;
      final entries = entry.value;

      // Calculate confidence score (average of all entries)
      final avgConfidence = entries
          .map((e) => _confidenceToScore(e.confidence))
          .reduce((a, b) => a + b) / entries.length;

      // Determine consensus
      final verificationCounts = <String, int>{};
      for (final factCheck in entries) {
        verificationCounts[factCheck.verification] = 
            (verificationCounts[factCheck.verification] ?? 0) + 1;
      }
      
      final consensus = verificationCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      // Collect all sources
      final allSources = entries
          .expand((e) => e.sources)
          .toSet()
          .toList();

      final aggregated = AggregatedFactCheck(
        claim: claim,
        entries: entries,
        confidenceScore: avgConfidence,
        consensus: consensus,
        sources: allSources,
        lastUpdated: DateTime.now(),
      );

      aggregatedList.add(aggregated);
      _aggregatedFactChecks[claim] = aggregated;
    }

    _factChecksController.add(_aggregatedFactChecks.values.toList());
  }

  String _extractTopic(String claim) {
    // Simple topic extraction - in a real implementation, this could use NLP
    final words = claim.toLowerCase().split(' ');
    if (words.contains('search') || words.contains('warrant')) return 'search_rights';
    if (words.contains('arrest') || words.contains('detain')) return 'arrest_rights';
    if (words.contains('traffic') || words.contains('stop')) return 'traffic_stop';
    if (words.contains('record') || words.contains('film')) return 'recording_rights';
    return 'general';
  }

  double _confidenceToScore(ConfidenceLevel confidence) {
    switch (confidence) {
      case ConfidenceLevel.low:
        return 0.3;
      case ConfidenceLevel.medium:
        return 0.6;
      case ConfidenceLevel.high:
        return 0.9;
      case ConfidenceLevel.verified:
        return 1.0;
    }
  }

  void dispose() {
    _eventsController.close();
    _factChecksController.close();
    _participantsController.close();
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
  }
}