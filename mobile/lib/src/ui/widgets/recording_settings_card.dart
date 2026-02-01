import 'package:flutter/material.dart';
import 'settings_card.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Recording settings card with video quality and audio bitrate controls
class RecordingSettingsCard extends StatefulWidget {
  final String videoQuality;
  final double audioBitrate;
  final String fileFormat;
  final bool autoSave;
  final ValueChanged<String?>? onVideoQualityChanged;
  final ValueChanged<double>? onAudioBitrateChanged;
  final ValueChanged<String?>? onFileFormatChanged;
  final ValueChanged<bool>? onAutoSaveChanged;

  const RecordingSettingsCard({
    Key? key,
    required this.videoQuality,
    required this.audioBitrate,
    required this.fileFormat,
    required this.autoSave,
    this.onVideoQualityChanged,
    this.onAudioBitrateChanged,
    this.onFileFormatChanged,
    this.onAutoSaveChanged,
  }) : super(key: key);

  @override
  State<RecordingSettingsCard> createState() => _RecordingSettingsCardState();
}

class _RecordingSettingsCardState extends State<RecordingSettingsCard> {
  static const List<String> videoQualities = ['720p', '1080p', '4K'];
  static const List<String> fileFormats = ['MP4', 'MOV', 'AVI'];
  static const double minBitrate = 64.0;
  static const double maxBitrate = 320.0;

  String get _bitrateLabel {
    return '${widget.audioBitrate.round()} kbps';
  }

  String get _qualityDescription {
    switch (widget.videoQuality) {
      case '720p':
        return 'Good quality, smaller file size';
      case '1080p':
        return 'High quality, balanced file size';
      case '4K':
        return 'Ultra quality, large file size';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsCard(
      title: 'Recording Settings',
      subtitle: 'Configure video and audio recording preferences',
      icon: Icons.videocam,
      children: [
        // Video Quality Selector
        SettingsItem(
          title: 'Video Quality',
          subtitle: _qualityDescription,
          trailing: DropdownButton<String>(
            value: widget.videoQuality,
            underline: const SizedBox(),
            items: videoQualities.map((quality) {
              return DropdownMenuItem<String>(
                value: quality,
                child: Text(
                  quality,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: widget.onVideoQualityChanged,
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Audio Bitrate Slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Audio Bitrate',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  _bitrateLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              'Higher bitrate means better audio quality but larger files',
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: colorScheme.primary,
                inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
                thumbColor: colorScheme.primary,
                overlayColor: colorScheme.primary.withOpacity(0.1),
                valueIndicatorColor: colorScheme.primary,
                valueIndicatorTextStyle: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
              child: Slider(
                value: widget.audioBitrate,
                min: minBitrate,
                max: maxBitrate,
                divisions: 8,
                label: _bitrateLabel,
                onChanged: widget.onAudioBitrateChanged,
              ),
            ),
          ],
        ),

        AppSpacing.verticalSpaceSM,

        // File Format Selector
        SettingsItem(
          title: 'File Format',
          subtitle: 'Choose recording file format',
          trailing: DropdownButton<String>(
            value: widget.fileFormat,
            underline: const SizedBox(),
            items: fileFormats.map((format) {
              return DropdownMenuItem<String>(
                value: format,
                child: Text(
                  format,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: widget.onFileFormatChanged,
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Auto-save Toggle
        SettingsItem(
          title: 'Auto-save Recordings',
          subtitle: 'Automatically save recordings when stopped',
          trailing: Switch(
            value: widget.autoSave,
            onChanged: widget.onAutoSaveChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}