import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_event.dart';
import 'package:mobile/src/blocs/emergency/emergency_state.dart';
import 'package:mobile/src/blocs/recording/recording_bloc.dart';
import 'package:mobile/src/ui/app_spacing.dart';
import 'package:mobile/src/ui/app_text_styles.dart';

/// Global emergency button that persists across all screens and can be minimized
class GlobalEmergencyButton extends StatefulWidget {
  const GlobalEmergencyButton({Key? key}) : super(key: key);

  @override
  State<GlobalEmergencyButton> createState() => _GlobalEmergencyButtonState();
}

class _GlobalEmergencyButtonState extends State<GlobalEmergencyButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isMinimized = false;
  bool _isDragging = false;
  Offset _position = const Offset(0.85, 0.15); // Top right by default

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for emergency state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for press feedback
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Slide animation for minimize/expand
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.7, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onPressed() {
    HapticFeedback.heavyImpact();
    
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    final emergencyBloc = context.read<EmergencyBloc>();
    final recordingBloc = context.read<RecordingBloc>();
    
    if (emergencyBloc.state.isEmergencyModeActive) {
      // Show stop confirmation
      emergencyBloc.add(const EmergencyStopConfirmationRequested());
    } else {
      // Start emergency mode (without automatic recording)
      emergencyBloc.add(const EmergencyModeActivated());
      
      // Show emergency activated feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('EMERGENCY MODE ACTIVATED'),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
        ),
      );
    }
  }

  void _onLongPress() {
    setState(() {
      _isMinimized = !_isMinimized;
    });
    
    if (_isMinimized) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
    
    HapticFeedback.mediumImpact();
  }

  void _onPanUpdate(DragUpdateDetails details, Size screenSize) {
    setState(() {
      _isDragging = true;
      _position = Offset(
        (_position.dx * screenSize.width + details.delta.dx) / screenSize.width,
        (_position.dy * screenSize.height + details.delta.dy) / screenSize.height,
      );
      
      // Keep button within screen bounds
      _position = Offset(
        _position.dx.clamp(0.0, 1.0),
        _position.dy.clamp(0.0, 1.0),
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    
    // Snap to edges for better UX
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final currentX = _position.dx * screenSize.width;
    
    setState(() {
      if (currentX < centerX) {
        _position = Offset(0.05, _position.dy); // Snap to left
      } else {
        _position = Offset(0.95, _position.dy); // Snap to right
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return BlocBuilder<EmergencyBloc, EmergencyState>(
      builder: (context, state) {
        // Control pulse animation
        if (state.isEmergencyModeActive && !_pulseController.isAnimating) {
          _pulseController.repeat(reverse: true);
        } else if (!state.isEmergencyModeActive && _pulseController.isAnimating) {
          _pulseController.stop();
          _pulseController.reset();
        }

        return Positioned(
          left: _position.dx * screenSize.width - (_isMinimized ? 30 : 40),
          top: _position.dy * screenSize.height - (_isMinimized ? 30 : 40),
          child: GestureDetector(
            onTap: _onPressed,
            onLongPress: _onLongPress,
            onPanUpdate: (details) => _onPanUpdate(details, screenSize),
            onPanEnd: _onPanEnd,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _pulseAnimation,
                _scaleAnimation,
                _slideAnimation,
              ]),
              builder: (context, child) {
                final size = _isMinimized ? 60.0 : 80.0;
                final iconSize = _isMinimized ? 20.0 : 28.0;
                
                return Transform.scale(
                  scale: _scaleAnimation.value * 
                         (state.isEmergencyModeActive ? _pulseAnimation.value : 1.0),
                  child: Transform.translate(
                    offset: _isMinimized ? _slideAnimation.value * 20 : Offset.zero,
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
                                : Colors.orange).withOpacity(_isDragging ? 0.6 : 0.4),
                            blurRadius: _isDragging ? 25 : 15,
                            spreadRadius: _isDragging ? 4 : 2,
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
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: _isMinimized
                                  ? Icon(
                                      state.isEmergencyModeActive
                                          ? Icons.stop
                                          : Icons.warning_rounded,
                                      key: const ValueKey('minimized'),
                                      size: iconSize,
                                      color: Colors.white,
                                    )
                                  : Column(
                                      key: const ValueKey('expanded'),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          state.isEmergencyModeActive
                                              ? Icons.stop
                                              : Icons.warning_rounded,
                                          size: iconSize,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          state.isEmergencyModeActive ? 'STOP' : 'SOS',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: _isMinimized ? 8 : 10,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Minimized emergency status indicator that shows when emergency mode is active
class EmergencyStatusIndicator extends StatelessWidget {
  const EmergencyStatusIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyBloc, EmergencyState>(
      builder: (context, state) {
        if (!state.isEmergencyModeActive) {
          return const SizedBox.shrink();
        }

        return Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade600.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emergency,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'EMERGENCY MODE ACTIVE',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}