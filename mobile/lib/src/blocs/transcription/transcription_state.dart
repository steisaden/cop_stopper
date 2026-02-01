import 'package:equatable/equatable.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';

/// Transcription status enumeration
enum TranscriptionStatus {
  initial,
  initializing,
  ready,
  listening,
  processing,
  error,
  stopped,
}

/// State for transcription functionality
class TranscriptionState extends Equatable {
  final TranscriptionStatus status;
  final List<TranscriptionSegment> segments;
  final bool isListening;
  final bool isWhisperReady;
  final String? currentSessionId;
  final String? errorMessage;
  final DateTime? lastSegmentTime;

  const TranscriptionState({
    this.status = TranscriptionStatus.initial,
    this.segments = const [],
    this.isListening = false,
    this.isWhisperReady = false,
    this.currentSessionId,
    this.errorMessage,
    this.lastSegmentTime,
  });

  /// Initial state
  const TranscriptionState.initial() : this();

  /// Copy with method for state updates
  TranscriptionState copyWith({
    TranscriptionStatus? status,
    List<TranscriptionSegment>? segments,
    bool? isListening,
    bool? isWhisperReady,
    String? currentSessionId,
    String? errorMessage,
    DateTime? lastSegmentTime,
    bool clearError = false,
  }) {
    return TranscriptionState(
      status: status ?? this.status,
      segments: segments ?? this.segments,
      isListening: isListening ?? this.isListening,
      isWhisperReady: isWhisperReady ?? this.isWhisperReady,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastSegmentTime: lastSegmentTime ?? this.lastSegmentTime,
    );
  }

  /// Whether transcription is active
  bool get isActive => isListening && status == TranscriptionStatus.listening;

  /// Whether there are any transcription segments
  bool get hasSegments => segments.isNotEmpty;

  /// Get the most recent segment
  TranscriptionSegment? get latestSegment => 
      segments.isNotEmpty ? segments.last : null;

  /// Get segments from the last few minutes
  List<TranscriptionSegment> getRecentSegments([Duration? duration]) {
    final cutoff = DateTime.now().subtract(duration ?? const Duration(minutes: 5));
    return segments.where((segment) => segment.timestamp.isAfter(cutoff)).toList();
  }

  @override
  List<Object?> get props => [
        status,
        segments,
        isListening,
        isWhisperReady,
        currentSessionId,
        errorMessage,
        lastSegmentTime,
      ];
}