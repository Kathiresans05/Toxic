import 'dart:async';
import 'package:expert_customer/services/api_service.dart';
import 'package:expert_customer/services/socket_service.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  Future<String> initiateCall({
    required String expertId,
    required String customerId,
    required String customerName,
    required String channelName,
    required String callType,
    required double pricePerMinute,
  }) async {
    // Ensure WebSocket is connected for real-time signaling
    _socketService.connect(customerId);

    // Call Spring Boot backend to create call session & trigger push/WS alerts
    final resp = await _apiService.initiateCall(
      expertId: expertId,
      callType: callType,
    );

    if (resp != null && resp['callId'] != null) {
      return resp['callId'].toString();
    }

    // Direct WebSocket invite fallback
    final fallbackCallId = 'call_${DateTime.now().millisecondsSinceEpoch}';
    _socketService.sendEvent('CALL_INVITE', {
      'callId': fallbackCallId,
      'targetUserId': expertId,
      'callerName': customerName,
      'channelName': channelName,
      'callType': callType,
      'pricePerMinute': pricePerMinute,
    });
    return fallbackCallId;
  }

  Future<void> endCall(String callId, int durationSeconds, double amountCharged) async {
    await _apiService.endCall(
      callId: callId,
      durationSeconds: durationSeconds,
      amountCharged: amountCharged,
    );
    _socketService.sendEvent('CALL_END', {
      'callId': callId,
      'durationSeconds': durationSeconds,
      'amountCharged': amountCharged,
    });
  }

  Future<void> processBilling(String customerId, String expertId, double pricePerMinute, int durationSeconds) async {
    // Billing is handled atomically and securely by the backend /calls/{callId}/end endpoint
  }
}
