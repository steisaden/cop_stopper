import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_event.dart';
import 'package:mobile/src/blocs/emergency/emergency_state.dart';
import 'package:mobile/src/ui/app_spacing.dart';
import 'package:mobile/src/ui/app_text_styles.dart';

/// Prominent emergency button for one-tap emergency mode activation
class EmergencyButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isCompact;

  const EmergencyButton({
    Key? key,
    this.onPressed,
    this.isCompact = false,
  }) : super(key: key);

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for emergency state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for press feedback
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onPressed() {
    // Haptic feedback for emergency action
    HapticFeedback.heavyImpact();
    
    // Scale animation for visual feedback
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // Trigger emergency mode activation
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      context.read<EmergencyBloc>().add(const EmergencyModeActivated());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyBloc, EmergencyState>(
      builder: (context, state) {
        // Start/stop pulse animation based on emergency state
        if (state.isEmergencyModeActive && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        } else if (!state.isEmergencyModeActive && _pulseController.isAnimating) {
          _pulseController.stop();
          _pulseController.reset();
        }

        return AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _scaleAnimation]),
          builder: (context, child) {
            final size = widget.isCompact ? 80.0 : 120.0;
            final iconSize = widget.isCompact ? 32.0 : 48.0;
            
            return Transform.scale(
              scale: _scaleAnimation.value * 
                     (state.isEmergencyModeActive ? _pulseAnimation.value : 1.0),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: state.isEmergencyModeActive
                        ? [
                            Colors.red.shade400,
                            Colors.red.shade600,
                            Colors.red.shade800,
                          ]
                        : [
                            Colors.orange.shade400,
                            Colors.orange.shade600,
                            Colors.red.shade600,
                          ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (state.isEmergencyModeActive 
                          ? Colors.red 
                          : Colors.orange).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _onPressed,
                    borderRadius: BorderRadius.circular(size / 2),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              state.isEmergencyModeActive
                                  ? Icons.emergency
                                  : Icons.warning_rounded,
                              size: iconSize,
                              color: Colors.white,
                            ),
                            if (!widget.isCompact) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                state.isEmergencyModeActive ? 'ACTIVE' : 'SOS',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
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
      },
    );
  }
}

/// Floating emergency button that can be overlaid on any screen
class FloatingEmergencyButton extends StatelessWidget {
  final Alignment alignment;
  final EdgeInsets margin;

  const FloatingEmergencyButton({
    Key? key,
    this.alignment = Alignment.bottomRight,
    this.margin = const EdgeInsets.all(AppSpacing.md),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          margin: margin,
          child: const EmergencyButton(isCompact: true),
        ),
      ),
    );
  }
}