/// Represents the result of a fact-checking operation
class FactCheckResult {
  final String id;
  final String claim;
  final String segmentId; // Links to TranscriptionSegment
  final FactCheckStatus status;
  final double confidence;
  final String? explanation;
  final List<String> sources;
  final DateTime timestamp;
  final String? jurisdiction;

  const FactCheckResult({
    required this.id,
    required this.claim,
    required this.segmentId,
    required this.status,
    required this.confidence,
    this.explanation,
    required this.sources,
    required this.timestamp,
    this.jurisdiction,
  });

  factory FactCheckResult.fromJson(Map<String, dynamic> json) {
    return FactCheckResult(
      id: json['id'] as String,
      claim: json['claim'] as String,
      segmentId: json['segmentId'] as String,
      status: FactCheckStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => FactCheckStatus.unknown,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      explanation: json['explanation'] as String?,
      sources: List<String>.from(json['sources'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
      jurisdiction: json['jurisdiction'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'claim': claim,
      'segmentId': segmentId,
      'status': status.name,
      'confidence': confidence,
      'explanation': explanation,
      'sources': sources,
      'timestamp': timestamp.toIso8601String(),
      'jurisdiction': jurisdiction,
    };
  }

  FactCheckResult copyWith({
    String? id,
    String? claim,
    String? segmentId,
    FactCheckStatus? status,
    double? confidence,
    String? explanation,
    List<String>? sources,
    DateTime? timestamp,
    String? jurisdiction,
  }) {
    return FactCheckResult(
      id: id ?? this.id,
      claim: claim ?? this.claim,
      segmentId: segmentId ?? this.segmentId,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      explanation: explanation ?? this.explanation,
      sources: sources ?? this.sources,
      timestamp: timestamp ?? this.timestamp,
      jurisdiction: jurisdiction ?? this.jurisdiction,
    );
  }

  /// Get status color for UI display
  String get statusColor {
    switch (status) {
      case FactCheckStatus.verified:
        return '#4CAF50'; // Green
      case FactCheckStatus.disputed:
        return '#FF9800'; // Orange
      case FactCheckStatus.false_claim:
        return '#F44336'; // Red
      case FactCheckStatus.unverifiable:
        return '#9E9E9E'; // Grey
      case FactCheckStatus.unknown:
        return '#607D8B'; // Blue Grey
    }
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case FactCheckStatus.verified:
        return 'Verified';
      case FactCheckStatus.disputed:
        return 'Disputed';
      case FactCheckStatus.false_claim:
        return 'False';
      case FactCheckStatus.unverifiable:
        return 'Unverifiable';
      case FactCheckStatus.unknown:
        return 'Unknown';
    }
  }

  /// Get confidence level as descriptive text
  String get confidenceLevel {
    if (confidence >= 0.9) return 'Very High';
    if (confidence >= 0.7) return 'High';
    if (confidence >= 0.5) return 'Medium';
    if (confidence >= 0.3) return 'Low';
    return 'Very Low';
  }

  /// Check if this result requires attention
  bool get requiresAttention {
    return status == FactCheckStatus.disputed || 
           status == FactCheckStatus.false_claim ||
           (status == FactCheckStatus.verified && confidence < 0.7);
  }

  void validate() {
    if (claim.isEmpty) {
      throw ArgumentError('Claim cannot be empty');
    }
    if (confidence < 0 || confidence > 1) {
      throw ArgumentError('Confidence must be between 0 and 1');
    }
    if (segmentId.isEmpty) {
      throw ArgumentError('Segment ID cannot be empty');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FactCheckResult &&
        other.id == id &&
        other.claim == claim &&
        other.segmentId == segmentId &&
        other.status == status &&
        other.confidence == confidence &&
        other.explanation == explanation &&
        other.sources.length == sources.length &&
        other.timestamp == timestamp &&
        other.jurisdiction == jurisdiction;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      claim,
      segmentId,
      status,
      confidence,
      explanation,
      sources.length,
      timestamp,
      jurisdiction,
    );
  }

  @override
  String toString() {
    return 'FactCheckResult(id: $id, claim: $claim, status: $status, confidence: $confidence)';
  }
}

/// Status of a fact-check result
enum FactCheckStatus {
  verified,      // Claim is verified as true
  disputed,      // Claim is questionable or partially true
  false_claim,   // Claim is verified as false
  unverifiable,  // Cannot be verified with available sources
  unknown,       // Status not yet determined
}

/// Legal alert for rights violations or procedural issues
class LegalAlert {
  final String id;
  final String segmentId;
  final LegalAlertType type;
  final String title;
  final String description;
  final String suggestedResponse;
  final LegalAlertSeverity severity;
  final List<String> relevantLaws;
  final String? jurisdiction;
  final DateTime timestamp;

  const LegalAlert({
    required this.id,
    required this.segmentId,
    required this.type,
    required this.title,
    required this.description,
    required this.suggestedResponse,
    required this.severity,
    required this.relevantLaws,
    this.jurisdiction,
    required this.timestamp,
  });

  factory LegalAlert.fromJson(Map<String, dynamic> json) {
    return LegalAlert(
      id: json['id'] as String,
      segmentId: json['segmentId'] as String,
      type: LegalAlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LegalAlertType.other,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      suggestedResponse: json['suggestedResponse'] as String,
      severity: LegalAlertSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => LegalAlertSeverity.medium,
      ),
      relevantLaws: List<String>.from(json['relevantLaws'] as List),
      jurisdiction: json['jurisdiction'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'segmentId': segmentId,
      'type': type.name,
      'title': title,
      'description': description,
      'suggestedResponse': suggestedResponse,
      'severity': severity.name,
      'relevantLaws': relevantLaws,
      'jurisdiction': jurisdiction,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Get severity color for UI display
  String get severityColor {
    switch (severity) {
      case LegalAlertSeverity.low:
        return '#4CAF50'; // Green
      case LegalAlertSeverity.medium:
        return '#FF9800'; // Orange
      case LegalAlertSeverity.high:
        return '#F44336'; // Red
      case LegalAlertSeverity.critical:
        return '#D32F2F'; // Dark Red
    }
  }

  /// Get type icon for UI display
  String get typeIcon {
    switch (type) {
      case LegalAlertType.rightsViolation:
        return 'warning';
      case LegalAlertType.proceduralError:
        return 'error';
      case LegalAlertType.illegalSearch:
        return 'search_off';
      case LegalAlertType.mirandaRights:
        return 'record_voice_over';
      case LegalAlertType.excessiveForce:
        return 'report_problem';
      case LegalAlertType.other:
        return 'info';
    }
  }

  void validate() {
    if (title.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    if (description.isEmpty) {
      throw ArgumentError('Description cannot be empty');
    }
    if (suggestedResponse.isEmpty) {
      throw ArgumentError('Suggested response cannot be empty');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LegalAlert &&
        other.id == id &&
        other.segmentId == segmentId &&
        other.type == type &&
        other.title == title &&
        other.description == description &&
        other.suggestedResponse == suggestedResponse &&
        other.severity == severity &&
        other.relevantLaws.length == relevantLaws.length &&
        other.jurisdiction == jurisdiction &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      segmentId,
      type,
      title,
      description,
      suggestedResponse,
      severity,
      relevantLaws.length,
      jurisdiction,
      timestamp,
    );
  }

  @override
  String toString() {
    return 'LegalAlert(id: $id, type: $type, severity: $severity, title: $title)';
  }
}

/// Types of legal alerts
enum LegalAlertType {
  rightsViolation,
  proceduralError,
  illegalSearch,
  mirandaRights,
  excessiveForce,
  other,
}

/// Severity levels for legal alerts
enum LegalAlertSeverity {
  low,
  medium,
  high,
  critical,
}