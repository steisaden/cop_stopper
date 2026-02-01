import 'package:flutter/material.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Generic error card component for displaying error states with actions
class ErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final List<ErrorAction> actions;
  final ErrorSeverity severity;

  const ErrorCard({
    Key? key,
    required this.title,
    required this.message,
    this.actions = const [],
    this.severity = ErrorSeverity.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color backgroundColor;
    final Color iconColor;
    final IconData icon;

    switch (severity) {
      case ErrorSeverity.warning:
        backgroundColor = colorScheme.warningContainer;
        iconColor = colorScheme.onWarningContainer;
        icon = Icons.warning_amber;
        break;
      case ErrorSeverity.info:
        backgroundColor = colorScheme.primaryContainer;
        iconColor = colorScheme.onPrimaryContainer;
        icon = Icons.info;
        break;
      case ErrorSeverity.error:
      default:
        backgroundColor = colorScheme.errorContainer;
        iconColor = colorScheme.onErrorContainer;
        icon = Icons.error;
    }

    return Card(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.cardBorderRadius,
      ),
      elevation: AppSpacing.elevationLow,
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor,
                  size: AppSpacing.tabIconSize,
                ),
                AppSpacing.horizontalSpaceSM,
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: iconColor.withOpacity(0.9),
              ),
            ),
            if (actions.isNotEmpty) ...[
              AppSpacing.verticalSpaceMD,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: action.isPrimary
                        ? ElevatedButton(
                            onPressed: action.onPressed,
                            child: Text(action.label),
                          )
                        : TextButton(
                            onPressed: action.onPressed,
                            child: Text(action.label),
                          ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



/// Data models for error handling components
class ErrorAction {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  ErrorAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });
}



enum ErrorSeverity {
  info,
  warning,
  error,
}