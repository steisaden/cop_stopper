import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/components/glass_overlay_container.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';
import 'package:mobile/src/services/transcription_storage_service.dart';
import 'package:mobile/src/services/emergency_contact_service.dart';
import 'package:mobile/src/services/history_service.dart';
import 'package:mobile/src/models/recording_model.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/service_locator.dart';

// Import overlay widgets
import 'package:mobile/src/ui/widgets/recording_overlays/contacts_overlay.dart';
import 'package:mobile/src/ui/widgets/recording_overlays/transcript_overlay.dart';
import 'package:mobile/src/ui/widgets/recording_overlays/legal_ai_overlay.dart';
import 'package:mobile/src/ui/widgets/recording_overlays/save_upload_overlay.dart';

/// Full-screen video recording screen with overlay controls.
///
/// Features:
/// - Full-screen camera preview
/// - Double-tap to switch front/back camera
/// - 5 floating icons (hideable with single tap)
/// - Slide-in modals for each feature
class VideoRecordingScreen extends StatefulWidget {
  const VideoRecordingScreen({super.key});

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Camera
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _currentCameraIndex = 0;
  bool _isCameraInitialized = false;

  // Recording state
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _durationTimer;

  // UI state
  bool _areIconsVisible = true;
  late AnimationController _iconAnimationController;
  late Animation<double> _iconFadeAnimation;

  // Overlay visibility
  bool _showContactsOverlay = false;
  bool _showTranscriptOverlay = false;
  bool _showLegalOverlay = false;
  bool _showSaveOverlay = false;
  bool _isToggleProcessing = false;
  bool _isStealthMode = false;

  // Services
  late RecordingService _recordingService;
  late TranscriptionServiceInterface _transcriptionService;
  late EmergencyContactService _emergencyService;
  late HistoryService _historyService;
  late TranscriptionStorageService _transcriptionStorageService;

  // Track transcription segments
  final List<TranscriptionSegment> _transcriptionSegments = [];
  StreamSubscription<TranscriptionSegment>? _transcriptionSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
    _initializeAnimations();
    _initializeCamera();

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _initializeServices() {
    _recordingService = locator<RecordingService>();
    _transcriptionService = locator<TranscriptionServiceInterface>();
    _emergencyService = locator<EmergencyContactService>();
    _historyService = locator<HistoryService>();
    _transcriptionStorageService = locator<TranscriptionStorageService>();
  }

  void _initializeAnimations() {
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: 1.0,
    );

