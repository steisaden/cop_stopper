import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/app_spacing.dart';

/// Camera preview card widget with 16:9 aspect ratio and rounded corners
/// Provides camera initialization, error handling, and fallback to audio-only mode
class CameraPreviewCard extends StatefulWidget {
  final CameraController? cameraController;
  final VoidCallback? onCameraSwitch;
  final VoidCallback? onFocusTap;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final bool isRecording;
  final String? errorMessage;
  final bool showControls;
  final double currentZoom;
  final double minZoom;
  final double maxZoom;
  final VoidCallback? onEnableCamera;

  const CameraPreviewCard({
    Key? key,
    this.cameraController,
    this.onCameraSwitch,
    this.onFocusTap,
    this.onZoomIn,
    this.onZoomOut,
    this.isRecording = false,
    this.errorMessage,
    this.showControls = true,
    this.currentZoom = 1.0,
    this.minZoom = 1.0,
    this.maxZoom = 8.0,
    this.onEnableCamera,
  }) : super(key: key);

  @override
  State<CameraPreviewCard> createState() => _CameraPreviewCardState();
}

class _CameraPreviewCardState extends State<CameraPreviewCard>
    with TickerProviderStateMixin {
  late AnimationController _focusAnimationController;
  late AnimationController _recordingAnimationController;
  late Animation<double> _focusAnimation;
  late Animation<double> _recordingAnimation;

  Offset? _focusPoint;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 8.0;

  @override
  void initState() {
    super.initState();

    // Initialize focus animation
    _focusAnimationController = AnimationController(
      duration: AppSpacing.animationDurationMedium,
      vsync: this,
    );
    _focusAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _focusAnimationController,
      curve: Curves.easeInOut,
    ));

    // Initialize recording animation
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _recordingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _recordingAnimationController,
      curve: Curves.easeInOut,
    ));

    _initializeZoomLevels();
  }

  @override
  void didUpdateWidget(CameraPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle recording animation
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _recordingAnimationController.repeat(reverse: true);
      } else {
        _recordingAnimationController.stop();
        _recordingAnimationController.reset();
      }
    }

    // Update zoom levels when camera controller changes
    if (widget.cameraController != oldWidget.cameraController) {
      _initializeZoomLevels();
    }
  }

  @override
  void dispose() {
    _focusAnimationController.dispose();
    _recordingAnimationController.dispose();
    super.dispose();
  }

  void _initializeZoomLevels() async {
    if (widget.cameraController?.value.isInitialized == true) {
      try {
        _minZoom = await widget.cameraController!.getMinZoomLevel();
        _maxZoom = await widget.cameraController!.getMaxZoomLevel();
        _currentZoom = _minZoom;
      } catch (e) {
        // Fallback to default values if zoom levels can't be retrieved
        _minZoom = 1.0;
        _maxZoom = 8.0;
        _currentZoom = 1.0;
      }
    }
  }

  void _handleTapToFocus(TapDownDetails details) {
    if (widget.cameraController?.value.isInitialized != true) return;

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition =
        renderBox.globalToLocal(details.globalPosition);
    final Size size = renderBox.size;

    // Convert tap position to camera coordinates (0.0 to 1.0)
    final double x = localPosition.dx / size.width;
    final double y = localPosition.dy / size.height;

    setState(() {
      _focusPoint = localPosition;
    });

    // Animate focus indicator
    _focusAnimationController.forward().then((_) {
      _focusAnimationController.reverse();
    });

    // Set focus point on camera
    widget.cameraController!.setFocusPoint(Offset(x, y));
    widget.onFocusTap?.call();

    // Clear focus point after animation
    Future.delayed(AppSpacing.animationDurationLong, () {
      if (mounted) {
        setState(() {
          _focusPoint = null;
        });
      }
    });
  }

  void _handleZoomIn() {
    widget.onZoomIn?.call();
  }

  void _handleZoomOut() {
    widget.onZoomOut?.call();
  }

  Widget _buildCameraPreview() {
    if (widget.cameraController?.value.isInitialized != true) {
      return _buildPlaceholder();
    }

    return GestureDetector(
      onTapDown: _handleTapToFocus,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview with proper aspect ratio
          ClipRRect(
            borderRadius: AppSpacing.cameraPreviewBorderRadius,
            child: OverflowBox(
              alignment: Alignment.center,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width:
                      widget.cameraController!.value.previewSize?.height ?? 1,
                  height:
                      widget.cameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(widget.cameraController!),
                ),
              ),
            ),
          ),

          // Recording indicator overlay
          if (widget.isRecording)
            AnimatedBuilder(
              animation: _recordingAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: AppSpacing.cameraPreviewBorderRadius,
                    border: Border.all(
                      color: AppColors.recording
                          .withOpacity(_recordingAnimation.value),
                      width: 3.0,
                    ),
                  ),
                );
              },
            ),

          // Focus indicator
          if (_focusPoint != null)
            Positioned(
              left: _focusPoint!.dx - 30,
              top: _focusPoint!.dy - 30,
              child: AnimatedBuilder(
                animation: _focusAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _focusAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.center_focus_strong,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Camera controls overlay
          if (widget.showControls) _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      top: AppSpacing.sm,
      right: AppSpacing.sm,
      child: Column(
        children: [
          // Camera switch button
          if (widget.onCameraSwitch != null)
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              onPressed: widget.onCameraSwitch!,
              tooltip: 'Switch Camera',
            ),

          AppSpacing.verticalSpaceSM,

          // Zoom controls
          _buildControlButton(
            icon: Icons.zoom_in,
            onPressed:
                widget.currentZoom < widget.maxZoom ? _handleZoomIn : null,
            tooltip: 'Zoom In',
          ),

          AppSpacing.verticalSpaceXS,

          _buildControlButton(
            icon: Icons.zoom_out,
            onPressed:
                widget.currentZoom > widget.minZoom ? _handleZoomOut : null,
            tooltip: 'Zoom Out',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 20,
              color: onPressed != null
                  ? AppColors.onSurface
                  : AppColors.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (widget.errorMessage != null) {
      return _buildErrorState();
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.cameraPreviewBorderRadius,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 48,
              color: AppColors.onSurfaceVariant,
            ),
            AppSpacing.verticalSpaceMD,
            const Text(
              'Camera Not Initialized',
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            if (widget.onEnableCamera != null)
              ElevatedButton(
                onPressed: widget.onEnableCamera,
                child: const Text('Enable Camera'),
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppSpacing.cameraPreviewBorderRadius,
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Padding(
          padding: AppSpacing.paddingMD,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 48,
                color: AppColors.error.withOpacity(0.7),
              ),
              AppSpacing.verticalSpaceMD,
              const Text(
                'Camera Unavailable',
                style: TextStyle(
                  color: AppColors.onErrorContainer,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.verticalSpaceSM,
              Text(
                widget.errorMessage ?? 'Unable to access camera',
                style: TextStyle(
                  color: AppColors.onErrorContainer.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSpaceMD,
              ElevatedButton.icon(
                onPressed: () {
                  // This would trigger a retry in the parent widget
                  widget.onCameraSwitch?.call();
                },
                icon: const Icon(Icons.mic),
                label: const Text('Use Audio Only'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.elevationMedium,
      color: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.cameraPreviewBorderRadius,
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: _buildCameraPreview(),
      ),
    );
  }
}
