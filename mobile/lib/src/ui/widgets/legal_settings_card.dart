import 'package:flutter/material.dart';
import 'settings_card.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Legal settings card with jurisdiction and consent recording options
class LegalSettingsCard extends StatefulWidget {
  final String jurisdiction;
  final bool consentRecording;
  final bool notificationsEnabled;
  final bool rightsReminders;
  final bool legalHotlineAccess;
  final ValueChanged<String?>? onJurisdictionChanged;
  final ValueChanged<bool>? onConsentRecordingChanged;
  final ValueChanged<bool>? onNotificationsChanged;
  final ValueChanged<bool>? onRightsRemindersChanged;
  final ValueChanged<bool>? onLegalHotlineAccessChanged;

  const LegalSettingsCard({
    Key? key,
    required this.jurisdiction,
    required this.consentRecording,
    required this.notificationsEnabled,
    required this.rightsReminders,
    required this.legalHotlineAccess,
    this.onJurisdictionChanged,
    this.onConsentRecordingChanged,
    this.onNotificationsChanged,
    this.onRightsRemindersChanged,
    this.onLegalHotlineAccessChanged,
  }) : super(key: key);

  @override
  State<LegalSettingsCard> createState() => _LegalSettingsCardState();
}

class _LegalSettingsCardState extends State<LegalSettingsCard> {
  static const List<String> jurisdictions = [
    'Auto-detect',
    'California',
    'New York',
    'Texas',
    'Florida',
    'Illinois',
    'Pennsylvania',
    'Ohio',
    'Georgia',
    'North Carolina',
    'Michigan',
  ];

  String get _jurisdictionDescription {
    switch (widget.jurisdiction) {
      case 'Auto-detect':
        return 'Automatically detect jurisdiction based on GPS location';
      case 'California':
        return 'Two-party consent state - all parties must consent to recording';
      case 'New York':
        return 'One-party consent state - only one party needs to consent';
      case 'Texas':
        return 'One-party consent state - only one party needs to consent';
      case 'Florida':
        return 'Two-party consent state - all parties must consent to recording';
      default:
        return 'Check local laws for recording consent requirements';
    }
  }

  bool get _isTwoPartyConsentState {
    return ['California', 'Florida', 'Pennsylvania', 'Illinois', 'Michigan']
        .contains(widget.jurisdiction);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsCard(
      title: 'Legal Settings',
      subtitle: 'Configure jurisdiction and consent preferences',
      icon: Icons.gavel,
      children: [
        // Jurisdiction Override
        SettingsItem(
          title: 'Jurisdiction',
          subtitle: _jurisdictionDescription,
          trailing: DropdownButton<String>(
            value: widget.jurisdiction,
            underline: const SizedBox(),
            items: jurisdictions.map((jurisdiction) {
              return DropdownMenuItem<String>(
                value: jurisdiction,
                child: Text(
                  jurisdiction,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              );
            }).toList(),
            onChanged: widget.onJurisdictionChanged,
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Consent Recording Warning
        if (_isTwoPartyConsentState && widget.jurisdiction != 'Auto-detect')
          Container(
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withOpacity(0.3),
              borderRadius: AppSpacing.radiusSM,
              border: Border.all(
                color: colorScheme.tertiary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: colorScheme.tertiary,
                  size: 20,
                ),
                AppSpacing.horizontalSpaceSM,
                Expanded(
                  child: Text(
                    'Two-party consent required in ${widget.jurisdiction}. '
                    'Ensure all parties consent before recording.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),

        if (_isTwoPartyConsentState && widget.jurisdiction != 'Auto-detect')
          AppSpacing.verticalSpaceSM,

        // Consent Recording Toggle
        SettingsItem(
          title: 'Consent Recording',
          subtitle: 'Record verbal consent before starting main recording',
          trailing: Switch(
            value: widget.consentRecording,
            onChanged: widget.onConsentRecordingChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Notifications Toggle
        SettingsItem(
          title: 'Legal Notifications',
          subtitle: 'Receive notifications about relevant legal updates',
          trailing: Switch(
            value: widget.notificationsEnabled,
            onChanged: widget.onNotificationsChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Rights Reminders Toggle
        SettingsItem(
          title: 'Rights Reminders',
          subtitle: 'Show reminders about your rights during interactions',
          trailing: Switch(
            value: widget.rightsReminders,
            onChanged: widget.onRightsRemindersChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Legal Hotline Access Toggle
        SettingsItem(
          title: 'Legal Hotline Access',
          subtitle: 'Enable quick access to legal assistance hotlines',
          trailing: Switch(
            value: widget.legalHotlineAccess,
            onChanged: widget.onLegalHotlineAccessChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Legal Disclaimer
        Container(
          padding: AppSpacing.paddingSM,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: AppSpacing.radiusSM,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: Text(
                  'This app provides general legal information only. '
                  'Consult with a qualified attorney for specific legal advice.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}