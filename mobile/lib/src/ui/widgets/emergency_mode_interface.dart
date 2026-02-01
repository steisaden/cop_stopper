import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_bloc.dart';
import 'package:mobile/src/blocs/emergency/emergency_event.dart';
import 'package:mobile/src/blocs/emergency/emergency_state.dart';
import 'package:mobile/src/ui/app_spacing.dart';
import 'package:mobile/src/ui/app_text_styles.dart';

/// Simplified emergency interface with large, high-contrast buttons
class EmergencyModeInterface extends StatelessWidget {
  const EmergencyModeInterface({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyBloc, EmergencyState>(
      builder: (context, state) {
        return Container(
          color: Colors.black,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Emergency status header
                  _buildEmergencyHeader(context, state),
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Main action buttons
                  Expanded(
                    child: _buildActionButtons(context, state),
                  ),
                  
                  // Stop emergency mode button
                  _buildStopButton(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyHeader(BuildContext context, EmergencyState state) {
    final duration = state.emergencyDuration;
    final durationText = duration != null
        ? '${duration.inMinutes.toString().padLeft(2, '0')}:'
          '${(duration.inSeconds % 60).toString().padLeft(2, '0')}'
        : '00:00';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.red.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade400, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emergency,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'EMERGENCY MODE ACTIVE',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Duration: $durationText',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              state.errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.orange,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, EmergencyState state) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.lg,
      mainAxisSpacing: AppSpacing.lg,
      children: [
        _buildActionButton(
          context: context,
          icon: state.isRecording ? Icons.stop_circle : Icons.videocam,
          label: state.isRecording ? 'STOP\nRECORDING' : 'START\nRECORDING',
          isActive: state.isRecording,
          onPressed: () {
            if (state.isRecording) {
              context.read<EmergencyBloc>().add(const EmergencyRecordingStopped());
            } else {
              context.read<EmergencyBloc>().add(const EmergencyRecordingStarted());
            }
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.location_on,
          label: 'SHARE\nLOCATION',
          isActive: state.isLocationShared,
          onPressed: () {
            context.read<EmergencyBloc>().add(const EmergencyLocationShared());
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.gavel,
          label: 'LEGAL\nHELP',
          isActive: false,
          onPressed: () {
            context.read<EmergencyBloc>().add(const EmergencyLegalHelpRequested());
          },
        ),
        _buildActionButton(
          context: context,
          icon: Icons.phone,
          label: 'CALL\nEMERGENCY',
          isActive: false,
          color: Colors.blue.shade700,
          onPressed: () {
            context.read<EmergencyBloc>().add(const EmergencyServicesContacted());
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final buttonColor = color ?? (isActive ? Colors.green.shade700 : Colors.grey.shade700);
    
    return Container(
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? Colors.white : Colors.grey.shade500,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.mediumImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (isActive) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStopButton(BuildContext context, EmergencyState state) {
    return Container(
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      child: ElevatedButton(
        onPressed: () {
          context.read<EmergencyBloc>().add(const EmergencyStopConfirmationRequested());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade800,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stop, size: 32),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'STOP EMERGENCY MODE',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Emergency mode overlay that can be shown over any screen
class EmergencyModeOverlay extends StatelessWidget {
  final Widget child;

  const EmergencyModeOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmergencyBloc, EmergencyState>(
      builder: (context, state) {
        return Stack(
          children: [
            child,
            if (state.isEmergencyModeActive)
              const EmergencyModeInterface(),
          ],
        );
      },
    );
  }
}