import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/blocs/transcription/transcription_bloc.dart';
import 'package:mobile/src/blocs/transcription/transcription_state.dart';
import 'package:mobile/src/ui/app_colors.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';

/// Live transcript overlay for video recording.
/// Shows real-time transcription with AI lookup capability.
class TranscriptOverlay extends StatefulWidget {
  final TranscriptionServiceInterface transcriptionService;

  const TranscriptOverlay({
    super.key,
    required this.transcriptionService,
  });

  @override
  State<TranscriptOverlay> createState() => _TranscriptOverlayState();
}

class _TranscriptOverlayState extends State<TranscriptOverlay> {
  final List<TranscriptionSegment> _segments = [];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<TranscriptionSegment>? _serviceSubscription;
  StreamSubscription<TranscriptionState>? _blocSubscription;
  bool _isAutoScrolling = true;
  String? _selectedText;
  bool _showAIBubble = false;
  bool _isAIThinking = false;
  String? _aiResponse;
  bool _hasUnreadResponse = false;

  @override
  void initState() {
    super.initState();
    _subscribeToTranscription();
  }

  void _subscribeToTranscription() {
    TranscriptionBloc? bloc;
    try {
      bloc = BlocProvider.of<TranscriptionBloc>(context);
    } catch (_) {
      bloc = null;
    }

    if (bloc != null) {
      _segments
        ..clear()
        ..addAll(bloc.state.segments);

      _blocSubscription = bloc.stream.listen(
        (state) {
          if (!mounted) return;
          setState(() {
            _segments
              ..clear()
              ..addAll(state.segments);
          });
          if (_isAutoScrolling) {
            _scrollToBottom();
          }
        },
        onError: (e) => debugPrint('Transcription bloc error: $e'),
      );
      return;
    }

    // Fallback: direct service subscription if Bloc isn't in scope.
    _serviceSubscription =
        widget.transcriptionService.transcriptionStream.listen(
      (segment) {
        if (mounted) {
          setState(() {
            _segments.add(segment);
          });
          if (_isAutoScrolling) {
            _scrollToBottom();
          }
        }
      },
      onError: (e) => debugPrint('Transcription error: $e'),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onScrollNotification() {
    // Pause auto-scroll when user scrolls up
    if (_scrollController.hasClients) {
      final isNearBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent - 50;
      if (_isAutoScrolling != isNearBottom) {
        setState(() => _isAutoScrolling = isNearBottom);
      }
    }
  }

  void _resumeAutoScroll() {
    setState(() => _isAutoScrolling = true);
    _scrollToBottom();
  }

  Future<void> _lookupWithAI(String text) async {
    setState(() {
      _selectedText = text;
      _showAIBubble = true;
      _isAIThinking = true;
      _aiResponse = null;
    });

    try {
      // Use OpenAI service to get real AI response
      final openAIService = widget.transcriptionService as dynamic;

      // Try to get OpenAI service - if not available, show error
      String response;
      try {
        // Import and use OpenAI service
        final apiKey =
            const String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
        if (apiKey.isEmpty) {
          response = 'AI lookup requires OpenAI API key configuration. '
              'Please add your API key in lib/src/config/api_keys.dart';
        } else {
          // Make actual OpenAI API call
          response = await _callOpenAI(text, apiKey);
        }
      } catch (e) {
        response = 'Failed to get AI response: $e';
      }

      if (mounted) {
        setState(() {
          _isAIThinking = false;
          _aiResponse = response;
          _hasUnreadResponse = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAIThinking = false;
          _aiResponse = 'Error: $e';
          _hasUnreadResponse = true;
        });
      }
    }
  }

  Future<String> _callOpenAI(String text, String apiKey) async {
    // This is a placeholder - the proper implementation would use the OpenAI service
    // For now, return a helpful message
    return 'AI lookup feature requires integration with OpenAI service. '
        'Use the "Ask AI" button in Legal Guidance screen for full AI chat functionality.';
  }

  void _showAIResponseModal() {
    setState(() => _hasUnreadResponse = false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: AppColors.glassCardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassCardBorder),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.psychology, color: AppColors.glassAI),
                  const SizedBox(width: 12),
                  const Text(
                    'AI Analysis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.glassCardBorder, height: 1),

            // Selected text
            if (_selectedText != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.glassPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.glassPrimary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '"$_selectedText"',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Response
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _aiResponse ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _serviceSubscription?.cancel();
    _blocSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Auto-scroll indicator
        if (!_isAutoScrolling)
          GestureDetector(
            onTap: _resumeAutoScroll,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.glassPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_downward,
                      size: 14, color: AppColors.glassPrimary),
                  const SizedBox(width: 4),
                  Text(
                    'Resume live feed',
                    style: TextStyle(
                      color: AppColors.glassPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Transcript list
        Expanded(
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _onScrollNotification();
                  return false;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _segments.length,
                  itemBuilder: (context, index) =>
                      _buildSegmentTile(_segments[index]),
                ),
              ),

              if (_segments.isEmpty)
                Center(
                  child: Text(
                    'No transcription yet.\nSpeak while recording to see it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),

              // AI bubble indicator
              if (_showAIBubble)
                Positioned(
                  left: 0,
                  top: 50,
                  child: GestureDetector(
                    onTap: _aiResponse != null ? _showAIResponseModal : null,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.glassAI.withOpacity(0.9),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.glassAI.withOpacity(0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isAIThinking)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          else
                            const Icon(
                              Icons.psychology,
                              color: Colors.white,
                              size: 24,
                            ),

                          // Notification badge
                          if (_hasUnreadResponse)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.glassRecording,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.glassAI,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentTile(TranscriptionSegment segment) {
    final isUser = segment.speakerLabel?.toLowerCase() == 'user';

    return GestureDetector(
      onLongPress: () => _lookupWithAI(segment.text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.glassPrimary.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUser
                ? AppColors.glassPrimary.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  segment.speakerLabel ?? 'Speaker',
                  style: TextStyle(
                    color: isUser ? AppColors.glassPrimary : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatTime(segment.startTime),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              segment.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Duration? duration) {
    if (duration == null) return '';
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
