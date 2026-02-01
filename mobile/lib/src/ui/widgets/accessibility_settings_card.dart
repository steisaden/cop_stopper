import 'package:flutter/material.dart';
import 'settings_card.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Accessibility settings card with voice commands, text size, and contrast controls
class AccessibilitySettingsCard extends StatefulWidget {
  final bool voiceCommands;
  final double textSize;
  final bool highContrast;
  final bool reducedMotion;
  final bool screenReaderSupport;
  final bool hapticFeedback;
  final ValueChanged<bool>? onVoiceCommandsChanged;
  final ValueChanged<double>? onTextSizeChanged;
  final ValueChanged<bool>? onHighContrastChanged;
  final ValueChanged<bool>? onReducedMotionChanged;
  final ValueChanged<bool>? onScreenReaderSupportChanged;
  final ValueChanged<bool>? onHapticFeedbackChanged;

  const AccessibilitySettingsCard({
    Key? key,
    required this.voiceCommands,
    required this.textSize,
    required this.highContrast,
    required this.reducedMotion,
    required this.screenReaderSupport,
    required this.hapticFeedback,
    this.onVoiceCommandsChanged,
    this.onTextSizeChanged,
    this.onHighContrastChanged,
    this.onReducedMotionChanged,
    this.onScreenReaderSupportChanged,
    this.onHapticFeedbackChanged,
  }) : super(key: key);

  @override
  State<AccessibilitySettingsCard> createState() => _AccessibilitySettingsCardState();
}

class _AccessibilitySettingsCardState extends State<AccessibilitySettingsCard> {
  static const double minTextSize = 0.8;
  static const double maxTextSize = 2.0;
  static const double defaultTextSize = 1.0;

  String get _textSizeLabel {
    if (widget.textSize <= 0.9) {
      return 'Small';
    } else if (widget.textSize <= 1.1) {
      return 'Default';
    } else if (widget.textSize <= 1.4) {
      return 'Large';
    } else {
      return 'Extra Large';
    }
  }

  String get _textSizeDescription {
    return 'Adjust text size for better readability (${(widget.textSize * 100).round()}%)';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsCard(
      title: 'Accessibility',
      subtitle: 'Configure accessibility features and preferences',
      icon: Icons.accessibility,
      children: [
        // Voice Commands Toggle
        SettingsItem(
          title: 'Voice Commands',
          subtitle: 'Control the app using voice commands for hands-free operation',
          trailing: Switch(
            value: widget.voiceCommands,
            onChanged: widget.onVoiceCommandsChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Text Size Slider
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Text Size',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  _textSizeLabel,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceXS,
            Text(
              _textSizeDescription,
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
                value: widget.textSize,
                min: minTextSize,
                max: maxTextSize,
                divisions: 12,
                label: _textSizeLabel,
                onChanged: widget.onTextSizeChanged,
              ),
            ),
            // Text size preview
            Container(
              padding: AppSpacing.paddingSM,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: AppSpacing.radiusSM,
              ),
              child: Text(
                'Sample text at ${_textSizeLabel.toLowerCase()} size',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: AppTextStyles.bodyMedium.fontSize! * widget.textSize,
                ),
              ),
            ),
          ],
        ),

        AppSpacing.verticalSpaceSM,

        // High Contrast Toggle
        SettingsItem(
          title: 'High Contrast',
          subtitle: 'Increase contrast for better visibility',
          trailing: Switch(
            value: widget.highContrast,
            onChanged: widget.onHighContrastChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Reduced Motion Toggle
        SettingsItem(
          title: 'Reduced Motion',
          subtitle: 'Minimize animations and transitions',
          trailing: Switch(
            value: widget.reducedMotion,
            onChanged: widget.onReducedMotionChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Screen Reader Support Toggle
        SettingsItem(
          title: 'Screen Reader Support',
          subtitle: 'Enhanced compatibility with screen readers',
          trailing: Switch(
            value: widget.screenReaderSupport,
            onChanged: widget.onScreenReaderSupportChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Haptic Feedback Toggle
        SettingsItem(
          title: 'Haptic Feedback',
          subtitle: 'Vibration feedback for interactions and alerts',
          trailing: Switch(
            value: widget.hapticFeedback,
            onChanged: widget.onHapticFeedbackChanged,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withOpacity(0.3),
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
          ),
        ),

        AppSpacing.verticalSpaceSM,

        // Accessibility Status
        Container(
          padding: AppSpacing.paddingSM,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: AppSpacing.radiusSM,
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 20,
              ),
              AppSpacing.horizontalSpaceSM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accessibility Features Active',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppSpacing.verticalSpaceXS,
                    Text(
                      'App is optimized for accessibility compliance (WCAG 2.1 AA)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}