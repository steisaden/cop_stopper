import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/notification_data.dart';

void main() {
  group('NotificationData', () {
    test('can be instantiated', () {
      final data = NotificationData(
        title: 'title',
        body: 'body',
      );
      expect(data, isA<NotificationData>());
      expect(data.title, 'title');
      expect(data.body, 'body');
    });
  });
}
