import 'dart:async';
import 'package:expert_professional/services/api_service.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final ApiService _apiService = ApiService();

  Future<void> acceptCall(String callId) async {
    await _apiService.acceptCall(callId);
  }

  Future<void> rejectCall(String callId) async {
    await _apiService.rejectCall(callId);
  }

  Future<void> endCall(String callId) async {
    await _apiService.endCall(callId);
  }
}
