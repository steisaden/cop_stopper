import 'package:flutter/material.dart';
import 'package:mobile/src/collaborative_monitoring/services/collaborative_session_manager.dart';
import 'package:mobile/src/collaborative_monitoring/services/real_time_collaboration_service.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';
import 'package:mobile/src/models/transcription_segment_model.dart';
import 'package:mobile/src/service_locator.dart' if (dart.library.html) 'package:mobile/src/service_locator_web.dart';

class RealTimeTranscriptionWidget extends StatefulWidget {
  final CollaborativeSessionManager sessionManager;

  const RealTimeTranscriptionWidget({
    Key? key,
    required this.sessionManager,
  }) : super(key: key);

  @override
  State<RealTimeTranscriptionWidget> createState() => _RealTimeTranscriptionWidgetState();
}

class _RealTimeTranscriptionWidgetState extends State<RealTimeTranscriptionWidget> {
  final List<TranscriptionSegment> _segments = [];
  final ScrollController _scrollController = ScrollController();
  bool _isExpanded = false;
  late final TranscriptionServiceInterface _transcriptionService;

  @override
  void initState() {
    super.initState();
    _transcriptionService = locator<TranscriptionServiceInterface>();
    _listenToTranscriptionUpdates();
  }

  void _listenToTranscriptionUpdates() {
    // Listen to direct transcription service for real-time segments
    _transcriptionService.transcriptionStream.listen((segment) {
      if (mounted) {
        setState(() {
          _segments.add(segment);
        });
        _scrollToBottom();
      }
    });

    // Also listen to collaboration events for segments from other participants
    widget.sessionManager.onCollaborationEvent.listen((event) {
      if (event.type == CollaborationEventType.transcriptionUpdate && mounted) {
        final transcriptionText = event.data['transcription'] as String?;
        if (transcriptionText != null) {
          final segment = TranscriptionSegment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: transcriptionText,
            timestamp: event.timestamp,
            confidence: 0.8,
            speaker: event.participantId ?? 'Unknown',
            language: 'en',
            isPartial: false,
          );
          
          setState(() {
            _segments.add(segment);
          });
          _scrollToBottom();
        }
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isExpanded ? 200 : 80,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.closed_caption,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Live Transcription',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  if (_segments.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                  ],
                  IconButton(
                    icon: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ),
            
            // Transcription Content
            Expanded(
              child: _segments.isEmpty
                  ? _buildEmptyState()
                  : _buildTranscriptionList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic_off,
            color: Colors.white54,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            'Waiting for audio...',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: _segments.length,
      itemBuilder: (context, index) {
        final segment = _segments[index];
        return _buildTranscriptionSegment(segment, index == _segments.length - 1);
      },
    );
  }

  Widget _buildTranscriptionSegment(TranscriptionSegment segment, bool isLatest) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isLatest ? Colors.blue.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isExpanded) ...[
            Row(
              children: [
                Text(
                  _getSpeakerName(segment.speaker),
                  style: TextStyle(
                    color: Colors.blue.shade300,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  _formatTimestamp(segment.timestamp),
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2),
          ],
          Text(
            segment.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: _isExpanded ? 12 : 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String _getSpeakerName(String speaker) {
    if (speaker == 'current_user') return 'You';
    if (speaker.startsWith('participant_')) return 'Participant';
    return 'Broadcaster';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

