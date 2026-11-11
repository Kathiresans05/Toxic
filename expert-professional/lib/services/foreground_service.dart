import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:expert_professional/screens/incoming_call_screen.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class ForegroundService {
  static const MethodChannel _channel =
      MethodChannel('com.connectax.expert_professional/foreground_service');

  static final ForegroundService _instance = ForegroundService._internal();
  factory ForegroundService() => _instance;

  ForegroundService._internal() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  Future<void> _handleNativeCall(MethodCall call) async {
    debugPrint('ForegroundService received method call from native: ${call.method}');
    if (call.method == 'onIncomingCallFromNotification') {
      final data = Map<String, dynamic>.from(call.arguments as Map);
      _openIncomingCallScreen(data);
    }
  }

  Future<bool> startOnlineService() async {
    if (!Platform.isAndroid) return false;
    try {
      // Request notification permission for Android 13+
      await Permission.notification.request();

      final res = await _channel.invokeMethod<bool>('startService');
      debugPrint('ForegroundService startService returned: $res');
      return res ?? false;
    } catch (e) {
      debugPrint('Error starting foreground service: $e');
      return false;
    }
  }

  Future<bool> stopOnlineService() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('stopService');
      debugPrint('ForegroundService stopService returned: $res');
      return res ?? false;
    } catch (e) {
      debugPrint('Error stopping foreground service: $e');
      return false;
    }
  }

  Future<bool> isServiceRunning() async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isServiceRunning');
      return res ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> triggerIncomingCall({
    required String callerName,
    required String callId,
    required String channelName,
    double price = 3.0,
    String callType = 'video',
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('triggerIncomingCall', {
        'callerName': callerName,
        'callId': callId,
        'channelName': channelName,
        'price': price,
        'callType': callType,
      });
    } catch (e) {
      debugPrint('Error triggering incoming call native notification: $e');
    }
  }

  Future<void> bringAppToForeground() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('bringAppToForeground');
    } catch (e) {
      debugPrint('Error bringing app to foreground: $e');
    }
  }

  void _openIncomingCallScreen(Map<String, dynamic> data) {
    final callerName = data['callerName']?.toString() ?? 'Customer';
    final callId = data['callId']?.toString() ?? '';
    final channelName = data['channelName']?.toString() ?? 'room_$callId';
    final price = double.tryParse(data['price']?.toString() ?? '') ?? 3.0;
    final callType = data['callType']?.toString() ?? 'video';

    final nav = appNavigatorKey.currentState;
    if (nav != null) {
      nav.push(
        MaterialPageRoute(
          builder: (_) => IncomingCallScreen(
            callId: callId,
            callerName: callerName,
            channelName: channelName,
            pricePerMinute: price,
            callType: callType,
          ),
        ),
      );
    }
  }
}

