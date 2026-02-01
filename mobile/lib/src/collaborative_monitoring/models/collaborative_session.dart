import 'package:meta/meta.dart';
import 'package:mobile/src/collaborative_monitoring/models/participant.dart';
import 'package:mobile/src/collaborative_monitoring/models/privacy_settings.dart';
import 'package:mobile/src/collaborative_monitoring/models/session_type.dart';
import 'package:mobile/src/collaborative_monitoring/models/fact_check_entry.dart';
import 'package:mobile/src/collaborative_monitoring/models/emergency_event.dart';

enum SessionStatus {
  initializing,
  active,
  paused,
  ended,
}

class GeoLocation {
  final double latitude;
  final double longitude;
  final String? address;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String?,
    );
  }
}

class CollaborativeSession {
  final String id;
  final String broadcasterId;
  final SessionType type;
  final List<Participant> participants;
  final GeoLocation? location;
  final DateTime startTime;
  final DateTime? endTime;
  final SessionStatus status;
  final PrivacySettings privacy;
  final List<FactCheckEntry> factChecks;
  final List<EmergencyEvent> emergencyEvents;

  const CollaborativeSession({
    required this.id,
    required this.broadcasterId,
    required this.type,
    required this.participants,
    this.location,
    required this.startTime,
    this.endTime,
    required this.status,
    required this.privacy,
    required this.factChecks,
    required this.emergencyEvents,
  });

  CollaborativeSession copyWith({
    String? id,
    String? broadcasterId,
    SessionType? type,
    List<Participant>? participants,
    GeoLocation? location,
    DateTime? startTime,
    DateTime? endTime,
    SessionStatus? status,
    PrivacySettings? privacy,
    List<FactCheckEntry>? factChecks,
    List<EmergencyEvent>? emergencyEvents,
  }) {
    return CollaborativeSession(
      id: id ?? this.id,
      broadcasterId: broadcasterId ?? this.broadcasterId,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      privacy: privacy ?? this.privacy,
      factChecks: factChecks ?? this.factChecks,
      emergencyEvents: emergencyEvents ?? this.emergencyEvents,
    );
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isActive => status == SessionStatus.active;
  bool get hasEnded => status == SessionStatus.ended;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'broadcasterId': broadcasterId,
      'type': type.toString(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'location': location?.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status.toString(),
      'privacy': privacy.toJson(),
      'factChecks': factChecks.map((f) => f.toJson()).toList(),
      'emergencyEvents': emergencyEvents.map((e) => e.toJson()).toList(),
    };
  }

  factory CollaborativeSession.fromJson(Map<String, dynamic> json) {
    return CollaborativeSession(
      id: json['id'] as String,
      broadcasterId: json['broadcasterId'] as String,
      type: SessionType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SessionType.privateGroup,
      ),
      participants: (json['participants'] as List<dynamic>)
          .map((p) => Participant.fromJson(p as Map<String, dynamic>))
          .toList(),
      location: json['location'] != null
          ? GeoLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      status: SessionStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => SessionStatus.initializing,
      ),
      privacy: PrivacySettings.fromJson(json['privacy'] as Map<String, dynamic>),
      factChecks: (json['factChecks'] as List<dynamic>)
          .map((f) => FactCheckEntry.fromJson(f as Map<String, dynamic>))
          .toList(),
      emergencyEvents: (json['emergencyEvents'] as List<dynamic>)
          .map((e) => EmergencyEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CollaborativeSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CollaborativeSession(id: $id, type: $type, status: $status, participants: ${participants.length})';
  }
}
