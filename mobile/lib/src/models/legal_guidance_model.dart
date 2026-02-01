/// Model representing a legal guidance item
class LegalGuidanceItem {
  final String id;
  final String title;
  final String content;
  final String jurisdiction;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double relevanceScore;
  final String? scenario;
  final List<String> citations;

  const LegalGuidanceItem({
    required this.id,
    required this.title,
    required this.content,
    required this.jurisdiction,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    required this.relevanceScore,
    this.scenario,
    this.citations = const [],
  });

  factory LegalGuidanceItem.fromJson(Map<String, dynamic> json) {
    return LegalGuidanceItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      jurisdiction: json['jurisdiction'] as String,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => tag as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      relevanceScore: (json['relevance_score'] as num?)?.toDouble() ?? 0.0,
      scenario: json['scenario'] as String?,
      citations: (json['citations'] as List<dynamic>?)
              ?.map((citation) => citation as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'jurisdiction': jurisdiction,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'relevance_score': relevanceScore,
      'scenario': scenario,
      'citations': citations,
    };
  }

  LegalGuidanceItem copyWith({
    String? id,
    String? title,
    String? content,
    String? jurisdiction,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? relevanceScore,
    String? scenario,
    List<String>? citations,
  }) {
    return LegalGuidanceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      scenario: scenario ?? this.scenario,
      citations: citations ?? this.citations,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LegalGuidanceItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LegalGuidanceItem(id: $id, title: $title, jurisdiction: $jurisdiction)';
  }
}