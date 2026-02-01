import 'package:mobile/src/collaborative_monitoring/models/officer_profile.dart';
import 'package:mobile/src/collaborative_monitoring/models/encounter.dart';

abstract class OfficerRecordsService {
  Future<OfficerProfile> getOfficer(String officerId);
  Future<OfficerProfile> createOfficer({
    required String name,
    String? badgeNumber,
    String? department,
  });
  Future<List<String>> searchOfficersByName(String name, {String? jurisdiction});
  Future<List<String>> searchOfficersByBadge(String badgeNumber, {String? jurisdiction});
  Future<void> addEncounter(String officerId, Encounter encounter);
}
