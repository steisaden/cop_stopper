import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/src/ui/widgets/permission_request_overlay.dart';
import '../../../lib/src/services/settings_validation_service.dart';

void main() {
  group('PermissionRequestOverlay', () {
    late List<PermissionRequirement> testPermissions;

    setUp(() {
      testPermissions = [
        const PermissionRequirement(
          permission: 'camera',
          reason: 'Required to record video during police interactions',
          required: true,
        ),
        const PermissionRequirement(
          permission: 'microphone',
          reason: 'Required to record audio during police interactions',
          required: true,
        ),
        const PermissionRequirement(
          permission: 'location',
          reason: 'Required to automatically detect your jurisdiction for legal guidance',
          required: false,
        ),
      ];
    });

    testWidgets('should display permission request overlay', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: testPermissions,
            ),
          ),
        ),
      );

      expect(find.text('Permission Required'), findsOneWidget);
      expect(find.text('1 of 3'), findsOneWidget);
      expect(find.text('Camera Access'), findsOneWidget);
      expect(find.text('Required to record video during police interactions'), findsOneWidget);
    });

    testWidgets('should show required permission indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: testPermissions,
            ),
          ),
        ),
      );

      expect(find.text('Required for app functionality'), findsOneWidget);
      expect(find.text('Grant Permission'), findsOneWidget);
    });

    testWidgets('should show optional permission without required indicator', (WidgetTester tester) async {
      final optionalPermissions = [
        const PermissionRequirement(
          permission: 'location',
          reason: 'Required to automatically detect your jurisdiction',
          required: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: optionalPermissions,
            ),
          ),
        ),
      );

      expect(find.text('Required for app functionality'), findsNothing);
      expect(find.text('Allow Access'), findsOneWidget);
      expect(find.text('Not Now'), findsOneWidget);
    });

    testWidgets('should display correct permission icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: testPermissions,
            ),
          ),
        ),
      );

      // Camera icon should be present for camera permission
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('should show progress indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: testPermissions,
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('1/3'), findsOneWidget);
    });

    testWidgets('should show skip button for required permissions when showSkipOption is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: testPermissions,
            ),
          ),
        ),
      );

      // Skip button should be available for required permissions when showSkipOption is true
      expect(find.text('Skip for Now'), findsOneWidget);
    });

    testWidgets('should handle different permission types', (WidgetTester tester) async {
      final differentPermissions = [
        const PermissionRequirement(
          permission: 'microphone',
          reason: 'For audio recording',
          required: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: differentPermissions,
            ),
          ),
        ),
      );

      expect(find.text('Microphone Access'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('should handle storage permission', (WidgetTester tester) async {
      final storagePermissions = [
        const PermissionRequirement(
          permission: 'storage',
          reason: 'For saving recordings',
          required: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: storagePermissions,
            ),
          ),
        ),
      );

      expect(find.text('Storage Access'), findsOneWidget);
      expect(find.byIcon(Icons.storage), findsOneWidget);
    });

    testWidgets('should handle internet permission', (WidgetTester tester) async {
      final internetPermissions = [
        const PermissionRequirement(
          permission: 'internet',
          reason: 'For cloud backup',
          required: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: internetPermissions,
            ),
          ),
        ),
      );

      expect(find.text('Internet Access'), findsOneWidget);
      expect(find.byIcon(Icons.cloud), findsOneWidget);
    });

    testWidgets('should handle unknown permission type', (WidgetTester tester) async {
      final unknownPermissions = [
        const PermissionRequirement(
          permission: 'unknown',
          reason: 'For unknown functionality',
          required: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: unknownPermissions,
            ),
          ),
        ),
      );

      expect(find.text('Permission Access'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });

    testWidgets('should disable skip option when showSkipOption is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: testPermissions,
              showSkipOption: false,
            ),
          ),
        ),
      );

      // Skip button should not be available when showSkipOption is false
      expect(find.text('Skip for Now'), findsNothing);
      expect(find.text('Not Now'), findsNothing);
    });

    testWidgets('should handle empty permissions list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: [],
            ),
          ),
        ),
      );

      // Should handle empty list gracefully by not showing anything
      expect(find.byType(PermissionRequestOverlay), findsOneWidget);
      expect(find.text('Permission Required'), findsNothing);
    });

    testWidgets('should handle microphone_always permission', (WidgetTester tester) async {
      final micAlwaysPermissions = [
        const PermissionRequirement(
          permission: 'microphone_always',
          reason: 'For voice commands when app is in background',
          required: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PermissionRequestOverlay(
              permissions: micAlwaysPermissions,
            ),
          ),
        ),
      );

      expect(find.text('Always-On Microphone'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });
  });
}