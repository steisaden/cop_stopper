import 'package:flutter/material.dart';
import 'settings_card.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Privacy settings card with data sharing and backup controls
class PrivacySettingsCard extends StatefulWidget {
  final bool dataSharing;
  final bool cloudBackup;
  final bool analyticsSharing;
  final int autoDeleteDays;
  final bool encryptionEnabled;
  final ValueChanged<bool>? onDataSharingChanged;
  final ValueChanged<bool>? onCloudBackupChanged;
  final ValueChanged<bool>? onAnalyticsSharingChanged;
  final ValueChanged<int?>? onAutoDeleteDaysChanged;
  final ValueChanged<bool>? onEncryptionChanged;

  const PrivacySettingsCard({
    Key? key,
    required this.dataSharing,
    required this.cloudBackup,
    required this.analyticsSharing,
    required this.autoDeleteDays,
    required this.encryptionEnabled,
    this.onDataSharingChanged,
    this.onCloudBackupChanged,
    this.onAnalyticsSharingChanged,
    this.onAutoDeleteDaysChanged,
    this.onEncryptionChanged,
  }) : super(key: key);

  @override
  State<PrivacySettingsCard> createState() => _PrivacySettingsCardState();
}

class _PrivacySettingsCardState extends State<PrivacySettingsCard> {
  static const List<int> autoDeleteOptions = [7, 30, 90, 365, 0]; // 0 means never

  String get _autoDeleteLabel {
    if (widget.autoDeleteDays == 0) {
      return 'Never';
    } else if (widget.autoDeleteDays < 30) {
      return '${widget.autoDeleteDays} days';
    } else if (widget.autoDeleteDays < 365) {
      return '${(widget.autoDeleteDays / 30).round()} months';
    } else {
      return '1 year';
    }
  }

  String get _autoDeleteDescription {
    if (widget.autoDeleteDays == 0) {
      return 'Recordings will be kept indefinitely';
    } else {
      return 'Recordings older than $_autoDeleteLabel will be automatically deleted';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsCard(
      title: 'Privacy Settings',
      subtitle: 'Control data sharing and storage preferences',
      icon: Icons.privacy_tip,
      children: [
        // Data Sharing Toggle
        SettingsItem(
          title: 'Data Sharing',
          subtitle: 'Share anonymized usage data to improve the app',
          trailing: Switch(
            value: widget.dataSharing,
            onChanged: widget.onDataSharingChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Cloud Backup Toggle
        SettingsItem(
          title: 'Cloud Backup',
          subtitle: 'Securely backup recordings to encrypted cloud storage',
          trailing: Switch(
            value: widget.cloudBackup,
            onChanged: widget.onCloudBackupChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Analytics Sharing Toggle
        SettingsItem(
          title: 'Analytics Sharing',
          subtitle: 'Help improve app performance by sharing crash reports',
          trailing: Switch(
            value: widget.analyticsSharing,
            onChanged: widget.onAnalyticsSharingChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Auto-delete Timer
        SettingsItem(
          title: 'Auto-delete Timer',
          subtitle: _autoDeleteDescription,
          trailing: DropdownButton<int>(
            value: widget.autoDeleteDays,
            underline: const SizedBox(),
            items: autoDeleteOptions.map((days) {
              String label;
              if (days == 0) {
                label = 'Never';
              } else if (days < 30) {
                label = '$days days';
              } else if (days < 365) {
                label = '${(days / 30).round()} months';
              } else {
                label = '1 year';
              }
              
              return DropdownMenuItem<int>(
                value: days,
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: widget.onAutoDeleteDaysChanged,
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Encryption Status
        Container(
          padding: AppSpacing.paddingSM,
          decoration: BoxDecoration(
            color: widget.encryptionEnabled 
              ? colorScheme.primaryContainer.withOpacity(0.3)
              : colorScheme.errorContainer.withOpacity(0.3),
            borderRadius: AppSpacing.radiusSM,
            border: Border.all(
              color: widget.encryptionEnabled 
                ? colorScheme.primary.withOpacity(0.3)
                : colorScheme.error.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.encryptionEnabled ? Icons.lock : Icons.lock_open,
                color: widget.encryptionEnabled 
                  ? colorScheme.primary 
                  : colorScheme.error,
                size: 20,
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.encryptionEnabled 
                        ? 'Encryption Enabled' 
                        : 'Encryption Disabled',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: widget.encryptionEnabled 
                          ? colorScheme.primary 
                          : colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalSpaceXS,
                    Text(
                      widget.encryptionEnabled
                        ? 'All recordings are encrypted with AES-256'
                        : 'Recordings are stored without encryption',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: widget.encryptionEnabled 
                          ? colorScheme.onPrimaryContainer 
                          : colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
              if (!widget.encryptionEnabled)
                Switch(
                  value: widget.encryptionEnabled,
                  onChanged: widget.onEncryptionChanged,
                  activeThumbColor: colorScheme.primary,
                  activeTrackColor: colorScheme.primary.withOpacity(0.3),
                  inactiveThumbColor: colorScheme.outline,
                  inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
                ),
            ],
          ),
        ),
      ],
    );
  }
}