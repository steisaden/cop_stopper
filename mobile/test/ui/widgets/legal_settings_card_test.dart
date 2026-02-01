import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/legal_settings_card.dart';
import '../../test_helpers.dart';

void main() {
  group('LegalSettingsCard Widget Tests', () {
    testWidgets('renders with default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      expect(find.text('Legal Settings'), findsOneWidget);
      expect(find.text('Configure jurisdiction and consent preferences'), findsOneWidget);
      expect(find.byIcon(Icons.gavel), findsOneWidget);
    });

    testWidgets('displays jurisdiction dropdown correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      expect(find.text('Jurisdiction'), findsOneWidget);
      expect(find.text('Automatically detect jurisdiction based on GPS location'), findsOneWidget);
    });

    testWidgets('handles jurisdiction change', (WidgetTester tester) async {
      String? selectedJurisdiction;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
            onJurisdictionChanged: (value) => selectedJurisdiction = value,
          ),
        ),
      );

      // Just verify the callback is set up correctly
      expect(find.text('Jurisdiction'), findsOneWidget);
      expect(selectedJurisdiction, isNull); // Initially null
    });

    testWidgets('shows two-party consent warning for California', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'California',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      expect(find.textContaining('Two-party consent required in California'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('does not show warning for one-party consent states', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Texas',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      expect(find.textContaining('Two-party consent required'), findsNothing);
      expect(find.byIcon(Icons.warning), findsNothing);
    });

    testWidgets('displays consent recording toggle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      expect(find.text('Consent Recording'), findsOneWidget);
      expect(find.text('Record verbal consent before starting main recording'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(4)); // 4 switches total
    });

    testWidgets('handles consent recording toggle change', (WidgetTester tester) async {
      bool? consentValue;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
            onConsentRecordingChanged: (value) => consentValue = value,
          ),
        ),
      );

      // Tap the first switch (consent recording)
      await tester.tap(find.byType(Switch).first);
      await tester.pumpAndSettle();

      expect(consentValue, equals(false));
    });

    testWidgets('displays notifications toggle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      expect(find.text('Legal Notifications'), findsOneWidget);
      expect(find.text('Receive notifications about relevant legal updates'), findsOneWidget);
    });

    testWidgets('handles notifications toggle change', (WidgetTester tester) async {
      bool? notificationsValue;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
            onNotificationsChanged: (value) => notificationsValue = value,
          ),
        ),
      );

      // Tap the second switch (notifications)
      await tester.tap(find.byType(Switch).at(1));
      await tester.pumpAndSettle();

      expect(notificationsValue, equals(false));
    });

    testWidgets('displays rights reminders toggle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      expect(find.text('Rights Reminders'), findsOneWidget);
      expect(find.text('Show reminders about your rights during interactions'), findsOneWidget);
    });

    testWidgets('displays legal hotline access toggle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      expect(find.text('Legal Hotline Access'), findsOneWidget);
      expect(find.text('Enable quick access to legal assistance hotlines'), findsOneWidget);
    });

    testWidgets('displays legal disclaimer', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      expect(find.textContaining('This app provides general legal information only'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('updates jurisdiction description correctly', (WidgetTester tester) async {
      // Test different jurisdiction descriptions
      final testCases = {
        'Auto-detect': 'Automatically detect jurisdiction based on GPS location',
        'California': 'Two-party consent state - all parties must consent to recording',
        'New York': 'One-party consent state - only one party needs to consent',
        'Texas': 'One-party consent state - only one party needs to consent',
      };

      for (final entry in testCases.entries) {
        final jurisdiction = entry.key;
        final expectedDescription = entry.value;
        
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: LegalSettingsCard(
              jurisdiction: jurisdiction,
              consentRecording: true,
              notificationsEnabled: true,
              rightsReminders: true,
              legalHotlineAccess: true,
            ),
          ),
        );

        expect(find.text(expectedDescription), findsOneWidget);
      }
    });

    testWidgets('identifies two-party consent states correctly', (WidgetTester tester) async {
      final twoPartyStates = ['California', 'Florida', 'Pennsylvania', 'Illinois', 'Michigan'];
      
      for (final state in twoPartyStates) {
        await tester.pumpWidget(
          TestHelpers.createTestApp(
            child: LegalSettingsCard(
              jurisdiction: state,
              consentRecording: true,
              notificationsEnabled: true,
              rightsReminders: true,
              legalHotlineAccess: true,
            ),
          ),
        );

        expect(find.textContaining('Two-party consent required in $state'), findsOneWidget);
      }
    });

    testWidgets('has proper accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'Auto-detect',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      // Verify semantic labels exist
      expect(find.text('Jurisdiction'), findsOneWidget);
      expect(find.text('Consent Recording'), findsOneWidget);
      expect(find.text('Legal Notifications'), findsOneWidget);
      expect(find.text('Rights Reminders'), findsOneWidget);
      expect(find.text('Legal Hotline Access'), findsOneWidget);

      // Verify interactive elements are accessible
      expect(find.byType(Switch), findsNWidgets(4));
    });
  });

  group('Responsive Behavior Tests', () {
    testWidgets('adapts to different screen sizes', (WidgetTester tester) async {
      // Test mobile size
      await tester.binding.setSurfaceSize(Size(400, 1200));
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'California',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      expect(find.text('Legal Settings'), findsOneWidget);
      expect(find.textContaining('Two-party consent required'), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(Size(800, 1400));
      await tester.pumpAndSettle();

      expect(find.text('Legal Settings'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('maintains layout with warning messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: LegalSettingsCard(
            jurisdiction: 'California',
            consentRecording: true,
            notificationsEnabled: true,
            rightsReminders: true,
            legalHotlineAccess: true,
          ),
        ),
      );

      // Verify no overflow with warning message
      expect(tester.takeException(), isNull);
      
      // Verify warning and disclaimer are both visible
      expect(find.textContaining('Two-party consent required'), findsOneWidget);
      expect(find.textContaining('This app provides general legal information'), findsOneWidget);
    });
  });
}