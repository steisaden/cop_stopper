import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Badge component matching Figma design system
class FigmaBadge extends StatelessWidget {
  final String text;
  final FigmaBadgeVariant variant;
  final Widget? icon;
  final bool showDot;

  const FigmaBadge({
    Key? key,
    required this.text,
    this.variant = FigmaBadgeVariant.secondary,
    this.icon,
    this.showDot = false,
  }) : super(key: key);

  const FigmaBadge.success({
    Key? key,
    required String text,
    Widget? icon,
    bool showDot = false,
  }) : this(
          key: key,
          text: text,
          variant: FigmaBadgeVariant.success,
          icon: icon,
          showDot: showDot,
        );

  const FigmaBadge.warning({
    Key? key,
    required String text,
    Widget? icon,
    bool showDot = false,
  }) : this(
          key: key,
          text: text,
          variant: FigmaBadgeVariant.warning,
          icon: icon,
          showDot: showDot,
        );

  const FigmaBadge.error({
    Key? key,
    required String text,
    Widget? icon,
    bool showDot = false,
  }) : this(
          key: key,
          text: text,
          variant: FigmaBadgeVariant.error,
          icon: icon,
          showDot: showDot,
        );

  const FigmaBadge.info({
    Key? key,
    required String text,
    Widget? icon,
    bool showDot = false,
  }) : this(
          key: key,
          text: text,
          variant: FigmaBadgeVariant.info,
          icon: icon,
          showDot: showDot,
        );

  @override
  Widget build(BuildContext context) {
    final badgeStyle = _getBadgeStyle();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: badgeStyle.backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.figmaRadius),
        border: Border.all(
          color: badgeStyle.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: badgeStyle.foregroundColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs / 2),
          ],
          if (icon != null) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: icon,
            ),
            const SizedBox(width: AppSpacing.xs / 2),
          ],
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: badgeStyle.foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeStyle _getBadgeStyle() {
    switch (variant) {
      case FigmaBadgeVariant.primary:
        return _BadgeStyle(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          borderColor: AppColors.primary,
        );
      case FigmaBadgeVariant.secondary:
        return _BadgeStyle(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.onSecondary,
          borderColor: AppColors.outlineVariant,
        );
      case FigmaBadgeVariant.success:
        return _BadgeStyle(
          backgroundColor: AppColors.successContainer,
          foregroundColor: AppColors.onSuccessContainer,
          borderColor: AppColors.success,
        );
      case FigmaBadgeVariant.warning:
        return _BadgeStyle(
          backgroundColor: AppColors.warningContainer,
          foregroundColor: AppColors.onWarningContainer,
          borderColor: AppColors.warning,
        );
      case FigmaBadgeVariant.error:
        return _BadgeStyle(
          backgroundColor: AppColors.errorContainer,
          foregroundColor: AppColors.onErrorContainer,
          borderColor: AppColors.error,
        );
      case FigmaBadgeVariant.info:
        return _BadgeStyle(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: AppColors.onPrimaryContainer,
          borderColor: AppColors.primary,
        );
      case FigmaBadgeVariant.outline:
        return _BadgeStyle(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.mutedForeground,
          borderColor: AppColors.outline,
        );
    }
  }
}

/// Badge variants matching Figma design system
enum FigmaBadgeVariant {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
  outline,
}

/// Internal badge style class
class _BadgeStyle {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;

  _BadgeStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
  });
}