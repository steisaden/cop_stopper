import 'package:mobile/src/collaborative_monitoring/models/participant.dart';

abstract class ScreenSharingService {
  Future<void> startScreenSharing();
  Future<void> stopScreenSharing();
  Future<void> addParticipant(String participantId);
  Future<void> removeParticipant(String participantId);
  Future<void> toggleAudienceAssist(bool enabled);
  Future<void> setBitrate(int bitrate);
  Stream<bool> get onScreenSharingChanged;
  Stream<List<Participant>> get onParticipantsChanged;
  Stream<Map<String, dynamic>> get onNetworkQualityChanged;
}
