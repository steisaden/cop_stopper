import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

/// BLoC for managing navigation state and tab switching
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState.initial()) {
    on<NavigationTabChanged>(_onNavigationTabChanged);
    on<RecordingStarted>(_onRecordingStarted);
    on<RecordingStopped>(_onRecordingStopped);
    on<NavigateToTab>(_onNavigateToTab);
  }

  /// Handle tab change events from user interaction
  void _onNavigationTabChanged(
    NavigationTabChanged event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(activeTab: event.tab));
  }

  /// Handle recording started event
  void _onRecordingStarted(
    RecordingStarted event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(isRecording: true));
  }

  /// Handle recording stopped event
  void _onRecordingStopped(
    RecordingStopped event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(isRecording: false));
  }

  /// Handle programmatic navigation
  void _onNavigateToTab(
    NavigateToTab event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(activeTab: event.tab));
  }
}