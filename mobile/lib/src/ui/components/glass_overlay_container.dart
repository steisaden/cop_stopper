import 'dart:ui';
import 'package:flutter/material.dart';
import '../app_colors.dart';

/// Direction from which the overlay slides in
enum SlideDirection {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

/// A glassmorphism overlay container with slide-in animation and transparency control.
/// Used for recording screen modals (contacts, transcript, legal AI, save).
class GlassOverlayContainer extends StatefulWidget {
  /// The child content
  final Widget child;

  /// Whether the overlay is visible
  final bool isVisible;

  /// Direction to slide from
  final SlideDirection slideDirection;

  /// Callback when close is requested
  final VoidCallback? onClose;

  /// Initial transparency (0.0 = fully transparent, 1.0 = fully opaque)
  final double initialTransparency;

  /// Whether to show transparency slider
  final bool showTransparencyControl;

  /// Width of the overlay (null = auto)
  final double? width;

  /// Height of the overlay (null = auto)
  final double? height;

  /// Maximum width constraint
  final double? maxWidth;

  /// Maximum height constraint
  final double? maxHeight;

  /// Title for the overlay header
  final String? title;

  /// Callback when transparency changes
  final ValueChanged<double>? onTransparencyChanged;

  const GlassOverlayContainer({
    super.key,
    required this.child,
    required this.isVisible,
    this.slideDirection = SlideDirection.center,
    this.onClose,
    this.initialTransparency = 0.85,
    this.showTransparencyControl = true,
    this.width,
    this.height,
    this.maxWidth,
    this.maxHeight,
    this.title,
    this.onTransparencyChanged,
  });

  @override
  State<GlassOverlayContainer> createState() => _GlassOverlayContainerState();
}

class _GlassOverlayContainerState extends State<GlassOverlayContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late double _transparency;

  @override
  void initState() {
    super.initState();
    _transparency = widget.initialTransparency;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: _getStartOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  Offset _getStartOffset() {
    switch (widget.slideDirection) {
      case SlideDirection.topLeft:
        return const Offset(-1.0, -1.0);
      case SlideDirection.topRight:
        return const Offset(1.0, -1.0);
      case SlideDirection.bottomLeft:
        return const Offset(-1.0, 1.0);
      case SlideDirection.bottomRight:
        return const Offset(1.0, 1.0);
      case SlideDirection.center:
        return const Offset(0.0, 0.3);
    }
  }

  @override
  void didUpdateWidget(GlassOverlayContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateTransparency(double value) {
    setState(() => _transparency = value);
    widget.onTransparencyChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        if (!widget.isVisible && _animationController.isDismissed) {
          return const SizedBox.shrink();
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: widget.width,
              height: widget.height,
              constraints: BoxConstraints(
                maxWidth: widget.maxWidth ?? double.infinity,
                maxHeight: widget.maxHeight ?? double.infinity,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.glassCardBackground
                          .withOpacity(_transparency),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.glassCardBorder.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with title, transparency, and close button
                        _buildHeader(),

                        // Content
                        Flexible(
                          child: widget.child,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    if (widget.title == null &&
        !widget.showTransparencyControl &&
        widget.onClose == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.glassCardBorder.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Title
          if (widget.title != null)
            Expanded(
              child: Text(
                widget.title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),

          // Transparency slider
          if (widget.showTransparencyControl) ...[
            Icon(
              Icons.opacity,
              size: 16,
              color: Colors.white.withOpacity(0.5),
            ),
            SizedBox(
              width: 80,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                  activeTrackColor: AppColors.glassPrimary,
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  thumbColor: Colors.white,
                ),
                child: Slider(
                  value: _transparency,
                  min: 0.3,
                  max: 1.0,
                  onChanged: _updateTransparency,
                ),
              ),
            ),
          ],

          // Close button
          if (widget.onClose != null)
            GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Floating action button for recording overlay
class RecordingOverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool isActive;
  final double size;

  const RecordingOverlayButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.isActive = false,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.glassPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? buttonColor.withOpacity(0.3)
              : Colors.black.withOpacity(0.5),
          border: Border.all(
            color: isActive ? buttonColor : Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? buttonColor : Colors.white,
          size: size * 0.5,
        ),
      ),
    );
  }
}
