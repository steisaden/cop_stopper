import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import 'base_card.dart';

/// Information card component for displaying informational content
/// with optional icon, title, description, and action buttons.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    this.icon,
    this.title,
    this.description,
    this.content,
    this.actions,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
    this.semanticLabel,
  });

  /// Optional icon to display at the top of the card
  final IconData? icon;

  /// Title text for the card
  final String? title;

  /// Description text below the title
  final String? description;

  /// Custom content widget (alternative to title/description)
  final Widget? content;

  /// Action buttons to display at the bottom
  final List<Widget>? actions;

  /// Background color override
  final Color? backgroundColor;

  /// Icon color override
  final Color? iconColor;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return BaseCard(
      backgroundColor: backgroundColor,
      onTap: onTap,
      semanticLabel: semanticLabel ?? title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon section
          if (icon != null) ...[
            Center(
              child: Icon(
                icon,
                size: 32,
                color: iconColor ?? colorScheme.primary,
              ),
            ),
            AppSpacing.verticalSpaceMD,
          ],

          // Content section
          if (content != null)
            content!
          else ...[
            // Title
            if (title != null) ...[
              Text(
                title!,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (description != null) AppSpacing.verticalSpaceSM,
            ],

            // Description
            if (description != null)
              Text(
                description!,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],

          // Actions section
          if (actions != null && actions!.isNotEmpty) ...[
            AppSpacing.verticalSpaceMD,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions!
                  .expand((action) => [action, AppSpacing.horizontalSpaceSM])
                  .take(actions!.length * 2 - 1)
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

/// Specialized info card for displaying status information
class StatusInfoCard extends StatelessWidget {
  const StatusInfoCard({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    this.icon,
    this.actions,
    this.onTap,
    this.semanticLabel,
  });

  final String title;
  final String description;
  final StatusType status;
  final IconData? icon;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: title,
      description: description,
      icon: icon ?? _getStatusIcon(status),
      iconColor: _getStatusColor(status),
      backgroundColor: _getStatusBackgroundColor(status),
      actions: actions,
      onTap: onTap,
      semanticLabel: semanticLabel,
    );
  }

  static IconData _getStatusIcon(StatusType status) {
    switch (status) {
      case StatusType.success:
        return Icons.check_circle_outline;
      case StatusType.warning:
        return Icons.warning_amber_outlined;
      case StatusType.error:
        return Icons.error_outline;
      case StatusType.info:
        return Icons.info_outline;
      case StatusType.recording:
        return Icons.fiber_manual_record;
    }
  }

  static Color _getStatusColor(StatusType status) {
    switch (status) {
      case StatusType.success:
        return AppColors.success;
      case StatusType.warning:
        return AppColors.warning;
      case StatusType.error:
        return AppColors.error;
      case StatusType.info:
        return AppColors.primary;
      case StatusType.recording:
        return AppColors.recording;
    }
  }

  static Color _getStatusBackgroundColor(StatusType status) {
    switch (status) {
      case StatusType.success:
        return AppColors.successContainer;
      case StatusType.warning:
        return AppColors.warningContainer;
      case StatusType.error:
        return AppColors.errorContainer;
      case StatusType.info:
        return AppColors.primaryContainer;
      case StatusType.recording:
        return AppColors.recordingContainer;
    }
  }
}

/// Status types for status info cards
enum StatusType {
  success,
  warning,
  error,
  info,
  recording,
}