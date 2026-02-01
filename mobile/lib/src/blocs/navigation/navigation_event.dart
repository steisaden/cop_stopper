import 'package:equatable/equatable.dart';

/// Navigation events for managing tab switching and recording state
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when user taps on a navigation tab
class NavigationTabChanged extends NavigationEvent {
  final NavigationTab tab;

  const NavigationTabChanged(this.tab);

  @override
  List<Object> get props => [tab];
}

/// Event triggered when recording starts
class RecordingStarted extends NavigationEvent {
  const RecordingStarted();
}

/// Event triggered when recording stops
class RecordingStopped extends NavigationEvent {
  const RecordingStopped();
}

/// Event for programmatic navigation (used by navigation service)
class NavigateToTab extends NavigationEvent {
  final NavigationTab tab;

  const NavigateToTab(this.tab);

  @override
  List<Object> get props => [tab];
}

/// Available navigation tabs
enum NavigationTab {
  record,
  monitor,
  officers,
  documents,
  history,
  settings,
}