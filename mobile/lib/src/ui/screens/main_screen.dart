
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile/src/service_locator.dart' if (dart.library.html) 'package:mobile/src/service_locator_web.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/offline_service.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/app_spacing.dart';
import 'package:mobile/src/ui/app_text_styles.dart';
import 'package:mobile/src/ui/components/glass_morphism_container.dart';
import 'package:mobile/src/ui/components/figma_badge.dart';
import 'package:mobile/src/ui/components/shadcn_card.dart';
import 'package:mobile/src/ui/widgets/offline_indicator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final RecordingService _recordingService = locator<RecordingService>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    return Consumer<OfflineService>(
      builder: (context, offlineService, child) {
        return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassMorphismAppBar(
        title: Text(
          'Cop Stopper',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          ConnectivityIndicator(),
          SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF8FAFC), // slate-50 from Figma
              Color(0xFFEFF6FF), // blue-50 from Figma
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Status Bar
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status badges
                    Semantics(
                      container: true,
                      label: 'Status indicators showing GPS and internet connection status',
                      child: Row(
                        children: [
                          Semantics(
                            button: true,
                            label: 'GPS status: Ready',
                            child: const FigmaBadge.success(
                              text: 'GPS Ready',
                              icon: Icon(Icons.location_on, size: 12, color: Color(0xFF2E7D32)),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Consumer<OfflineService>(
                            builder: (context, offlineService, child) {
                              return ConnectivityIndicator();
                            },
                          ),
                        ],
                      ),
                    ),
                    // Battery indicator
                    Row(
                      children: [
                        Icon(Icons.battery_std, size: 16, color: AppColors.mutedForeground),
                        const SizedBox(width: AppSpacing.xs / 2),
                        Text(
                          '89%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mutedForeground,
                            fontWeight: FontWeight.w500, // Bold for better hierarchy
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Offline indicator
              const OfflineIndicator(),

              // App Title and Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    Text(
                      'Cop Stopper',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.primary, // Use primary accent color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Secure documentation for your safety',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w500, // Slightly bolder for better hierarchy
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Main Recording Button
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        button: true,
                        label: _recordingService.isRecording 
                            ? 'Stop recording' 
                            : 'Start recording',
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            if (_recordingService.isRecording) {
                              _recordingService.stopAudioVideoRecording();
                            } else {
                              _recordingService.startAudioVideoRecording();
                            }
                            setState(() {});
                          },
                          child: FigmaRecordingButton(
                            isRecording: _recordingService.isRecording,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          'Press and hold to start recording. Your location and audio will be securely documented.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Emergency Button (Prominent emergency workflow)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
                child: Semantics(
                  button: true,
                  label: 'Activate emergency mode - enables location sharing and alerts emergency contacts',
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF6B6B), // Red
                          Color(0xFFD9534F), // Darker red
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        // Trigger emergency mode - in a real implementation, this would connect to the emergency BLoC
                        // For now, we'll just show a snackbar to indicate the action
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.white),
                                SizedBox(width: 8),
                                Text('EMERGENCY MODE ACTIVATED'),
                              ],
                            ),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'EMERGENCY MODE',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Quick Info Cards
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassMorphismContainer(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            Icon(
                              Icons.signal_cellular_alt,
                              size: 16,
                              color: AppColors.success, // Use accent color
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Network',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                  Text(
                                    'Strong',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.success, // Use accent color
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GlassMorphismContainer(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.success, // Use accent color
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.mutedForeground,
                                    ),
                                  ),
                                  Text(
                                    'Acquired',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: AppColors.success, // Use accent color
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}

/// Figma-styled recording button
class FigmaRecordingButton extends StatelessWidget {
  final bool isRecording;

  const FigmaRecordingButton({Key? key, required this.isRecording})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 192,
      height: 192,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary, // Dark color from Figma
        borderRadius: BorderRadius.circular(96),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRecording ? Icons.stop_rounded : Icons.fiber_manual_record,
            size: 64,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap to Record',
            style: AppTextStyles.titleMedium.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
}
