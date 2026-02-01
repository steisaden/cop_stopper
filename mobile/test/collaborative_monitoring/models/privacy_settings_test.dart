import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/collaborative_monitoring/models/privacy_settings.dart';

void main() {
  group('PrivacySettings', () {
    test('can be instantiated', () {
      final settings = PrivacySettings(
        anonymizeParticipants: true,
        restrictToProAccounts: false,
      );
      expect(settings, isA<PrivacySettings>());
      expect(settings.anonymizeParticipants, isTrue);
      expect(settings.restrictToProAccounts, isFalse);
    });
  });
}
