/// Model representing a segment of transcription with speaker identification
class TranscriptionSegment {
  final String id;
  final String text;
  final DateTime timestamp;
  final double confidence;
  final String? speakerId;
  final String? speakerLabel;
  final Duration startTime;
  final Duration endTime;
  final bool isComplete;

  const TranscriptionSegment({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.confidence,
    this.speakerId,
    this.speakerLabel,
    required this.startTime,
    required this.endTime,
    this.isComplete = true,
  });

  factory TranscriptionSegment.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegment(
      id: json['id'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      confidence: (json['confidence'] as num).toDouble(),
      speakerId: json['speakerId'] as String?,
      speakerLabel: json['speakerLabel'] as String?,
      startTime: Duration(milliseconds: json['startTimeMs'] as int),
      endTime: Duration(milliseconds: json['endTimeMs'] as int),
      isComplete: json['isComplete'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'confidence': confidence,
      'speakerId': speakerId,
      'speakerLabel': speakerLabel,
      'startTimeMs': startTime.inMilliseconds,
      'endTimeMs': endTime.inMilliseconds,
      'isComplete': isComplete,
    };
  }

  TranscriptionSegment copyWith({
    String? id,
    String? text,
    DateTime? timestamp,
    double? confidence,
    String? speakerId,
    String? speakerLabel,
    Duration? startTime,
    Duration? endTime,
    bool? isComplete,
  }) {
    return TranscriptionSegment(
      id: id ?? this.id,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      confidence: confidence ?? this.confidence,
      speakerId: speakerId ?? this.speakerId,
      speakerLabel: speakerLabel ?? this.speakerLabel,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  /// Get confidence level as a descriptive string
  String get confidenceLevel {
    if (confidence >= 0.9) return 'High';
    if (confidence >= 0.7) return 'Medium';
    if (confidence >= 0.5) return 'Low';
    return 'Very Low';
  }

  /// Get speaker display name with fallback
  String get displaySpeaker {
    if (speakerLabel != null && speakerLabel!.isNotEmpty) {
      return speakerLabel!;
    }
    if (speakerId != null && speakerId!.isNotEmpty) {
      return 'Speaker ${speakerId!}';
    }
    return 'Unknown Speaker';
  }

  /// Get formatted timestamp for display
  String get formattedTime {
    final minutes = startTime.inMinutes;
    final seconds = (startTime.inSeconds % 60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void validate() {
    if (text.isEmpty) {
      throw ArgumentError('Transcription text cannot be empty');
    }
    if (confidence < 0 || confidence > 1) {
      throw ArgumentError('Confidence must be between 0 and 1');
    }
    if (startTime > endTime) {
      throw ArgumentError('Start time cannot be after end time');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TranscriptionSegment &&
        other.id == id &&
        other.text == text &&
        other.timestamp == timestamp &&
        other.confidence == confidence &&
        other.speakerId == speakerId &&
        other.speakerLabel == speakerLabel &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.isComplete == isComplete;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      text,
      timestamp,
      confidence,
      speakerId,
      speakerLabel,
      startTime,
      endTime,
      isComplete,
    );
  }

  @override
  String toString() {
    return 'TranscriptionSegment(id: $id, text: $text, speaker: $displaySpeaker, confidence: $confidence)';
  }
}