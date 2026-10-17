import 'package:dio/dio.dart';
import 'package:expert_professional/constants.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Dio get client => _dio;

  Future<bool> sendOtp(String mobileNumber) async {
    try {
      final response = await _dio.post('/auth/send-otp', data: {
        'mobileNumber': mobileNumber,
      });
      return response.data['success'] ?? false;
    } catch (e) {
      print('Send OTP Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyOtp(String mobileNumber, String otp) async {
    try {
      final response = await _dio.post('/auth/verify-otp', data: {
        'mobileNumber': mobileNumber,
        'otp': otp,
      });
      return response.data; 
    } catch (e) {
      print('Verify OTP Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginWithEmail(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login-email', data: {
        'email': email,
        'password': password,
      });
      return response.data; 
    } catch (e) {
      print('Login Email Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getExpertProfile() async {
    try {
      final response = await _dio.get('/experts/profile');
      return response.data;
    } catch (e) {
      print('Get Expert Profile Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getExpertStats() async {
    try {
      final response = await _dio.get('/experts/stats');
      return response.data;
    } catch (e) {
      print('Get Expert Stats Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> recordCompletedCall({int durationSeconds = 225, double amountCharged = 25.0}) async {
    try {
      final response = await _dio.post('/calls/record', data: {
        'durationSeconds': durationSeconds,
        'amountCharged': amountCharged,
      });
      return response.data;
    } catch (e) {
      print('Record Call Error: $e');
      return null;
    }
  }

  Future<List<dynamic>?> getCallHistory() async {
    try {
      final response = await _dio.get('/calls/history');
      return response.data;
    } catch (e) {
      print('Get Call History Error: $e');
      return [];
    }
  }

  Future<List<dynamic>?> getExpertReviews() async {
    try {
      final response = await _dio.get('/experts/reviews');
      return response.data;
    } catch (e) {
      print('Get Expert Reviews Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getExpertEarnings(String filter) async {
    try {
      final response = await _dio.get('/experts/earnings', queryParameters: {
        'filter': filter.toLowerCase().contains('week')
            ? 'week'
            : filter.toLowerCase().contains('month')
                ? 'month'
                : 'today',
      });
      return response.data;
    } catch (e) {
      print('Get Expert Earnings Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> toggleExpertStatus(bool isOnline) async {
    try {
      final response = await _dio.put('/experts/status', data: {
        'isOnline': isOnline,
      });
      return response.data;
    } catch (e) {
      print('Toggle Expert Status Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateExpertProfile({
    String? bio,
    int? experienceYears,
    List<String>? languages,
    String? aadhaarNumber,
    String? panNumber,
    String? voiceSampleUrl,
  }) async {
    try {
      final response = await _dio.put('/experts/profile', data: {
        'bio': ?bio,
        'experienceYears': ?experienceYears,
        'languages': ?languages,
        'aadhaarNumber': ?aadhaarNumber,
        'panNumber': ?panNumber,
        'voiceSampleUrl': ?voiceSampleUrl,
      });
      return response.data;
    } catch (e) {
      print('Update Expert Profile Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> requestPayoutWithdrawal(double amount, Map<String, dynamic> methodDetails) async {
    try {
      final String method = methodDetails['method'] ?? 'UPI';
      final String accountDetails = method == 'UPI'
          ? (methodDetails['upiId'] ?? 'UPI ID')
          : 'A/C: ${methodDetails['accountNumber'] ?? ''}, Bank: ${methodDetails['bankName'] ?? ''}';

      final response = await _dio.post('/users/payout-request', data: {
        'amount': amount,
        'payoutMethod': method,
        'accountDetails': accountDetails,
      });
      return response.data;
    } catch (e) {
      print('Request Payout Error: $e');
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
}
