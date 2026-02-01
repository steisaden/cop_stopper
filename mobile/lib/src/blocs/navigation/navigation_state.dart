import 'package:equatable/equatable.dart';
import 'navigation_event.dart';

/// Navigation state containing active tab and recording status
class NavigationState extends Equatable {
  final NavigationTab activeTab;
  final bool isRecording;

  const NavigationState({
    required this.activeTab,
    required this.isRecording,
  });

  /// Initial state with Record tab active and no recording
  const NavigationState.initial()
      : activeTab = NavigationTab.record,
        isRecording = false;

  /// Copy state with optional parameter changes
  NavigationState copyWith({
    NavigationTab? activeTab,
    bool? isRecording,
  }) {
    return NavigationState(
      activeTab: activeTab ?? this.activeTab,
      isRecording: isRecording ?? this.isRecording,
    );
  }

  @override
  List<Object> get props => [activeTab, isRecording];

  @override
  String toString() {
    return 'NavigationState(activeTab: $activeTab, isRecording: $isRecording)';
  }
}