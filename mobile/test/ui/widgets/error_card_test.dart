import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/error_card.dart';

void main() {
  group('ErrorCard', () {
    testWidgets('should display title and message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorCard(
            title: 'Test Error',
            message: 'This is a test error message',
          ),
        ),
      );

      expect(find.text('Test Error'), findsOneWidget);
      expect(find.text('This is a test error message'), findsOneWidget);
    });

    testWidgets('should display error severity by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ErrorCard(
            title: 'Error',
            message: 'Error message',
          ),
        ),
      );

      // Should show error icon
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should display warning severity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorCard(
            title: 'Warning',
            message: 'Warning message',
            severity: ErrorSeverity.warning,
          ),
        ),
      );

      // Should show warning icon
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('should display info severity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorCard(
            title: 'Info',
            message: 'Info message',
            severity: ErrorSeverity.info,
          ),
        ),
      );

      // Should show info icon
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('should display actions when provided', (tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorCard(
            title: 'Error',
            message: 'Error message',
            actions: [
              ErrorAction(
                label: 'Retry',
                onPressed: () => actionPressed = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(actionPressed, isTrue);
    });
  });

  group('StorageWarningBanner', () {
    testWidgets('should display storage information', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StorageWarningBanner(
            usagePercentage: 75.5,
            availableSpace: '2.5 GB',
          ),
        ),
      );

      expect(find.text('Storage Warning'), findsOneWidget);
      expect(find.text('Usage: 75.5% (2.5 GB remaining)'), findsOneWidget);
    });

    testWidgets('should show critical warning for high usage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StorageWarningBanner(
            usagePercentage: 95.0,
            availableSpace: '0.5 GB',
          ),
        ),
      );

      expect(find.text('Storage Critical'), findsOneWidget);
      expect(find.byIcon(Icons.sd_card_alert), findsOneWidget);
    });

    testWidgets('should show normal info for low usage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: StorageWarningBanner(
            usagePercentage: 30.0,
            availableSpace: '10.0 GB',
          ),
        ),
      );

      expect(find.text('Storage Information'), findsOneWidget);
      expect(find.byIcon(Icons.sd_card), findsOneWidget);
    });

    testWidgets('should display cleanup options', (tester) async {
      bool deleteOldPressed = false;
      bool compressPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StorageWarningBanner(
            usagePercentage: 80.0,
            availableSpace: '1.5 GB',
            cleanupOptions: [
              CleanupOption(
                label: 'Delete Old Files',
                icon: Icons.delete,
                onPressed: () => deleteOldPressed = true,
              ),
              CleanupOption(
                label: 'Compress Files',
                icon: Icons.compress,
                onPressed: () => compressPressed = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Delete Old Files'), findsOneWidget);
      expect(find.text('Compress Files'), findsOneWidget);

      await tester.tap(find.text('Delete Old Files'));
      await tester.pumpAndSettle();

      expect(deleteOldPressed, isTrue);
    });
  });
}