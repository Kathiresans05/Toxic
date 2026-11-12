import 'package:dio/dio.dart';
import 'package:expert_customer/constants.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio get client => _dio;

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get('/users/profile');
      return response.data;
    } catch (e) {
      print('Get Profile Error: $e');
      return null;
    }
  }

  Future<List<dynamic>> getOnlineExperts({String? preferredLanguage}) async {
    try {
      final response = await _dio.get(
        '/experts/online',
        queryParameters: preferredLanguage != null ? {'preferredLanguage': preferredLanguage} : null,
      );
      return response.data as List<dynamic>;
    } catch (e) {
      print('Get Online Experts Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> rechargeWallet(double amount) async {
    try {
      final response = await _dio.put('/users/recharge', data: {
        'amount': amount,
      });
      return response.data;
    } catch (e) {
      print('Recharge Wallet Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getAgoraToken(String channelName, String uid) async {
    try {
      final response = await _dio.get('/calls/token', queryParameters: {
        'channelName': channelName,
        'uid': uid,
      });
      return response.data;
    } catch (e) {
      print('Get Agora Token Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> initiateCall({
    required String expertId,
    String callType = 'VIDEO',
  }) async {
    try {
      final response = await _dio.post('/calls/initiate', data: {
        'expertId': expertId,
        'callType': callType.toUpperCase(),
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Initiate Call Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> acceptCall(String callId) async {
    try {
      final response = await _dio.post('/calls/$callId/accept');
      return response.data != null ? Map<String, dynamic>.from(response.data) : null;
    } catch (e) {
      print('Accept Call Error: $e');
      return null;
    }
  }

  Future<bool> rejectCall(String callId) async {
    try {
      final response = await _dio.post('/calls/$callId/reject');
      return response.statusCode == 200;
    } catch (e) {
      print('Reject Call Error: $e');
      return false;
    }
  }

  Future<void> endCall({String? callId, String? channelName, int? durationSeconds, double? amountCharged}) async {
    try {
      if (callId != null && callId.isNotEmpty) {
        await _dio.post('/calls/$callId/end');
      } else {
        await _dio.post('/calls/end', data: {
          'callId': callId,
          'channelName': channelName,
          'durationSeconds': durationSeconds,
          'amountCharged': amountCharged,
        });
      }
    } catch (e) {
      print('End Call Error: $e');
    }
  }

  Future<Map<String, dynamic>?> processBilling(String customerId, String expertId, double pricePerMinute) async {
    try {
      final response = await _dio.post('/calls/billing', data: {
        'customerId': customerId,
        'expertId': expertId,
        'pricePerMinute': pricePerMinute,
      });
      return response.data;
    } catch (e) {
      print('Process Billing Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getActiveBanners() async {
    try {
      final response = await _dio.get('/users/banners', queryParameters: {'activeOnly': 'true'});
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } catch (e) {
      print('Get Active Banners Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final response = await _dio.get('/users/settings');
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Get Settings Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> notifyCall({
    required String expertId,
    required String callId,
    required String callerName,
    required String channelName,
    required double pricePerMinute,
    required String callType,
  }) async {
    try {
      final response = await _dio.post('/calls/notify', data: {
        'expertId': expertId,
        'callId': callId,
        'callerName': callerName,
        'channelName': channelName,
        'pricePerMinute': pricePerMinute,
        'callType': callType,
      });
      return response.data;
    } catch (e) {
      print('Notify Call Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createRazorpayOrder(double amount) async {
    try {
      final response = await _dio.post('/payments/razorpay/order', data: {
        'amount': amount,
      });
      return response.data;
    } catch (e) {
      print('Create Razorpay Order Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyRazorpayPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required double amount,
  }) async {
    try {
      final response = await _dio.post('/payments/razorpay/verify', data: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
        'amount': amount,
      });
      return response.data;
    } catch (e) {
      print('Verify Razorpay Payment Error: $e');
      return null;
    }
  }

  Future<bool> reportCall({
    required String callId,
    required String reason,
    String details = '',
    String targetType = 'CREATOR',
  }) async {
    try {
      final response = await _dio.post('/calls/$callId/report', data: {
        'reason': reason,
        'details': details,
        'targetType': targetType,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Report Call Error: $e');
      return false;
    }
  }
}

