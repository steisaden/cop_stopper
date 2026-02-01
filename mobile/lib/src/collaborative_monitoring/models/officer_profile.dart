import 'package:mobile/src/collaborative_monitoring/models/career_timeline.dart';
import 'package:mobile/src/collaborative_monitoring/models/commendation.dart';
import 'package:mobile/src/collaborative_monitoring/models/complaint_record.dart';
import 'package:mobile/src/collaborative_monitoring/models/community_rating.dart';
import 'package:mobile/src/collaborative_monitoring/models/disciplinary_action.dart';
import 'package:mobile/src/collaborative_monitoring/models/encounter.dart';

class OfficerProfile {
  final String id;
  final String name;
  final String badgeNumber;
  final String department;
  final List<ComplaintRecord> complaintRecords;
  final List<DisciplinaryAction> disciplinaryActions;
  final List<Commendation> commendations;
  final CareerTimeline careerTimeline;
  final CommunityRating communityRating;
  final bool isUserGenerated; // New field
  final String? createdBy; // New field
  final List<Encounter> encounters; // New field

  OfficerProfile({
    required this.id,
    required this.name,
    required this.badgeNumber,
    required this.department,
    required this.complaintRecords,
    required this.disciplinaryActions,
    required this.commendations,
    required this.careerTimeline,
    required this.communityRating,
    this.isUserGenerated = false,
    this.createdBy,
    this.encounters = const [],
  });
}
