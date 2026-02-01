import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Confirmation feedback widget for immediate settings application
class ConfirmationFeedback {
  /// Shows a success snackbar with haptic feedback
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    bool includeHaptic = true,
  }) {
    if (includeHaptic) {
      HapticFeedback.lightImpact();
    }

    final colorScheme = Theme.of(context).colorScheme;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.onSuccess,
              size: 20,
            ),
            AppSpacing.horizontalSpaceSM,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSuccess,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
        margin: AppSpacing.paddingMD,
      ),
    );
  }

  /// Shows an error snackbar with haptic feedback
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    bool includeHaptic = true,
  }) {
    if (includeHaptic) {
      HapticFeedback.heavyImpact();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error,
              color: AppColors.onError,
              size: 20,
            ),
            AppSpacing.horizontalSpaceSM,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onError,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
        margin: AppSpacing.paddingMD,
      ),
    );
  }

  /// Shows a warning snackbar with haptic feedback
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    bool includeHaptic = true,
  }) {
    if (includeHaptic) {
      HapticFeedback.mediumImpact();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.warning,
              color: AppColors.onWarning,
              size: 20,
            ),
            AppSpacing.horizontalSpaceSM,
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onWarning,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.warning,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
        ),
        margin: AppSpacing.paddingMD,
      ),
    );
  }

  /// Shows an animated confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? icon,
    Color? iconColor,
    bool includeHaptic = true,
  }) {
    if (includeHaptic) {
      HapticFeedback.selectionClick();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => _AnimatedConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor ?? colorScheme.primary,
      ),
    );
  }
}

/// Animated confirmation dialog
class _AnimatedConfirmationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData? icon;
  final Color iconColor;

  const _AnimatedConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  State<_AnimatedConfirmationDialog> createState() => _AnimatedConfirmationDialogState();
}

class _AnimatedConfirmationDialogState extends State<_AnimatedConfirmationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppSpacing.animationDurationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.radiusLG,
              ),
              title: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 28,
                    ),
                    AppSpacing.horizontalSpaceMD,
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTextStyles.titleLarge.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                widget.message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    widget.cancelText,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(widget.confirmText),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}