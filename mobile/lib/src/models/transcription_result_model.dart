class TranscriptionResult {
  final String id;
  final String recordingId; // Link to Recording
  final String transcriptionText;
  final DateTime timestamp;
  final double confidence;

  TranscriptionResult({
    required this.id,
    required this.recordingId,
    required this.transcriptionText,
    required this.timestamp,
    required this.confidence,
  });

  factory TranscriptionResult.fromJson(Map<String, dynamic> json) {
    return TranscriptionResult(
      id: json['id'] as String,
      recordingId: json['recordingId'] as String,
      transcriptionText: json['transcriptionText'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidence: json['confidence'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordingId': recordingId,
      'transcriptionText': transcriptionText,
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
    };
  }

  void validate() {
    if (transcriptionText.isEmpty) {
      throw ArgumentError('Transcription text cannot be empty');
    }
    if (confidence < 0 || confidence > 1) {
      throw ArgumentError('Confidence must be between 0 and 1');
    }
  }
}