enum ConfidenceLevel {
  low,
  medium,
  high,
  verified,
}

class FactCheckEntry {
  final String id;
  final String sessionId;
  final String participantId;
  final String claim;
  final String verification;
  final List<String> sources;
  final ConfidenceLevel confidence;
  final DateTime timestamp;
  final List<String> supportingParticipants;
  final Map<String, dynamic>? metadata;

  const FactCheckEntry({
    required this.id,
    required this.sessionId,
    required this.participantId,
    required this.claim,
    required this.verification,
    required this.sources,
    required this.confidence,
    required this.timestamp,
    this.supportingParticipants = const [],
    this.metadata,
  });

  FactCheckEntry copyWith({
    String? id,
    String? sessionId,
    String? participantId,
    String? claim,
    String? verification,
    List<String>? sources,
    ConfidenceLevel? confidence,
    DateTime? timestamp,
    List<String>? supportingParticipants,
    Map<String, dynamic>? metadata,
  }) {
    return FactCheckEntry(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      participantId: participantId ?? this.participantId,
      claim: claim ?? this.claim,
      verification: verification ?? this.verification,
      sources: sources ?? this.sources,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      supportingParticipants: supportingParticipants ?? this.supportingParticipants,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'participantId': participantId,
      'claim': claim,
      'verification': verification,
      'sources': sources,
      'confidence': confidence.toString(),
      'timestamp': timestamp.toIso8601String(),
      'supportingParticipants': supportingParticipants,
      'metadata': metadata,
    };
  }

  factory FactCheckEntry.fromJson(Map<String, dynamic> json) {
    return FactCheckEntry(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      participantId: json['participantId'] as String,
      claim: json['claim'] as String,
      verification: json['verification'] as String,
      sources: (json['sources'] as List<dynamic>).cast<String>(),
      confidence: ConfidenceLevel.values.firstWhere(
        (e) => e.toString() == json['confidence'],
        orElse: () => ConfidenceLevel.medium,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      supportingParticipants: (json['supportingParticipants'] as List<dynamic>?)?.cast<String>() ?? [],
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  bool get isVerified => confidence == ConfidenceLevel.verified;
  bool get hasMultipleSupport => supportingParticipants.length > 1;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FactCheckEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FactCheckEntry(id: $id, claim: $claim, confidence: $confidence)';
  }
}
