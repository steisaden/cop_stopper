import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/services/officer_records_service_impl.dart';
import 'package:mobile/src/collaborative_monitoring/models/officer_profile.dart';

void main() {
  group('OfficerRecordsService', () {
    late OfficerRecordsServiceImpl officerRecordsService;

    setUp(() {
      officerRecordsService = OfficerRecordsServiceImpl();
    });

    test('getOfficer returns a mock officer profile', () async {
      final officer = await officerRecordsService.getOfficer('1');
      expect(officer, isA<OfficerProfile>());
      expect(officer.id, '1');
      expect(officer.name, 'John Doe');
    });

    test('getComplaintHistory returns an empty list', () async {
      final history = await officerRecordsService.getComplaintHistory('1');
      expect(history, isEmpty);
    });

    test('getDisciplinaryActions returns an empty list', () async {
      final actions = await officerRecordsService.getDisciplinaryActions('1');
      expect(actions, isEmpty);
    });

    test('submitCommunityIncidentReport does not throw', () async {
      expect(() async => await officerRecordsService.submitCommunityIncidentReport('1', 'report'), returnsNormally);
    });

    test('subscribeToOfficerNotifications does not throw', () async {
      expect(() async => await officerRecordsService.subscribeToOfficerNotifications('1'), returnsNormally);
    });
  });
}
