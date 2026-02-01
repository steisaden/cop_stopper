import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';

/// Glass morphism container component matching Figma design system
class GlassMorphismContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blurSigma;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;

  const GlassMorphismContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = AppSpacing.figmaRadius,
    this.blurSigma = 10.0,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final defaultBackgroundColor = backgroundColor ?? 
        (isDark 
          ? AppColors.darkGlassMorphismBackground 
          : AppColors.glassMorphismBackground);
    
    final defaultBorderColor = borderColor ?? 
        (isDark 
          ? Colors.white.withOpacity(0.1) 
          : Colors.white.withOpacity(0.3));

    final defaultBoxShadow = boxShadow ?? [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: defaultBackgroundColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: defaultBorderColor,
                width: borderWidth,
              ),
              boxShadow: defaultBoxShadow,
            ),
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Glass morphism app bar component
class GlassMorphismAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final double blurSigma;

  const GlassMorphismAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.blurSigma = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: AppBar(
          title: title,
          actions: actions,
          leading: leading,
          centerTitle: centerTitle,
          elevation: elevation,
          backgroundColor: isDark 
            ? AppColors.darkGlassMorphismBackground 
            : AppColors.glassMorphismBackground,
          foregroundColor: theme.colorScheme.onSurface,
          systemOverlayStyle: isDark 
            ? const SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.light,
              )
            : const SystemUiOverlayStyle(
                statusBarBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.dark,
              ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Glass morphism bottom navigation bar
class GlassMorphismBottomNavBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final double blurSigma;

  const GlassMorphismBottomNavBar({
    Key? key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.blurSigma = 10.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: BottomNavigationBar(
          items: items,
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: isDark 
            ? AppColors.darkGlassMorphismBackground 
            : AppColors.glassMorphismBackground,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: AppColors.mutedForeground,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }
}