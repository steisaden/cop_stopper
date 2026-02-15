import 'package:flutter/material.dart';
import 'package:mobile/src/collaborative_monitoring/models/collaborative_session.dart';
import 'package:mobile/src/collaborative_monitoring/models/fact_check_entry.dart';
import 'package:mobile/src/collaborative_monitoring/services/collaborative_session_manager.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/fact_checking_panel.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/real_time_transcription_widget.dart';
import 'package:mobile/src/collaborative_monitoring/ui/widgets/session_controls_widget.dart';

class MonitoringParticipantScreen extends StatefulWidget {
  final String sessionId;
  final CollaborativeSessionManager sessionManager;

  const MonitoringParticipantScreen({
    Key? key,
    required this.sessionId,
    required this.sessionManager,
  }) : super(key: key);

  @override
  State<MonitoringParticipantScreen> createState() => _MonitoringParticipantScreenState();
}

class _MonitoringParticipantScreenState extends State<MonitoringParticipantScreen> {
  CollaborativeSession? _session;
  bool _isFactCheckingPanelExpanded = false;
  bool _isTranscriptionVisible = true;

  @override
  void initState() {
    super.initState();
    _listenToSessionUpdates();
  }

  void _listenToSessionUpdates() {
    widget.sessionManager.onSessionChanged.listen((session) {
      if (mounted) {
        setState(() {
          _session = session;
        });
        
        // Start transcription when session becomes active
        if (session != null && _isTranscriptionVisible) {
          widget.sessionManager.startTranscription();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoring Session'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.emergency),
            onPressed: _triggerEmergency,
            tooltip: 'Report Emergency',
          ),
          IconButton(
            icon: Icon(_isTranscriptionVisible ? Icons.closed_caption : Icons.closed_caption_off),
            onPressed: () {
              setState(() {
                _isTranscriptionVisible = !_isTranscriptionVisible;
              });
              
              // Start or stop transcription based on visibility
              if (_isTranscriptionVisible && _session != null) {
                widget.sessionManager.startTranscription();
              } else {
                widget.sessionManager.stopTranscription();
              }
            },
            tooltip: 'Toggle Transcription',
          ),
        ],
      ),
      body: _session == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Session Info Bar
                _buildSessionInfoBar(),
                
                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Screen Share and Side Panel Row
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            // Screen Share View (Main Area)
                            Expanded(
                              flex: 3,
                              child: _buildScreenShareView(),
                            ),
                            
                            // Side Panel (Participants only)
                            Container(
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border(left: BorderSide(color: Colors.grey.shade300)),
                              ),
                              child: _buildParticipantsPanel(),
                            ),
                          ],
                        ),
                      ),
                      
                      // Transcription Section
                      if (_isTranscriptionVisible)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.grey.shade300)),
                            color: Colors.grey.shade50,
                          ),
                          child: RealTimeTranscriptionWidget(
                            sessionManager: widget.sessionManager,
                          ),
                        ),
                      
                      // Fact Check and Legal Advice Section
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey.shade300)),
                        ),
                        child: _buildFactCheckSection(),
                      ),
                    ],
                  ),
                ),
                
                // Bottom Controls
                _buildBottomControls(),
              ],
            ),
    );
  }

  Widget _buildSessionInfoBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          const Icon(Icons.live_tv, color: Colors.red),
          const SizedBox(width: 8),
          const Text(
            'Live Monitoring',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.people, size: 16),
          const SizedBox(width: 4),
          Text('${_session?.participants.length ?? 0} participants'),
          const Spacer(),
          if (_session?.location != null) ...[
            Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              _session!.location!.address ?? 'Location tracked',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScreenShareView() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Screen share content would go here
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.screen_share,
                  size: 64,
                  color: Colors.white54,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Broadcaster\'s Screen',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Viewing live screen share from ${_session?.broadcasterId ?? "broadcaster"}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Overlay Controls
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                _buildOverlayButton(
                  icon: Icons.fullscreen,
                  onPressed: _toggleFullscreen,
                  tooltip: 'Fullscreen',
                ),
                const SizedBox(width: 8),
                _buildOverlayButton(
                  icon: Icons.screenshot,
                  onPressed: _takeScreenshot,
                  tooltip: 'Screenshot',
                ),
              ],
            ),
          ),
          

        ],
      ),
    );
  }

  Widget _buildOverlayButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildFactCheckSection() {
    return Column(
      children: [
        // Section Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Icon(Icons.fact_check, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Fact Check & Legal Advice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(_isFactCheckingPanelExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _isFactCheckingPanelExpanded = !_isFactCheckingPanelExpanded;
                  });
                },
              ),
            ],
          ),
        ),
        
        // Fact Check Content
        if (_isFactCheckingPanelExpanded)
          Expanded(
            child: FactCheckingPanel(sessionManager: widget.sessionManager),
          ),
      ],
    );
  }



  Widget _buildParticipantsPanel() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Participants',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        
        // Participants List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Broadcaster
              _buildParticipantTile(
                name: _session?.broadcasterId ?? 'Broadcaster',
                role: 'Broadcaster',
                isOnline: true,
                isBroadcaster: true,
              ),
              
              const SizedBox(height: 8),
              
              // Other Participants
              ..._session?.participants.map((participant) => _buildParticipantTile(
                name: participant.name ?? participant.id,
                role: participant.role.toString().split('.').last,
                isOnline: participant.connectionStatus == ConnectionStatus.connected,
                isBroadcaster: false,
              )) ?? [],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantTile({
    required String name,
    required String role,
    required bool isOnline,
    required bool isBroadcaster,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBroadcaster ? Colors.red.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: isBroadcaster ? Border.all(color: Colors.red.shade200) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isBroadcaster ? Colors.red : Colors.blue,
            child: Icon(
              isBroadcaster ? Icons.videocam : Icons.person,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SessionControlsWidget(
        sessionManager: widget.sessionManager,
        isParticipant: true,
      ),
    );
  }

  void _triggerEmergency() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Emergency'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to report an emergency situation?'),
            SizedBox(height: 16),
            Text(
              'This will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('• Alert all participants'),
            Text('• Contact emergency services'),
            Text('• Notify emergency contacts'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.sessionManager.triggerConsensusEmergency(
                participantId: 'current_user',
                reason: 'Emergency reported by monitoring participant',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency reported'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Report Emergency'),
          ),
        ],
      ),
    );
  }

  void _toggleFullscreen() {
    // Implementation for fullscreen toggle
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fullscreen mode toggled')),
    );
  }

  void _takeScreenshot() {
    // Implementation for taking screenshot
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Screenshot saved')),
    );
  }
}