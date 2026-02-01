class DisciplinaryAction {
  final String id;
  final DateTime date;
  final String description;
  final String outcome;
  final String actionType;
  final DateTime actionDate;

  DisciplinaryAction({
    required this.id,
    required this.date,
    required this.description,
    required this.outcome,
    required this.actionType,
    required this.actionDate,
  });

  factory DisciplinaryAction.fromJson(Map<String, dynamic> json) {
    return DisciplinaryAction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      outcome: json['outcome'] as String,
      actionType: json['actionType'] as String,
      actionDate: DateTime.parse(json['actionDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'outcome': outcome,
      'actionType': actionType,
      'actionDate': actionDate.toIso8601String(),
    };
  }
}
