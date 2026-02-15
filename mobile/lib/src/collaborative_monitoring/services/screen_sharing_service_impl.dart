import 'dart:async';
import 'dart:math';

// import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mobile/src/collaborative_monitoring/interfaces/screen_sharing_service.dart';
import 'package:mobile/src/collaborative_monitoring/models/participant.dart';
import 'package:mobile/src/collaborative_monitoring/services/peer_connection_manager.dart';

// Stub classes for WebRTC when disabled
class MediaStream {
  // Stub implementation
}

class RTCPeerConnection {
  Function(dynamic)? onIceConnectionState;
  Function(dynamic)? onConnectionState;
  Function(dynamic)? onIceCandidate;
  
  Future<List<dynamic>> getSenders() async => [];
  Future<void> addStream(MediaStream stream) async {}
  Future<void> close() async {}
}

class RTCRtpSender {
  dynamic track;
}

class RTCIceConnectionState {
  static const connected = 'connected';
  static const disconnected = 'disconnected';
  static const failed = 'failed';
}

class RTCPeerConnectionState {
  static const connected = 'connected';
  static const disconnected = 'disconnected';
  static const failed = 'failed';
}

Future<MediaStream> navigator_mediaDevices_getDisplayMedia(Map<String, dynamic> constraints) async {
  return MediaStream();
}

Future<RTCPeerConnection> createPeerConnection(Map<String, dynamic> configuration) async {
  return RTCPeerConnection();
}

class ScreenSharingServiceImpl implements ScreenSharingService {
  MediaStream? _localStream;
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final List<Participant> _participants = [];
  bool _audienceAssistEnabled = false;
  int _currentBitrate = 1000000; // 1 Mbps default
  
  final _onScreenSharingChangedController = StreamController<bool>.broadcast();
  final _onParticipantsChangedController = StreamController<List<Participant>>.broadcast();
  final _onNetworkQualityChangedController = StreamController<Map<String, dynamic>>.broadcast();
  
  Timer? _networkQualityTimer;
  Timer? _bitrateAdjustmentTimer;

  @override
  Future<void> startScreenSharing() async {
    try {
      _localStream = await navigator.mediaDevices.getDisplayMedia({
        'video': {
          'width': {'ideal': 1920},
          'height': {'ideal': 1080},
          'frameRate': {'ideal': 30, 'max': 60}
        },
        'audio': true,
      });
      
      _onScreenSharingChangedController.add(true);
      _startNetworkQualityMonitoring();
      _startBitrateAdjustment();
    } catch (e) {
      throw Exception('Failed to start screen sharing: $e');
    }
  }

