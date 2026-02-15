import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/ui/widgets/error_card.dart';
import 'package:mobile/src/ui/widgets/storage_warning_banner.dart';
import 'package:mobile/src/ui/widgets/camera_preview_card.dart';
import 'package:mobile/src/ui/widgets/recording_controls.dart';
import 'package:mobile/src/ui/widgets/transcription_display.dart';
import 'package:mobile/src/ui/widgets/fact_check_panel.dart';
import 'package:mobile/src/ui/widgets/bottom_navigation_component.dart';
import 'package:mobile/src/ui/widgets/theme_switcher.dart';

void main() {
  group('Visual Regression Tests', () {
    testWidgets('error card visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorCard(
              title: 'Connection Failed',
              message: 'Unable to connect to the server. Please check your internet connection.',
              actions: [
                ErrorAction(
                  label: 'Retry',
                  onPressed: () {},
                  isPrimary: true,
                ),
                ErrorAction(
                  label: 'Cancel',
                  onPressed: () {},
                ),
              ],
              severity: ErrorSeverity.error,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ErrorCard),
        matchesGoldenFile('goldens/error_card.png'),
      );
    });

    testWidgets('storage warning banner visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StorageWarningBanner(
              usagePercentage: 85.5,
              availableSpace: '1.2 GB',
              cleanupOptions: [
                CleanupOption(
                  label: 'Clean Storage',
                  icon: Icons.cleaning_services,
                  onPressed: () {},
                ),
                CleanupOption(
                  label: 'Delete Old Files',
                  icon: Icons.delete_outline,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(StorageWarningBanner),
        matchesGoldenFile('goldens/storage_warning_banner.png'),
      );
    });

    testWidgets('camera preview card visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraPreviewCard(
              isRecording: false,
              onCameraSwitch: () {},
              onFlashToggle: () {},
              onFocusTap: (details) {},
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CameraPreviewCard),
        matchesGoldenFile('goldens/camera_preview_card.png'),
      );
    });

    testWidgets('recording controls visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecordingControls(
              isRecording: false,
              onRecordPressed: () {},
              onAudioOnlyToggle: () {},
              onQuickSettings: () {},
              audioLevel: 0.5,
              recordingDuration: const Duration(minutes: 2, seconds: 30),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(RecordingControls),
        matchesGoldenFile('goldens/recording_controls.png'),
      );
    });

    testWidgets('transcription display visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TranscriptionDisplay(
              segments: [
                TranscriptionSegment(
                  text: 'Hello, this is a test transcription.',
                  speaker: 'Officer',
                  timestamp: DateTime.now(),
                  confidence: 0.95,
                ),
                TranscriptionSegment(
                  text: 'I understand my rights.',
                  speaker: 'Citizen',
                  timestamp: DateTime.now().add(const Duration(seconds: 5)),
                  confidence: 0.92,
                ),
              ],
              isListening: true,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(TranscriptionDisplay),
        matchesGoldenFile('goldens/transcription_display.png'),
      );
    });

    testWidgets('fact check panel visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FactCheckPanel(
              results: [
                FactCheckResult(
                  claim: 'You must answer all questions.',
                  status: FactCheckStatus.false_claim,
                  explanation: 'You have the right to remain silent.',
                  legalReference: 'Fifth Amendment',
                ),
                FactCheckResult(
                  claim: 'We can search your car without a warrant.',
                  status: FactCheckStatus.questionable,
                  explanation: 'Depends on circumstances and probable cause.',
                  legalReference: 'Fourth Amendment',
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(FactCheckPanel),
        matchesGoldenFile('goldens/fact_check_panel.png'),
      );
    });

    testWidgets('bottom navigation visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavigationComponent(
              currentIndex: 0,
              onTabSelected: (index) {},
              isRecording: false,
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(BottomNavigationComponent),
        matchesGoldenFile('goldens/bottom_navigation.png'),
      );
    });

    testWidgets('theme switcher visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeSwitcher(
              currentTheme: ThemeMode.system,
              onThemeChanged: (theme) {},
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(ThemeSwitcher),
        matchesGoldenFile('goldens/theme_switcher.png'),
      );
    });

    testWidgets('dark theme visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: Column(
              children: [
                ErrorCard(
                  title: 'Dark Theme Error',
                  message: 'This is how errors look in dark theme.',
                  severity: ErrorSeverity.error,
                ),
                SizedBox(height: 16),
                StorageWarningBanner(
                  usagePercentage: 75.0,
                  availableSpace: '2.5 GB',
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/dark_theme_components.png'),
      );
    });

    testWidgets('high contrast mode visual consistency', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.highContrastLight(),
          ),
          home: const Scaffold(
            body: Column(
              children: [
                ErrorCard(
                  title: 'High Contrast Error',
                  message: 'This is how errors look in high contrast mode.',
                  severity: ErrorSeverity.error,
                ),
                SizedBox(height: 16),
                StorageWarningBanner(
                  usagePercentage: 90.0,
                  availableSpace: '500 MB',
                ),
              ],
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/high_contrast_components.png'),
      );
    });

    testWidgets('responsive layout visual consistency', (tester) async {
      // Test tablet layout
      await tester.binding.setSurfaceSize(const Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CameraPreviewCard(
                      isRecording: false,
                      onCameraSwitch: () {},
                      onFlashToggle: () {},
                      onFocusTap: (details) {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        RecordingControls(
                          isRecording: false,
                          onRecordPressed: () {},
                          onAudioOnlyToggle: () {},
                          onQuickSettings: () {},
                          audioLevel: 0.3,
                          recordingDuration: Duration.zero,
                        ),
                        const SizedBox(height: 16),
                        const Expanded(
                          child: TranscriptionDisplay(
                            segments: [],
                            isListening: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/tablet_layout.png'),
      );

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });
  });
}

// Mock data classes for testing
class TranscriptionSegment {
  final String text;
  final String speaker;
  final DateTime timestamp;
  final double confidence;

  TranscriptionSegment({
    required this.text,
    required this.speaker,
    required this.timestamp,
    required this.confidence,
  });
}

class FactCheckResult {
  final String claim;
  final FactCheckStatus status;
  final String explanation;
  final String legalReference;

  FactCheckResult({
    required this.claim,
    required this.status,
    required this.explanation,
    required this.legalReference,
  });
}

enum FactCheckStatus {
  verified,
  questionable,
  false_claim,
}