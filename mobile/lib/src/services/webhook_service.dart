import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../models/webhook_event.dart';

/// Real-time webhook service for data freshness updates
class WebhookService {
  final String webhookUrl;
  final Duration reconnectInterval;
  final int maxReconnectAttempts;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final StreamController<WebhookEvent> _eventController = StreamController.broadcast();
  
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;

  WebhookService({
    required this.webhookUrl,
    this.reconnectInterval = const Duration(seconds: 5),
    this.maxReconnectAttempts = 10,
  });

  /// Stream of webhook events
  Stream<WebhookEvent> get events => _eventController.stream;

  /// Check if webhook service is connected
  bool get isConnected => _isConnected;

  /// Connect to webhook service
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      print('Connecting to webhook service: $webhookUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(webhookUrl));
      
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      
      // Start heartbeat to keep connection alive
      _startHeartbeat();
      
      print('Connected to webhook service');
      
      // Send connection acknowledgment
      await _sendMessage({
        'type': 'connection',
        'client_id': 'cop_stopper_mobile',
        'timestamp': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      print('Failed to connect to webhook service: $e');
      _scheduleReconnect();
    }
  }

  /// Disconnect from webhook service
  Future<void> disconnect() async {
    _isConnected = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    await _subscription?.cancel();
    await _channel?.sink.close(status.normalClosure);
    
    _channel = null;
    _subscription = null;
    
    print('Disconnected from webhook service');
  }

  /// Subscribe to specific officer record updates
  Future<void> subscribeToOfficerUpdates(String officerId) async {
    if (!_isConnected) {
      throw StateError('Not connected to webhook service');
    }

    await _sendMessage({
      'type': 'subscribe',
      'topic': 'officer_updates',
      'officer_id': officerId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Subscribed to updates for officer: $officerId');
  }

  /// Subscribe to jurisdiction-wide updates
  Future<void> subscribeToJurisdictionUpdates(String jurisdiction) async {
    if (!_isConnected) {
      throw StateError('Not connected to webhook service');
    }

    await _sendMessage({
      'type': 'subscribe',
      'topic': 'jurisdiction_updates',
      'jurisdiction': jurisdiction,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Subscribed to updates for jurisdiction: $jurisdiction');
  }

  /// Subscribe to general public records updates
  Future<void> subscribeToPublicRecordsUpdates() async {
    if (!_isConnected) {
      throw StateError('Not connected to webhook service');
    }

    await _sendMessage({
      'type': 'subscribe',
      'topic': 'public_records_updates',
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Subscribed to public records updates');
  }

  /// Unsubscribe from specific updates
  Future<void> unsubscribe(String topic, {String? identifier}) async {
    if (!_isConnected) return;

    await _sendMessage({
      'type': 'unsubscribe',
      'topic': topic,
      if (identifier != null) 'identifier': identifier,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('Unsubscribed from topic: $topic');
  }

  /// Handle incoming webhook messages
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = WebhookEvent.fromJson(data);
      
      print('Received webhook event: ${event.type} for ${event.topic}');
      _eventController.add(event);
      
      // Handle special message types
      switch (event.type) {
        case WebhookEventType.heartbeat:
          _handleHeartbeat(event);
          break;
        case WebhookEventType.dataUpdate:
          _handleDataUpdate(event);
          break;
        case WebhookEventType.systemNotification:
          _handleSystemNotification(event);
          break;
        default:
          // Regular event, already added to stream
          break;
      }
    } catch (e) {
      print('Error parsing webhook message: $e');
    }
  }

  /// Handle heartbeat messages
  void _handleHeartbeat(WebhookEvent event) {
    // Respond to server heartbeat
    _sendMessage({
      'type': 'heartbeat_response',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle data update notifications
  void _handleDataUpdate(WebhookEvent event) {
    print('Data update received: ${event.data}');
    // The event is already added to the stream, consumers will handle it
  }

  /// Handle system notifications
  void _handleSystemNotification(WebhookEvent event) {
    print('System notification: ${event.data?['message']}');
    
    // Handle service maintenance notifications
    if (event.data?['type'] == 'maintenance') {
      print('Service maintenance scheduled: ${event.data?['scheduled_time']}');
    }
  }

  /// Handle connection errors
  void _handleError(dynamic error) {
    print('Webhook connection error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Handle connection disconnection
  void _handleDisconnection() {
    print('Webhook connection closed');
    _isConnected = false;
    _scheduleReconnect();
  }

  /// Schedule automatic reconnection
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      print('Max reconnection attempts reached, giving up');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(
      seconds: reconnectInterval.inSeconds * _reconnectAttempts,
    );

    print('Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s');
    
    _reconnectTimer = Timer(delay, () async {
      try {
        await connect();
      } catch (e) {
        print('Reconnection attempt failed: $e');
      }
    });
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _sendMessage({
          'type': 'heartbeat',
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  /// Send message to webhook service
  Future<void> _sendMessage(Map<String, dynamic> message) async {
    if (_channel?.sink != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  /// Get connection status information
  Map<String, dynamic> getStatus() {
    return {
      'connected': _isConnected,
      'reconnect_attempts': _reconnectAttempts,
      'max_reconnect_attempts': maxReconnectAttempts,
      'webhook_url': webhookUrl,
      'last_connection_attempt': DateTime.now().toIso8601String(),
    };
  }

  /// Dispose of resources
  void dispose() {
    disconnect();
    _eventController.close();
  }
}

/// Factory for managing webhook services
class WebhookServiceFactory {
  static WebhookService? _instance;

  static WebhookService getInstance({
    String? webhookUrl,
  }) {
    _instance ??= WebhookService(
      webhookUrl: webhookUrl ?? 'wss://api.copstopper.com/webhooks',
    );
    return _instance!;
  }

  static void dispose() {
    _instance?.dispose();
    _instance = null;
  }
}