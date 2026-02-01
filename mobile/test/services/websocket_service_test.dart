import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/services/websocket_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:mockito/mockito.dart';

class MockWebSocketChannel extends Mock implements WebSocketChannel {}
class MockWebSocketSink extends Mock implements WebSocketSink {}

void main() {
  group('WebSocketService', () {
    late WebSocketService webSocketService;
    late MockWebSocketChannel mockChannel;
    late MockWebSocketSink mockSink;

    setUp(() {
      webSocketService = WebSocketService();
      mockChannel = MockWebSocketChannel();
      mockSink = MockWebSocketSink();
      when(mockChannel.sink).thenReturn(mockSink);
    });

    test('connect does not throw', () {
      // This is not a real test as we can't connect to a real WebSocket in a test environment.
      // We are just checking that the method doesn't throw an error.
      expect(() => webSocketService.connect('ws://localhost:8080'), returnsNormally);
    });

    test('sendMessage does not throw', () {
      webSocketService.connect('ws://localhost:8080');
      expect(() => webSocketService.sendMessage('test message'), returnsNormally);
    });

    test('disconnect does not throw', () {
      webSocketService.connect('ws://localhost:8080');
      expect(() => webSocketService.disconnect(), returnsNormally);
    });
  });
}
