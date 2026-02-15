import 'package:flutter/material.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/models/note_model.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../components/shadcn_card.dart';
import '../components/figma_badge.dart';
import '../components/shadcn_button.dart';
import '../components/shadcn_input.dart';

/// Session Detail Screen with full transcript and notes functionality
class SessionDetailScreen extends StatefulWidget {
  final String sessionId;
  final String title;
  final DateTime date;
  final Duration? duration;
  final String type;
  final String status;
  final String? location;
  final List<TranscriptionSegment> transcriptSegments;
  final List<Note> notes;

  const SessionDetailScreen({
    Key? key,
    required this.sessionId,
    required this.title,
    required this.date,
    this.duration,
    required this.type,
    required this.status,
    this.location,
    required this.transcriptSegments,
    this.notes = const [],
  }) : super(key: key);

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final bool _showFullTranscript = false;
  late List<TranscriptionSegment> _transcriptSegments;
  late List<TranscriptionSegment> _filteredTranscriptSegments;
  String _selectedFilter = 'All';
  late List<Note> _notes;

  @override
  void initState() {
    super.initState();
    _transcriptSegments = widget.transcriptSegments;
    _filteredTranscriptSegments = _transcriptSegments;
    _notes = List.from(widget.notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50 from Figma
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Figma design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs / 2),
                        Text(
                          _formatDate(widget.date),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Session metadata
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Type', widget.type),
                  if (widget.duration != null)
                    _buildDetailRow('Duration', _formatDuration(widget.duration!)),
                  _buildDetailRow('Status', widget.status),
                  if (widget.location != null)
                    _buildDetailRow('Location', widget.location!),
                ],
              ),
            ),

            // Transcript section header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transcript',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_transcriptSegments.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs / 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1), // Use accent color with opacity
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_transcriptSegments.length} segments',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.accentForeground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Confidence filter tabs if transcript exists
            if (_transcriptSegments.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    ...['All', 'High', 'Medium', 'Low'].map((filter) {
                      final isSelected = filter == _selectedFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                              _applyFilter();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSpacing.figmaRadius),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.outline,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isSelected ? Colors.white : AppColors.mutedForeground,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],

            // Transcript content
            Expanded(
              child: _transcriptSegments.isEmpty
                  ? _buildEmptyTranscript()
                  : Semantics(
                      explicitChildNodes: true,
                      label: 'Transcript content with ${_transcriptSegments.length} segments',
                      child: _buildTranscriptList(),
                    ),
            ),

            // Notes section
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Notes',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1), // Use accent color with opacity
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_notes.length} notes',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accentForeground,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildAddNoteInput(),
                  const SizedBox(height: AppSpacing.md),
                  if (_notes.isNotEmpty) _buildNotesList(),
                ],
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: ShadcnButton.outline(
                      text: 'Share',
                      leadingIcon: const Icon(Icons.share, size: 16),
                      onPressed: () {
                        // TODO: Implement share functionality
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ShadcnButton.primary(
                      text: 'Export',
                      leadingIcon: const Icon(Icons.download, size: 16),
                      onPressed: () {
                        // TODO: Implement export functionality
                      },
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

  Widget _buildAddNoteInput() {
    final controller = TextEditingController();
    return ShadcnCard(
      backgroundColor: Colors.white,
      borderColor: AppColors.outline,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Note',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ShadcnInput(
              controller: controller,
              placeholder: 'Enter your notes about this session...',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: ShadcnButton.primary(
                text: 'Add Note',
                size: ShadcnButtonSize.sm,
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    final newNote = Note(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      content: controller.text.trim(),
                    );
                    setState(() {
                      _notes.add(newNote);
                    });
                    controller.clear();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList() {
    return Column(
      children: _notes.asMap().entries.map((entry) {
        final index = entry.key;
        final note = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ShadcnCard(
            backgroundColor: Colors.white,
            borderColor: AppColors.outline,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Note ${index + 1}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatNoteDate(note.createdAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    note.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ShadcnButton.outline(
                      text: 'Edit',
                      size: ShadcnButtonSize.sm,
                      onPressed: () {
                        _editNote(note);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTranscript() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.transcribe,
            size: 80,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Transcript Available',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'This session does not have any transcription data',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ShadcnButton.primary(
            text: 'View Recording',
            leadingIcon: const Icon(Icons.videocam, size: 16),
            onPressed: () {
              // TODO: Navigate to recording viewer
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView.builder(
        itemCount: _filteredTranscriptSegments.length,
        itemBuilder: (context, index) {
          final segment = _filteredTranscriptSegments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Semantics(
              container: true,
              label: 'Transcript segment at ${segment.formattedTime} by ${segment.displaySpeaker}. Confidence: ${segment.confidenceLevel}',
              child: ShadcnCard(
                backgroundColor: Colors.white,
                borderColor: AppColors.outline,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            segment.formattedTime,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            segment.displaySpeaker,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          _getConfidenceBadge(segment.confidenceLevel),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        segment.text,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _getConfidenceBadge(String confidenceLevel) {
    switch (confidenceLevel.toLowerCase()) {
      case 'high':
        return const FigmaBadge.success(text: 'High');
      case 'medium':
        return const FigmaBadge.warning(text: 'Medium');
      case 'low':
        return const FigmaBadge.error(text: 'Low');
      default:
        return const FigmaBadge(text: 'Unknown');
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatNoteDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${date.weekday} at ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year} ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filteredTranscriptSegments = _transcriptSegments;
      } else {
        _filteredTranscriptSegments = _transcriptSegments
            .where((segment) => segment.confidenceLevel == _selectedFilter)
            .toList();
      }
    });
  }

  void _editNote(Note note) {
    final controller = TextEditingController(text: note.content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Note',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        content: ShadcnInput(
          controller: controller,
          placeholder: 'Edit your note...',
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          ShadcnButton.primary(
            text: 'Save',
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  final noteIndex = _notes.indexWhere((n) => n.id == note.id);
                  if (noteIndex != -1) {
                    _notes[noteIndex] = note.copyWith(
                      content: controller.text.trim(),
                      updatedAt: DateTime.now(),
                    );
                  }
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}