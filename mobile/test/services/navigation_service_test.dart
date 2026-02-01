import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/services/navigation_service.dart';
import 'package:mobile/src/blocs/navigation/navigation_bloc.dart';
import 'package:mobile/src/blocs/navigation/navigation_event.dart';
import 'package:mobile/src/blocs/navigation/navigation_state.dart';

import 'navigation_service_test.mocks.dart';

@GenerateMocks([NavigationBloc])

void main() {
  group('NavigationService', () {
    late NavigationService navigationService;
    late MockNavigationBloc mockNavigationBloc;

    setUp(() {
      navigationService = NavigationService();
      mockNavigationBloc = MockNavigationBloc();
    });

    test('initialize sets the navigation bloc', () {
      navigationService.initialize(mockNavigationBloc);
      
      // Test that the service can now use the bloc
      navigationService.navigateToRecord();
      
      verify(mockNavigationBloc.add(const NavigateToTab(NavigationTab.record))).called(1);
    });

    test('navigateToTab adds NavigateToTab event to bloc', () {
      navigationService.initialize(mockNavigationBloc);
      
      navigationService.navigateToTab(NavigationTab.monitor);
      
      verify(mockNavigationBloc.add(const NavigateToTab(NavigationTab.monitor))).called(1);
    });

    test('navigateToRecord navigates to record tab', () {
      navigationService.initialize(mockNavigationBloc);
      
      navigationService.navigateToRecord();
      
      verify(mockNavigationBloc.add(const NavigateToTab(NavigationTab.record))).called(1);
    });

    test('navigateToMonitor navigates to monitor tab', () {
      navigationService.initialize(mockNavigationBloc);
      
      navigationService.navigateToMonitor();
      
      verify(mockNavigationBloc.add(const NavigateToTab(NavigationTab.monitor))).called(1);
    });

    test('navigateToDocuments navigates to documents tab', () {
      navigationService.initialize(mockNavigationBloc);
      
      navigationService.navigateToDocuments();
      
      verify(mockNavigationBloc.add(const NavigateToTab(NavigationTab.documents))).called(1);
    });

    test('navigateToHistory navigates to history tab', () {
      navigationService.initialize(mockNavigationBloc);
      
      navigationService.navigateToHistory();
      
      verify(mockNavigationBloc.add(const NavigateToTab(NavigationTab.history))).called(1);
    });

    test('navigateToSettings navigates to settings tab', () {
      navigationService.initialize(mockNavigationBloc);
      
      navigationService.navigateToSettings();
      
      verify(mockNavigationBloc.add(const NavigateToTab(NavigationTab.settings))).called(1);
    });

    test('currentTab returns active tab from bloc state', () {
      const testState = NavigationState(
        activeTab: NavigationTab.monitor,
        isRecording: false,
      );
      
      when(mockNavigationBloc.state).thenReturn(testState);
      navigationService.initialize(mockNavigationBloc);
      
      expect(navigationService.currentTab, equals(NavigationTab.monitor));
    });

    test('currentTab returns null when bloc is not initialized', () {
      expect(navigationService.currentTab, isNull);
    });

    test('isRecording returns recording state from bloc', () {
      const testState = NavigationState(
        activeTab: NavigationTab.record,
        isRecording: true,
      );
      
      when(mockNavigationBloc.state).thenReturn(testState);
      navigationService.initialize(mockNavigationBloc);
      
      expect(navigationService.isRecording, isTrue);
    });

    test('isRecording returns false when bloc is not initialized', () {
      expect(navigationService.isRecording, isFalse);
    });

    test('notifyRecordingStarted adds RecordingStarted event', () {
      navigationService.initialize(mockNavigationBloc);
      
      navigationService.notifyRecordingStarted();
      
      verify(mockNavigationBloc.add(const RecordingStarted())).called(1);
    });

    test('notifyRecordingStopped adds RecordingStopped event', () {
      navigationService.initialize(mockNavigationBloc);
      
      navigationService.notifyRecordingStopped();
      
      verify(mockNavigationBloc.add(const RecordingStopped())).called(1);
    });

    test('methods handle uninitialized bloc gracefully', () {
      // These should not throw exceptions even when bloc is not initialized
      expect(() => navigationService.navigateToRecord(), returnsNormally);
      expect(() => navigationService.navigateToMonitor(), returnsNormally);
      expect(() => navigationService.navigateToDocuments(), returnsNormally);
      expect(() => navigationService.navigateToHistory(), returnsNormally);
      expect(() => navigationService.navigateToSettings(), returnsNormally);
      expect(() => navigationService.notifyRecordingStarted(), returnsNormally);
      expect(() => navigationService.notifyRecordingStopped(), returnsNormally);
    });

    test('multiple navigation calls work correctly', () {
      navigationService.initialize(mockNavigationBloc);
      
      navigationService.navigateToRecord();
      navigationService.navigateToMonitor();
      navigationService.navigateToSettings();
      
      verify(mockNavigationBloc.add(const NavigateToTab(NavigationTab.record))).called(1);
      verify(mockNavigationBloc.add(const NavigateToTab(NavigationTab.monitor))).called(1);
      verify(mockNavigationBloc.add(const NavigateToTab(NavigationTab.settings))).called(1);
    });

    test('recording state changes work correctly', () {
      navigationService.initialize(mockNavigationBloc);
      
      navigationService.notifyRecordingStarted();
      navigationService.notifyRecordingStopped();
      navigationService.notifyRecordingStarted();
      
      verify(mockNavigationBloc.add(const RecordingStarted())).called(2);
      verify(mockNavigationBloc.add(const RecordingStopped())).called(1);
    });
  });
}