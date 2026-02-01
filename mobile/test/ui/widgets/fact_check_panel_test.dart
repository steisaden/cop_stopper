import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/models/fact_check_result_model.dart';
import 'package:mobile/src/ui/widgets/fact_check_panel.dart';

void main() {
  group('FactCheckPanel Widget Tests', () {
    late List<FactCheckResult> mockFactCheckResults;
    late List<LegalAlert> mockLegalAlerts;

    setUp(() {
      mockFactCheckResults = [
        FactCheckResult(
          id: '1',
          claim: 'Speed limit is 35 mph',
          segmentId: 'segment_1',
          status: FactCheckStatus.verified,
          confidence: 0.95,
          explanation: 'Verified against traffic database',
          sources: ['Traffic Authority', 'City Records'],
          timestamp: DateTime.now(),
          jurisdiction: 'Test City',
        ),
        FactCheckResult(
          id: '2',
          claim: 'Radar shows 45 mph',
          segmentId: 'segment_2',
          status: FactCheckStatus.disputed,
          confidence: 0.6,
          explanation: 'Radar accuracy questionable',
          sources: ['Equipment Manual'],
          timestamp: DateTime.now(),
        ),
        FactCheckResult(
          id: '3',
          claim: 'This is a false claim',
          segmentId: 'segment_3',
          status: FactCheckStatus.false_claim,
          confidence: 0.9,
          explanation: 'Contradicted by evidence',
          sources: ['Official Records'],
          timestamp: DateTime.now(),
        ),
      ];

      mockLegalAlerts = [
        LegalAlert(
          id: '1',
          segmentId: 'segment_1',
          type: LegalAlertType.rightsViolation,
          title: 'Miranda Rights Not Read',
          description: 'Officer failed to read Miranda rights before questioning',
          suggestedResponse: 'Request that questioning stop until rights are read',
          severity: LegalAlertSeverity.high,
          relevantLaws: ['Miranda v. Arizona', 'Fifth Amendment'],
          jurisdiction: 'Test State',
          timestamp: DateTime.now(),
        ),
        LegalAlert(
          id: '2',
          segmentId: 'segment_2',
          type: LegalAlertType.proceduralError,
          title: 'Improper Traffic Stop',
          description: 'No reasonable suspicion for the traffic stop',
          suggestedResponse: 'Ask for the reason for the stop',
          severity: LegalAlertSeverity.medium,
          relevantLaws: ['Fourth Amendment', 'Terry v. Ohio'],
          timestamp: DateTime.now(),
        ),
        LegalAlert(
          id: '3',
          segmentId: 'segment_3',
          type: LegalAlertType.excessiveForce,
          title: 'Excessive Force Warning',
          description: 'Officer behavior escalating beyond necessary force',
          suggestedResponse: 'Document everything and request supervisor',
          severity: LegalAlertSeverity.critical,
          relevantLaws: ['Use of Force Policy'],
          timestamp: DateTime.now(),
        ),
      ];
    });

    Widget createTestWidget({
      List<FactCheckResult>? factCheckResults,
      List<LegalAlert>? legalAlerts,
      Function(FactCheckResult)? onFactCheckTap,
      Function(LegalAlert)? onLegalAlertTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: FactCheckPanel(
            factCheckResults: factCheckResults ?? [],
            legalAlerts: legalAlerts ?? [],
            onFactCheckTap: onFactCheckTap,
            onLegalAlertTap: onLegalAlertTap,
          ),
        ),
      );
    }

    testWidgets('displays empty state when no data provided', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show tabs
      expect(find.text('Fact Check'), findsOneWidget);
      expect(find.text('Legal'), findsOneWidget);

      // Should show empty state message
      expect(find.text('No fact-check results yet.\nClaims will appear here as they are analyzed.'), findsOneWidget);
    });

    testWidgets('displays fact-check results correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        factCheckResults: mockFactCheckResults,
      ));

      // Should display all fact-check results
      expect(find.text('Speed limit is 35 mph'), findsOneWidget);
      expect(find.text('Radar shows 45 mph'), findsOneWidget);
      expect(find.text('This is a false claim'), findsOneWidget);

      // Should show status indicators
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Disputed'), findsOneWidget);
      expect(find.text('False'), findsOneWidget);
    });

    testWidgets('displays legal alerts correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        legalAlerts: mockLegalAlerts,
      ));

      // Switch to legal alerts tab
      await tester.tap(find.text('Legal'));
      await tester.pumpAndSettle();

      // Should display all legal alerts
      expect(find.text('Miranda Rights Not Read'), findsOneWidget);
      expect(find.text('Improper Traffic Stop'), findsOneWidget);
      expect(find.text('Excessive Force Warning'), findsOneWidget);

      // Should show severity indicators
      expect(find.text('HIGH'), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('CRITICAL'), findsOneWidget);
    });

    testWidgets('shows attention badges for critical items', (tester) async {
      await tester.pumpWidget(createTestWidget(
        factCheckResults: mockFactCheckResults,
        legalAlerts: mockLegalAlerts,
      ));

      // Should show badge for fact-check results requiring attention
      // (disputed and false claims require attention)
      expect(find.text('2'), findsOneWidget); // Badge on fact check tab

      // Should show badge for critical legal alerts
      expect(find.text('1'), findsOneWidget); // Badge on legal tab
    });

    testWidgets('calls onFactCheckTap when fact-check card is tapped', (tester) async {
      FactCheckResult? tappedResult;

      await tester.pumpWidget(createTestWidget(
        factCheckResults: mockFactCheckResults,
        onFactCheckTap: (result) => tappedResult = result,
      ));

      // Tap on the first fact-check result
      await tester.tap(find.text('Speed limit is 35 mph'));
      await tester.pumpAndSettle();

      expect(tappedResult, isNotNull);
      expect(tappedResult!.claim, equals('Speed limit is 35 mph'));
    });

    testWidgets('calls onLegalAlertTap when legal alert card is tapped', (tester) async {
      LegalAlert? tappedAlert;

      await tester.pumpWidget(createTestWidget(
        legalAlerts: mockLegalAlerts,
        onLegalAlertTap: (alert) => tappedAlert = alert,
      ));

      // Switch to legal alerts tab
      await tester.tap(find.text('Legal'));
      await tester.pumpAndSettle();

      // Tap on the first legal alert
      await tester.tap(find.text('Miranda Rights Not Read'));
      await tester.pumpAndSettle();

      expect(tappedAlert, isNotNull);
      expect(tappedAlert!.title, equals('Miranda Rights Not Read'));
    });

    testWidgets('displays confidence percentages correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        factCheckResults: mockFactCheckResults,
      ));

      // Should show confidence percentages
      expect(find.text('95%'), findsOneWidget); // 0.95 * 100
      expect(find.text('60%'), findsOneWidget); // 0.6 * 100
      expect(find.text('90%'), findsOneWidget); // 0.9 * 100
    });

    testWidgets('displays sources count correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        factCheckResults: mockFactCheckResults,
      ));

      // Should show sources count
      expect(find.text('Sources: 2'), findsAtLeastNWidgets(1));
      expect(find.text('Sources: 1'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays suggested responses in legal alerts', (tester) async {
      await tester.pumpWidget(createTestWidget(
        legalAlerts: mockLegalAlerts,
      ));

      // Switch to legal alerts tab
      await tester.tap(find.text('Legal'));
      await tester.pumpAndSettle();

      // Should show suggested responses
      expect(find.text('Suggested Response:'), findsAtLeastNWidgets(1));
      expect(find.text('Request that questioning stop until rights are read'), findsOneWidget);
    });

    testWidgets('sorts legal alerts by severity', (tester) async {
      await tester.pumpWidget(createTestWidget(
        legalAlerts: mockLegalAlerts,
      ));

      // Switch to legal alerts tab
      await tester.tap(find.text('Legal'));
      await tester.pumpAndSettle();

      // Find all alert titles
      final alertTitles = tester.widgetList<Text>(
        find.byWidgetPredicate((widget) => 
          widget is Text && 
          (widget.data == 'Miranda Rights Not Read' ||
           widget.data == 'Improper Traffic Stop' ||
           widget.data == 'Excessive Force Warning')
        )
      ).map((text) => text.data).toList();

      // Critical alerts should appear first
      expect(alertTitles.first, equals('Excessive Force Warning'));
    });

    testWidgets('shows appropriate icons for different alert types', (tester) async {
      await tester.pumpWidget(createTestWidget(
        legalAlerts: mockLegalAlerts,
      ));

      // Switch to legal alerts tab
      await tester.tap(find.text('Legal'));
      await tester.pumpAndSettle();

      // Should show different icons for different alert types
      expect(find.byIcon(Icons.warning), findsAtLeastNWidgets(1)); // Rights violation
      expect(find.byIcon(Icons.error), findsAtLeastNWidgets(1)); // Procedural error
      expect(find.byIcon(Icons.report_problem), findsAtLeastNWidgets(1)); // Excessive force
    });

    testWidgets('displays relevant laws for legal alerts', (tester) async {
      await tester.pumpWidget(createTestWidget(
        legalAlerts: mockLegalAlerts,
      ));

      // Switch to legal alerts tab
      await tester.tap(find.text('Legal'));
      await tester.pumpAndSettle();

      // Should show relevant laws
      expect(find.textContaining('Miranda v. Arizona'), findsOneWidget);
      expect(find.textContaining('Fourth Amendment'), findsOneWidget);
      expect(find.textContaining('Use of Force Policy'), findsOneWidget);
    });

    testWidgets('handles empty legal alerts tab correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        factCheckResults: mockFactCheckResults,
        legalAlerts: [], // Empty legal alerts
      ));

      // Switch to legal alerts tab
      await tester.tap(find.text('Legal'));
      await tester.pumpAndSettle();

      // Should show empty state for legal alerts
      expect(find.text('No legal alerts.\nRights violations and procedural issues will appear here.'), findsOneWidget);
      // The gavel icon appears in both the tab and the empty state, so we expect at least one
      expect(find.byIcon(Icons.gavel), findsAtLeastNWidgets(1));
    });

    testWidgets('tab switching works correctly', (tester) async {
      await tester.pumpWidget(createTestWidget(
        factCheckResults: mockFactCheckResults,
        legalAlerts: mockLegalAlerts,
      ));

      // Initially on fact check tab
      expect(find.text('Speed limit is 35 mph'), findsOneWidget);

      // Switch to legal tab
      await tester.tap(find.text('Legal'));
      await tester.pumpAndSettle();

      // Should show legal alerts
      expect(find.text('Miranda Rights Not Read'), findsOneWidget);
      expect(find.text('Speed limit is 35 mph'), findsNothing);

      // Switch back to fact check tab
      await tester.tap(find.text('Fact Check'));
      await tester.pumpAndSettle();

      // Should show fact check results again
      expect(find.text('Speed limit is 35 mph'), findsOneWidget);
      expect(find.text('Miranda Rights Not Read'), findsNothing);
    });
  });
}