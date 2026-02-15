import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../components/glass_surface.dart';

/// A floating glass chip widget for quick actions, filters, and tags.
///
/// Example:
/// ```dart
/// GlassChip(
///   label: 'Know Your Rights',
///   icon: Icons.gavel,
///   onTap: () => print('Tapped'),
/// )
/// ```
class GlassChip extends StatelessWidget {
  /// The label text displayed on the chip
  final String label;

  /// Optional icon to display before the label
  final IconData? icon;

  /// Whether this chip is currently selected
  final bool isSelected;

  /// Callback when the chip is tapped
  final VoidCallback? onTap;

  /// Custom text color (defaults to white)
  final Color? textColor;

  /// Custom icon color (defaults to primary blue)
  final Color? iconColor;

  /// Text style override
  final TextStyle? textStyle;

  const GlassChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.textColor,
    this.iconColor,
  }) : textStyle = null;

  const GlassChip.custom({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.textColor,
    this.iconColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? Colors.white.withOpacity(0.9);
    final effectiveIconColor = iconColor ?? AppColors.glassPrimary;

    return GlassSurface(
      variant: GlassVariant.floating,
      onTap: onTap,
      enablePressAnimation: true,
      backgroundColor:
          isSelected ? AppColors.glassPrimary.withOpacity(0.2) : null,
      borderColor: isSelected ? AppColors.glassPrimary.withOpacity(0.4) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: effectiveIconColor,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: textStyle ??
                TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: effectiveTextColor,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }
}

/// A horizontal scrollable row of glass chips
class GlassChipRow extends StatelessWidget {
  /// List of chips to display
  final List<GlassChip> chips;

  /// Padding around the row
  final EdgeInsets? padding;

  /// Spacing between chips
  final double spacing;

  const GlassChipRow({
    super.key,
    required this.chips,
    this.padding,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: chips.map((chip) {
          final index = chips.indexOf(chip);
          return Padding(
            padding: EdgeInsets.only(
              right: index < chips.length - 1 ? spacing : 0,
            ),
            child: chip,
          );
        }).toList(),
      ),
    );
  }
}
