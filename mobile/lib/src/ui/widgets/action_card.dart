import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import 'base_card.dart';

/// Action card component for displaying actionable content
/// with prominent call-to-action buttons and visual emphasis.
class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    this.icon,
    required this.title,
    this.description,
    required this.primaryAction,
    this.secondaryAction,
    this.backgroundColor,
    this.iconColor,
    this.isDestructive = false,
    this.isEmergency = false,
    this.semanticLabel,
  });

  /// Optional icon to display
  final IconData? icon;

  /// Title text for the action
  final String title;

  /// Description text below the title
  final String? description;

  /// Primary action button
  final ActionButton primaryAction;

  /// Optional secondary action button
  final ActionButton? secondaryAction;

  /// Background color override
  final Color? backgroundColor;

  /// Icon color override
  final Color? iconColor;

  /// Whether this is a destructive action (uses error colors)
  final bool isDestructive;

  /// Whether this is an emergency action (uses emergency styling)
  final bool isEmergency;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    Color cardBackgroundColor = backgroundColor ?? colorScheme.surface;
    Color cardIconColor = iconColor ?? colorScheme.primary;

    if (isEmergency) {
      cardBackgroundColor = AppColors.emergencyContainer;
      cardIconColor = AppColors.emergency;
    } else if (isDestructive) {
      cardBackgroundColor = AppColors.errorContainer;
      cardIconColor = AppColors.error;
    }

    return BaseCard(
      backgroundColor: cardBackgroundColor,
      semanticLabel: semanticLabel ?? title,
      elevation: isEmergency ? AppSpacing.elevationHigh : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section with icon and text
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: isEmergency ? 32 : 24,
                  color: cardIconColor,
                ),
                AppSpacing.horizontalSpaceMD,
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: (isEmergency 
                          ? AppTextStyles.emergencyButton 
                          : textTheme.titleMedium)?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isEmergency || isDestructive 
                            ? cardIconColor 
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (description != null) ...[
                      AppSpacing.verticalSpaceXS,
                      Text(
                        description!,
                        style: textTheme.bodySmall?.copyWith(
                          color: isEmergency || isDestructive
                              ? cardIconColor.withOpacity(0.8)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.verticalSpaceMD,

          // Action buttons section
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (secondaryAction != null) ...[
                _buildActionButton(
                  context,
                  secondaryAction!,
                  isPrimary: false,
                  isEmergency: isEmergency,
                  isDestructive: isDestructive,
                ),
                AppSpacing.horizontalSpaceSM,
              ],
              _buildActionButton(
                context,
                primaryAction,
                isPrimary: true,
                isEmergency: isEmergency,
                isDestructive: isDestructive,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ActionButton action,
    {
      required bool isPrimary,
      required bool isEmergency,
      required bool isDestructive,
    }
  ) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    ButtonStyle buttonStyle;
    if (isPrimary) {
      if (isEmergency) {
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: AppColors.emergency,
          foregroundColor: AppColors.onEmergency,
          elevation: AppSpacing.elevationMedium,
        );
      } else if (isDestructive) {
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.onError,
        );
      } else {
        buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        );
      }
    } else {
      buttonStyle = TextButton.styleFrom(
        foregroundColor: isEmergency || isDestructive
            ? (isEmergency ? AppColors.emergency : AppColors.error)
            : colorScheme.primary,
      );
    }

    if (isPrimary) {
      return ElevatedButton(
        onPressed: action.onPressed,
        style: buttonStyle,
        child: Text(action.label),
      );
    } else {
      return TextButton(
        onPressed: action.onPressed,
        style: buttonStyle,
        child: Text(action.label),
      );
    }
  }
}

/// Action button configuration for action cards
class ActionButton {
  const ActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  /// Button label text
  final String label;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Optional icon for the button
  final IconData? icon;
}