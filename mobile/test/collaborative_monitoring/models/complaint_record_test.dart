import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/complaint_record.dart';

void main() {
  group('ComplaintRecord', () {
    test('can be instantiated', () {
      final record = ComplaintRecord(
        id: '1',
        date: DateTime(2023),
        description: 'description',
        status: 'status',
      );
      expect(record, isA<ComplaintRecord>());
      expect(record.id, '1');
      expect(record.date, DateTime(2023));
      expect(record.description, 'description');
      expect(record.status, 'status');
    });
  });
}
