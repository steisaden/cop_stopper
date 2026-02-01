import 'package:flutter/material.dart';
import '../../models/transcription_segment_model.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Widget for displaying real-time transcription with speaker identification
class TranscriptionDisplay extends StatefulWidget {
  final List<TranscriptionSegment> segments;
  final bool autoScrollEnabled;
  final double confidenceThreshold;
  final VoidCallback? onToggleAutoScroll;
  final Function(String speakerId, String label)? onSetSpeakerLabel;

  const TranscriptionDisplay({
    Key? key,
    required this.segments,
    this.autoScrollEnabled = true,
    this.confidenceThreshold = 0.5,
    this.onToggleAutoScroll,
    this.onSetSpeakerLabel,
  }) : super(key: key);

  @override
  State<TranscriptionDisplay> createState() => _TranscriptionDisplayState();
}

class _TranscriptionDisplayState extends State<TranscriptionDisplay> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, Color> _speakerColors = {};
  late final List<Color> _availableColors = [
    Theme.of(context).colorScheme.primary,
    Theme.of(context).colorScheme.secondary,
    Theme.of(context).colorScheme.tertiary,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TranscriptionDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll to bottom when new segments are added
    if (widget.autoScrollEnabled &&
        widget.segments.length > oldWidget.segments.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _onScroll() {
    // Disable auto-scroll if user manually scrolls up
    if (_scrollController.hasClients &&
        _scrollController.offset <
            _scrollController.position.maxScrollExtent - 100) {
      // User scrolled up, could disable auto-scroll here if needed
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Color _getSpeakerColor(String? speakerId) {
    if (speakerId == null)
      return Theme.of(context).colorScheme.onSurfaceVariant;

    if (!_speakerColors.containsKey(speakerId)) {
      _speakerColors[speakerId] =
          _availableColors[_colorIndex % _availableColors.length];
      _colorIndex++;
    }

    return _speakerColors[speakerId]!;
  }

  Widget _buildConfidenceIndicator(double confidence) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color;
    IconData icon;

    if (confidence >= 0.9) {
      color = colorScheme.primary;
      icon = Icons.check_circle;
    } else if (confidence >= 0.7) {
      color = colorScheme.secondary;
      icon = Icons.warning_amber;
    } else {
      color = colorScheme.error;
      icon = Icons.error_outline;
    }

    return Tooltip(
      message: 'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }

  Widget _buildSpeakerChip(TranscriptionSegment segment) {
    final speakerColor = _getSpeakerColor(segment.speakerId);

    return GestureDetector(
      onTap: () => _showSpeakerLabelDialog(segment),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: speakerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: speakerColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: speakerColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              segment.displaySpeaker,
              style: AppTextStyles.labelSmall.copyWith(
                color: speakerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeakerLabelDialog(TranscriptionSegment segment) {
    if (segment.speakerId == null || widget.onSetSpeakerLabel == null) return;

    final controller = TextEditingController(text: segment.speakerLabel ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Speaker Label'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Speaker Name',
            hintText: 'Enter speaker name or role',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                widget.onSetSpeakerLabel!(segment.speakerId!, controller.text);
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionSegment(TranscriptionSegment segment) {
    final isLowConfidence = segment.confidence < widget.confidenceThreshold;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isLowConfidence
            ? colorScheme.secondary.withOpacity(0.05)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLowConfidence
              ? colorScheme.secondary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with speaker, timestamp, and confidence
          Row(
            children: [
              if (segment.speakerId != null) ...[
                _buildSpeakerChip(segment),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                segment.formattedTime,
                style: AppTextStyles.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              _buildConfidenceIndicator(segment.confidence),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Transcription text
          Text(
            segment.text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isLowConfidence
                  ? colorScheme.onSurface.withOpacity(0.7)
                  : colorScheme.onSurface,
            ),
          ),
          if (isLowConfidence) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Low confidence transcription',
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.secondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mic_none,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Waiting for transcription...',
              style: AppTextStyles.titleMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start speaking to see real-time transcription',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollControls() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'scroll_to_bottom',
            onPressed: _scrollToBottom,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.keyboard_arrow_down),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'toggle_auto_scroll',
            onPressed: widget.onToggleAutoScroll,
            backgroundColor: widget.autoScrollEnabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceVariant,
            child: Icon(
              widget.autoScrollEnabled ? Icons.lock : Icons.lock_open,
              color: widget.autoScrollEnabled
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: widget.segments.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: widget.segments.length,
                  itemBuilder: (context, index) {
                    return _buildTranscriptionSegment(widget.segments[index]);
                  },
                ),
        ),
        if (widget.segments.isNotEmpty) _buildScrollControls(),
      ],
    );
  }
}
