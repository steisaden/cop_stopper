import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/ui/widgets/settings_conflict_warning.dart';
import '../../../lib/src/services/settings_validation_service.dart';

void main() {
  group('SettingsConflictWarning', () {
    late SettingsValidationResult validResult;
    late SettingsValidationResult resultWithConflicts;

    setUp(() {
      validResult = const SettingsValidationResult(
        isValid: true,
        warnings: [],
        conflicts: [],
        suggestions: [],
      );

      resultWithConflicts = SettingsValidationResult(
        isValid: false,
        warnings: [],
        conflicts: [
          const SettingsConflict(
            type: ConflictType.legalRequirement,
            message: 'Consent recording is required in California',
            affectedSetting: 'consentRecording',
            suggestedValue: true,
            severity: ConflictSeverity.high,
          ),
        ],
        suggestions: ['Enable consent recording to comply with California law'],
      );
    });

    testWidgets('should not display when no conflicts or warnings', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsConflictWarning(
              validationResult: validResult,
            ),
          ),
        ),
      );

      expect(find.byType(SettingsConflictWarning), findsOneWidget);
      expect(find.text('Settings Issues Found'), findsNothing);
    });

    testWidgets('should display conflict warning header', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsConflictWarning(
              validationResult: resultWithConflicts,
            ),
          ),
        ),
      );

      expect(find.text('Settings Issues Found'), findsOneWidget);
      expect(find.text('1 conflict'), findsOneWidget);
    });

    testWidgets('should call onDismiss when close button is tapped', (WidgetTester tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsConflictWarning(
              validationResult: resultWithConflicts,
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('should not show close button when onDismiss is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsConflictWarning(
              validationResult: resultWithConflicts,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });
  });
}