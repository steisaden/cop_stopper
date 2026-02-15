import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../components/glass_surface.dart';

/// A single transcript entry with timestamp and speaker
class TranscriptEntry {
  /// Timestamp of the entry
  final Duration timestamp;

  /// Speaker identifier (e.g., 'Officer', 'You', 'Unknown')
  final String? speaker;

  /// The transcribed text
  final String text;

  /// Whether this is a user/self entry
  final bool isUser;

  /// Confidence score (0.0 to 1.0)
  final double? confidence;

  const TranscriptEntry({
    required this.timestamp,
    required this.text,
    this.speaker,
    this.isUser = false,
    this.confidence,
  });
}

/// A live scrolling transcript panel for displaying Whisper transcription.
///
/// Example:
/// ```dart
/// TranscriptPanel(
///   entries: [
///     TranscriptEntry(
///       timestamp: Duration(seconds: 0),
///       text: 'License and registration please.',
///       speaker: 'Officer',
///     ),
///   ],
///   autoScroll: true,
/// )
/// ```
class TranscriptPanel extends StatefulWidget {
  /// List of transcript entries to display
  final List<TranscriptEntry> entries;

  /// Whether to auto-scroll to the latest entry
  final bool autoScroll;

  /// Maximum height of the panel
  final double? maxHeight;

  /// Whether to show timestamps
  final bool showTimestamps;

  /// Whether to show speaker labels
  final bool showSpeakers;

  /// Title for the panel header
  final String? title;

  const TranscriptPanel({
    super.key,
    required this.entries,
    this.autoScroll = true,
    this.maxHeight,
    this.showTimestamps = true,
    this.showSpeakers = true,
    this.title,
  });

  @override
  State<TranscriptPanel> createState() => _TranscriptPanelState();
}

class _TranscriptPanelState extends State<TranscriptPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(TranscriptPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.autoScroll && widget.entries.length > oldWidget.entries.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      variant: GlassVariant.inset,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title != null) ...[
            Row(
              children: [
                Icon(
                  Icons.closed_caption,
                  size: 14,
                  color: AppColors.glassTextSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.glassTextSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: widget.maxHeight ?? 200,
            ),
            child: widget.entries.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    controller: _scrollController,
                    shrinkWrap: true,
                    itemCount: widget.entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _TranscriptEntryWidget(
                        entry: widget.entries[index],
                        showTimestamp: widget.showTimestamps,
                        showSpeaker: widget.showSpeakers,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic_none,
              size: 32,
              color: AppColors.glassTextSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for audio...',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.glassTextSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranscriptEntryWidget extends StatelessWidget {
  final TranscriptEntry entry;
  final bool showTimestamp;
  final bool showSpeaker;

  const _TranscriptEntryWidget({
    required this.entry,
    required this.showTimestamp,
    required this.showSpeaker,
  });

  String _formatTimestamp(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTimestamp) ...[
          SizedBox(
            width: 45,
            child: Text(
              _formatTimestamp(entry.timestamp),
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: AppColors.glassTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSpeaker && entry.speaker != null) ...[
                Text(
                  entry.speaker!,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: entry.isUser
                        ? AppColors.glassPrimary
                        : AppColors.glassTextSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                entry.text,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(
                    entry.confidence != null && entry.confidence! < 0.7
                        ? 0.6
                        : 0.9,
                  ),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
