import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobile/src/models/recording_model.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/services/transcription_storage_service.dart';
import 'package:mobile/src/service_locator.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/components/glass_surface.dart';
import 'package:mobile/src/ui/screens/media_player_screen.dart';

/// Session summary screen with dark glassmorphism design
/// Displays details and transcription for a specific recording
class GlassSessionScreen extends StatefulWidget {
  final Recording recording;

  const GlassSessionScreen({
    Key? key,
    required this.recording,
  }) : super(key: key);

  @override
  State<GlassSessionScreen> createState() => _GlassSessionScreenState();
}

class _GlassSessionScreenState extends State<GlassSessionScreen> {
  List<TranscriptionSegment> _transcriptionSegments = [];
  bool _isLoadingTranscription = true;
  final TranscriptionStorageService _transcriptionStorage =
      locator<TranscriptionStorageService>();

  @override
  void initState() {
    super.initState();
    _loadTranscription();
  }

  Future<void> _loadTranscription() async {
    if (!widget.recording.hasTranscription) {
      setState(() => _isLoadingTranscription = false);
      return;
    }

    try {
      final segments =
          await _transcriptionStorage.loadTranscription(widget.recording.id);
      if (mounted) {
        setState(() {
          _transcriptionSegments = segments;
          _isLoadingTranscription = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading transcription: $e');
      if (mounted) {
        setState(() => _isLoadingTranscription = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.glassBackground,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session info card
                    _buildSessionInfo(),

                    const SizedBox(height: 20),

                    // Officer info (placeholder for now)
                    _buildOfficerInfo(),

                    const SizedBox(height: 20),

                    // Location info (placeholder for now)
                    _buildLocationCard(),

                    const SizedBox(height: 20),

                    // Transcript
                    _buildTranscriptSection(),

                    const SizedBox(height: 24),

                    // Action buttons
                    _buildActionButtons(context),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceFrosted,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.9)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Session Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white.withOpacity(0.7)),
            onPressed: () => HapticFeedback.lightImpact(),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo() {
    final dateStr =
        DateFormat('MMM d, y • h:mm a').format(widget.recording.timestamp);
    final duration = Duration(seconds: widget.recording.durationSeconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final durationStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final isFlagged = widget.recording.isFlagged;

    return GlassSurface(
      variant: GlassVariant.base,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recording',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.glassSuccess.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.glassSuccess.withOpacity(0.3)),
                ),
                child: Text(
                  'Saved',
                  style: TextStyle(
                    color: AppColors.glassSuccess,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem(Icons.timer, durationStr, 'Duration'),
              _buildStatDivider(),
              _buildStatItem(Icons.flag, isFlagged ? 'Yes' : 'No', 'Flagged'),
              _buildStatDivider(),
              _buildStatItem(
                  Icons.subtitles,
                  widget.recording.transcriptionSegmentCount.toString(),
                  'Segments'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.glassPrimary, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 48,
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildOfficerInfo() {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.badge,
              color: Colors.white.withOpacity(0.6),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Officer Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Badge #4521 • Metro PD', // Placeholder
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.glassPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.map,
              color: AppColors.glassPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unknown Location', // Placeholder
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Lat: --, Long: --', // Placeholder
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TRANSCRIPT',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
            if (!_isLoadingTranscription && _transcriptionSegments.isNotEmpty)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showFullTranscript(context);
                },
                child: Text(
                  'View Full',
                  style: TextStyle(
                    color: AppColors.glassPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        GlassSurface(
          variant: GlassVariant.inset,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16),
          child: _isLoadingTranscription
              ? const Center(child: CircularProgressIndicator())
              : _transcriptionSegments.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No transcription available',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : Column(
                      children: _transcriptionSegments.map((segment) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildTranscriptItem(segment),
                        );
                      }).toList(),
                    ),
        ),
      ],
    );
  }

  Widget _buildTranscriptItem(TranscriptionSegment segment) {
    // Format timestamp
    final minutes = segment.startTime.inMinutes;
    final seconds = segment.startTime.inSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timeStr,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          segment.text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  void _showFullTranscript(BuildContext context) {
    final fullText = _transcriptionSegments.map((s) => s.text).join(' ');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Full Transcript',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.close, color: Colors.white.withOpacity(0.6)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Text(
                  fullText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: GlassSurface(
                      variant: GlassVariant.base,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: fullText));
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Transcript copied to clipboard')),
                        );
                      },
                      child: Center(
                        child: Text(
                          'Copy Text',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassSurface(
            variant: GlassVariant.floating,
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.symmetric(vertical: 14),
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MediaPlayerScreen(
                    recording: widget.recording,
                    transcriptionSegments: _transcriptionSegments,
                  ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, color: AppColors.glassPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Play',
                  style: TextStyle(
                    color: AppColors.glassPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassSurface(
            variant: GlassVariant.floating,
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.symmetric(vertical: 14),
            onTap: () {
              HapticFeedback.lightImpact();
              // Export functionality (TODO)
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export coming soon')));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download,
                    color: Colors.white.withOpacity(0.8), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Export',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
