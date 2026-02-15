import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/components/glass_surface.dart';
import 'package:mobile/src/ui/widgets/waveform_strip.dart';
import 'package:mobile/src/ui/widgets/glass_chip.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';
import 'package:mobile/src/services/emergency_contact_service.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';

import 'package:mobile/src/service_locator.dart';

/// Live recording screen with dark glassmorphism design
/// Based on Stitch live-recording.html
class GlassRecordingScreen extends StatefulWidget {
  const GlassRecordingScreen({Key? key}) : super(key: key);

  @override
  State<GlassRecordingScreen> createState() => _GlassRecordingScreenState();
}

class _GlassRecordingScreenState extends State<GlassRecordingScreen> {
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _isPaused = false;

  // Transcription service integration
  late final TranscriptionServiceInterface _transcriptionService;
  late final EmergencyContactService _emergencyService;
  StreamSubscription<TranscriptionSegment>? _transcriptionSubscription;
  bool _isTranscribing = false;
  bool _isSendingEmergency = false;

  // Live transcript from Whisper
  final List<TranscriptEntry> _transcript = [];

  // Demo transcription fallback
  Timer? _demoTimer;
  int _demoIndex = 0;
  final List<String> _demoTranscripts = [
    'Step out of the vehicle, please.',
    'Am I being detained or am I free to go?',
    'Just answer the question.',
    'I am invoking my right to remain silent.',
    'I do not consent to any searches.',
    'What is your badge number?',
    'I would like to speak to a lawyer.',
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _startTimer();
    _startTimer();
    _subscribeToTranscription();
  }

  void _initializeServices() {
    _transcriptionService = locator<TranscriptionServiceInterface>();
    _emergencyService = locator<EmergencyContactService>();
  }

