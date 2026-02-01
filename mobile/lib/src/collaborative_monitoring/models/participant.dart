enum ParticipantRole {
  broadcaster,
  groupMember,
  spectator,
}

enum ConnectionStatus {
  connecting,
  connected,
  disconnected,
  reconnecting,
}

class Participant {
  final String id;
  final String? name;
  final ParticipantRole role;
  final ConnectionStatus connectionStatus;
  final DateTime joinedAt;
  final DateTime? lastSeen;
  final Map<String, dynamic>? metadata;

  const Participant({
    required this.id,
    this.name,
    required this.role,
    required this.connectionStatus,
    required this.joinedAt,
    this.lastSeen,
    this.metadata,
  });

  Participant copyWith({
    String? id,
    String? name,
    ParticipantRole? role,
    ConnectionStatus? connectionStatus,
    DateTime? joinedAt,
    DateTime? lastSeen,
    Map<String, dynamic>? metadata,
  }) {
    return Participant(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      joinedAt: joinedAt ?? this.joinedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.toString(),
      'connectionStatus': connectionStatus.toString(),
      'joinedAt': joinedAt.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as String,
      name: json['name'] as String?,
      role: ParticipantRole.values.firstWhere(
        (e) => e.toString() == json['role'],
        orElse: () => ParticipantRole.spectator,
      ),
      connectionStatus: ConnectionStatus.values.firstWhere(
        (e) => e.toString() == json['connectionStatus'],
        orElse: () => ConnectionStatus.disconnected,
      ),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastSeen: json['lastSeen'] != null 
          ? DateTime.parse(json['lastSeen'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Participant && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Participant(id: $id, name: $name, role: $role, status: $connectionStatus)';
  }
}
