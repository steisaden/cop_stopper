import 'package:flutter/material.dart';
import '../app_spacing.dart';

/// Custom toggle switch with iOS-style smooth animations
class CustomToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final bool enabled;

  const CustomToggleSwitch({
    Key? key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomToggleSwitch> createState() => _CustomToggleSwitchState();
}

class _CustomToggleSwitchState extends State<CustomToggleSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<Color?> _trackColorAnimation;
  late Animation<Color?> _thumbColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppSpacing.animationDurationMedium,
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _updateAnimations();

    if (widget.value) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CustomToggleSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    
    if (oldWidget.activeColor != widget.activeColor ||
        oldWidget.inactiveColor != widget.inactiveColor ||
        oldWidget.activeTrackColor != widget.activeTrackColor ||
        oldWidget.inactiveTrackColor != widget.inactiveTrackColor) {
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    final colorScheme = Theme.of(context).colorScheme;
    
    _trackColorAnimation = ColorTween(
      begin: widget.inactiveTrackColor ?? colorScheme.outline.withOpacity(0.3),
      end: widget.activeTrackColor ?? colorScheme.primary.withOpacity(0.3),
    ).animate(_animation);

    _thumbColorAnimation = ColorTween(
      begin: widget.inactiveColor ?? colorScheme.outline,
      end: widget.activeColor ?? colorScheme.primary,
    ).animate(_animation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enabled && widget.onChanged != null) {
      widget.onChanged!(!widget.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    const double width = 52.0;
    const double height = 32.0;
    const double thumbSize = 28.0;
    const double padding = 2.0;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              color: _trackColorAnimation.value,
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: AppSpacing.animationDurationMedium,
                  curve: Curves.easeInOut,
                  left: widget.value 
                    ? width - thumbSize - padding 
                    : padding,
                  top: padding,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _thumbColorAnimation.value,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}