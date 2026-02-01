import 'package:flutter/material.dart';
import '../app_spacing.dart';

/// Base card component with rounded corners, shadows, and consistent spacing
/// following Material Design 3 principles with custom police-interaction styling.
/// Provides foundation for all card-based UI elements in the app.
class BaseCard extends StatelessWidget {
  const BaseCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.onTap,
    this.semanticLabel,
    this.clipBehavior = Clip.antiAlias,
  });

  /// The widget to display inside the card
  final Widget child;

  /// Internal padding of the card content
  final EdgeInsetsGeometry? padding;

  /// External margin around the card
  final EdgeInsetsGeometry? margin;

  /// Background color of the card
  final Color? backgroundColor;

  /// Elevation/shadow depth of the card
  final double? elevation;

  /// Border radius of the card corners
  final BorderRadiusGeometry? borderRadius;

  /// Optional border around the card
  final BoxBorder? border;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Semantic label for accessibility
  final String? semanticLabel;

  /// How to clip the card content
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    final Widget cardContent = Container(
      margin: margin ?? AppSpacing.paddingSM,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: borderRadius ?? AppSpacing.cardBorderRadius,
        border: border,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: elevation ?? AppSpacing.elevationMedium,
            offset: Offset(0, (elevation ?? AppSpacing.elevationMedium) / 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? AppSpacing.cardBorderRadius,
        clipBehavior: clipBehavior,
        child: Padding(
          padding: padding ?? AppSpacing.paddingMD,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return Semantics(
        label: semanticLabel,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: (borderRadius ?? AppSpacing.cardBorderRadius) as BorderRadius?,
            child: cardContent,
          ),
        ),
      );
    }

    return Semantics(
      label: semanticLabel,
      child: cardContent,
    );
  }
}