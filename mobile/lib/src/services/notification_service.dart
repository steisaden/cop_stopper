// import 'package:firebase_messaging/firebase_messaging.dart'; // Disabled for web testing
import 'package:mobile/src/collaborative_monitoring/models/collaborative_session.dart';

enum NotificationPriority {
  low,
  normal,
  high,
  emergency,
}

class NotificationService {
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance; // Disabled for web testing

  Future<void> initialize() async {
    // Web-compatible notification initialization
    print('NotificationService initialized (web mode)');
    // await _firebaseMessaging.requestPermission();
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   // Handle foreground messages
    //   _handleForegroundMessage(message);
    // });
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   // Handle background messages
    //   _handleBackgroundMessage(message);
    // });
  }

  Future<String?> getToken() async {
    // return await _firebaseMessaging.getToken();
    return 'web-test-token'; // Mock token for web testing
  }

  // Group invitation methods
  Future<void> sendGroupInvitation(String participantId, CollaborativeSession session) async {
    await _sendNotification(
      participantId,
      'Monitoring Request',
      'You\'ve been invited to monitor a police interaction',
      {
        'type': 'group_invitation',
        'sessionId': session.id,
        'broadcasterId': session.broadcasterId,
        'urgency': _calculateUrgency(session),
      },
      NotificationPriority.high,
    );
  }

  // Spectator-related methods
  Future<void> broadcastSpectatorOpportunity(CollaborativeSession session) async {
    // In a real implementation, this would broadcast to nearby pro users
    await _sendLocationBasedNotification(
      session.location,
      session.privacy.spectatorRadius ?? 5.0,
      'Assistance Needed',
      'Someone nearby needs monitoring assistance',
      {
        'type': 'spectator_opportunity',
        'sessionId': session.id,
        'location': session.location?.toJson(),
        'urgency': _calculateUrgency(session),
      },
      NotificationPriority.normal,
    );
  }

  Future<void> notifySpectatorApproved(String spectatorId, String sessionId) async {
    await _sendNotification(
      spectatorId,
      'Request Approved',
      'You can now assist with the monitoring session',
      {
        'type': 'spectator_approved',
        'sessionId': sessionId,
      },
      NotificationPriority.normal,
    );
  }

  Future<void> notifySpectatorRejected(String spectatorId, String sessionId, String reason) async {
    await _sendNotification(
      spectatorId,
      'Request Declined',
      'Your assistance request was declined: $reason',
      {
        'type': 'spectator_rejected',
        'sessionId': sessionId,
        'reason': reason,
      },
      NotificationPriority.low,
    );
  }

  Future<void> notifySpectatorDisconnected(String spectatorId, String sessionId) async {
    await _sendNotification(
      spectatorId,
      'Session Ended',
      'The monitoring session has ended',
      {
        'type': 'spectator_disconnected',
        'sessionId': sessionId,
      },
      NotificationPriority.normal,
    );
  }

  // Session management methods
  Future<void> notifySessionEnded(String participantId, String sessionId) async {
    await _sendNotification(
      participantId,
      'Session Ended',
      'The monitoring session has ended',
      {
        'type': 'session_ended',
        'sessionId': sessionId,
      },
      NotificationPriority.normal,
    );
  }

  Future<void> sendEmergencyAlert(CollaborativeSession session) async {
    // Send to all participants
    for (final participant in session.participants) {
      await _sendNotification(
        participant.id,
        'EMERGENCY',
        'Emergency escalation triggered in monitoring session',
        {
          'type': 'emergency_alert',
          'sessionId': session.id,
          'location': session.location?.toJson(),
          'broadcasterId': session.broadcasterId,
        },
        NotificationPriority.emergency,
      );
    }

    // Also send to emergency contacts if configured
    await _sendEmergencyContacts(session);
  }

  // Legacy methods
  Future<void> sendSessionInvitation(String userId, String sessionId) async {
    await _sendNotification(
      userId,
      'Session Invitation',
      'You\'ve been invited to a monitoring session',
      {
        'type': 'session_invitation',
        'sessionId': sessionId,
      },
      NotificationPriority.high,
    );
  }

  Future<void> setAvailabilityStatus(bool available) async {
    // In a real implementation, this would update the user's availability status
    // This might involve updating a backend service or local storage
  }

  Future<void> sendEmergencyNotification(String message) async {
    await _sendNotification(
      'current_user', // Would come from auth service
      'EMERGENCY',
      message,
      {
        'type': 'emergency',
        'message': message,
      },
      NotificationPriority.emergency,
    );
  }
  
  Future<void> showError(String title, String message) async {
    await _sendNotification(
      'current_user', // Would come from auth service
      title,
      message,
      {
        'type': 'error',
        'title': title,
        'message': message,
      },
      NotificationPriority.high,
    );
  }

  // Private helper methods
  Future<void> _sendNotification(
    String recipientId,
    String title,
    String body,
    Map<String, dynamic> data,
    NotificationPriority priority,
  ) async {
    // In a real implementation, this would send via Firebase Cloud Messaging
    // For now, we'll just log the notification
    print('Notification to $recipientId: $title - $body (Priority: $priority)');
    print('Data: $data');
  }

  Future<void> _sendLocationBasedNotification(
    GeoLocation? location,
    double radiusMiles,
    String title,
    String body,
    Map<String, dynamic> data,
    NotificationPriority priority,
  ) async {
    // In a real implementation, this would query for users within the radius
    // and send notifications to them
    print('Location-based notification within $radiusMiles miles of ${location?.address}');
    print('$title - $body (Priority: $priority)');
    print('Data: $data');
  }

  Future<void> _sendEmergencyContacts(CollaborativeSession session) async {
    // In a real implementation, this would send to configured emergency contacts
    print('Sending emergency alerts for session ${session.id}');
  }

  String _calculateUrgency(CollaborativeSession session) {
    // In a real implementation, this would analyze various factors:
    // - Audio analysis for stress indicators
    // - Location (high-crime areas)
    // - Time of day
    // - Duration of interaction
    // For now, return a default value
    return 'medium';
  }

  void _handleForegroundMessage(dynamic message) {
    // Handle notifications when app is in foreground (web-compatible)
    print('Foreground message: $message');
  }

  void _handleBackgroundMessage(dynamic message) {
    // Handle notifications when app is opened from background (web-compatible)
    print('Background message: $message');
  }
}
