import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/service_locator.dart';
import 'transcription_event.dart';
import 'transcription_state.dart';

/// BLoC for managing transcription functionality
class TranscriptionBloc extends Bloc<TranscriptionEvent, TranscriptionState> {
  final TranscriptionServiceInterface _transcriptionService;
  
  StreamSubscription<dynamic>? _transcriptionSubscription;

  TranscriptionBloc()
      : _transcriptionService = locator<TranscriptionServiceInterface>(),
        super(const TranscriptionState.initial()) {
    
    // Register event handlers
    on<WhisperInitializeRequested>(_onWhisperInitializeRequested);
    on<TranscriptionStartRequested>(_onTranscriptionStartRequested);
    on<TranscriptionStopRequested>(_onTranscriptionStopRequested);
    on<TranscriptionSegmentReceived>(_onTranscriptionSegmentReceived);
    on<TranscriptionCleared>(_onTranscriptionCleared);
    on<TranscriptionErrorOccurred>(_onTranscriptionErrorOccurred);

    // Listen to transcription stream
    _transcriptionSubscription = _transcriptionService.transcriptionStream.listen(
      (segment) => add(TranscriptionSegmentReceived(segment)),
      onError: (error) => add(TranscriptionErrorOccurred(error.toString())),
    );
  }

  /// Handle Whisper initialization
  Future<void> _onWhisperInitializeRequested(
    WhisperInitializeRequested event,
    Emitter<TranscriptionState> emit,
  ) async {
    try {
      emit(state.copyWith(status: TranscriptionStatus.initializing));

      await _transcriptionService.initializeWhisper();

      emit(state.copyWith(
        status: TranscriptionStatus.ready,
        isWhisperReady: true,
        clearError: true,
      ));

    } catch (e) {
      emit(state.copyWith(
        status: TranscriptionStatus.error,
        errorMessage: 'Failed to initialize Whisper: ${e.toString()}',
      ));
    }
  }

  /// Handle transcription start
  Future<void> _onTranscriptionStartRequested(
    TranscriptionStartRequested event,
    Emitter<TranscriptionState> emit,
  ) async {
    try {
      // Initialize Whisper if not ready
      if (!state.isWhisperReady) {
        emit(state.copyWith(status: TranscriptionStatus.initializing));
        await _transcriptionService.initializeWhisper();
      }

      emit(state.copyWith(
        status: TranscriptionStatus.listening,
        isListening: true,
        currentSessionId: event.sessionId,
        clearError: true,
      ));

      await _transcriptionService.startTranscription(event.sessionId);

    } catch (e) {
      emit(state.copyWith(
        status: TranscriptionStatus.error,
        isListening: false,
        errorMessage: 'Failed to start transcription: ${e.toString()}',
      ));
    }
  }

  /// Handle transcription stop
  Future<void> _onTranscriptionStopRequested(
    TranscriptionStopRequested event,
    Emitter<TranscriptionState> emit,
  ) async {
    try {
      await _transcriptionService.stopTranscription();

      emit(state.copyWith(
        status: TranscriptionStatus.stopped,
        isListening: false,
        currentSessionId: null,
      ));

    } catch (e) {
      emit(state.copyWith(
        status: TranscriptionStatus.error,
        errorMessage: 'Failed to stop transcription: ${e.toString()}',
      ));
    }
  }

  /// Handle new transcription segment
  void _onTranscriptionSegmentReceived(
    TranscriptionSegmentReceived event,
    Emitter<TranscriptionState> emit,
  ) {
    final updatedSegments = List<TranscriptionSegment>.from(state.segments)..add(event.segment);
    
    emit(state.copyWith(
      segments: updatedSegments,
      lastSegmentTime: event.segment.timestamp,
      status: TranscriptionStatus.listening, // Keep listening status
    ));
  }

  /// Handle transcription clear
  void _onTranscriptionCleared(
    TranscriptionCleared event,
    Emitter<TranscriptionState> emit,
  ) {
    emit(state.copyWith(segments: []));
  }

  /// Handle transcription error
  void _onTranscriptionErrorOccurred(
    TranscriptionErrorOccurred event,
    Emitter<TranscriptionState> emit,
  ) {
    emit(state.copyWith(
      status: TranscriptionStatus.error,
      errorMessage: event.error,
    ));
  }

  @override
  Future<void> close() async {
    await _transcriptionSubscription?.cancel();
    _transcriptionService.dispose();
    return super.close();
  }
}