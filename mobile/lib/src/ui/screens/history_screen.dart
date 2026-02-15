import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/models/recording_model.dart';
import 'package:mobile/src/services/history_service.dart';
import 'package:mobile/src/service_locator.dart'
    if (dart.library.html) 'package:mobile/src/service_locator_web.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';
import '../app_colors.dart';
import '../components/shadcn_card.dart';
import '../components/figma_badge.dart';
import '../components/shadcn_button.dart';
import 'session_detail_screen.dart';
import 'media_player_screen.dart';
import '../../blocs/navigation/navigation_bloc.dart';
import '../../blocs/navigation/navigation_event.dart';
import '../../blocs/navigation/navigation_state.dart';

/// History screen for previous recordings and interactions
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Recordings',
    'Documents',
    'Interactions'
  ];
  List<Recording> _recordings = [];
  bool _isLoading = true;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload history every time we come back to this screen
    // (but not on the very first build, which is handled by initState)
    if (_hasLoadedOnce && mounted) {
      _loadHistory();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('📂 Loading recording history...');
      final historyService = locator<HistoryService>();
      final recordings = await historyService.getRecordingHistory();
      debugPrint('📂 Loaded ${recordings.length} recordings from history');

      if (recordings.isNotEmpty) {
        debugPrint(
            '📂 First recording: ${recordings.first.id}, path: ${recordings.first.filePath}');
      }

      setState(() {
        _recordings = recordings;
        _isLoading = false;
        _hasLoadedOnce = true;
      });
    } catch (e) {
      debugPrint('❌ Error loading history: $e');
      setState(() {
        _isLoading = false;
        _hasLoadedOnce = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50 from Figma
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        child: SafeArea(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'History',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      'View and manage your recorded interactions',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),

              // Filter tabs
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = filter == _selectedFilter;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.figmaRadius),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.outline,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.mutedForeground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: _buildHistoryContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final filteredRecordings = _getFilteredRecordings();

    if (filteredRecordings.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: filteredRecordings.length,
      itemBuilder: (context, index) {
        final recording = filteredRecordings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildHistoryItemCard(recording),
        );
      },
    );
  }

  List<Recording> _getFilteredRecordings() {
    switch (_selectedFilter) {
      case 'Recordings':
        return _recordings;
      case 'Documents':
      case 'Interactions':
        // For now, return recordings for these filters since we only have recordings
        return _recordings;
      case 'All':
      default:
        return _recordings;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.history,
            size: 80,
            color: AppColors.mutedForeground,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No History Yet',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Your recorded interactions and saved documents will appear here',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ShadcnButton.primary(
            text: 'Start Recording',
            leadingIcon: const Icon(Icons.fiber_manual_record, size: 16),
            onPressed: () {
              // Navigate to record screen
              context
                  .read<NavigationBloc>()
                  .add(const NavigationTabChanged(NavigationTab.record));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItemCard(Recording recording) {
    // Determine the type based on file extension
    final isVideo = recording.fileType == RecordingFileType.video;
    final type = isVideo ? 'Recording' : 'Audio';

    // Format duration
    final duration = Duration(seconds: recording.durationSeconds);
    final durationStr = _formatDuration(duration);

    return ShadcnCard(
      backgroundColor: Colors.white,
      borderColor: const Color(0xFFE5E7EB),
      onTap: () {
        _showHistoryItemDetails(recording);
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recording from ${_formatDate(recording.timestamp)}',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _getStatusBadge(
                    'Completed'), // All saved recordings are completed
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  isVideo ? Icons.videocam : Icons.mic,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs / 2),
                Text(
                  type,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs / 2),
                Text(
                  durationStr,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: AppSpacing.xs / 2),
                Text(
                  _formatDate(recording.timestamp),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getStatusBadge(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const FigmaBadge.success(text: 'Completed');
      case 'processing':
        return const FigmaBadge.warning(text: 'Processing');
      case 'saved':
        return const FigmaBadge.info(text: 'Saved');
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

  void _playRecording(Recording recording) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MediaPlayerScreen(
          recording: recording,
          transcriptionSegments: const [], // TODO: Load actual transcription segments
        ),
      ),
    );
  }

  void _showHistoryItemDetails(Recording recording) {
    // For now, we'll create a minimal SessionDetailScreen with basic information
    // In a complete implementation, we would use actual transcription data

    // Determine type and duration
    final isVideo = recording.fileType == RecordingFileType.video;
    final type = isVideo ? 'Recording' : 'Audio';
    final duration = Duration(seconds: recording.durationSeconds);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailScreen(
          sessionId: recording.id,
          title: 'Recording from ${_formatDate(recording.timestamp)}',
          date: recording.timestamp,
          duration: duration,
          type: type,
          status: 'Completed',
          location: null, // Location not stored with recording currently
          transcriptSegments: const [], // Will be loaded from actual transcription later
          notes: const [], // Initially empty, will be loaded in actual implementation
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
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
}
