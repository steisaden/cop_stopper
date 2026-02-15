import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import '../app_spacing.dart';
import '../../services/whisper_model_manager.dart';

/// Whisper Settings Screen - Model download and configuration
class WhisperSettingsScreen extends StatefulWidget {
  const WhisperSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WhisperSettingsScreen> createState() => _WhisperSettingsScreenState();
}

class _WhisperSettingsScreenState extends State<WhisperSettingsScreen> {
  bool _isDownloading = false;
  bool _isModelDownloaded = false;
  bool _isCheckingStatus = true;
  double _downloadProgress = 0.0;
  String? _errorMessage;
  String _modelSize = '~75 MB';

  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }

  Future<void> _checkModelStatus() async {
    setState(() {
      _isCheckingStatus = true;
      _errorMessage = null;
    });

    try {
      final downloaded = await WhisperModelManager.isModelDownloaded();
      if (mounted) {
        setState(() {
          _isModelDownloaded = downloaded;
          _isCheckingStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to check model status: $e';
          _isCheckingStatus = false;
        });
      }
    }
  }

  Future<void> _downloadModel() async {
    debugPrint('🔵 Download button tapped!');

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _errorMessage = null;
    });

    debugPrint('🔵 Starting download...');

    try {
      await WhisperModelManager.downloadModel(
        'tiny.en',
        onProgress: (progress) {
          debugPrint(
              '🔵 Download progress: ${(progress * 100).toStringAsFixed(1)}%');
          if (mounted) {
            setState(() => _downloadProgress = progress);
          }
        },
      );

      debugPrint('🔵 Download completed successfully!');

      if (mounted) {
        setState(() {
          _isModelDownloaded = true;
          _isDownloading = false;
          _downloadProgress = 1.0;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Whisper model downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('🔴 Download failed: $e');

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = 'Download failed: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteModel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model'),
        content: const Text(
          'Are you sure you want to delete the Whisper model? '
          'You will need to download it again to use transcription.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await WhisperModelManager.deleteModel();
        if (mounted) {
          setState(() => _isModelDownloaded = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Model deleted successfully'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete model: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whisper Settings'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
      ),
      body: _isCheckingStatus
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Model info card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isModelDownloaded
                                  ? Icons.check_circle
                                  : Icons.download,
                              color: _isModelDownloaded
                                  ? Colors.green
                                  : AppColors.primary,
                              size: 32,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Whisper Tiny (English)',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs / 2),
                                  Text(
                                    _isModelDownloaded
                                        ? 'Downloaded'
                                        : 'Not Downloaded',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: _isModelDownloaded
                                          ? Colors.green
                                          : AppColors.mutedForeground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Size: $_modelSize',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Fast, accurate speech recognition optimized for mobile devices.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Download progress
                  if (_isDownloading) ...[
                    Text(
                      'Downloading model...',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: AppColors.outline,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Action buttons
                  if (!_isModelDownloaded && !_isDownloading)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _downloadModel,
                        icon: const Icon(Icons.download),
                        label: const Text('Download Model'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                        ),
                      ),
                    ),

                  if (_isModelDownloaded && !_isDownloading) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _deleteModel,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Delete Model'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Info section
                  Text(
                    'About Whisper',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Whisper is an automatic speech recognition (ASR) system trained on 680,000 hours of multilingual data. '
                    'The Tiny model provides fast, accurate transcription while using minimal device resources.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Download required before using real-time transcription during recordings.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
