import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:expert_professional/constants.dart';

class SocketService {
  IO.Socket? _socket;
  Function(Map<String, dynamic>)? onIncomingCall;
  Function(Map<String, dynamic>)? onReceiveMessage;
  
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? get socket => _socket;

  void connect(String userId) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      AppConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket']) 
          .disableAutoConnect()
          .setQuery({'userId': userId}) 
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Connected to WebSocket server');
    });

    _socket!.on('incoming_call', (data) {
      print('Incoming call event received: $data');
      if (onIncomingCall != null && data is Map) {
        onIncomingCall!(Map<String, dynamic>.from(data));
      }
    });

    _socket!.on('receive_message', (data) {
      print('Chat message received: $data');
      if (onReceiveMessage != null && data is Map) {
        onReceiveMessage!(Map<String, dynamic>.from(data));
      }
    });

    _socket!.onDisconnect((_) {
      print('Disconnected from WebSocket server');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
