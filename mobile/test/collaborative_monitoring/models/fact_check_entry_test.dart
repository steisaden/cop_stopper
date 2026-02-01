import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/fact_check_entry.dart';

void main() {
  group('FactCheckEntry', () {
    test('can be instantiated', () {
      final entry = FactCheckEntry(
        id: '1',
        text: 'text',
        source: 'source',
        timestamp: DateTime(2023),
      );
      expect(entry, isA<FactCheckEntry>());
      expect(entry.id, '1');
      expect(entry.text, 'text');
      expect(entry.source, 'source');
      expect(entry.timestamp, DateTime(2023));
    });
  });
}
