import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_colors.dart';

/// A frosted glass app bar matching the Stitch design.
///
/// Example:
/// ```dart
/// GlassAppBar(
///   title: 'CopStopper',
///   subtitle: 'Dashboard',
///   leading: Icon(Icons.shield),
///   actions: [
///     IconButton(icon: Icon(Icons.settings), onPressed: () {}),
///   ],
/// )
/// ```
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Main title text
  final String? title;

  /// Optional subtitle text
  final String? subtitle;

  /// Widget displayed at the start (usually back button or logo)
  final Widget? leading;

  /// Action widgets displayed at the end
  final List<Widget>? actions;

  /// Whether to center the title
  final bool centerTitle;

  /// Height of the app bar
  final double height;

  /// Blur sigma for frosted effect
  final double blurSigma;

  /// Whether to show a bottom border
  final bool showBorder;

  /// Custom title widget (overrides title/subtitle)
  final Widget? titleWidget;

  const GlassAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.height = kToolbarHeight + 24,
    this.blurSigma = 20,
    this.showBorder = false,
    this.titleWidget,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    Widget? titleContent;
    if (titleWidget != null) {
      titleContent = titleWidget;
    } else if (title != null) {
      titleContent = Column(
        crossAxisAlignment:
            centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 2,
              ),
            ),
          ],
        ],
      );
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          height: height + topPadding,
          padding: EdgeInsets.only(top: topPadding),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: showBorder
                ? const Border(
                    bottom: BorderSide(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 12),
                ],
                if (titleContent != null) Expanded(child: titleContent),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A floating glass icon button for app bar actions
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.glassSurfaceFloating,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.white.withOpacity(0.8),
          size: size * 0.5,
        ),
      ),
    );
  }
}

/// A shield logo button for the app bar
class GlassLogoButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const GlassLogoButton({
    super.key,
    this.onPressed,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.glassSurfaceFloating,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.shield,
          color: AppColors.glassPrimary,
          size: 24,
        ),
      ),
    );
  }
}
