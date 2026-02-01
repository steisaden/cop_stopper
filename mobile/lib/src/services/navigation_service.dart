import '../blocs/navigation/navigation_bloc.dart';
import '../blocs/navigation/navigation_event.dart';

/// Service for programmatic navigation between tabs
class NavigationService {
  NavigationBloc? _navigationBloc;

  /// Initialize the service with the navigation bloc
  void initialize(NavigationBloc navigationBloc) {
    _navigationBloc = navigationBloc;
  }

  /// Navigate to a specific tab programmatically
  void navigateToTab(NavigationTab tab) {
    _navigationBloc?.add(NavigateToTab(tab));
  }

  /// Navigate to Record tab
  void navigateToRecord() {
    navigateToTab(NavigationTab.record);
  }

  /// Navigate to Monitor tab
  void navigateToMonitor() {
    navigateToTab(NavigationTab.monitor);
  }

  /// Navigate to Documents tab
  void navigateToDocuments() {
    navigateToTab(NavigationTab.documents);
  }

  /// Navigate to History tab
  void navigateToHistory() {
    navigateToTab(NavigationTab.history);
  }

  /// Navigate to Settings tab
  void navigateToSettings() {
    navigateToTab(NavigationTab.settings);
  }

  /// Get current active tab
  NavigationTab? get currentTab => _navigationBloc?.state.activeTab;

  /// Check if currently recording
  bool get isRecording => _navigationBloc?.state.isRecording ?? false;

  /// Notify that recording has started
  void notifyRecordingStarted() {
    _navigationBloc?.add(const RecordingStarted());
  }

  /// Notify that recording has stopped
  void notifyRecordingStopped() {
    _navigationBloc?.add(const RecordingStopped());
  }
}