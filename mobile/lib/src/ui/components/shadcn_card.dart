import 'package:flutter/material.dart';
import '../app_spacing.dart';
import '../app_colors.dart';

/// shadcn/ui inspired card component for Flutter
class ShadcnCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool elevated;

  const ShadcnCard({
    Key? key,
    this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius = AppSpacing.figmaRadius, // Use Figma radius
    this.boxShadow,
    this.onTap,
    this.elevated = false,
  }) : super(key: key);

  const ShadcnCard.elevated({
    Key? key,
    Widget? child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    double borderRadius = AppSpacing.figmaRadius, // Use Figma radius
    List<BoxShadow>? boxShadow,
    VoidCallback? onTap,
  }) : this(
          key: key,
          child: child,
          padding: padding,
          margin: margin,
          backgroundColor: backgroundColor,
          borderColor: borderColor,
          borderWidth: borderWidth,
          borderRadius: borderRadius,
          boxShadow: boxShadow,
          onTap: onTap,
          elevated: true,
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultBoxShadow = elevated
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ];

    final cardDecoration = BoxDecoration(
      color: backgroundColor ?? AppColors.cardBackground, // Use Figma card background
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppColors.outline, // Use Figma outline color
        width: borderWidth ?? 1.0,
      ),
      boxShadow: boxShadow ?? defaultBoxShadow,
    );

    Widget cardContent = Container(
      margin: margin,
      decoration: cardDecoration,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpacing.figmaCardPadding), // Use Figma card padding
        child: child,
      ),
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}

/// Card header component matching shadcn/ui design
class ShadcnCardHeader extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final EdgeInsets? padding;

  const ShadcnCardHeader({
    Key? key,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) title!,
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    child: subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Card content component
class ShadcnCardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ShadcnCardContent({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
  }
}

/// Card footer component
class ShadcnCardFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ShadcnCardFooter({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: AppSpacing.sm),
      child: child,
    );
  }
}