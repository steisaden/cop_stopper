import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/recording/recording_bloc.dart';
import '../../blocs/recording/recording_event.dart';
import '../../blocs/recording/recording_state.dart';
import '../../blocs/transcription/transcription_bloc.dart';
import '../../blocs/transcription/transcription_event.dart';
import '../../blocs/transcription/transcription_state.dart';
import '../../blocs/emergency/emergency_bloc.dart';
import '../../blocs/emergency/emergency_event.dart';
import '../../blocs/emergency/emergency_state.dart';
import '../../blocs/navigation/navigation_bloc.dart';
import '../../blocs/navigation/navigation_event.dart';
import '../../blocs/navigation/navigation_state.dart';
import '../widgets/recording_controls.dart';
import '../widgets/camera_preview_card.dart';
import '../widgets/emergency_button.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../components/shadcn_card.dart';
import '../components/figma_badge.dart';
import '../components/shadcn_button.dart';
import '../widgets/offline_indicator.dart';
import '../../services/offline_service.dart';

/// Record screen for audio/video recording functionality
class RecordScreen extends StatefulWidget {
  const RecordScreen({Key? key}) : super(key: key);

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  bool _isLocationSharingActive = false;

  @override
  void initState() {
    super.initState();
    // Initialize camera when screen loads but don't start recording automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<RecordingBloc>().add(const CameraInitializeRequested());
      // Initialize Whisper for transcription
      context.read<TranscriptionBloc>().add(const WhisperInitializeRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor:
          const Color(0xFF1a1a1a), // Dark theme background from Figma
      body: MultiBlocListener(
        listeners: [
          BlocListener<EmergencyBloc, EmergencyState>(
            listener: (context, state) {
              // Update local state when emergency mode changes
              if (!state.isEmergencyModeActive && _isLocationSharingActive) {
                setState(() {
                  _isLocationSharingActive = false;
                });

                // Show confirmation when emergency mode is stopped
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Emergency mode stopped'),
                      ],
                    ),
                    backgroundColor: Colors.orange.shade600,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          BlocListener<RecordingBloc, RecordingState>(
            listener: (context, recordingState) {
              // Show error snackbar if error occurs
              if (recordingState.status == RecordingStatus.error &&
                  recordingState.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(recordingState.errorMessage!),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }

              final transcriptionBloc = context.read<TranscriptionBloc>();

              // Start transcription when recording starts
              if (recordingState.isRecording &&
                  !transcriptionBloc.state.isListening) {
                final sessionId =
                    'session_${DateTime.now().millisecondsSinceEpoch}';
                transcriptionBloc.add(TranscriptionStartRequested(sessionId));
              }

              // Stop transcription when recording stops
              if (!recordingState.isRecording &&
                  transcriptionBloc.state.isListening) {
                transcriptionBloc.add(const TranscriptionStopRequested());
              }
            },
          ),
        ],
        child: BlocBuilder<EmergencyBloc, EmergencyState>(
          builder: (context, emergencyState) {
            return BlocBuilder<RecordingBloc, RecordingState>(
              builder: (context, recordingState) {
                return Column(
                  children: [
                    // Recording Status Header - Figma design - only show when recording
                    if (recordingState.isRecording)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top +
                              AppSpacing.md,
                          left: AppSpacing.md,
                          right: AppSpacing.md,
                          bottom: AppSpacing.md,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(
                              0xFFDC2626), // Red recording header from Figma
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  // Pulsing recording indicator
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const _PulsingDot(),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'RECORDING LIVE',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Recording timer
                            Text(
                              _formatRecordingTime(
                                  recordingState.recordingDuration),
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontFeatures: [
                                  const FontFeature.tabularFigures()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Offline indicator
                    const OfflineIndicator(),

                    // Content Area - Figma design
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: Column(
                          children: [
                            // Video Preview Card
                            Container(
                              margin: const EdgeInsets.all(AppSpacing.md),
                              child: ShadcnCard(
                                backgroundColor: const Color(
                                    0xFF262626), // Dark card background from Figma
                                borderColor: const Color(
                                    0xFF404040), // Dark border from Figma
                                child: Stack(
                                  children: [
                                    // Video preview
                                    AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(
                                              0xFF1a1a1a), // Dark background from Figma
                                          borderRadius: BorderRadius.circular(
                                              AppSpacing.figmaRadius),
                                        ),
                                        child: recordingState
                                                    .cameraController !=
                                                null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppSpacing.figmaRadius),
                                                child: CameraPreviewCard(
                                                  cameraController:
                                                      recordingState
                                                          .cameraController,
                                                  isRecording: recordingState
                                                      .isRecording,
                                                  errorMessage: recordingState
                                                      .errorMessage,
                                                  currentZoom:
                                                      recordingState.zoomLevel,
                                                  onCameraSwitch: recordingState
                                                          .hasMultipleCameras
                                                      ? () => context
                                                          .read<RecordingBloc>()
                                                          .add(
                                                              const CameraSwitchRequested())
                                                      : null,
                                                  onFocusTap: () =>
                                                      HapticFeedback
                                                          .selectionClick(),
                                                  onZoomIn: () {
                                                    final newZoom =
                                                        (recordingState
                                                                    .zoomLevel *
                                                                1.2)
                                                            .clamp(1.0, 8.0);
                                                    context
                                                        .read<RecordingBloc>()
                                                        .add(ZoomLevelChanged(
                                                            newZoom));
                                                    HapticFeedback
                                                        .selectionClick();
                                                  },
                                                  onZoomOut: () {
                                                    final newZoom =
                                                        (recordingState
                                                                    .zoomLevel /
                                                                1.2)
                                                            .clamp(1.0, 8.0);
                                                    context
                                                        .read<RecordingBloc>()
                                                        .add(ZoomLevelChanged(
                                                            newZoom));
                                                    HapticFeedback
                                                        .selectionClick();
                                                  },
                                                ),
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.videocam,
                                                  size: 48,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                      ),
                                    ),
                                    // Recording badge
                                    if (recordingState.isRecording)
                                      Positioned(
                                        top: AppSpacing.sm,
                                        left: AppSpacing.sm,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.xs,
                                            vertical: AppSpacing.xs / 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.recording,
                                            borderRadius: BorderRadius.circular(
                                                AppSpacing.xs),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const _PulsingDot(),
                                              ),
                                              const SizedBox(
                                                  width: AppSpacing.xs / 2),
                                              Text(
                                                'REC',
                                                style: AppTextStyles.labelSmall
                                                    .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    // Timer overlay
                                    Positioned(
                                      bottom: AppSpacing.sm,
                                      right: AppSpacing.sm,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.xs,
                                          vertical: AppSpacing.xs / 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(
                                              AppSpacing.xs),
                                        ),
                                        child: Text(
                                          _formatRecordingTime(
                                              recordingState.recordingDuration),
                                          style:
                                              AppTextStyles.labelSmall.copyWith(
                                            color: Colors.white,
                                            fontFeatures: [
                                              const FontFeature.tabularFigures()
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Live Transcription Card - Figma design
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md),
                              constraints: const BoxConstraints(
                                  minHeight: 240, maxHeight: 320),
                              child: ShadcnCard(
                                backgroundColor: const Color(
                                    0xFF262626), // Dark card background from Figma
                                borderColor: const Color(
                                    0xFF404040), // Dark border from Figma
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Container(
                                      padding:
                                          const EdgeInsets.all(AppSpacing.sm),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: const Color(
                                                0xFF404040), // Dark border from Figma
                                            width: 1,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.mic,
                                            size: 16,
                                            color: Color(
                                                0xFF60A5FA), // Blue from Figma
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          Text(
                                            'Live Transcription',
                                            style: AppTextStyles.titleSmall
                                                .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Transcription content
                                    Expanded(
                                      child: BlocBuilder<TranscriptionBloc,
                                          TranscriptionState>(
                                        builder: (context, transcriptionState) {
                                          return Padding(
                                            padding: const EdgeInsets.all(
                                                AppSpacing.sm),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Show transcription segments
                                                if (transcriptionState
                                                    .hasSegments) ...[
                                                  Expanded(
                                                    child: ListView.builder(
                                                      itemCount:
                                                          transcriptionState
                                                              .segments.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final segment =
                                                            transcriptionState
                                                                    .segments[
                                                                index];
                                                        final timeStr =
                                                            _formatTime(segment
                                                                .timestamp);
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom:
                                                                      AppSpacing
                                                                          .xs),
                                                          child:
                                                              _buildTranscriptionLine(
                                                                  timeStr,
                                                                  segment.text),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ] else ...[
                                                  // Show initial message when no transcription yet
                                                  if (recordingState
                                                          .isRecording &&
                                                      transcriptionState
                                                          .isListening)
                                                    _buildTranscriptionLine(
                                                        _formatTime(
                                                            DateTime.now()),
                                                        'Recording started - listening for speech...')
                                                  else if (!recordingState
                                                      .isRecording)
                                                    _buildTranscriptionLine(
                                                        _formatTime(
                                                            DateTime.now()),
                                                        'Start recording to begin live transcription'),
                                                  const Spacer(),
                                                ],

                                                // Status indicator
                                                const SizedBox(
                                                    height: AppSpacing.sm),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                        color: _getTranscriptionStatusColor(
                                                            transcriptionState),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: transcriptionState
                                                              .isListening
                                                          ? const _PulsingDot()
                                                          : null,
                                                    ),
                                                    const SizedBox(
                                                        width: AppSpacing.xs),
                                                    Text(
                                                      _getTranscriptionStatusText(
                                                          transcriptionState,
                                                          recordingState),
                                                      style: AppTextStyles
                                                          .labelSmall
                                                          .copyWith(
                                                        color: _getTranscriptionStatusColor(
                                                            transcriptionState),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Location Info Card - Figma design
                            Container(
                              margin: const EdgeInsets.all(AppSpacing.md),
                              child: ShadcnCard(
                                backgroundColor: const Color(
                                    0xFF262626), // Dark card background from Figma
                                borderColor: const Color(
                                    0xFF404040), // Dark border from Figma
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 16,
                                              color: Color(
                                                  0xFF34D399), // Green from Figma
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.xs),
                                            Text(
                                              'Current Location',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const FigmaBadge(
                                        text: 'GPS Active',
                                        variant: FigmaBadgeVariant.success,
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

                    // Action Buttons - Figma design
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF262626), // Dark surface from Figma
                        border: Border(
                          top: BorderSide(
                            color: const Color(
                                0xFF404040), // Dark border from Figma
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ShadcnButton.outline(
                              text: 'Alert Contacts',
                              leadingIcon: const Icon(Icons.phone, size: 16),
                              onPressed: () {
                                // TODO: Implement alert contacts
                                HapticFeedback.selectionClick();
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const SizedBox(width: AppSpacing.sm),
                          if (!recordingState.isRecording)
                            Expanded(
                              child: ShadcnButton.primary(
                                text: 'Start Recording',
                                leadingIcon: const Icon(
                                    Icons.fiber_manual_record,
                                    size: 16,
                                    color: Colors.white),
                                onPressed: () {
                                  // Visual feedback immediately
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Debug: Button Pressed!'),
                                      duration: Duration(milliseconds: 500),
                                      backgroundColor: Colors.blue,
                                    ),
                                  );

                                  print('DEBUG: BUTTON_PRESSED_ACTION_STARTED');
                                  try {
                                    context
                                        .read<RecordingBloc>()
                                        .add(const RecordingStartRequested());
                                  } catch (e, stack) {
                                    print('DEBUG: ERROR DISPATCHING EVENT: $e');
                                    print(stack);
                                  }
                                },
                              ),
                            )
                          else
                            Expanded(
                              child: ShadcnButton.destructive(
                                text: 'Stop Recording',
                                leadingIcon: const Icon(Icons.stop, size: 16),
                                onPressed: () {
                                  _showStopRecordingDialog(
                                      context, recordingState);
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showLocationSharingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.green),
            SizedBox(width: 8),
            Text('Location Sharing Active'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your live location is now being shared with your emergency contacts:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  _buildContactItem('John Doe', '+1 (555) 123-4567'),
                  const Divider(height: 16),
                  _buildContactItem('Jane Smith', '+1 (555) 987-6543'),
                  const Divider(height: 16),
                  _buildContactItem('Emergency Services', '911'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Location updates every 30 seconds while active',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to emergency contacts settings
            },
            child: const Text('Manage Contacts'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String name, String phone) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.green.shade100,
          child: Icon(
            Icons.person,
            size: 16,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                phone,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.check_circle,
          size: 16,
          color: Colors.green.shade600,
        ),
      ],
    );
  }

  Widget _buildTranscriptionLine(String time, String text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: AppTextStyles.labelSmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurface,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  String _formatRecordingTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Color _getTranscriptionStatusColor(TranscriptionState transcriptionState) {
    switch (transcriptionState.status) {
      case TranscriptionStatus.listening:
        return const Color(0xFF60A5FA); // Blue
      case TranscriptionStatus.processing:
        return const Color(0xFFFBBF24); // Yellow
      case TranscriptionStatus.error:
        return const Color(0xFFEF4444); // Red
      case TranscriptionStatus.ready:
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getTranscriptionStatusText(
      TranscriptionState transcriptionState, RecordingState recordingState) {
    if (!recordingState.isRecording) {
      return 'Ready to transcribe';
    }

    switch (transcriptionState.status) {
      case TranscriptionStatus.initializing:
        return 'Initializing...';
      case TranscriptionStatus.listening:
        return 'Listening...';
      case TranscriptionStatus.processing:
        return 'Processing...';
      case TranscriptionStatus.error:
        return transcriptionState.errorMessage ?? 'Error occurred';
      case TranscriptionStatus.ready:
        return 'Ready';
      default:
        return 'Stopped';
    }
  }

  void _showStopRecordingDialog(
      BuildContext context, RecordingState recordingState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final recordingBloc = context
        .read<RecordingBloc>(); // Get the bloc reference before showing dialog

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber,
              color: AppColors.warning,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Stop Recording?',
              style: AppTextStyles.titleMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to end this recording session? The recording will be saved securely to your device and cloud storage.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Continue Recording',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ShadcnButton.destructive(
            text: 'Stop & Save',
            onPressed: () {
              Navigator.pop(dialogContext);
              recordingBloc.add(const RecordingStopRequested());
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }
}

/// Pulsing dot animation widget
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
