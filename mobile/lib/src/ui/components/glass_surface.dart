import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Glass surface variant types based on the Stitch glassmorphism design system.
enum GlassVariant {
  /// Primary containers - stronger blur (20px), soft wide shadow
  base,

  /// Inner panels, grouped content - reduced blur (10px), tighter shadow
  inset,

  /// Chips, buttons, badges - minimal blur, crisp border, subtle elevation
  floating,

  /// Navigation bars - heavy blur, frosted effect
  frosted,
}

/// A glassmorphism surface widget implementing the Stitch design system.
///
/// Provides three main variants:
/// - [GlassVariant.base]: Primary containers with strong blur and soft shadows
/// - [GlassVariant.inset]: Inner panels with reduced blur and inset shadows
/// - [GlassVariant.floating]: Chips and buttons with crisp borders
///
/// Example:
/// ```dart
/// GlassSurface(
///   variant: GlassVariant.base,
///   child: Text('Hello'),
/// )
/// ```
class GlassSurface extends StatefulWidget {
  /// The glass variant to use
  final GlassVariant variant;

  /// The child widget
  final Widget child;

  /// Optional padding inside the glass surface
  final EdgeInsets? padding;

  /// Optional margin around the glass surface
  final EdgeInsets? margin;

  /// Border radius of the glass surface
  final BorderRadius? borderRadius;

  /// Optional fixed width
  final double? width;

  /// Optional fixed height
  final double? height;

  /// Callback when the surface is tapped
  final VoidCallback? onTap;

  /// Callback when the surface is long-pressed
  final VoidCallback? onLongPress;

  /// Whether to enable press animation (scale and translate)
  final bool enablePressAnimation;

  /// Optional custom background color override
  final Color? backgroundColor;

  /// Optional custom border color override
  final Color? borderColor;

  /// Whether to show the highlight sheen gradient
  final bool showHighlightSheen;

  const GlassSurface({
    super.key,
    required this.child,
    this.variant = GlassVariant.base,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.height,
    this.onTap,
    this.onLongPress,
    this.enablePressAnimation = true,
    this.backgroundColor,
    this.borderColor,
    this.showHighlightSheen = false,
  });

  @override
  State<GlassSurface> createState() => _GlassSurfaceState();
}

class _GlassSurfaceState extends State<GlassSurface>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _translateAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _translateAnimation = Tween<double>(
      begin: 0.0,
      end: -2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enablePressAnimation &&
        (widget.onTap != null || widget.onLongPress != null)) {
      setState(() => _isPressed = true);
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _animationController.reverse();
    }
  }

  /// Returns the blur sigma based on variant
  double get _blurSigma {
    switch (widget.variant) {
      case GlassVariant.base:
        return 10.0; // 20px CSS blur ≈ 10 sigma
      case GlassVariant.inset:
        return 5.0; // 10px CSS blur ≈ 5 sigma
      case GlassVariant.floating:
        return 8.0; // 16px CSS blur ≈ 8 sigma
      case GlassVariant.frosted:
        return 12.5; // 25px CSS blur ≈ 12.5 sigma
    }
  }

  /// Returns the background color based on variant
  Color get _backgroundColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;

    switch (widget.variant) {
      case GlassVariant.base:
        return AppColors.glassSurfaceBase;
      case GlassVariant.inset:
        return AppColors.glassSurfaceInset;
      case GlassVariant.floating:
        return AppColors.glassSurfaceFloating;
      case GlassVariant.frosted:
        return AppColors.glassSurfaceFrosted;
    }
  }

  /// Returns the border color based on variant
  Color get _borderColor {
    if (widget.borderColor != null) return widget.borderColor!;

    switch (widget.variant) {
      case GlassVariant.base:
      case GlassVariant.floating:
      case GlassVariant.frosted:
        return AppColors.glassBorder;
      case GlassVariant.inset:
        return AppColors.glassBorderSubtle;
    }
  }

  /// Returns the box shadows based on variant
  List<BoxShadow> get _boxShadows {
    switch (widget.variant) {
      case GlassVariant.base:
        return [
          BoxShadow(
            color: AppColors.glassShadow.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ];
      case GlassVariant.inset:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ];
      case GlassVariant.floating:
        return [
          BoxShadow(
            color: AppColors.glassShadow.withOpacity(0.25),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ];
      case GlassVariant.frosted:
        return []; // Frosted surfaces typically don't have shadows
    }
  }

  /// Returns the default border radius based on variant
  BorderRadius get _defaultBorderRadius {
    switch (widget.variant) {
      case GlassVariant.base:
        return BorderRadius.circular(24); // 3xl
      case GlassVariant.inset:
        return BorderRadius.circular(12); // xl
      case GlassVariant.floating:
        return BorderRadius.circular(16); // 2xl
      case GlassVariant.frosted:
        return BorderRadius.zero; // Full-width bars
    }
  }

  /// Returns the default padding based on variant
  EdgeInsets get _defaultPadding {
    switch (widget.variant) {
      case GlassVariant.base:
        return const EdgeInsets.all(20);
      case GlassVariant.inset:
        return const EdgeInsets.all(16);
      case GlassVariant.floating:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case GlassVariant.frosted:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? _defaultBorderRadius;
    final padding = widget.padding ?? _defaultPadding;

    Widget content = Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blurSigma, sigmaY: _blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: borderRadius,
              border: Border.all(
                color: _borderColor,
                width: 1.0,
              ),
              boxShadow: _boxShadows,
              gradient: widget.showHighlightSheen
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5],
                    )
                  : null,
            ),
            padding: padding,
            child: widget.child,
          ),
        ),
      ),
    );

    // Wrap with gesture detector if interactive
    if (widget.onTap != null || widget.onLongPress != null) {
      content = GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: widget.enablePressAnimation
            ? AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _translateAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: content,
              )
            : content,
      );
    }

    return content;
  }
}

/// Convenience constructor for base glass variant
class GlassBase extends GlassSurface {
  const GlassBase({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.borderRadius,
    super.width,
    super.height,
    super.onTap,
    super.onLongPress,
    super.enablePressAnimation,
    super.backgroundColor,
    super.borderColor,
    super.showHighlightSheen,
  }) : super(variant: GlassVariant.base);
}

/// Convenience constructor for inset glass variant
class GlassInset extends GlassSurface {
  const GlassInset({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.borderRadius,
    super.width,
    super.height,
    super.onTap,
    super.onLongPress,
    super.enablePressAnimation,
    super.backgroundColor,
    super.borderColor,
    super.showHighlightSheen,
  }) : super(variant: GlassVariant.inset);
}

/// Convenience constructor for floating glass variant
class GlassFloating extends GlassSurface {
  const GlassFloating({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.borderRadius,
    super.width,
    super.height,
    super.onTap,
    super.onLongPress,
    super.enablePressAnimation,
    super.backgroundColor,
    super.borderColor,
    super.showHighlightSheen,
  }) : super(variant: GlassVariant.floating);
}

/// Convenience constructor for frosted glass variant
class GlassFrosted extends GlassSurface {
  const GlassFrosted({
    super.key,
    required super.child,
    super.padding,
    super.margin,
    super.borderRadius,
    super.width,
    super.height,
    super.onTap,
    super.onLongPress,
    super.enablePressAnimation,
    super.backgroundColor,
    super.borderColor,
    super.showHighlightSheen,
  }) : super(variant: GlassVariant.frosted);
}
