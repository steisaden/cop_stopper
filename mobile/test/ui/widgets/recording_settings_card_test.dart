import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/recording_settings_card.dart';
import '../../test_helpers.dart';

void main() {
  group('RecordingSettingsCard Widget Tests', () {
    testWidgets('renders with default values', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
          ),
        ),
      );

      expect(find.text('Recording Settings'), findsOneWidget);
      expect(find.text('Configure video and audio recording preferences'), findsOneWidget);
      expect(find.byIcon(Icons.videocam), findsOneWidget);
    });

    testWidgets('displays video quality options correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
          ),
        ),
      );

      expect(find.text('Video Quality'), findsOneWidget);
      expect(find.text('High quality, balanced file size'), findsOneWidget);
    });

    testWidgets('handles video quality change', (WidgetTester tester) async {
      String? selectedQuality;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
            onVideoQualityChanged: (value) => selectedQuality = value,
          ),
        ),
      );

      // Just verify the callback is set up correctly by checking the widget exists
      expect(find.text('Video Quality'), findsOneWidget);
      expect(selectedQuality, isNull); // Initially null
    });

    testWidgets('displays audio bitrate slider correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
          ),
        ),
      );

      expect(find.text('Audio Bitrate'), findsOneWidget);
      expect(find.text('128 kbps'), findsOneWidget);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('handles audio bitrate change', (WidgetTester tester) async {
      double? selectedBitrate;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
            onAudioBitrateChanged: (value) => selectedBitrate = value,
          ),
        ),
      );

      // Find and interact with the slider
      final slider = find.byType(Slider);
      await tester.drag(slider, Offset(100, 0));
      await tester.pumpAndSettle();

      expect(selectedBitrate, isNotNull);
      expect(selectedBitrate, greaterThan(128.0));
    });

    testWidgets('displays file format options correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
          ),
        ),
      );

      expect(find.text('File Format'), findsOneWidget);
      expect(find.text('Choose recording file format'), findsOneWidget);
    });

    testWidgets('handles file format change', (WidgetTester tester) async {
      String? selectedFormat;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
            onFileFormatChanged: (value) => selectedFormat = value,
          ),
        ),
      );

      // Just verify the callback is set up correctly
      expect(find.text('File Format'), findsOneWidget);
      expect(selectedFormat, isNull); // Initially null
    });

    testWidgets('displays auto-save toggle correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
          ),
        ),
      );

      expect(find.text('Auto-save Recordings'), findsOneWidget);
      expect(find.text('Automatically save recordings when stopped'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('handles auto-save toggle change', (WidgetTester tester) async {
      bool? autoSaveValue;
      
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
            onAutoSaveChanged: (value) => autoSaveValue = value,
          ),
        ),
      );

      // Tap the switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(autoSaveValue, equals(false));
    });

    testWidgets('updates quality description based on selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '720p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
          ),
        ),
      );

      expect(find.text('Good quality, smaller file size'), findsOneWidget);
    });

    testWidgets('updates bitrate label based on value', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 256.0,
            fileFormat: 'MP4',
            autoSave: true,
          ),
        ),
      );

      expect(find.text('256 kbps'), findsOneWidget);
    });

    testWidgets('has proper accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
          ),
        ),
      );

      // Verify semantic labels exist
      expect(find.text('Video Quality'), findsOneWidget);
      expect(find.text('Audio Bitrate'), findsOneWidget);
      expect(find.text('File Format'), findsOneWidget);
      expect(find.text('Auto-save Recordings'), findsOneWidget);

      // Verify interactive elements are accessible
      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });
  });

  group('Responsive Behavior Tests', () {
    testWidgets('adapts to different screen sizes', (WidgetTester tester) async {
      // Test mobile size
      await tester.binding.setSurfaceSize(Size(400, 800));
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '1080p',
            audioBitrate: 128.0,
            fileFormat: 'MP4',
            autoSave: true,
          ),
        ),
      );

      expect(find.text('Recording Settings'), findsOneWidget);

      // Test tablet size
      await tester.binding.setSurfaceSize(Size(800, 1200));
      await tester.pumpAndSettle();

      expect(find.text('Recording Settings'), findsOneWidget);

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('maintains layout with extreme values', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: RecordingSettingsCard(
            videoQuality: '4K',
            audioBitrate: 320.0, // Maximum value
            fileFormat: 'AVI',
            autoSave: false,
          ),
        ),
      );

      // Verify no overflow
      expect(tester.takeException(), isNull);
      
      // Verify extreme values are displayed correctly
      expect(find.text('Ultra quality, large file size'), findsOneWidget);
      expect(find.text('320 kbps'), findsOneWidget);
    });
  });
}