    _iconFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconAnimationController,
      curve: Curves.easeOut,
    ));
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        await _setupCameraController(_cameras![_currentCameraIndex]);
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    _cameraController?.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      _recordingService.setCameraController(_cameraController);

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Error setting up camera: $e');
    }
  }

  void _switchCamera() {
    if (_cameras == null || _cameras!.length < 2) return;

    HapticFeedback.mediumImpact();
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    _setupCameraController(_cameras![_currentCameraIndex]);
  }

  void _toggleIconsVisibility() {
    if (_isStealthMode) return; // Prevent showing icons in stealth mode via tap

    setState(() {
      _areIconsVisible = !_areIconsVisible;
      if (_areIconsVisible) {
        _iconAnimationController.forward();
      } else {
        _iconAnimationController.reverse();
      }
    });
  }

  void _toggleStealthMode() {
    setState(() {
      _isStealthMode = !_isStealthMode;
      if (_isStealthMode) {
        // Hide icons when entering stealth mode
        _areIconsVisible = false;
        _iconAnimationController.reverse();
      }
    });

    HapticFeedback.heavyImpact();

    if (_isStealthMode) {
      _showError('Stealth Mode Active. Double-tap to exit.');
    }
  }

  Future<void> _cancelRecording() async {
    // Pause recording first
    if (_isRecording && !_isPaused) {
      // Pause logically without triggering UI toggle animation if possible,
      // but calling _toggleRecording is safest provided we handle state.
      // Actually, we can just stop directly.
      // _toggleRecording() just toggles logic.
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.glassCardBackground.withOpacity(0.9),
        title: const Text('Discard Recording?',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will delete the current recording. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard',
                style: TextStyle(color: AppColors.glassDestructive)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _transcriptionService.stopTranscription();
        await _transcriptionSubscription?.cancel();

        // Stop recording but verify path
        final path = await _recordingService.stopAudioVideoRecording();

        // Delete the file if it exists
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
            debugPrint('Deleted discarded recording: $path');
          }
        }

        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        debugPrint('Error discarding recording: $e');
      }
    }
  }

  void _toggleRecording() async {
    HapticFeedback.heavyImpact();

    if (_isToggleProcessing) return;
    setState(() => _isToggleProcessing = true);

    try {
      if (!_isRecording) {
        // Start recording
        try {
          debugPrint('🎥 VideoRecordingScreen: Starting recording...');
          await _recordingService.startAudioVideoRecording();
          debugPrint('🎥 VideoRecordingScreen: AudioVideo started.');

          await _transcriptionService.initializeWhisper();
          final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
          debugPrint(
              '🎥 VideoRecordingScreen: Starting transcription session: $sessionId');
          await _transcriptionService.startTranscription(sessionId);

          // Subscribe to transcription stream
          debugPrint(
              '🎥 VideoRecordingScreen: Subscribing to transcription stream');
          _transcriptionSegments.clear();

          await _transcriptionSubscription?.cancel();
          _transcriptionSubscription =
              _transcriptionService.transcriptionStream.listen(
            (segment) {
              _transcriptionSegments.add(segment);
              debugPrint(
                  '📝 VideoRecordingScreen: Collected segment: "${segment.text}" (total: ${_transcriptionSegments.length})');
            },
            onError: (e) => debugPrint(
                '⚠️ VideoRecordingScreen: Transcription stream error: $e'),
          );

          setState(() {
            _isRecording = true;
            _isPaused = false;
          });
          _startDurationTimer();
        } catch (e) {
          debugPrint('Error starting recording: $e');
          _showError('Failed to start recording');
        }
      } else if (_isPaused) {
        // Resume recording
        setState(() => _isPaused = false);
        _startDurationTimer();
      } else {
        // Pause recording
        setState(() => _isPaused = true);
        _durationTimer?.cancel();
      }
    } finally {
      if (mounted) {
        setState(() => _isToggleProcessing = false);
      }
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPaused && mounted) {
        setState(() {
          _recordingDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  void _showSaveDialog() {
    if (!_isPaused) return;
    setState(() => _showSaveOverlay = true);
  }

  Future<void> _saveAndExit(String videoName, String? uploadDestination) async {
    try {
      await _transcriptionService.stopTranscription();

      // Wait for final segments to propagate through the stream
      debugPrint('⏳ VideoRecordingScreen: Waiting for final segments...');
      await Future.delayed(const Duration(seconds: 2));

      await _transcriptionSubscription?.cancel();
      final path = await _recordingService.stopAudioVideoRecording();

      if (path != null && path.isNotEmpty) {
        final recordingId = DateTime.now().millisecondsSinceEpoch.toString();

        // Save transcription segments if any were captured
        int transcriptionSegmentCount = 0;
        bool hasTranscription = false;

        debugPrint(
            '📝 Checking transcription segments: ${_transcriptionSegments.length} collected');

        if (_transcriptionSegments.isNotEmpty) {
          try {
            debugPrint(
                '💾 Saving ${_transcriptionSegments.length} transcription segments...');
            await _transcriptionStorageService.saveTranscription(
              recordingId,
              _transcriptionSegments,
            );
            transcriptionSegmentCount = _transcriptionSegments.length;
            hasTranscription = true;
            debugPrint(
                '✅ Saved ${_transcriptionSegments.length} transcription segments');
          } catch (e) {
            debugPrint('⚠️ Failed to save transcription: $e');
          }
        }

        // Create and save recording to history
        final recording = Recording(
          id: recordingId,
          filePath: path,
          timestamp: DateTime.now(),
          durationSeconds: _recordingDuration.inSeconds,
          fileType: RecordingFileType.video,
          transcriptionSegmentCount: transcriptionSegmentCount,
          hasTranscription: hasTranscription,
        );

        await _historyService.saveRecordingToHistory(recording);
        debugPrint('✅ Recording saved to history: ${recording.id}');
        debugPrint(
            'Video saved: $path, Name: $videoName, Upload: $uploadDestination');
      }

      if (mounted) {
        Navigator.of(context)
            .pop(true); // Return true to indicate successful save
      }
    } catch (e) {
      debugPrint('Error saving recording: $e');
      _showError('Failed to save recording');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.glassRecording,
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCameraController(_cameras![_currentCameraIndex]);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _durationTimer?.cancel();
    _iconAnimationController.dispose();
    _transcriptionSubscription?.cancel();

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen camera preview
          _buildCameraPreview(),

          // Recording duration indicator
          if (_isRecording && !_isStealthMode) _buildDurationIndicator(),

          // Overlay icons (hideable)
          if (!_isStealthMode)
            FadeTransition(
              opacity: _iconFadeAnimation,
              child: _buildOverlayIcons(),
            ),

          // Slide-in overlays
          _buildContactsOverlay(),
          _buildTranscriptOverlay(),
          _buildLegalOverlay(),
          _buildSaveOverlay(),

          // Stealth Mode Overlay
          if (_isStealthMode) _buildStealthOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.glassPrimary,
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleIconsVisibility,
      onDoubleTap: _switchCamera,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _cameraController!.value.previewSize!.height,
            height: _cameraController!.value.previewSize!.width,
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationIndicator() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _isPaused
                ? Colors.orange.withOpacity(0.8)
                : AppColors.glassRecording.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isPaused ? Colors.orange : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isPaused ? 'PAUSED' : 'REC',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDuration(_recordingDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayIcons() {
    return Stack(
      children: [
        // Cancel Button - Top Left
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          left: 20,
          child: RecordingOverlayButton(
            icon: Icons.close,
            isActive: false, // Always normal state
            color: AppColors.glassDestructive,
            onTap: () {
              HapticFeedback.lightImpact();
              _cancelRecording();
            },
          ),
        ),

        // Stealth Mode - Top Right (Above Contacts)
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          right: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RecordingOverlayButton(
                icon: Icons.visibility_off,
                isActive: _isStealthMode,
                color: Colors.white,
                onTap: _toggleStealthMode,
              ),
              const SizedBox(height: 16),
              RecordingOverlayButton(
                icon: Icons.contacts,
                isActive: _showContactsOverlay,
                color: AppColors.glassRecording,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _showContactsOverlay = !_showContactsOverlay);
                },
              ),
            ],
          ),
        ),

        // Legal AI - Bottom Left
        Positioned(
          bottom: 120,
          left: 20,
          child: RecordingOverlayButton(
            icon: Icons.gavel,
            isActive: _showLegalOverlay,
            color: AppColors.glassAI,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _showLegalOverlay = !_showLegalOverlay);
            },
          ),
        ),

        // Transcript - Bottom Right
        Positioned(
          bottom: 120,
          right: 20,
          child: RecordingOverlayButton(
            icon: Icons.subtitles,
            isActive: _showTranscriptOverlay,
            color: AppColors.glassPrimary,
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _showTranscriptOverlay = !_showTranscriptOverlay);
            },
          ),
        ),

        // Stop/Record Button - Bottom Center
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Save button (only visible when paused)
                if (_isPaused)
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: RecordingOverlayButton(
                      icon: Icons.save,
                      color: AppColors.glassSuccess,
                      size: 52,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _showSaveDialog();
                      },
                    ),
                  ),

                // Main record/pause button
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording && !_isPaused
                          ? AppColors.glassRecording
                          : Colors.white.withOpacity(0.9),
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isRecording
                          ? Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _isPaused
                                    ? AppColors.glassRecording
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius.circular(_isPaused ? 4 : 0),
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStealthOverlay() {
    return GestureDetector(
      onDoubleTap: _toggleStealthMode,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black, // Completely black screen
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildContactsOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 120,
      right: 16,
      child: GlassOverlayContainer(
        isVisible: _showContactsOverlay,
        slideDirection: SlideDirection.topRight,
        title: 'EMERGENCY CONTACTS',
        maxWidth: 300,
        maxHeight: 400,
        onClose: () => setState(() => _showContactsOverlay = false),
        child: ContactsOverlay(
          emergencyService: _emergencyService,
          onContactSent: (contact) {
            debugPrint('Sent alert to: ${contact.name}');
          },
        ),
      ),
    );
  }

  Widget _buildTranscriptOverlay() {
    return Positioned(
      bottom: 180,
      right: 16,
      left: 100,
      child: GlassOverlayContainer(
        isVisible: _showTranscriptOverlay,
        slideDirection: SlideDirection.bottomRight,
        title: 'LIVE TRANSCRIPT',
        height: 300,
        onClose: () => setState(() => _showTranscriptOverlay = false),
        child: TranscriptOverlay(
          transcriptionService: _transcriptionService,
        ),
      ),
    );
  }

  Widget _buildLegalOverlay() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 120,
      left: 16,
      child: GlassOverlayContainer(
        isVisible: _showLegalOverlay,
        slideDirection: SlideDirection.topLeft,
        title: 'LEGAL AI',
        maxWidth: 320,
        maxHeight: 450,
        onClose: () => setState(() => _showLegalOverlay = false),
        child: const LegalAIOverlay(),
      ),
    );
  }

  Widget _buildSaveOverlay() {
    return Positioned.fill(
      child: GlassOverlayContainer(
        isVisible: _showSaveOverlay,
        slideDirection:
            SlideDirection.bottomRight, // Or center, keeping consistent style
        title: 'SAVE RECORDING',
        showTransparencyControl: false,
        onClose: () => setState(() => _showSaveOverlay = false),
        child: SaveUploadOverlay(
          duration: _recordingDuration,
          onSave: _saveAndExit,
          onCancel: () => setState(() => _showSaveOverlay = false),
        ),
      ),
    );
  }
}
