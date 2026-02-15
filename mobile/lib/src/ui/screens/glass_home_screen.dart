import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/service_locator.dart'
    if (dart.library.html) 'package:mobile/src/service_locator_web.dart';

import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/widgets/glass_chip.dart';
import 'package:mobile/src/ui/widgets/recording_button.dart';
import 'package:mobile/src/ui/widgets/waveform_strip.dart';
import 'package:mobile/src/ui/screens/video_recording_screen.dart';

/// New dark glassmorphism home screen based on Stitch design
class GlassHomeScreen extends StatefulWidget {
  const GlassHomeScreen({Key? key}) : super(key: key);

  @override
  State<GlassHomeScreen> createState() => _GlassHomeScreenState();
}

class _GlassHomeScreenState extends State<GlassHomeScreen> {
  bool _isRecording = false;

  void _toggleRecording() {
    HapticFeedback.mediumImpact();
    // Navigate to full-screen video recording
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VideoRecordingScreen(),
      ),
    );
  }

  void _activateEmergency() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            SizedBox(width: 8),
            Text('EMERGENCY MODE ACTIVATED'),
          ],
        ),
        backgroundColor: AppColors.glassDestructive,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        // Design ref: gradient from #0a0a0a via #0f1729 to #0a0a0a
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF0F1729), // Subtle blue-ish dark mid-point
            Color(0xFF0A0A0A),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Status Bar
            _buildStatusBar(),

            const SizedBox(height: 24),

            // Status Cards (design ref: 2-column grid)
            _buildStatusCards(),

            const SizedBox(height: 16),

            // Recent Sessions
            _buildRecentSessions(),

            // Main Recording Area
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Recording Button
                      RecordingButton(
                        isRecording: _isRecording,
                        onTap: _toggleRecording,
                        onLongPress: _activateEmergency,
                        size: 160,
                      ),

                      const SizedBox(height: 24),

                      // Status Text
                      Text(
                        _isRecording ? 'Recording...' : 'Tap to Record',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        _isRecording
                            ? 'Long press to activate emergency mode'
                            : 'Hold for 3s to activate SOS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),

                      // Waveform when recording
                      if (_isRecording) ...[
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: LiveWaveform(
                            isActive: true,
                            height: 48,
                            barCount: 40,
                            color: AppColors.glassPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Quick Actions (design ref: 3-column grid)
            _buildQuickActions(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.glassPrimary, AppColors.glassAccent],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shield,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'COPSTOPPER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),

          // Status indicators
          Row(
            children: [
              _buildStatusPill(Icons.location_on, 'GPS', true),
              const SizedBox(width: 8),
              _buildStatusPill(Icons.wifi, 'Online', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(IconData icon, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.glassSuccess.withOpacity(0.2)
            : AppColors.glassSurfaceBase,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppColors.glassSuccess.withOpacity(0.5)
              : AppColors.glassBorderSubtle,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isActive ? AppColors.glassSuccess : AppColors.glassTextMuted,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color:
                  isActive ? AppColors.glassSuccess : AppColors.glassTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Status cards matching Dashboard.tsx design (2-column grid)
  Widget _buildStatusCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Ready to Record card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glassCardBackground,
                borderRadius: BorderRadius.circular(16), // rounded-2xl
                border: Border.all(color: AppColors.glassCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.glassSuccess,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'READY TO RECORD',
                        style: TextStyle(
                          color: AppColors.glassTextMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'System Online',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Storage card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.glassCardBackground,
                borderRadius: BorderRadius.circular(16), // rounded-2xl
                border: Border.all(color: AppColors.glassCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STORAGE',
                    style: TextStyle(
                      color: AppColors.glassTextMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '14.2 GB',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Recent sessions section matching Dashboard.tsx design
  Widget _buildRecentSessions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECENT SESSIONS',
                style: TextStyle(
                  color: AppColors.glassTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: TextStyle(
                    color: AppColors.glassPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          // Session card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.glassCardBackground,
              borderRadius: BorderRadius.circular(16), // rounded-2xl
              border: Border.all(color: AppColors.glassCardBorder),
            ),
            child: Row(
              children: [
                // Play icon container
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.glassRecording.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: AppColors.glassRecording,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                // Session info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Traffic Stop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Today, 2:43 PM',
                        style: TextStyle(
                          color: AppColors.glassTextMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Duration
                Text(
                  '4:12',
                  style: TextStyle(
                    color: AppColors.glassTextMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassChipRow(
        chips: [
          GlassChip(
            label: 'Know Your Rights',
            icon: Icons.gavel,
            onTap: () {},
          ),
          GlassChip(
            label: 'Emergency',
            icon: Icons.warning,
            onTap: _activateEmergency,
          ),
          GlassChip(
            label: 'History',
            icon: Icons.history,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
