import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import '../app_spacing.dart';

/// Whisper Settings Screen - temporarily disabled
class WhisperSettingsScreen extends StatefulWidget {
  const WhisperSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WhisperSettingsScreen> createState() => _WhisperSettingsScreenState();
}

class _WhisperSettingsScreenState extends State<WhisperSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whisper Settings'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mic_off,
                size: 80,
                color: AppColors.mutedForeground,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Whisper Settings Unavailable',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Whisper transcription functionality is temporarily disabled. This feature will be available in a future update.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}