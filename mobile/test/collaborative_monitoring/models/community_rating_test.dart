import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/community_rating.dart';

void main() {
  group('CommunityRating', () {
    test('can be instantiated', () {
      final rating = CommunityRating(
        averageRating: 4.5,
        ratingCount: 100,
      );
      expect(rating, isA<CommunityRating>());
      expect(rating.averageRating, 4.5);
      expect(rating.ratingCount, 100);
    });
  });
}
