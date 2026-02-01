import 'package:equatable/equatable.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';

/// Base class for transcription events
abstract class TranscriptionEvent extends Equatable {
  const TranscriptionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start transcription
class TranscriptionStartRequested extends TranscriptionEvent {
  final String sessionId;
  
  const TranscriptionStartRequested(this.sessionId);
  
  @override
  List<Object?> get props => [sessionId];
}

/// Event to stop transcription
class TranscriptionStopRequested extends TranscriptionEvent {
  const TranscriptionStopRequested();
}

/// Event when a new transcription segment is received
class TranscriptionSegmentReceived extends TranscriptionEvent {
  final TranscriptionSegment segment;
  
  const TranscriptionSegmentReceived(this.segment);
  
  @override
  List<Object?> get props => [segment];
}

/// Event to clear transcription history
class TranscriptionCleared extends TranscriptionEvent {
  const TranscriptionCleared();
}

/// Event when transcription error occurs
class TranscriptionErrorOccurred extends TranscriptionEvent {
  final String error;
  
  const TranscriptionErrorOccurred(this.error);
  
  @override
  List<Object?> get props => [error];
}

/// Event to initialize Whisper model
class WhisperInitializeRequested extends TranscriptionEvent {
  const WhisperInitializeRequested();
}