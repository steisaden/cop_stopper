import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Button variants matching shadcn/ui design system
enum ShadcnButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
  link,
}

/// Button sizes matching shadcn/ui design system
enum ShadcnButtonSize {
  sm,
  md,
  lg,
  icon,
}

/// shadcn/ui inspired button component for Flutter
class ShadcnButton extends StatefulWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ShadcnButtonVariant variant;
  final ShadcnButtonSize size;
  final bool isLoading;
  final bool disabled;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? width;

  const ShadcnButton({
    Key? key,
    this.text,
    this.child,
    required this.onPressed,
    this.variant = ShadcnButtonVariant.primary,
    this.size = ShadcnButtonSize.md,
    this.isLoading = false,
    this.disabled = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
  }) : super(key: key);

  const ShadcnButton.primary({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    ShadcnButtonSize size = ShadcnButtonSize.md,
    bool isLoading = false,
    bool disabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
    double? width,
  }) : this(
          key: key,
          text: text,
          child: child,
          onPressed: onPressed,
          variant: ShadcnButtonVariant.primary,
          size: size,
          isLoading: isLoading,
          disabled: disabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
          width: width,
        );

  const ShadcnButton.secondary({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    ShadcnButtonSize size = ShadcnButtonSize.md,
    bool isLoading = false,
    bool disabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
    double? width,
  }) : this(
          key: key,
          text: text,
          child: child,
          onPressed: onPressed,
          variant: ShadcnButtonVariant.secondary,
          size: size,
          isLoading: isLoading,
          disabled: disabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
          width: width,
        );

  const ShadcnButton.outline({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    ShadcnButtonSize size = ShadcnButtonSize.md,
    bool isLoading = false,
    bool disabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
    double? width,
  }) : this(
          key: key,
          text: text,
          child: child,
          onPressed: onPressed,
          variant: ShadcnButtonVariant.outline,
          size: size,
          isLoading: isLoading,
          disabled: disabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
          width: width,
        );

  const ShadcnButton.ghost({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    ShadcnButtonSize size = ShadcnButtonSize.md,
    bool isLoading = false,
    bool disabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
    double? width,
  }) : this(
          key: key,
          text: text,
          child: child,
          onPressed: onPressed,
          variant: ShadcnButtonVariant.ghost,
          size: size,
          isLoading: isLoading,
          disabled: disabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
          width: width,
        );

  const ShadcnButton.destructive({
    Key? key,
    String? text,
    Widget? child,
    required VoidCallback? onPressed,
    ShadcnButtonSize size = ShadcnButtonSize.md,
    bool isLoading = false,
    bool disabled = false,
    Widget? leadingIcon,
    Widget? trailingIcon,
    double? width,
  }) : this(
          key: key,
          text: text,
          child: child,
          onPressed: onPressed,
          variant: ShadcnButtonVariant.destructive,
          size: size,
          isLoading: isLoading,
          disabled: disabled,
          leadingIcon: leadingIcon,
          trailingIcon: trailingIcon,
          width: width,
        );

  @override
  State<ShadcnButton> createState() => _ShadcnButtonState();
}

