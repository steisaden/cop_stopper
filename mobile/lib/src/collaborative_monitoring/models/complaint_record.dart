class ComplaintRecord {
  final String id;
  final DateTime date;
  final String description;
  final String status;
  final String caseNumber;
  final DateTime dateReported;

  ComplaintRecord({
    required this.id,
    required this.date,
    required this.description,
    required this.status,
    required this.caseNumber,
    required this.dateReported,
  });

  factory ComplaintRecord.fromJson(Map<String, dynamic> json) {
    return ComplaintRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      status: json['status'] as String,
      caseNumber: json['caseNumber'] as String,
      dateReported: DateTime.parse(json['dateReported'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'status': status,
      'caseNumber': caseNumber,
      'dateReported': dateReported.toIso8601String(),
    };
  }
}
