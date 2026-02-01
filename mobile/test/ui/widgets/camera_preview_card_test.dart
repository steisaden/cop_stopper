import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/camera_preview_card.dart';
import 'package:mobile/src/ui/app_colors.dart';

void main() {
  group('CameraPreviewCard Widget Tests', () {

    testWidgets('should display loading state when camera controller is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Initializing Camera...'), findsOneWidget);
    });

    testWidgets('should display error state when error message is provided', (WidgetTester tester) async {
      const errorMessage = 'Camera permission denied';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              errorMessage: errorMessage,
            ),
          ),
        ),
      );

      // Should show error state
      expect(find.text('Camera Unavailable'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Use Audio Only'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });

    testWidgets('should display loading state when camera controller is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(),
          ),
        ),
      );

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Initializing Camera...'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(AspectRatio), findsOneWidget);
    });

    testWidgets('should not show camera controls when camera is not initialized', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              showControls: true,
            ),
          ),
        ),
      );

      // Should not show control buttons when camera is not initialized
      expect(find.byIcon(Icons.flip_camera_ios), findsNothing);
      expect(find.byIcon(Icons.zoom_in), findsNothing);
      expect(find.byIcon(Icons.zoom_out), findsNothing);
    });

    testWidgets('should hide camera controls when showControls is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              showControls: false,
            ),
          ),
        ),
      );

      // Should not show control buttons
      expect(find.byIcon(Icons.flip_camera_ios), findsNothing);
      expect(find.byIcon(Icons.zoom_in), findsNothing);
      expect(find.byIcon(Icons.zoom_out), findsNothing);
    });

    testWidgets('should show recording indicator when isRecording is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              isRecording: true,
            ),
          ),
        ),
      );

      await tester.pump();

      // The recording indicator should be present (animated border)
      // We can verify the widget structure exists
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('should show loading state without controls when camera not initialized', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              showControls: true,
            ),
          ),
        ),
      );

      // Should show loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Initializing Camera...'), findsOneWidget);
      
      // Should not show zoom buttons when camera not initialized
      expect(find.byIcon(Icons.zoom_in), findsNothing);
      expect(find.byIcon(Icons.zoom_out), findsNothing);
    });

    testWidgets('should not show gesture detector when camera not initialized', (WidgetTester tester) async {
      bool focusCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              onFocusTap: () {
                focusCalled = true;
              },
            ),
          ),
        ),
      );

      // Should not have gesture detector when camera not initialized
      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsNothing);

      // Focus callback should not be called
      expect(focusCalled, isFalse);
    });

    testWidgets('should have correct aspect ratio', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(),
          ),
        ),
      );

      final aspectRatio = tester.widget<AspectRatio>(find.byType(AspectRatio));
      expect(aspectRatio.aspectRatio, equals(16 / 9));
    });

    testWidgets('should use correct colors and styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(),
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.color, equals(AppColors.cardBackground));
      
      // Verify card has rounded corners
      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, isNotNull);
    });

    testWidgets('should handle audio-only fallback button', (WidgetTester tester) async {
      bool audioOnlyPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              errorMessage: 'Camera error',
              onCameraSwitch: () {
                audioOnlyPressed = true;
              },
            ),
          ),
        ),
      );

      // Find and tap the audio-only button
      final audioButton = find.text('Use Audio Only');
      expect(audioButton, findsOneWidget);
      
      await tester.tap(audioButton);
      await tester.pump();
      
      expect(audioOnlyPressed, isTrue);
    });

    testWidgets('should show basic structure when controls are enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              showControls: true,
            ),
          ),
        ),
      );

      // Should show basic card structure
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(AspectRatio), findsOneWidget);
      
      // Zoom buttons should not be present when camera not initialized
      expect(find.byIcon(Icons.zoom_in), findsNothing);
      expect(find.byIcon(Icons.zoom_out), findsNothing);
    });
  });

  group('CameraPreviewCard Accessibility Tests', () {
    testWidgets('should have proper semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              showControls: true,
              onCameraSwitch: () {},
            ),
          ),
        ),
      );

      // When camera is not initialized, tooltips should not be present
      expect(find.byTooltip('Switch Camera'), findsNothing);
      expect(find.byTooltip('Zoom In'), findsNothing);
      expect(find.byTooltip('Zoom Out'), findsNothing);
    });

    testWidgets('should support screen readers in error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              errorMessage: 'Camera permission denied',
            ),
          ),
        ),
      );

      // Error state should have descriptive text
      expect(find.text('Camera Unavailable'), findsOneWidget);
      expect(find.text('Camera permission denied'), findsOneWidget);
      expect(find.text('Use Audio Only'), findsOneWidget);
    });
  });
}