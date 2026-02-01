import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/career_timeline.dart';

void main() {
  group('CareerTimeline', () {
    test('can be instantiated', () {
      final timeline = CareerTimeline(
        events: [
          CareerTimelineEvent(
            date: DateTime(2023),
            event: 'event',
          ),
        ],
      );
      expect(timeline, isA<CareerTimeline>());
      expect(timeline.events, isNotEmpty);
    });
  });
}
