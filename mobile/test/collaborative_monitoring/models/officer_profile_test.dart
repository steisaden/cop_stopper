import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/officer_profile.dart';
import 'package:mobile/src/collaborative_monitoring/models/career_timeline.dart';
import 'package:mobile/src/collaborative_monitoring/models/commendation.dart';
import 'package:mobile/src/collaborative_monitoring/models/complaint_record.dart';
import 'package:mobile/src/collaborative_monitoring/models/community_rating.dart';
import 'package:mobile/src/collaborative_monitoring/models/disciplinary_action.dart';

void main() {
  group('OfficerProfile', () {
    test('can be instantiated', () {
      final profile = OfficerProfile(
        id: '1',
        name: 'name',
        badgeNumber: 'badgeNumber',
        department: 'department',
        complaintRecords: [
          ComplaintRecord(
            id: '1',
            date: DateTime(2023),
            description: 'description',
            status: 'status',
          ),
        ],
        disciplinaryActions: [
          DisciplinaryAction(
            id: '1',
            date: DateTime(2023),
            description: 'description',
            outcome: 'outcome',
          ),
        ],
        commendations: [
          Commendation(
            id: '1',
            date: DateTime(2023),
            description: 'description',
          ),
        ],
        careerTimeline: CareerTimeline(
          events: [
            CareerTimelineEvent(
              date: DateTime(2023),
              event: 'event',
            ),
          ],
        ),
        communityRating: CommunityRating(
          averageRating: 4.5,
          ratingCount: 100,
        ),
      );
      expect(profile, isA<OfficerProfile>());
      expect(profile.id, '1');
      expect(profile.name, 'name');
      expect(profile.badgeNumber, 'badgeNumber');
      expect(profile.department, 'department');
      expect(profile.complaintRecords, isNotEmpty);
      expect(profile.disciplinaryActions, isNotEmpty);
      expect(profile.commendations, isNotEmpty);
      expect(profile.careerTimeline, isA<CareerTimeline>());
      expect(profile.communityRating, isA<CommunityRating>());
    });
  });
}