  @override
  Future<void> stopScreenSharing() async {
    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        track.stop();
      });
      _localStream = null;
    }
    
    // Close all peer connections
    for (final connection in _peerConnections.values) {
      await connection.close();
    }
    _peerConnections.clear();
    _participants.clear();
    
    _networkQualityTimer?.cancel();
    _bitrateAdjustmentTimer?.cancel();
    
    _onScreenSharingChangedController.add(false);
    _onParticipantsChangedController.add([]);
  }

  @override
  Future<void> addParticipant(String participantId) async {
    if (_localStream == null) {
      throw Exception('Screen sharing not started');
    }
    
    // Check participant limits for private groups (max 10)
    if (!_audienceAssistEnabled && _participants.length >= 10) {
      throw Exception('Maximum participants reached for private group (10)');
    }
    
    try {
      final peerConnection = await _createPeerConnection();
      _peerConnections[participantId] = peerConnection;
      
      // Add local stream to peer connection
      await peerConnection.addStream(_localStream!);
      
      // Create participant
      final participant = Participant(
        id: participantId,
        connectionStatus: ConnectionStatus.connecting,
        joinedAt: DateTime.now(),
        role: _audienceAssistEnabled ? ParticipantRole.spectator : ParticipantRole.groupMember,
      );
      
      _participants.add(participant);
      _onParticipantsChangedController.add(List.from(_participants));
      
      // Adjust bitrate based on participant count
      await _adjustBitrateForParticipantCount();
      
    } catch (e) {
      throw Exception('Failed to add participant: $e');
    }
  }

  @override
  Future<void> removeParticipant(String participantId) async {
    final connection = _peerConnections.remove(participantId);
    if (connection != null) {
      await connection.close();
    }
    
    _participants.removeWhere((p) => p.id == participantId);
    _onParticipantsChangedController.add(List.from(_participants));
    
    // Adjust bitrate based on new participant count
    await _adjustBitrateForParticipantCount();
  }

  @override
  Future<void> toggleAudienceAssist(bool enabled) async {
    _audienceAssistEnabled = enabled;
    
    if (!enabled) {
      // Remove spectator participants when disabling audience assist
      final spectatorsToRemove = _participants
          .where((p) => p.role == ParticipantRole.spectator)
          .map((p) => p.id)
          .toList();
      
      for (final spectatorId in spectatorsToRemove) {
        await removeParticipant(spectatorId);
      }
    }
  }

  @override
  Future<void> setBitrate(int bitrate) async {
    _currentBitrate = bitrate;
    await _applyBitrateToAllConnections();
  }

  @override
  Stream<bool> get onScreenSharingChanged =>
      _onScreenSharingChangedController.stream;

  @override
  Stream<List<Participant>> get onParticipantsChanged =>
      _onParticipantsChangedController.stream;

  @override
  Stream<Map<String, dynamic>> get onNetworkQualityChanged =>
      _onNetworkQualityChangedController.stream;

  Future<RTCPeerConnection> _createPeerConnection() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
      'iceCandidatePoolSize': 10,
    };
    
    final peerConnection = await createPeerConnection(configuration);
    
    peerConnection.onIceConnectionState = (state) {
      _updateParticipantConnectionStatus(peerConnection, state);
    };
    
    return peerConnection;
  }

  void _updateParticipantConnectionStatus(RTCPeerConnection connection, RTCIceConnectionState state) {
    final participantId = _peerConnections.entries
        .firstWhere((entry) => entry.value == connection, orElse: () => MapEntry('', connection))
        .key;
    
    if (participantId.isNotEmpty) {
      final participantIndex = _participants.indexWhere((p) => p.id == participantId);
      if (participantIndex != -1) {
        ConnectionStatus status;
        switch (state) {
          case RTCIceConnectionState.RTCIceConnectionStateConnected:
          case RTCIceConnectionState.RTCIceConnectionStateCompleted:
            status = ConnectionStatus.connected;
            break;
          case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          case RTCIceConnectionState.RTCIceConnectionStateFailed:
            status = ConnectionStatus.disconnected;
            break;
          default:
            status = ConnectionStatus.connecting;
        }
        
        _participants[participantIndex] = _participants[participantIndex].copyWith(
          connectionStatus: status,
        );
        _onParticipantsChangedController.add(List.from(_participants));
      }
    }
  }

  Future<void> _adjustBitrateForParticipantCount() async {
    final participantCount = _participants.length;
    int targetBitrate;
    
    if (participantCount <= 2) {
      targetBitrate = 2000000; // 2 Mbps for 1-2 participants
    } else if (participantCount <= 5) {
      targetBitrate = 1500000; // 1.5 Mbps for 3-5 participants
    } else if (participantCount <= 10) {
      targetBitrate = 1000000; // 1 Mbps for 6-10 participants
    } else {
      targetBitrate = 500000; // 500 Kbps for more than 10 participants
    }
    
    if (targetBitrate != _currentBitrate) {
      _currentBitrate = targetBitrate;
      await _applyBitrateToAllConnections();
    }
  }

  Future<void> _applyBitrateToAllConnections() async {
    for (final connection in _peerConnections.values) {
      try {
        final senders = await connection.getSenders();
        for (final sender in senders) {
          if (sender.track?.kind == 'video') {
            // TODO: Fix getParameters() method when WebRTC package is updated
            // final params = await sender.getParameters();
            // if (params.encodings.isNotEmpty) {
            //   params.encodings[0].maxBitrate = _currentBitrate;
            //   await sender.setParameters(params);
            // }
          }
        }
      } catch (e) {
        // Log error but continue with other connections
        print('Failed to set bitrate for connection: $e');
      }
    }
  }

  void _startNetworkQualityMonitoring() {
    _networkQualityTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final qualityData = <String, dynamic>{};
      
      for (final entry in _peerConnections.entries) {
        try {
          final stats = await entry.value.getStats();
          final participantQuality = _calculateNetworkQuality(stats);
          qualityData[entry.key] = participantQuality;
        } catch (e) {
          qualityData[entry.key] = {'quality': 'poor', 'error': e.toString()};
        }
      }
      
      qualityData['participantCount'] = _participants.length;
      qualityData['currentBitrate'] = _currentBitrate;
      
      _onNetworkQualityChangedController.add(qualityData);
    });
  }

  void _startBitrateAdjustment() {
    _bitrateAdjustmentTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _adjustBitrateBasedOnNetworkConditions();
    });
  }

  Map<String, dynamic> _calculateNetworkQuality(List<StatsReport> stats) {
    double avgRtt = 0;
    double packetLoss = 0;
    int bandwidth = 0;
    
    for (final report in stats) {
      if (report.type == 'candidate-pair' && report.values['state'] == 'succeeded') {
        avgRtt = double.tryParse(report.values['currentRoundTripTime']?.toString() ?? '0') ?? 0;
      }
      if (report.type == 'outbound-rtp' && report.values['mediaType'] == 'video') {
        final sent = int.tryParse(report.values['packetsSent']?.toString() ?? '0') ?? 0;
        final lost = int.tryParse(report.values['packetsLost']?.toString() ?? '0') ?? 0;
        if (sent > 0) {
          packetLoss = (lost / sent) * 100;
        }
        bandwidth = int.tryParse(report.values['totalEncodedBytesTarget']?.toString() ?? '0') ?? 0;
      }
    }
    
    String quality;
    if (avgRtt < 100 && packetLoss < 1) {
      quality = 'excellent';
    } else if (avgRtt < 200 && packetLoss < 3) {
      quality = 'good';
    } else if (avgRtt < 400 && packetLoss < 5) {
      quality = 'fair';
    } else {
      quality = 'poor';
    }
    
    return {
      'quality': quality,
      'rtt': avgRtt,
      'packetLoss': packetLoss,
      'bandwidth': bandwidth,
    };
  }

  Future<void> _adjustBitrateBasedOnNetworkConditions() async {
    if (_peerConnections.isEmpty) return;
    
    int poorQualityCount = 0;
    int totalConnections = _peerConnections.length;
    
    for (final connection in _peerConnections.values) {
      try {
        final stats = await connection.getStats();
        final quality = _calculateNetworkQuality(stats);
        if (quality['quality'] == 'poor' || quality['quality'] == 'fair') {
          poorQualityCount++;
        }
      } catch (e) {
        poorQualityCount++; // Count errors as poor quality
      }
    }
    
    // If more than 30% of connections have poor quality, reduce bitrate
    if (poorQualityCount > totalConnections * 0.3) {
      final newBitrate = max(200000, (_currentBitrate * 0.8).round()); // Reduce by 20%, minimum 200 Kbps
      if (newBitrate != _currentBitrate) {
        await setBitrate(newBitrate);
      }
    }
    // If all connections are good, gradually increase bitrate
    else if (poorQualityCount == 0 && _currentBitrate < 2000000) {
      final newBitrate = min(2000000, (_currentBitrate * 1.1).round()); // Increase by 10%, maximum 2 Mbps
      if (newBitrate != _currentBitrate) {
        await setBitrate(newBitrate);
      }
    }
  }

  void dispose() {
    _onScreenSharingChangedController.close();
    _onParticipantsChangedController.close();
    _onNetworkQualityChangedController.close();
    _networkQualityTimer?.cancel();
    _bitrateAdjustmentTimer?.cancel();
  }
}
