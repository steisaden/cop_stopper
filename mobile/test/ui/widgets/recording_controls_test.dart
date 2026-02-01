import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/recording_controls.dart';
import 'package:mobile/src/ui/app_colors.dart';

void main() {
  group('RecordingControls Widget Tests', () {
    testWidgets('should display basic recording controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(),
          ),
        ),
      );

      // Should show the main record button
      expect(find.byIcon(Icons.fiber_manual_record), findsOneWidget);
      
      // Should not show flash button by default (hasFlash = false)
      expect(find.byIcon(Icons.flash_off), findsNothing);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('should show recording state when isRecording is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isRecording: true,
              recordingDuration: Duration(minutes: 1, seconds: 30),
            ),
          ),
        ),
      );

      // Should show stop icon when recording
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.fiber_manual_record), findsNothing);
      
      // Should show recording timer
      expect(find.text('01:30'), findsOneWidget);
      
      // Should show recording indicator dot
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle record button press', (WidgetTester tester) async {
      bool recordPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              onRecordPressed: () {
                recordPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap the record button
      await tester.tap(find.byIcon(Icons.fiber_manual_record));
      await tester.pump();
      
      expect(recordPressed, isTrue);
    });

    testWidgets('should handle flash toggle when flash is available', (WidgetTester tester) async {
      bool flashToggled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              hasFlash: true,
              onFlashToggle: () {
                flashToggled = true;
              },
            ),
          ),
        ),
      );

      // Should show flash button when hasFlash is true
      expect(find.byIcon(Icons.flash_off), findsOneWidget);

      // Tap the flash button
      await tester.tap(find.byIcon(Icons.flash_off));
      await tester.pump();
      
      expect(flashToggled, isTrue);
    });

    testWidgets('should hide flash button when flash is not available', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              hasFlash: false,
            ),
          ),
        ),
      );

      // Should not show flash button when hasFlash is false
      expect(find.byIcon(Icons.flash_off), findsNothing);
      expect(find.byIcon(Icons.flash_on), findsNothing);
    });

    testWidgets('should show flash on icon when flash is enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isFlashOn: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.flash_on), findsOneWidget);
      expect(find.byIcon(Icons.flash_off), findsNothing);
    });

    testWidgets('should handle audio-only toggle', (WidgetTester tester) async {
      bool audioOnlyToggled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              onAudioOnlyToggle: () {
                audioOnlyToggled = true;
              },
            ),
          ),
        ),
      );

      // Tap the video/audio button
      await tester.tap(find.byIcon(Icons.videocam));
      await tester.pump();
      
      expect(audioOnlyToggled, isTrue);
    });

    testWidgets('should show audio-only mode when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isAudioOnly: true,
              recordingDuration: Duration(seconds: 30),
            ),
          ),
        ),
      );

      // Should show videocam_off icon
      expect(find.byIcon(Icons.videocam_off), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsNothing);
      
      // Should show AUDIO indicator
      expect(find.text('AUDIO'), findsOneWidget);
    });

    testWidgets('should handle settings button press', (WidgetTester tester) async {
      bool settingsPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              onSettingsPressed: () {
                settingsPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap the settings button
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();
      
      expect(settingsPressed, isTrue);
    });

    testWidgets('should display storage info when provided', (WidgetTester tester) async {
      const storageInfo = '2.5 GB free';
      
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              storageInfo: storageInfo,
            ),
          ),
        ),
      );

      expect(find.text(storageInfo), findsOneWidget);
    });

    testWidgets('should hide secondary controls when showSecondaryControls is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              showSecondaryControls: false,
            ),
          ),
        ),
      );

      // Should show only the record button
      expect(find.byIcon(Icons.fiber_manual_record), findsOneWidget);
      
      // Should not show secondary controls
      expect(find.byIcon(Icons.flash_off), findsNothing);
      expect(find.byIcon(Icons.videocam), findsNothing);
      expect(find.byIcon(Icons.settings), findsNothing);
    });

    testWidgets('should show audio level indicator when recording', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isRecording: true,
              audioLevel: 0.5,
            ),
          ),
        ),
      );

      // Should show custom paint for waveform (there may be multiple CustomPaint widgets)
      expect(find.byType(CustomPaint), findsWidgets);
      
      // More specifically, should find the waveform painter
      final customPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      expect(customPaints.any((cp) => cp.painter is WaveformPainter), isTrue);
    });

    testWidgets('should not show audio level indicator when not recording', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isRecording: false,
              audioLevel: 0.5,
            ),
          ),
        ),
      );

      // Should not show waveform painter when not recording
      final customPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      expect(customPaints.any((cp) => cp.painter is WaveformPainter), isFalse);
    });

    testWidgets('should format recording duration correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              recordingDuration: Duration(hours: 1, minutes: 5, seconds: 9),
            ),
          ),
        ),
      );

      // Should show formatted time (minutes:seconds)
      expect(find.text('65:09'), findsOneWidget);
    });

    testWidgets('should show correct button states for active controls', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isFlashOn: true,
              isAudioOnly: true,
            ),
          ),
        ),
      );

      // Find containers that represent the control buttons
      final containers = tester.widgetList<Container>(find.byType(Container));
      
      // Should have containers with primary container color for active states
      expect(containers.any((container) => 
        container.decoration is BoxDecoration &&
        (container.decoration as BoxDecoration).color == AppColors.primaryContainer
      ), isTrue);
    });
  });

  group('RecordingControls Animation Tests', () {
    testWidgets('should animate record button when recording', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isRecording: true,
            ),
          ),
        ),
      );

      // Should have AnimatedBuilder for pulse animation
      expect(find.byType(AnimatedBuilder), findsWidgets);
      
      // Should have Transform widgets for animations (there may be multiple)
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('should animate icon change when recording state changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isRecording: false,
            ),
          ),
        ),
      );

      // Should have AnimatedSwitcher for icon transition
      expect(find.byType(AnimatedSwitcher), findsOneWidget);
    });
  });

  group('RecordingControls Accessibility Tests', () {
    testWidgets('should have proper tooltips for accessibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(),
          ),
        ),
      );

      // Should have tooltips for control buttons
      expect(find.byTooltip('Turn Flash On'), findsOneWidget);
      expect(find.byTooltip('Audio Only'), findsOneWidget);
      expect(find.byTooltip('Recording Settings'), findsOneWidget);
    });

    testWidgets('should update tooltips based on state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isFlashOn: true,
              isAudioOnly: true,
            ),
          ),
        ),
      );

      // Should have updated tooltips for active states
      expect(find.byTooltip('Turn Flash Off'), findsOneWidget);
      expect(find.byTooltip('Enable Video'), findsOneWidget);
    });

    testWidgets('should have proper semantic structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isRecording: true,
              recordingDuration: Duration(minutes: 2, seconds: 15),
            ),
          ),
        ),
      );

      // Should have SafeArea for proper layout
      expect(find.byType(SafeArea), findsOneWidget);
      
      // Should have proper text for screen readers
      expect(find.text('02:15'), findsOneWidget);
    });
  });

  group('WaveformPainter Tests', () {
    testWidgets('should create waveform painter with correct properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isRecording: true,
              audioLevel: 0.8,
            ),
          ),
        ),
      );

      // Should have CustomPaint widget with WaveformPainter
      final customPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      final waveformPaint = customPaints.firstWhere((cp) => cp.painter is WaveformPainter);
      expect(waveformPaint.painter, isA<WaveformPainter>());
    });
  });
}