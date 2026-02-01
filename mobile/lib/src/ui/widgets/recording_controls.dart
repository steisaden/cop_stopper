import 'package:flutter/material.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/app_spacing.dart';
import '../components/shadcn_button.dart';

/// Recording controls interface with primary record button and secondary controls
/// Provides recording start/stop, audio-only mode, flash toggle, and settings access
class RecordingControls extends StatefulWidget {
  final bool isRecording;
  final bool isAudioOnly;
  final bool isFlashOn;
  final bool hasFlash;
  final VoidCallback? onRecordPressed;
  final VoidCallback? onAudioOnlyToggle;
  final VoidCallback? onFlashToggle;
  final VoidCallback? onSettingsPressed;
  final Duration? recordingDuration;
  final double audioLevel;
  final String? storageInfo;
  final bool showSecondaryControls;

  const RecordingControls({
    Key? key,
    this.isRecording = false,
    this.isAudioOnly = false,
    this.isFlashOn = false,
    this.hasFlash = false,
    this.onRecordPressed,
    this.onAudioOnlyToggle,
    this.onFlashToggle,
    this.onSettingsPressed,
    this.recordingDuration,
    this.audioLevel = 0.0,
    this.storageInfo,
    this.showSecondaryControls = true,
  }) : super(key: key);

  @override
  State<RecordingControls> createState() => _RecordingControlsState();
}

class _RecordingControlsState extends State<RecordingControls>
    with TickerProviderStateMixin {
  late AnimationController _pulseAnimationController;
  late AnimationController _waveformAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveformAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize pulse animation for recording button
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));

    // Initialize waveform animation for audio level
    _waveformAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _waveformAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveformAnimationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(RecordingControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle recording animation
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _pulseAnimationController.repeat(reverse: true);
      } else {
        _pulseAnimationController.stop();
        _pulseAnimationController.reset();
      }
    }

    // Handle audio level animation
    if (widget.audioLevel != oldWidget.audioLevel) {
      _waveformAnimationController.forward().then((_) {
        _waveformAnimationController.reverse();
      });
    }
  }

  @override
  void dispose() {
    _pulseAnimationController.dispose();
    _waveformAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Recording status and timer
            if (widget.isRecording || widget.recordingDuration != null)
              _buildRecordingStatus(),
            
            if (widget.isRecording || widget.recordingDuration != null)
              AppSpacing.verticalSpaceMD,

            // Audio level indicator
            if (widget.isRecording)
              _buildAudioLevelIndicator(),
            
            if (widget.isRecording)
              AppSpacing.verticalSpaceMD,

            // Main controls row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Secondary controls (left side)
                if (widget.showSecondaryControls)
                  _buildSecondaryControls(),
                
                // Primary record button (center)
                _buildRecordButton(),
                
                // Storage info and settings (right side)
                if (widget.showSecondaryControls)
                  _buildStorageAndSettings(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingStatus() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final duration = widget.recordingDuration ?? Duration.zero;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Recording indicator dot
        if (widget.isRecording)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: const BoxDecoration(
              color: AppColors.recording,
              shape: BoxShape.circle,
            ),
          ),
        
        // Recording timer
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: widget.isRecording ? AppColors.recording : colorScheme.onSurface,
          ),
        ),
        
        // Recording mode indicator
        if (widget.isAudioOnly)
          Container(
            margin: const EdgeInsets.only(left: AppSpacing.sm),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Text(
              'AUDIO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAudioLevelIndicator() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: AnimatedBuilder(
        animation: _waveformAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: WaveformPainter(
              audioLevel: widget.audioLevel,
              animationValue: _waveformAnimation.value,
              color: colorScheme.primary,
            ),
            size: const Size(double.infinity, 40),
          );
        },
      ),
    );
  }

  Widget _buildSecondaryControls() {
    return Column(
      children: [
        // Flash toggle (only show if flash is available)
        if (widget.hasFlash)
          _buildControlButton(
            icon: widget.isFlashOn ? Icons.flash_on : Icons.flash_off,
            onPressed: widget.onFlashToggle,
            isActive: widget.isFlashOn,
            tooltip: widget.isFlashOn ? 'Turn Flash Off' : 'Turn Flash On',
          ),
        
        if (widget.hasFlash)
          AppSpacing.verticalSpaceSM,
        
        // Audio-only mode toggle
        _buildControlButton(
          icon: widget.isAudioOnly ? Icons.videocam_off : Icons.videocam,
          onPressed: widget.onAudioOnlyToggle,
          isActive: widget.isAudioOnly,
          tooltip: widget.isAudioOnly ? 'Enable Video' : 'Audio Only',
        ),
      ],
    );
  }

  Widget _buildRecordButton() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isRecording ? _pulseAnimation.value : 1.0,
          child: Container(
            width: AppSpacing.recordButtonSize,
            height: AppSpacing.recordButtonSize,
            decoration: BoxDecoration(
              color: widget.isRecording ? AppColors.recording : colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.isRecording ? AppColors.recording : colorScheme.primary)
                      .withOpacity(0.3),
                  blurRadius: widget.isRecording ? 20 : 8,
                  spreadRadius: widget.isRecording ? 4 : 0,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.recordButtonSize / 2),
                onTap: widget.onRecordPressed,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: AppSpacing.animationDurationMedium,
                    child: Icon(
                      widget.isRecording ? Icons.stop : Icons.fiber_manual_record,
                      key: ValueKey(widget.isRecording),
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStorageAndSettings() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Storage info
        if (widget.storageInfo != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.xs),
            ),
            child: Text(
              widget.storageInfo!,
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        
        if (widget.storageInfo != null)
          AppSpacing.verticalSpaceSM,
        
        // Settings button
        _buildControlButton(
          icon: Icons.settings,
          onPressed: widget.onSettingsPressed,
          tooltip: 'Recording Settings',
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    bool isActive = false,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: ShadcnButton(
        onPressed: onPressed,
        variant: isActive ? ShadcnButtonVariant.primary : ShadcnButtonVariant.outline,
        size: ShadcnButtonSize.icon,
        child: Icon(
          icon,
          size: 20,
        ),
      ),
    );
  }
}

/// Custom painter for audio waveform visualization
class WaveformPainter extends CustomPainter {
  final double audioLevel;
  final double animationValue;
  final Color color;

  WaveformPainter({
    required this.audioLevel,
    required this.animationValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = 3.0;
    final barSpacing = 2.0;
    final totalBarWidth = barWidth + barSpacing;
    final barCount = (size.width / totalBarWidth).floor();

    for (int i = 0; i < barCount; i++) {
      final x = i * totalBarWidth + barWidth / 2;
      
      // Create varying heights based on audio level and position
      final normalizedPosition = i / barCount;
      final baseHeight = audioLevel * size.height * 0.8;
      final variation = (normalizedPosition - 0.5).abs() * 2; // Center emphasis
      final height = baseHeight * (1 - variation * 0.5) * animationValue;
      
      final startY = centerY - height / 2;
      final endY = centerY + height / 2;
      
      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return audioLevel != oldDelegate.audioLevel ||
           animationValue != oldDelegate.animationValue ||
           color != oldDelegate.color;
  }
}