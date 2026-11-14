import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:expert_professional/constants.dart';

class SocketService {
  WebSocket? _socket;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  String? _currentUserId;

  Function(Map<String, dynamic>)? onCallAccepted;
  Function(Map<String, dynamic>)? onCallRejected;
  Function(Map<String, dynamic>)? onCallEnded;
  Function(Map<String, dynamic>)? onIncomingCall;
  Function(Map<String, dynamic>)? onReceiveMessage;

  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  bool get isConnected => _socket != null && _socket!.readyState == WebSocket.open;

  void connect(String userId) async {
    if (kIsWeb || userId.isEmpty) return;
    _currentUserId = userId;

    if (isConnected) return;

    try {
      final base = AppConstants.baseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://')
          .replaceFirst('/api/v1', '');
      final wsUrl = '$base/ws/calls?userId=$userId';

      debugPrint('Professional connecting to Native WebSocket: $wsUrl');
      _socket = await WebSocket.connect(wsUrl).timeout(const Duration(seconds: 5));

      // Register message
      sendEvent('REGISTER', {'userId': userId});

      _socket!.listen(
        (data) {
          try {
            final Map<String, dynamic> message = jsonDecode(data as String);
            _handleMessage(message);
          } catch (e) {
            debugPrint('Error parsing ws message: $e');
          }
        },
        onError: (err) {
          debugPrint('Professional WebSocket error: $err');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('Professional WebSocket disconnected');
          _scheduleReconnect();
        },
        cancelOnError: true,
      );

      // Keepalive ping every 25s
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 25), (_) {
        if (isConnected) {
          _socket?.add(jsonEncode({'event': 'PING'}));
        }
      });
    } catch (e) {
      debugPrint('Failed to connect Professional WebSocket: $e');
      _scheduleReconnect();
    }
  }

  void _handleMessage(Map<String, dynamic> msg) {
    final event = msg['event']?.toString().toUpperCase();
    debugPrint('Professional received WS Event: $event -> $msg');

    switch (event) {
      case 'INCOMING_CALL':
      case 'CALL_INVITE':
        onIncomingCall?.call(msg);
        break;
      case 'CALL_ACCEPTED':
      case 'CALL_ACCEPT':
        onCallAccepted?.call(msg);
        break;
      case 'CALL_REJECTED':
      case 'CALL_REJECT':
        onCallRejected?.call(msg);
        break;
      case 'CALL_ENDED':
      case 'CALL_END':
        onCallEnded?.call(msg);
        break;
      case 'RECEIVE_MESSAGE':
        onReceiveMessage?.call(msg);
        break;
    }
  }

  void sendEvent(String event, Map<String, dynamic> data) {
    if (isConnected) {
      final payload = Map<String, dynamic>.from(data);
      payload['event'] = event;
      _socket?.add(jsonEncode(payload));
    }
  }

  void _scheduleReconnect() {
    _socket = null;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    if (!kIsWeb && _currentUserId != null && _currentUserId!.isNotEmpty) {
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        if (!isConnected && _currentUserId != null) {
          connect(_currentUserId!);
        }
      });
    }
  }

  void disconnect() {
    _currentUserId = null;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _socket?.close();
    _socket = null;
  }
}
