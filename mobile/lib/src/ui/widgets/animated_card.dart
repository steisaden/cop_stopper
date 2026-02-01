import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import 'base_card.dart';

/// Animated card component with smooth transitions and micro-interactions
/// Supports loading, error, and success states with appropriate visual feedback.
class AnimatedCard extends StatefulWidget {
  const AnimatedCard({
    super.key,
    required this.child,
    this.state = CardState.normal,
    this.onTap,
    this.onStateChanged,
    this.animationDuration,
    this.loadingWidget,
    this.errorWidget,
    this.successWidget,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.semanticLabel,
  });

  /// The widget to display when in normal state
  final Widget child;

  /// Current state of the card
  final CardState state;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when state changes
  final ValueChanged<CardState>? onStateChanged;

  /// Duration for state transition animations
  final Duration? animationDuration;

  /// Custom loading widget (defaults to CircularProgressIndicator)
  final Widget? loadingWidget;

  /// Custom error widget
  final Widget? errorWidget;

  /// Custom success widget
  final Widget? successWidget;

  /// Background color override
  final Color? backgroundColor;

  /// Internal padding
  final EdgeInsetsGeometry? padding;

  /// External margin
  final EdgeInsetsGeometry? margin;

  /// Semantic label for accessibility
  final String? semanticLabel;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late AnimationController _colorController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;

  CardState _previousState = CardState.normal;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: widget.animationDuration ?? AppSpacing.animationDurationShort,
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: widget.animationDuration ?? AppSpacing.animationDurationMedium,
      vsync: this,
    );
    
    _colorController = AnimationController(
      duration: widget.animationDuration ?? AppSpacing.animationDurationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.value = 1.0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateColorAnimation();
  }

  @override
  void didUpdateWidget(AnimatedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.state != widget.state) {
      _handleStateChange(oldWidget.state, widget.state);
    }
  }

  void _updateColorAnimation() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    
    Color fromColor = widget.backgroundColor ?? colorScheme.surface;
    Color toColor = _getStateBackgroundColor(widget.state, colorScheme);

    _colorAnimation = ColorTween(
      begin: fromColor,
      end: toColor,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
  }

  Color _getStateBackgroundColor(CardState state, ColorScheme colorScheme) {
    switch (state) {
      case CardState.normal:
        return widget.backgroundColor ?? colorScheme.surface;
      case CardState.loading:
        return colorScheme.surfaceContainerHighest;
      case CardState.success:
        return AppColors.successContainer;
      case CardState.error:
        return AppColors.errorContainer;
    }
  }

  void _handleStateChange(CardState oldState, CardState newState) {
    _previousState = oldState;
    
    // Trigger state change callback
    widget.onStateChanged?.call(newState);
    
    // Animate color change
    _updateColorAnimation();
    _colorController.forward();
    
    // Handle specific state transitions
    if (newState == CardState.loading) {
      _fadeController.forward();
    } else if (oldState == CardState.loading) {
      _fadeController.reverse();
    }
    
    // Success state animation
    if (newState == CardState.success) {
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
  }

  void _handleTap() {
    if (widget.state != CardState.loading) {
      // Tap animation
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
      
      widget.onTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleController,
        _fadeController,
        _colorController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: BaseCard(
            backgroundColor: _colorAnimation.value,
            padding: widget.padding,
            margin: widget.margin,
            onTap: widget.state != CardState.loading ? _handleTap : null,
            semanticLabel: widget.semanticLabel,
            child: Stack(
              children: [
                // Main content
                AnimatedOpacity(
                  opacity: widget.state == CardState.loading 
                      ? 1.0 - _fadeAnimation.value 
                      : 1.0,
                  duration: widget.animationDuration ?? AppSpacing.animationDurationMedium,
                  child: _buildStateContent(),
                ),
                
                // Loading overlay
                if (widget.state == CardState.loading)
                  AnimatedOpacity(
                    opacity: _fadeAnimation.value,
                    duration: widget.animationDuration ?? AppSpacing.animationDurationMedium,
                    child: _buildLoadingOverlay(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStateContent() {
    switch (widget.state) {
      case CardState.normal:
      case CardState.loading:
        return widget.child;
      case CardState.success:
        return widget.successWidget ?? _buildDefaultSuccessWidget();
      case CardState.error:
        return widget.errorWidget ?? _buildDefaultErrorWidget();
    }
  }

  Widget _buildLoadingOverlay() {
    return Center(
      child: widget.loadingWidget ?? const CircularProgressIndicator(),
    );
  }

  Widget _buildDefaultSuccessWidget() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          size: 48,
          color: AppColors.success,
        ),
        AppSpacing.verticalSpaceSM,
        Text(
          'Success',
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.onSuccessContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultErrorWidget() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          size: 48,
          color: AppColors.error,
        ),
        AppSpacing.verticalSpaceSM,
        Text(
          'Error',
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}

/// States for animated cards
enum CardState {
  normal,
  loading,
  success,
  error,
}

/// Stateful animated card that can be controlled externally
class StatefulAnimatedCard extends StatefulWidget {
  const StatefulAnimatedCard({
    super.key,
    required this.child,
    this.initialState = CardState.normal,
    this.onTap,
    this.animationDuration,
    this.loadingWidget,
    this.errorWidget,
    this.successWidget,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.semanticLabel,
  });

  final Widget child;
  final CardState initialState;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? successWidget;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? semanticLabel;

  @override
  State<StatefulAnimatedCard> createState() => StatefulAnimatedCardState();
}

class StatefulAnimatedCardState extends State<StatefulAnimatedCard> {
  late CardState _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
  }

  /// Update the card state externally
  void setCardState(CardState newState) {
    if (mounted && _currentState != newState) {
      setState(() {
        _currentState = newState;
      });
    }
  }

  /// Get the current card state
  CardState get currentState => _currentState;

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      state: _currentState,
      onTap: widget.onTap,
      animationDuration: widget.animationDuration,
      loadingWidget: widget.loadingWidget,
      errorWidget: widget.errorWidget,
      successWidget: widget.successWidget,
      backgroundColor: widget.backgroundColor,
      padding: widget.padding,
      margin: widget.margin,
      semanticLabel: widget.semanticLabel,
      child: widget.child,
    );
  }
}