class LegalAdvice {
  final String id;
  final String jurisdiction;
  final String adviceText;
  final List<String> relevantStatutes;
  final DateTime timestamp;

  LegalAdvice({
    required this.id,
    required this.jurisdiction,
    required this.adviceText,
    required this.relevantStatutes,
    required this.timestamp,
  });

  factory LegalAdvice.fromJson(Map<String, dynamic> json) {
    return LegalAdvice(
      id: json['id'] as String,
      jurisdiction: json['jurisdiction'] as String,
      adviceText: json['adviceText'] as String,
      relevantStatutes: List<String>.from(json['relevantStatutes'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jurisdiction': jurisdiction,
      'adviceText': adviceText,
      'relevantStatutes': relevantStatutes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  void validate() {
    if (jurisdiction.isEmpty) {
      throw ArgumentError('Jurisdiction cannot be empty');
    }
    if (adviceText.isEmpty) {
      throw ArgumentError('Advice text cannot be empty');
    }
  }
}