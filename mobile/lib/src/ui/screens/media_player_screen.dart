import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:just_audio/just_audio.dart';
import '../app_colors.dart';
import '../app_text_styles.dart';
import '../app_spacing.dart';
import '../../models/recording_model.dart';
import '../../models/transcription_segment_model.dart';

/// Media Player Screen for playing back audio and video recordings
class MediaPlayerScreen extends StatefulWidget {
  final Recording recording;
  final List<TranscriptionSegment> transcriptionSegments;

  const MediaPlayerScreen({
    Key? key,
    required this.recording,
    this.transcriptionSegments = const [],
  }) : super(key: key);

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  // Video player
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  // Audio player
  AudioPlayer? _audioPlayer;
  Duration? _audioDuration;
  Duration _audioPosition = Duration.zero;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isVideo = widget.recording.fileType == RecordingFileType.video;

      if (isVideo) {
        await _initializeVideoPlayer();
      } else {
        await _initializeAudioPlayer();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error initializing player: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load media: $e';
      });
    }
  }

  Future<void> _initializeVideoPlayer() async {
    final file = File(widget.recording.filePath);
    if (!await file.exists()) {
      throw Exception('Video file not found');
    }

    _videoPlayerController = VideoPlayerController.file(file);
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primary,
        handleColor: AppColors.primary,
        backgroundColor: AppColors.outline,
        bufferedColor: AppColors.mutedForeground.withOpacity(0.3),
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            'Error: $errorMessage',
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Future<void> _initializeAudioPlayer() async {
    final file = File(widget.recording.filePath);
    if (!await file.exists()) {
      throw Exception('Audio file not found');
    }

    _audioPlayer = AudioPlayer();
    await _audioPlayer!.setFilePath(widget.recording.filePath);

    // Listen to duration
    _audioPlayer!.durationStream.listen((duration) {
      if (mounted) {
        setState(() => _audioDuration = duration);
      }
    });

    // Listen to position
    _audioPlayer!.positionStream.listen((position) {
      if (mounted) {
        setState(() => _audioPosition = position);
      }
    });

    // Listen to playing state
    _audioPlayer!.playingStream.listen((playing) {
      if (mounted) {
        setState(() => _isPlaying = playing);
      }
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.recording.fileType == RecordingFileType.video;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isVideo ? 'Video Playback' : 'Audio Playback',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareRecording,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
            tooltip: 'More options',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : Column(
                  children: [
                    // Media player
                    if (isVideo) _buildVideoPlayer() else _buildAudioPlayer(),

                    // Transcription
                    if (widget.transcriptionSegments.isNotEmpty)
                      Expanded(
                        child: _buildTranscriptionView(),
                      ),
                  ],
                ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_chewieController == null) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: AspectRatio(
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outline),
        ),
      ),
      child: Column(
        children: [
          // Audio icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.audiotrack,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Progress bar
          Slider(
            value: _audioPosition.inMilliseconds.toDouble(),
            max: (_audioDuration?.inMilliseconds ?? 0).toDouble(),
            onChanged: (value) {
              _audioPlayer?.seek(Duration(milliseconds: value.toInt()));
            },
            activeColor: AppColors.primary,
            inactiveColor: AppColors.outline,
          ),

          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_audioPosition),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                Text(
                  _formatDuration(_audioDuration ?? Duration.zero),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Play/Pause button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                color: AppColors.primary,
                onPressed: () {
                  final newPosition =
                      _audioPosition - const Duration(seconds: 10);
                  _audioPlayer?.seek(
                      newPosition.isNegative ? Duration.zero : newPosition);
                },
              ),
              const SizedBox(width: AppSpacing.lg),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                  color: AppColors.onPrimary,
                  onPressed: () {
                    if (_isPlaying) {
                      _audioPlayer?.pause();
                    } else {
                      _audioPlayer?.play();
                    }
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              IconButton(
                icon: const Icon(Icons.forward_10),
                iconSize: 32,
                color: AppColors.primary,
                onPressed: () {
                  final newPosition =
                      _audioPosition + const Duration(seconds: 10);
                  final maxDuration = _audioDuration ?? Duration.zero;
                  _audioPlayer?.seek(
                      newPosition > maxDuration ? maxDuration : newPosition);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionView() {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Transcription',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: widget.transcriptionSegments.length,
              itemBuilder: (context, index) {
                final segment = widget.transcriptionSegments[index];
                return _buildTranscriptionSegment(segment);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionSegment(TranscriptionSegment segment) {
    return InkWell(
      onTap: () => _seekToTimestamp(segment.startTime),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDuration(segment.startTime),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                segment.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Playback Error',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _errorMessage!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  void _seekToTimestamp(Duration position) {
    if (_videoPlayerController != null) {
      _videoPlayerController!.seekTo(position);
      _videoPlayerController!.play();
    } else if (_audioPlayer != null) {
      _audioPlayer!.seek(position);
      _audioPlayer!.play();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _shareRecording() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Recording'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Recording Info'),
              onTap: () {
                Navigator.pop(context);
                _showRecordingInfo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recording'),
        content: const Text(
            'Are you sure you want to delete this recording? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to history
              // TODO: Implement actual deletion
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRecordingInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recording Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Date', widget.recording.timestamp.toString()),
            _buildInfoRow(
                'Duration',
                _formatDuration(
                    Duration(seconds: widget.recording.durationSeconds))),
            _buildInfoRow(
                'Type',
                widget.recording.fileType == RecordingFileType.video
                    ? 'Video'
                    : 'Audio'),
            _buildInfoRow('File', widget.recording.filePath),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
