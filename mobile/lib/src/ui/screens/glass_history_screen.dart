import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/ui/components/glass_surface.dart';
import 'package:mobile/src/models/recording_model.dart';
import 'package:mobile/src/services/history_service.dart';
import 'package:mobile/src/service_locator.dart';
import 'package:intl/intl.dart';
import 'glass_session_screen.dart';

/// Recording history screen with dark glassmorphism design
/// Based on Stitch recording-history.html
class GlassHistoryScreen extends StatefulWidget {
  const GlassHistoryScreen({Key? key}) : super(key: key);

  @override
  State<GlassHistoryScreen> createState() => _GlassHistoryScreenState();
}

class _GlassHistoryScreenState extends State<GlassHistoryScreen> {
  String _selectedFilter = 'All';
  List<Recording> _recordings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
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

      setState(() {
        _recordings = recordings;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.glassBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadHistory,
                color: AppColors.glassPrimary,
                backgroundColor: AppColors.glassSurfaceFrosted,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.glassPrimary,
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stats card
                            _buildStatsCard(),

                            const SizedBox(height: 24),

                            // Filter chips
                            _buildFilterChips(),

                            const SizedBox(height: 24),

                            // Grouped sessions
                            if (_recordings.isEmpty)
                              _buildEmptyState()
                            else
                              ..._buildGroupedSessions(),

                            const SizedBox(
                                height: 100), // Bottom padding for nav
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No Recordings Yet',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start recording to see your history here',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.glassSurfaceFrosted,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recording History',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              _buildHeaderButton(Icons.search),
              const SizedBox(width: 8),
              _buildHeaderButton(Icons.filter_list),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 22,
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalDuration = _recordings.fold<int>(
      0,
      (sum, r) => sum + r.durationSeconds,
    );
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;

    // Calculate total storage (rough estimate based on file paths)
    final storageGB = (_recordings.length * 25) / 1000; // Rough estimate

    return GlassSurface(
      variant: GlassVariant.base,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Row(
        children: [
          _buildStatItem('Total', '${_recordings.length}', null),
          _buildDivider(),
          _buildStatItem('Duration', '${hours}h', '${minutes}m'),
          _buildDivider(),
          _buildStatItem('Storage', storageGB.toStringAsFixed(1), 'GB'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String? suffix) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 2),
                Text(
                  suffix,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'This Week', 'Flagged'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedFilter = filter);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    if (filter == 'Flagged') ...[
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: Colors.orange.shade400,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<Widget> _buildGroupedSessions() {
    final grouped = <String, List<Recording>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final recording in _recordings) {
      final recordingDate = DateTime(
        recording.timestamp.year,
        recording.timestamp.month,
        recording.timestamp.day,
      );

      String dateLabel;
      if (recordingDate == today) {
        dateLabel = 'Today';
      } else if (recordingDate == yesterday) {
        dateLabel = 'Yesterday';
      } else {
        dateLabel = DateFormat('MMM d, y').format(recording.timestamp);
      }

      grouped.putIfAbsent(dateLabel, () => []).add(recording);
    }

    // Apply filter
    if (_selectedFilter == 'Flagged') {
      for (final key in grouped.keys.toList()) {
        grouped[key] = grouped[key]!.where((r) => r.isFlagged).toList();
        if (grouped[key]!.isEmpty) grouped.remove(key);
      }
    } else if (_selectedFilter == 'This Week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      for (final key in grouped.keys.toList()) {
        grouped[key] =
            grouped[key]!.where((r) => r.timestamp.isAfter(weekAgo)).toList();
        if (grouped[key]!.isEmpty) grouped.remove(key);
      }
    }

    return grouped.entries.map((entry) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              entry.key.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          ...entry.value.map((recording) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildSessionCard(recording),
              )),
          const SizedBox(height: 12),
        ],
      );
    }).toList();
  }

  Widget _buildSessionCard(Recording recording) {
    final duration = Duration(seconds: recording.durationSeconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final durationStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final timeStr = DateFormat('h:mm a').format(recording.timestamp);
    final isFlagged = recording.isFlagged;

    return GlassSurface(
      variant: GlassVariant.inset,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.all(16),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GlassSessionScreen(recording: recording),
          ),
        );
      },
      child: Row(
        children: [
          // Play button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFlagged
                  ? AppColors.glassPrimary.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              boxShadow: isFlagged
                  ? [
                      BoxShadow(
                        color: AppColors.glassPrimary.withOpacity(0.2),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              Icons.play_arrow,
              color: isFlagged
                  ? AppColors.glassPrimary
                  : Colors.white.withOpacity(0.4),
            ),
          ),

          const SizedBox(width: 16),

          // Info and waveform placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform placeholder (simplified)
                SizedBox(
                  height: 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(10, (i) {
                      final heights = [
                        0.2,
                        0.4,
                        1.0,
                        0.3,
                        0.2,
                        0.1,
                        0.2,
                        0.3,
                        0.5,
                        0.2
                      ];
                      final h = heights[i % heights.length];
                      return Container(
                        width: 3,
                        height: 24 * h,
                        margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(
                          color: isFlagged
                              ? AppColors.glassPrimary
                                  .withOpacity(0.3 + h * 0.5)
                              : Colors.white.withOpacity(0.1 + h * 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 8),

                // Time and transcription indicator
                Row(
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (recording.hasTranscription) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.subtitles,
                        size: 14,
                        color: AppColors.glassPrimary.withOpacity(0.7),
                      ),
                    ],
                    const Spacer(),
                    if (isFlagged)
                      Icon(
                        Icons.flag,
                        size: 16,
                        color: Colors.orange.shade400,
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Duration
          Text(
            durationStr,
            style: TextStyle(
              color: isFlagged ? Colors.white : Colors.white.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
