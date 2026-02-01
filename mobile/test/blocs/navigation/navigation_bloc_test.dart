import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/src/blocs/navigation/navigation_bloc.dart';
import 'package:mobile/src/blocs/navigation/navigation_event.dart';
import 'package:mobile/src/blocs/navigation/navigation_state.dart';

void main() {
  group('NavigationBloc', () {
    late NavigationBloc navigationBloc;

    setUp(() {
      navigationBloc = NavigationBloc();
    });

    tearDown(() {
      navigationBloc.close();
    });

    test('initial state is NavigationState.initial', () {
      expect(navigationBloc.state, equals(const NavigationState.initial()));
    });

    test('initial state has Record tab active and no recording', () {
      final initialState = navigationBloc.state;
      expect(initialState.activeTab, equals(NavigationTab.record));
      expect(initialState.isRecording, equals(false));
    });

    blocTest<NavigationBloc, NavigationState>(
      'emits new state when NavigationTabChanged is added',
      build: () => navigationBloc,
      act: (bloc) => bloc.add(const NavigationTabChanged(NavigationTab.monitor)),
      expect: () => [
        const NavigationState(
          activeTab: NavigationTab.monitor,
          isRecording: false,
        ),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'emits multiple states when switching between tabs',
      build: () => navigationBloc,
      act: (bloc) {
        bloc.add(const NavigationTabChanged(NavigationTab.monitor));
        bloc.add(const NavigationTabChanged(NavigationTab.documents));
        bloc.add(const NavigationTabChanged(NavigationTab.history));
        bloc.add(const NavigationTabChanged(NavigationTab.settings));
        bloc.add(const NavigationTabChanged(NavigationTab.record));
      },
      expect: () => [
        const NavigationState(
          activeTab: NavigationTab.monitor,
          isRecording: false,
        ),
        const NavigationState(
          activeTab: NavigationTab.documents,
          isRecording: false,
        ),
        const NavigationState(
          activeTab: NavigationTab.history,
          isRecording: false,
        ),
        const NavigationState(
          activeTab: NavigationTab.settings,
          isRecording: false,
        ),
        const NavigationState(
          activeTab: NavigationTab.record,
          isRecording: false,
        ),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'emits recording state when RecordingStarted is added',
      build: () => navigationBloc,
      act: (bloc) => bloc.add(const RecordingStarted()),
      expect: () => [
        const NavigationState(
          activeTab: NavigationTab.record,
          isRecording: true,
        ),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'emits non-recording state when RecordingStopped is added',
      build: () => navigationBloc,
      seed: () => const NavigationState(
        activeTab: NavigationTab.monitor,
        isRecording: true,
      ),
      act: (bloc) => bloc.add(const RecordingStopped()),
      expect: () => [
        const NavigationState(
          activeTab: NavigationTab.monitor,
          isRecording: false,
        ),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'maintains recording state when switching tabs',
      build: () => navigationBloc,
      seed: () => const NavigationState(
        activeTab: NavigationTab.record,
        isRecording: true,
      ),
      act: (bloc) => bloc.add(const NavigationTabChanged(NavigationTab.monitor)),
      expect: () => [
        const NavigationState(
          activeTab: NavigationTab.monitor,
          isRecording: true,
        ),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'handles NavigateToTab event for programmatic navigation',
      build: () => navigationBloc,
      act: (bloc) => bloc.add(const NavigateToTab(NavigationTab.settings)),
      expect: () => [
        const NavigationState(
          activeTab: NavigationTab.settings,
          isRecording: false,
        ),
      ],
    );

    blocTest<NavigationBloc, NavigationState>(
      'handles complex sequence of events',
      build: () => navigationBloc,
      act: (bloc) {
        bloc.add(const NavigationTabChanged(NavigationTab.monitor));
        bloc.add(const RecordingStarted());
        bloc.add(const NavigationTabChanged(NavigationTab.documents));
        bloc.add(const RecordingStopped());
        bloc.add(const NavigateToTab(NavigationTab.settings));
      },
      expect: () => [
        const NavigationState(
          activeTab: NavigationTab.monitor,
          isRecording: false,
        ),
        const NavigationState(
          activeTab: NavigationTab.monitor,
          isRecording: true,
        ),
        const NavigationState(
          activeTab: NavigationTab.documents,
          isRecording: true,
        ),
        const NavigationState(
          activeTab: NavigationTab.documents,
          isRecording: false,
        ),
        const NavigationState(
          activeTab: NavigationTab.settings,
          isRecording: false,
        ),
      ],
    );

    test('NavigationState equality works correctly', () {
      const state1 = NavigationState(
        activeTab: NavigationTab.record,
        isRecording: false,
      );
      const state2 = NavigationState(
        activeTab: NavigationTab.record,
        isRecording: false,
      );
      const state3 = NavigationState(
        activeTab: NavigationTab.monitor,
        isRecording: false,
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('NavigationState copyWith works correctly', () {
      const originalState = NavigationState(
        activeTab: NavigationTab.record,
        isRecording: false,
      );

      final newState1 = originalState.copyWith(activeTab: NavigationTab.monitor);
      expect(newState1.activeTab, equals(NavigationTab.monitor));
      expect(newState1.isRecording, equals(false));

      final newState2 = originalState.copyWith(isRecording: true);
      expect(newState2.activeTab, equals(NavigationTab.record));
      expect(newState2.isRecording, equals(true));

      final newState3 = originalState.copyWith(
        activeTab: NavigationTab.settings,
        isRecording: true,
      );
      expect(newState3.activeTab, equals(NavigationTab.settings));
      expect(newState3.isRecording, equals(true));
    });

    test('NavigationState toString works correctly', () {
      const state = NavigationState(
        activeTab: NavigationTab.monitor,
        isRecording: true,
      );

      expect(
        state.toString(),
        equals('NavigationState(activeTab: NavigationTab.monitor, isRecording: true)'),
      );
    });
  });

  group('NavigationEvent', () {
    test('NavigationTabChanged equality works correctly', () {
      const event1 = NavigationTabChanged(NavigationTab.record);
      const event2 = NavigationTabChanged(NavigationTab.record);
      const event3 = NavigationTabChanged(NavigationTab.monitor);

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('NavigateToTab equality works correctly', () {
      const event1 = NavigateToTab(NavigationTab.settings);
      const event2 = NavigateToTab(NavigationTab.settings);
      const event3 = NavigateToTab(NavigationTab.history);

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('RecordingStarted equality works correctly', () {
      const event1 = RecordingStarted();
      const event2 = RecordingStarted();

      expect(event1, equals(event2));
    });

    test('RecordingStopped equality works correctly', () {
      const event1 = RecordingStopped();
      const event2 = RecordingStopped();

      expect(event1, equals(event2));
    });
  });
}