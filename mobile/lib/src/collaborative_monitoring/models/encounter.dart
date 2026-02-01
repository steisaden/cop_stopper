class Encounter {
  final String id;
  final String? location;
  final DateTime timestamp;
  final String description;
  final String outcome;

  Encounter({
    required this.id,
    this.location,
    required this.timestamp,
    required this.description,
    required this.outcome,
  });
}
