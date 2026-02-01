import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;

  void connect(String url) {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void sendMessage(String message) {
    _channel?.sink.add(message);
  }

  Stream<dynamic>? get stream => _channel?.stream;

  void disconnect() {
    _channel?.sink.close();
  }
}