class _ShadcnButtonState extends State<ShadcnButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
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

  void _onTapDown(TapDownDetails details) {
    if (!widget.disabled && !widget.isLoading) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Size configurations
    final sizeConfig = _getSizeConfig();

    // Color configurations based on variant - Figma design system
    Color backgroundColor;
    Color foregroundColor;
    Color? overlayColor; // Pressed state
    Color? hoverColor;
    BorderSide? borderSide;

    switch (widget.variant) {
      case ShadcnButtonVariant.primary:
        backgroundColor = AppColors.primary;
        foregroundColor = AppColors.onPrimary;
        hoverColor = AppColors.primary.withOpacity(0.9);
        overlayColor = AppColors.primary.withOpacity(0.8);
        break;
      case ShadcnButtonVariant.secondary:
        backgroundColor = AppColors.secondary;
        foregroundColor = AppColors.onSecondary;
        hoverColor = AppColors.secondary.withOpacity(0.9);
        overlayColor = AppColors.secondary.withOpacity(0.8);
        break;
      case ShadcnButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primary;
        hoverColor = AppColors.primary.withOpacity(0.05);
        overlayColor = AppColors.primary.withOpacity(0.1);
        borderSide = BorderSide(color: AppColors.outline);
        break;
      case ShadcnButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.mutedForeground;
        hoverColor = AppColors.accent.withOpacity(0.5);
        overlayColor = AppColors.accent.withOpacity(0.7);
        break;
      case ShadcnButtonVariant.destructive:
        backgroundColor = AppColors.error;
        foregroundColor = AppColors.onError;
        hoverColor = AppColors.error.withOpacity(0.9);
        overlayColor = AppColors.error.withOpacity(0.8);
        break;
      case ShadcnButtonVariant.link:
        backgroundColor = Colors.transparent;
        foregroundColor = AppColors.primary;
        hoverColor = Colors.transparent;
        overlayColor = Colors.transparent;
        break;
    }

    // Handle disabled state
    if (widget.disabled || widget.isLoading) {
      backgroundColor = backgroundColor.withOpacity(0.5);
      foregroundColor = foregroundColor.withOpacity(0.5);
    }

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.hovered)) {
          return hoverColor;
        }
        return backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.all(foregroundColor),
      overlayColor: WidgetStateProperty.all(overlayColor),
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all(sizeConfig.padding),
      minimumSize: WidgetStateProperty.all(sizeConfig.minimumSize),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizeConfig.borderRadius),
        ),
      ),
      side: borderSide != null ? WidgetStateProperty.all(borderSide) : null,
    );
  }

  _SizeConfig _getSizeConfig() {
    // Use Figma design system sizing
    switch (widget.size) {
      case ShadcnButtonSize.sm:
        return _SizeConfig(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: const Size(0, 32),
          borderRadius: AppSpacing.figmaRadius, // Use Figma radius
          textStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w500),
          iconSize: 16,
        );
      case ShadcnButtonSize.md:
        return _SizeConfig(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 40),
          borderRadius: AppSpacing.figmaRadius, // Use Figma radius
          textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w500),
          iconSize: 18,
        );
      case ShadcnButtonSize.lg:
        return _SizeConfig(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(0, 48),
          borderRadius: AppSpacing.figmaRadius, // Use Figma radius
          textStyle: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w500),
          iconSize: 20,
        );
      case ShadcnButtonSize.icon:
        return _SizeConfig(
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(40, 40),
          borderRadius: AppSpacing.figmaRadius, // Use Figma radius
          textStyle: AppTextStyles.labelMedium,
          iconSize: 18,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeConfig = _getSizeConfig();
    final isEnabled = !widget.disabled && !widget.isLoading && widget.onPressed != null;

    Widget buttonChild;
    
    if (widget.isLoading) {
      buttonChild = SizedBox(
        width: sizeConfig.iconSize,
        height: sizeConfig.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getButtonStyle(context).foregroundColor!.resolve({})!,
          ),
        ),
      );
    } else {
      final content = widget.child ?? (widget.text != null ? Text(widget.text!) : const SizedBox.shrink());
      
      if (widget.leadingIcon != null || widget.trailingIcon != null) {
        buttonChild = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.leadingIcon != null) ...[
              SizedBox(
                width: sizeConfig.iconSize,
                height: sizeConfig.iconSize,
                child: widget.leadingIcon,
              ),
              const SizedBox(width: 8),
            ],
            content,
            if (widget.trailingIcon != null) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: sizeConfig.iconSize,
                height: sizeConfig.iconSize,
                child: widget.trailingIcon,
              ),
            ],
          ],
        );
      } else {
        buttonChild = content;
      }
    }

    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.width,
            child: ElevatedButton(
              onPressed: isEnabled ? widget.onPressed : null,
              style: _getButtonStyle(context),
              child: DefaultTextStyle(
                style: sizeConfig.textStyle,
                child: buttonChild,
              ),
            ),
          ),
        );
      },
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: button,
    );
  }
}

class _SizeConfig {
  final EdgeInsets padding;
  final Size minimumSize;
  final double borderRadius;
  final TextStyle textStyle;
  final double iconSize;

  const _SizeConfig({
    required this.padding,
    required this.minimumSize,
    required this.borderRadius,
    required this.textStyle,
    required this.iconSize,
  });
}