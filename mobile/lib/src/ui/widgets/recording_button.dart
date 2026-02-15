import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../app_colors.dart';

/// The primary "Start Recording" button with pulsing glow effect.
///
/// Features:
/// - Pulsing blue glow animation when idle
/// - Red glow when recording
/// - Long press for emergency SOS
/// - Central recording icon
///
/// Example:
/// ```dart
/// RecordingButton(
///   onTap: () => startRecording(),
///   onLongPress: () => triggerSOS(),
///   isRecording: false,
/// )
/// ```
class RecordingButton extends StatefulWidget {
  /// Callback when tapped to start/stop recording
  final VoidCallback onTap;

  /// Callback for long press (emergency SOS)
  final VoidCallback? onLongPress;

  /// Whether currently recording
  final bool isRecording;

  /// Elapsed recording duration (for display)
  final Duration? elapsed;

  /// Size of the button
  final double size;

  const RecordingButton({
    super.key,
    required this.onTap,
    this.onLongPress,
    this.isRecording = false,
    this.elapsed,
    this.size = 192,
  });

  @override
  State<RecordingButton> createState() => _RecordingButtonState();
}

class _RecordingButtonState extends State<RecordingButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _pressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Pulse animation for glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.4,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Press animation for scale
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  Color get _glowColor =>
      widget.isRecording ? AppColors.glassRecording : AppColors.glassPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      onLongPress: widget.onLongPress != null
          ? () {
              HapticFeedback.heavyImpact();
              widget.onLongPress!();
            }
          : null,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow - large blur
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, _) {
                  return Container(
                    width: widget.size * 1.3,
                    height: widget.size * 1.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _glowColor.withOpacity(
                        widget.isRecording ? 0.3 : _pulseAnimation.value * 0.2,
                      ),
                    ),
                  );
                },
              ),

              // Middle glow - medium blur
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, _) {
                  return Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _glowColor.withOpacity(
                        widget.isRecording ? 0.2 : _pulseAnimation.value * 0.1,
                      ),
                    ),
                  );
                },
              ),

              // Main button with glass effect
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _glowColor.withOpacity(0.2),
                          _glowColor.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: _glowColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _glowColor.withOpacity(0.1),
                          blurRadius: 1,
                        ),
                        BoxShadow(
                          color: _glowColor.withOpacity(0.2),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Inner ring
                        Container(
                          width: widget.size - 16,
                          height: widget.size - 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),

                        // Center content
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Record icon
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: _glowColor,
                                borderRadius: BorderRadius.circular(
                                  widget.isRecording ? 32 : 8,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _glowColor.withOpacity(0.5),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: widget.isRecording
                                  ? const Icon(
                                      Icons.stop,
                                      color: Colors.white,
                                      size: 32,
                                    )
                                  : Center(
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),

                            // Text label
                            Text(
                              widget.isRecording ? 'STOP' : 'START',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.isRecording
                                  ? _formatDuration(
                                      widget.elapsed ?? Duration.zero)
                                  : 'RECORDING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.6),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
