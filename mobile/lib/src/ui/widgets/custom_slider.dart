import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Custom slider with real-time preview and smooth animations
class CustomSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final String Function(double)? valueFormatter;
  final Widget Function(double)? previewBuilder;
  final bool showPreview;

  const CustomSlider({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    this.label,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.valueFormatter,
    this.previewBuilder,
    this.showPreview = false,
  }) : super(key: key);

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppSpacing.animationDurationShort,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleChangeStart(double value) {
    setState(() {
      _isInteracting = true;
    });
    _animationController.forward();
    widget.onChangeStart?.call(value);
  }

  void _handleChangeEnd(double value) {
    setState(() {
      _isInteracting = false;
    });
    _animationController.reverse();
    widget.onChangeEnd?.call(value);
  }

  String _formatValue(double value) {
    if (widget.valueFormatter != null) {
      return widget.valueFormatter!(value);
    }
    return value.toStringAsFixed(widget.divisions != null ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Value display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatValue(widget.min),
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    padding: AppSpacing.paddingXS,
                    decoration: BoxDecoration(
                      color: _isInteracting 
                        ? colorScheme.primary 
                        : colorScheme.surfaceContainerHighest,
                      borderRadius: AppSpacing.radiusXS,
                    ),
                    child: Text(
                      _formatValue(widget.value),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _isInteracting 
                          ? colorScheme.onPrimary 
                          : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
            Text(
              _formatValue(widget.max),
              style: AppTextStyles.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        
        AppSpacing.verticalSpaceXS,
        
        // Slider
        Slider(
          value: widget.value,
          min: widget.min,
          max: widget.max,
          divisions: widget.divisions,
          label: widget.label ?? _formatValue(widget.value),
          onChanged: widget.onChanged,
          onChangeStart: _handleChangeStart,
          onChangeEnd: _handleChangeEnd,
        ),
        
        // Preview widget
        if (widget.showPreview && widget.previewBuilder != null) ...[
          AppSpacing.verticalSpaceSM,
          AnimatedContainer(
            duration: AppSpacing.animationDurationMedium,
            curve: Curves.easeInOut,
            padding: AppSpacing.paddingSM,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: AppSpacing.radiusSM,
              border: _isInteracting 
                ? Border.all(color: colorScheme.primary.withOpacity(0.3))
                : null,
            ),
            child: widget.previewBuilder!(widget.value),
          ),
        ],
      ],
    );
  }
}
