import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Accessibility support components for comprehensive accessibility features
class AccessibilitySupport {
  /// Apply semantic labels to widgets for screen readers
  static Widget withSemanticLabel({
    required Widget child,
    required String label,
    String? hint,
    bool excludeSemantics = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      excludeSemantics: excludeSemantics,
      child: child,
    );
  }

  /// Create a focusable widget with proper focus management
  static Widget focusable({
    required Widget child,
    required VoidCallback onFocus,
    required VoidCallback onBlur,
    FocusNode? focusNode,
  }) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          onFocus();
        } else {
          onBlur();
        }
      },
      focusNode: focusNode,
      child: child,
    );
  }

  /// Provide haptic feedback for accessibility
  static Future<void> provideHapticFeedback(HapticFeedbackType type) async {
    switch (type) {
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.impactLight:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.impactMedium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.impactHeavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.notificationSuccess:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.notificationWarning:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.notificationError:
        await HapticFeedback.heavyImpact();
        break;
    }
  }
}

/// High contrast mode provider for enhanced visibility
class HighContrastMode extends InheritedWidget {
  final bool isEnabled;

  const HighContrastMode({
    Key? key,
    required this.isEnabled,
    required Widget child,
  }) : super(key: key, child: child);

  static HighContrastMode? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HighContrastMode>();
  }

  @override
  bool updateShouldNotify(HighContrastMode oldWidget) {
    return oldWidget.isEnabled != isEnabled;
  }
}

/// Text size scaler for dynamic text sizing
class TextSizeScaler extends InheritedWidget {
  final double scaleFactor;

  const TextSizeScaler({
    Key? key,
    required this.scaleFactor,
    required Widget child,
  }) : super(key: key, child: child);

  static TextSizeScaler? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TextSizeScaler>();
  }

  @override
  bool updateShouldNotify(TextSizeScaler oldWidget) {
    return oldWidget.scaleFactor != scaleFactor;
  }
}

/// Accessibility settings panel
class AccessibilitySettingsPanel extends StatelessWidget {
  final bool isHighContrastEnabled;
  final double textSizeScale;
  final bool isReduceMotionEnabled;
  final bool isVoiceControlEnabled;
  final ValueChanged<bool> onHighContrastChanged;
  final ValueChanged<double> onTextSizeScaleChanged;
  final ValueChanged<bool> onReduceMotionChanged;
  final ValueChanged<bool> onVoiceControlChanged;

  const AccessibilitySettingsPanel({
    Key? key,
    required this.isHighContrastEnabled,
    required this.textSizeScale,
    required this.isReduceMotionEnabled,
    required this.isVoiceControlEnabled,
    required this.onHighContrastChanged,
    required this.onTextSizeScaleChanged,
    required this.onReduceMotionChanged,
    required this.onVoiceControlChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accessibility',
          style: AppTextStyles.titleLarge.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        AppSpacing.verticalSpaceMD,
        _buildToggleSetting(
          context: context,
          title: 'High Contrast Mode',
          description: 'Increase color contrast for better visibility',
          value: isHighContrastEnabled,
          onChanged: onHighContrastChanged,
        ),
        AppSpacing.verticalSpaceMD,
        _buildSliderSetting(
          context: context,
          title: 'Text Size',
          description: 'Adjust text size for better readability',
          value: textSizeScale,
          min: 0.8,
          max: 2.0,
          divisions: 12,
          onChanged: onTextSizeScaleChanged,
        ),
        AppSpacing.verticalSpaceMD,
        _buildToggleSetting(
          context: context,
          title: 'Reduce Motion',
          description: 'Minimize animation effects',
          value: isReduceMotionEnabled,
          onChanged: onReduceMotionChanged,
        ),
        AppSpacing.verticalSpaceMD,
        _buildToggleSetting(
          context: context,
          title: 'Voice Control',
          description: 'Enable voice commands for hands-free operation',
          value: isVoiceControlEnabled,
          onChanged: onVoiceControlChanged,
        ),
      ],
    );
  }

  Widget _buildToggleSetting({
    required BuildContext context,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.horizontalSpaceMD,
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: colorScheme.primary,
        ),
      ],
    );
  }

  Widget _buildSliderSetting({
    required BuildContext context,
    required String title,
    required String description,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: AppTextStyles.labelMedium.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceXS,
        Text(
          description,
          style: AppTextStyles.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.verticalSpaceSM,
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: colorScheme.primary,
          inactiveColor: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }
}

/// Voice command overlay for hands-free operation
class VoiceCommandOverlay extends StatelessWidget {
  final bool isVisible;
  final String listeningText;
  final List<VoiceCommand> availableCommands;
  final VoidCallback onClose;

  const VoiceCommandOverlay({
    Key? key,
    required this.isVisible,
    this.listeningText = 'Listening...',
    this.availableCommands = const [],
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          margin: const EdgeInsets.all(AppSpacing.lg),
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppSpacing.cardBorderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Voice Commands',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                  ),
                ],
              ),
              AppSpacing.verticalSpaceMD,
              Container(
                padding: AppSpacing.paddingMD,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: AppSpacing.radiusSM,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: Colors.red),
                    AppSpacing.horizontalSpaceSM,
                    Text(
                      listeningText,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalSpaceMD,
              Text(
                'Available Commands:',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.verticalSpaceSM,
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: availableCommands.length,
                  itemBuilder: (context, index) {
                    final command = availableCommands[index];
                    return ListTile(
                      leading: Icon(
                        command.icon,
                        size: 20,
                      ),
                      title: Text(command.label),
                      subtitle: Text(
                        command.description,
                        style: AppTextStyles.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Data models for accessibility components
enum HapticFeedbackType {
  selection,
  impactLight,
  impactMedium,
  impactHeavy,
  notificationSuccess,
  notificationWarning,
  notificationError,
}

class VoiceCommand {
  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onExecute;

  VoiceCommand({
    required this.label,
    required this.description,
    required this.icon,
    required this.onExecute,
  });
}