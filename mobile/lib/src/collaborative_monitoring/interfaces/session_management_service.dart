import 'package:mobile/src/collaborative_monitoring/models/collaborative_session.dart';

abstract class SessionManagementService {
  Future<void> createSession();
  Future<void> joinSession(String sessionId);
  Future<void> leaveSession();
  Stream<CollaborativeSession?> get onSessionChanged;
}
