class Commendation {
  final String id;
  final DateTime date;
  final String description;
  final String type;
  final DateTime dateAwarded;

  Commendation({
    required this.id,
    required this.date,
    required this.description,
    required this.type,
    required this.dateAwarded,
  });

  factory Commendation.fromJson(Map<String, dynamic> json) {
    return Commendation(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      type: json['type'] as String,
      dateAwarded: DateTime.parse(json['dateAwarded'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'type': type,
      'dateAwarded': dateAwarded.toIso8601String(),
    };
  }
}
