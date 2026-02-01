enum CareerEventType {
  hired,
  promoted,
  transferred,
  suspended,
  terminated,
  resigned,
  retired,
  employmentGap,
  disciplinaryAction,
  commendation,
  training,
}

class CareerTimelineEvent {
  final DateTime date;
  final String eventType;
  final String description;
  final String? department;
  final String? jurisdiction;
  final Map<String, dynamic>? metadata;

  const CareerTimelineEvent({
    required this.date,
    required this.eventType,
    required this.description,
    this.department,
    this.jurisdiction,
    this.metadata,
  });

  CareerTimelineEvent copyWith({
    DateTime? date,
    String? eventType,
    String? description,
    String? department,
    String? jurisdiction,
    Map<String, dynamic>? metadata,
  }) {
    return CareerTimelineEvent(
      date: date ?? this.date,
      eventType: eventType ?? this.eventType,
      description: description ?? this.description,
      department: department ?? this.department,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isEmploymentGap => eventType == 'employment_gap';
  bool get isDisciplinaryAction => eventType == 'disciplinary_action';
  bool get isPositive => eventType == 'promoted' || eventType == 'commendation' || eventType == 'hired';
  bool get isNegative => eventType == 'suspended' || eventType == 'terminated' || eventType == 'disciplinary_action';

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'eventType': eventType,
      'description': description,
      'department': department,
      'jurisdiction': jurisdiction,
      'metadata': metadata,
    };
  }

  factory CareerTimelineEvent.fromJson(Map<String, dynamic> json) {
    return CareerTimelineEvent(
      date: DateTime.parse(json['date'] as String),
      eventType: json['eventType'] as String,
      description: json['description'] as String,
      department: json['department'] as String?,
      jurisdiction: json['jurisdiction'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CareerTimelineEvent &&
        other.date == date &&
        other.eventType == eventType &&
        other.description == description;
  }

  @override
  int get hashCode => Object.hash(date, eventType, description);

  @override
  String toString() {
    return 'CareerTimelineEvent(date: $date, type: $eventType, description: $description)';
  }
}

class CareerTimeline {
  final List<CareerTimelineEvent> events;

  const CareerTimeline({
    required this.events,
  });

  CareerTimeline copyWith({
    List<CareerTimelineEvent>? events,
  }) {
    return CareerTimeline(
      events: events ?? this.events,
    );
  }

  List<CareerTimelineEvent> get chronologicalEvents {
    final sortedEvents = List<CareerTimelineEvent>.from(events);
    sortedEvents.sort((a, b) => a.date.compareTo(b.date));
    return sortedEvents;
  }

  List<CareerTimelineEvent> get employmentGaps {
    return events.where((event) => event.isEmploymentGap).toList();
  }

  List<CareerTimelineEvent> get disciplinaryEvents {
    return events.where((event) => event.isDisciplinaryAction).toList();
  }

  List<CareerTimelineEvent> get positiveEvents {
    return events.where((event) => event.isPositive).toList();
  }

  List<CareerTimelineEvent> get negativeEvents {
    return events.where((event) => event.isNegative).toList();
  }

  List<String> get departments {
    return events
        .where((event) => event.department != null)
        .map((event) => event.department!)
        .toSet()
        .toList();
  }

  List<String> get jurisdictions {
    return events
        .where((event) => event.jurisdiction != null)
        .map((event) => event.jurisdiction!)
        .toSet()
        .toList();
  }

  Duration get totalCareerLength {
    if (events.isEmpty) return Duration.zero;
    
    final sortedEvents = chronologicalEvents;
    final firstEvent = sortedEvents.first;
    final lastEvent = sortedEvents.last;
    
    return lastEvent.date.difference(firstEvent.date);
  }

  int get totalEmploymentGaps {
    return employmentGaps.length;
  }

  Duration get totalGapDuration {
    Duration total = Duration.zero;
    
    for (final gap in employmentGaps) {
      // Extract gap duration from metadata if available
      final gapDays = gap.metadata?['gapDays'] as int? ?? 0;
      total += Duration(days: gapDays);
    }
    
    return total;
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => e.toJson()).toList(),
    };
  }

  factory CareerTimeline.fromJson(Map<String, dynamic> json) {
    return CareerTimeline(
      events: (json['events'] as List<dynamic>)
          .map((e) => CareerTimelineEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CareerTimeline && 
        other.events.length == events.length &&
        other.events.every((event) => events.contains(event));
  }

  @override
  int get hashCode => events.hashCode;

  @override
  String toString() {
    return 'CareerTimeline(events: ${events.length}, departments: ${departments.length})';
  }
}
