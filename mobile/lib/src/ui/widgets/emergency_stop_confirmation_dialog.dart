import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_event.dart';
import 'package:mobile/src/blocs/emergency/emergency_state.dart';
import 'package:mobile/src/ui/app_spacing.dart';
import 'package:mobile/src/ui/app_text_styles.dart';

/// Confirmation dialog for stopping emergency mode with accidental prevention
class EmergencyStopConfirmationDialog extends StatefulWidget {
  const EmergencyStopConfirmationDialog({Key? key}) : super(key: key);

  @override
  State<EmergencyStopConfirmationDialog> createState() =>
      _EmergencyStopConfirmationDialogState();
}

class _EmergencyStopConfirmationDialogState
    extends State<EmergencyStopConfirmationDialog>
    with TickerProviderStateMixin {
  late AnimationController _countdownController;
  late Animation<double> _countdownAnimation;
  bool _canConfirm = false;
  int _countdown = 3;

  @override
  void initState() {
    super.initState();
    
    // Countdown animation to prevent accidental stopping
    _countdownController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _countdownAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _countdownController,
      curve: Curves.linear,
    ));

    _countdownController.addListener(() {
      final newCountdown = (3 - (_countdownAnimation.value * 3)).ceil();
      if (newCountdown != _countdown) {
        setState(() {
          _countdown = newCountdown;
        });
      }
    });

    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _canConfirm = true;
        });
      }
    });

    // Start countdown
    _countdownController.forward();
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  void _confirmStop() {
    HapticFeedback.heavyImpact();
    context.read<EmergencyBloc>().add(
      const EmergencyModeDeactivated(confirmed: true),
    );
    Navigator.of(context).pop();
  }

  void _cancel() {
    HapticFeedback.lightImpact();
    context.read<EmergencyBloc>().add(
      const EmergencyStopConfirmationDismissed(),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade400, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning icon and title
            Icon(
              Icons.warning_rounded,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: AppSpacing.lg),
            
            Text(
              'Stop Emergency Mode?',
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            Text(
              'This will stop all emergency actions including recording, monitoring, and location sharing.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Countdown indicator
            if (!_canConfirm) ...[
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade400, width: 3),
                ),
                child: Stack(
                  children: [
                    // Countdown progress
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _countdownAnimation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _countdownAnimation.value,
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red.shade400,
                            ),
                            backgroundColor: Colors.transparent,
                          );
                        },
                      ),
                    ),
                    // Countdown number
                    Center(
                      child: Text(
                        _countdown.toString(),
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Please wait to prevent accidental stopping',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white60,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: AppSpacing.xl),
            
            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: Container(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _cancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Text(
                        'CANCEL',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: AppSpacing.md),
                
                // Confirm button
                Expanded(
                  child: Container(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _canConfirm ? _confirmStop : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canConfirm 
                            ? Colors.red.shade700 
                            : Colors.grey.shade800,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _canConfirm ? 4 : 0,
                      ),
                      child: Text(
                        'STOP',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: _canConfirm ? Colors.white : Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that shows the confirmation dialog when needed
class EmergencyStopConfirmationHandler extends StatelessWidget {
  final Widget child;

  const EmergencyStopConfirmationHandler({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmergencyBloc, EmergencyState>(
      listener: (context, state) {
        if (state.showStopConfirmation) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const EmergencyStopConfirmationDialog(),
          );
        }
      },
      child: child,
    );
  }
}