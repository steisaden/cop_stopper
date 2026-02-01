import 'dart:async';

import 'package:mobile/src/collaborative_monitoring/interfaces/screen_sharing_service.dart';
import 'package:mobile/src/collaborative_monitoring/models/participant.dart';

/// Stub implementation of ScreenSharingService when WebRTC is disabled
class ScreenSharingServiceStub implements ScreenSharingService {
  final StreamController<bool> _isScreenSharingController = StreamController<bool>.broadcast();
  final StreamController<List<Participant>> _participantsController = StreamController<List<Participant>>.broadcast();
  final StreamController<Map<String, dynamic>> _networkQualityController = StreamController<Map<String, dynamic>>.broadcast();

  bool _isSharing = false;
  final List<Participant> _participants = [];

  @override
  Future<void> startScreenSharing() async {
    print('Screen sharing started (stub implementation)');
    _isSharing = true;
    _isScreenSharingController.add(_isSharing);
  }

  @override
  Future<void> stopScreenSharing() async {
    print('Screen sharing stopped (stub implementation)');
    _isSharing = false;
    _isScreenSharingController.add(_isSharing);
  }

  @override
  Future<void> addParticipant(String participantId) async {
    print('Participant added: $participantId (stub implementation)');
    final participant = Participant(
      id: participantId,
      name: 'Participant $participantId',
      role: ParticipantRole.spectator,
      connectionStatus: ConnectionStatus.connected,
      joinedAt: DateTime.now(),
    );
    _participants.add(participant);
    _participantsController.add(List.from(_participants));
  }

  @override
  Future<void> removeParticipant(String participantId) async {
    print('Participant removed: $participantId (stub implementation)');
    _participants.removeWhere((p) => p.id == participantId);
    _participantsController.add(List.from(_participants));
  }

  @override
  Future<void> setBitrate(int bitrate) async {
    print('Bitrate set to: $bitrate (stub implementation)');
  }

  @override
  Future<void> toggleAudienceAssist(bool enabled) async {
    print('Audience assist toggled: $enabled (stub implementation)');
  }

  @override
  Stream<bool> get onScreenSharingChanged => _isScreenSharingController.stream;

  @override
  Stream<List<Participant>> get onParticipantsChanged => _participantsController.stream;

  @override
  Stream<Map<String, dynamic>> get onNetworkQualityChanged => _networkQualityController.stream;

  @override
  bool get isScreenSharing => _isSharing;

  @override
  List<Participant> get participants => List.from(_participants);

  void dispose() {
    _isScreenSharingController.close();
    _participantsController.close();
    _networkQualityController.close();
  }
}