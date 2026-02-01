class Document {
  final String id;
  final String title;
  final String filePath;
  final DateTime uploadDate;
  final DateTime? expirationDate;
  final String? description;

  Document({
    required this.id,
    required this.title,
    required this.filePath,
    required this.uploadDate,
    this.expirationDate,
    this.description,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['filePath'] as String,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'] as String)
          : null,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'filePath': filePath,
      'uploadDate': uploadDate.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'description': description,
    };
  }

  void validate() {
    if (title.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    if (filePath.isEmpty) {
      throw ArgumentError('File path cannot be empty');
    }
  }
}