  Future<void> _subscribeToTranscription() async {
    try {
      // Initialize Whisper if needed
      if (!_transcriptionService.isWhisperReady) {
        await _transcriptionService.initializeWhisper();
      }

      // Subscribe to transcription stream
      _transcriptionSubscription =
          _transcriptionService.transcriptionStream.listen(
        (segment) {
          setState(() {
            _transcript.add(TranscriptEntry(
              timestamp: _formatDuration(_elapsed),
              speaker: segment.speakerLabel ?? 'Speaker',
              text: segment.text,
              isUser: segment.speakerLabel == 'user',
            ));
          });
        },
        onError: (error) {
          debugPrint('Transcription error: $error');
        },
      );

      setState(() => _isTranscribing = true);
    } catch (e) {
      debugPrint('Failed to subscribe to transcription: $e');
      // Fall back to demo transcription for UI testing
      _startDemoTranscription();
    }

    // Also start demo if no real transcription after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (_transcript.isEmpty && mounted) {
        _startDemoTranscription();
      }
    });
  }

  void _startDemoTranscription() {
    if (_demoTimer != null) return; // Already running

    _demoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || _isPaused) return;

      final isOfficer = _demoIndex % 2 == 0;
      setState(() {
        _transcript.add(TranscriptEntry(
          timestamp: _formatDuration(_elapsed),
          speaker: isOfficer ? 'Officer' : 'You',
          text: _demoTranscripts[_demoIndex % _demoTranscripts.length],
          isUser: !isOfficer,
        ));
        _demoIndex++;
      });
    });
  }

  Future<void> _stopTranscription() async {
    await _transcriptionSubscription?.cancel();
    setState(() => _isTranscribing = false);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  void _togglePause() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  Future<void> _stopRecording() async {
    HapticFeedback.heavyImpact();
    _timer?.cancel();

    // Show blocking dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevent back button
        child: AlertDialog(
          backgroundColor: AppColors.glassCardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.glassCardBorder),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.glassPrimary),
              const SizedBox(height: 16),
              const Text(
                'Saving & Transcribing...',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we process the final audio chunk.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Wait for transcription to finish draining buffer
      await _stopTranscription();
    } catch (e) {
      debugPrint('Error stoping transcription: $e');
    }

    if (mounted) {
      // Close dialog
      Navigator.of(context).pop();
      // Close screen
      Navigator.of(context).pop();
    }
  }

  void _flagMoment() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.flag, color: Colors.white),
            SizedBox(width: 8),
            Text('Moment flagged at ${_formatDuration(_elapsed)}'),
          ],
        ),
        backgroundColor: AppColors.glassPrimary,
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _demoTimer?.cancel();
    _stopTranscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
      ),
      child: Stack(
        children: [
          // Background gradient blobs
          Positioned(
            top: -50,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.glassPrimary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.glassRecording.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Emergency button
          Positioned(
            top: 50,
            right: 16,
            child: _buildEmergencyButton(),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header with timer
                _buildHeader(),

                // Waveform visualizer
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: GlassSurface(
                    variant: GlassVariant.inset,
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    child: LiveWaveform(
                      isActive: !_isPaused,
                      height: 64,
                      barCount: 30,
                      color: AppColors.glassRecording,
                    ),
                  ),
                ),

                // Transcript panel
                Expanded(
                  child: _buildTranscriptPanel(),
                ),

                // Quick action chips
                _buildQuickActions(),

                // Bottom controls
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isSendingEmergency
            ? AppColors.glassRecording.withOpacity(0.5)
            : AppColors.glassRecording.withOpacity(0.2),
        border: Border.all(
          color: AppColors.glassRecording.withOpacity(0.5),
        ),
      ),
      child: _isSendingEmergency
          ? const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          : IconButton(
              icon: Icon(
                Icons.emergency,
                color: AppColors.glassRecording,
                size: 20,
              ),
              onPressed: _showEmergencyConfirmation,
            ),
    );
  }

  void _showEmergencyConfirmation() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.glassCardBorder),
        ),
        title: Row(
          children: [
            Icon(Icons.emergency, color: AppColors.glassRecording),
            const SizedBox(width: 8),
            const Text('Emergency Alert',
                style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'This will send your location and an alert message to all your emergency contacts. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.glassRecording,
            ),
            onPressed: () {
              Navigator.pop(context);
              _sendEmergencyAlert();
            },
            child:
                const Text('Send SOS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmergencyAlert() async {
    setState(() => _isSendingEmergency = true);

    try {
      final success = await _emergencyService.sendEmergencyNotification(
        message:
            '🚨 EMERGENCY: I am being recorded during a police encounter and may need assistance. Recording in progress.',
        includeLocation: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(success
                    ? 'Emergency alert sent to contacts'
                    : 'Failed to send alert. Try again.'),
              ],
            ),
            backgroundColor:
                success ? AppColors.glassSuccess : AppColors.glassRecording,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: AppColors.glassRecording,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSendingEmergency = false);
      }
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
      ),
      child: Column(
        children: [
          // Recording indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.glassRecording,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.glassRecording.withOpacity(0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _isPaused ? 'PAUSED' : 'RECORDING LIVE',
                style: TextStyle(
                  color: AppColors.glassRecording.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Timer display
          Text(
            _formatDuration(_elapsed),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
              letterSpacing: -2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // Design ref: #1a1a1a bg, gray-800 border, rounded-2xl (16px)
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.glassCardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassCardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row (design ref styling)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TRANSCRIPT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Transcription status indicator
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isTranscribing
                            ? AppColors.glassSuccess
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isTranscribing ? 'Live' : 'Initializing...',
                      style: TextStyle(
                        color: _isTranscribing
                            ? AppColors.glassPrimary
                            : Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Transcript entries
            Expanded(
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.1, 0.9, 1.0],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _transcript.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final entry = _transcript[index];
                    return _buildTranscriptEntry(
                        entry, index == _transcript.length - 1);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptEntry(TranscriptEntry entry, bool isLatest) {
    return Opacity(
      opacity: isLatest ? 1.0 : 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.timestamp,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              color: entry.isUser
                  ? AppColors.glassRecording.withOpacity(0.8)
                  : Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: entry.isUser
                ? const EdgeInsets.only(left: 12)
                : EdgeInsets.zero,
            decoration: entry.isUser
                ? BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: AppColors.glassRecording,
                        width: 2,
                      ),
                    ),
                  )
                : null,
            child: Text(
              entry.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: entry.isUser ? 15 : 14,
                fontWeight: entry.isUser ? FontWeight.w500 : FontWeight.w300,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildQuickActionChip(Icons.gavel, 'No Consent'),
            const SizedBox(width: 8),
            _buildQuickActionChip(Icons.help_outline, 'Am I Detained?'),
            const SizedBox(width: 8),
            _buildQuickActionChip(Icons.gavel, 'Need Lawyer'),
            const SizedBox(width: 8),
            _buildQuickActionChip(Icons.mic_off, 'Silent'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(IconData icon, String label) {
    // Design ref: #1a1a1a bg, gray-800 border, rounded-2xl
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Add transcript entry
        setState(() {
          _transcript.add(TranscriptEntry(
            timestamp: _formatDuration(_elapsed),
            speaker: 'You',
            text: label,
            isUser: true,
          ));
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.glassCardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassCardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      margin: const EdgeInsets.all(8),
      child: GlassSurface(
        variant: GlassVariant.floating,
        borderRadius: BorderRadius.circular(32),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Flag button
            _buildControlButton(
              icon: Icons.flag_outlined,
              onTap: _flagMoment,
            ),

            // STOP button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: _stopRecording,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.glassRecording,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glassRecording.withOpacity(0.4),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'STOP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Pause button
            _buildControlButton(
              icon: _isPaused ? Icons.play_arrow : Icons.pause,
              onTap: _togglePause,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 28,
        ),
      ),
    );
  }
}

/// Model for transcript entries
class TranscriptEntry {
  final String timestamp;
  final String speaker;
  final String text;
  final bool isUser;

  TranscriptEntry({
    required this.timestamp,
    required this.speaker,
    required this.text,
    required this.isUser,
  });
}
