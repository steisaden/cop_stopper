enum RecordingFileType {
  audio,
  video,
  audioVideo,
}

class Recording {
  final String id;
  final String filePath;
  final DateTime timestamp;
  final int durationSeconds;
  final String? transcriptionId; // Link to TranscriptionResult
  final RecordingFileType fileType;
  final String? transcriptionFilePath;
  final int transcriptionSegmentCount;
  final bool hasTranscription;
  final bool isFlagged;

  Recording({
    required this.id,
    required this.filePath,
    required this.timestamp,
    required this.durationSeconds,
    required this.fileType,
    this.transcriptionId,
    this.transcriptionFilePath,
    this.transcriptionSegmentCount = 0,
    this.hasTranscription = false,
    this.isFlagged = false,
  });

  factory Recording.fromJson(Map<String, dynamic> json) {
    return Recording(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationSeconds: json['durationSeconds'] as int,
      fileType: RecordingFileType.values.firstWhere(
          (e) => e.toString() == 'RecordingFileType.${json['fileType']}'),
      transcriptionId: json['transcriptionId'] as String?,
      transcriptionFilePath: json['transcriptionFilePath'] as String?,
      transcriptionSegmentCount: json['transcriptionSegmentCount'] as int? ?? 0,
      hasTranscription: json['hasTranscription'] as bool? ?? false,
      isFlagged: json['isFlagged'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': durationSeconds,
      'fileType': fileType.toString().split('.').last,
      'transcriptionId': transcriptionId,
      'transcriptionFilePath': transcriptionFilePath,
      'transcriptionSegmentCount': transcriptionSegmentCount,
      'hasTranscription': hasTranscription,
      'isFlagged': isFlagged,
    };
  }

  // Basic validation
  void validate() {
    if (filePath.isEmpty) {
      throw ArgumentError('File path cannot be empty');
    }
    if (durationSeconds <= 0) {
      throw ArgumentError('Duration must be positive');
    }
  }
}
