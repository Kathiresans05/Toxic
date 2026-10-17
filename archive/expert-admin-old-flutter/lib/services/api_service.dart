import 'package:dio/dio.dart';
import 'package:expert_admin/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  ApiService._internal();

  Future<List<Map<String, dynamic>>?> getAllExperts() async {
    try {
      final response = await _dio.get('/experts');
      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        List<dynamic> listData = [];
        if (rawData is List) {
          listData = rawData;
        } else if (rawData is Map && rawData['value'] is List) {
          listData = rawData['value'];
        } else if (rawData is Map && rawData['data'] is List) {
          listData = rawData['data'];
        }
        return listData.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } catch (e) {
      print('Get All Experts Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> approveExpert(String expertId, {bool isApproved = true}) async {
    try {
      final response = await _dio.put(
        '/experts/$expertId/approve',
        data: {'isApproved': isApproved},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Approve Expert Error: $e');
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

  Future<Map<String, dynamic>?> updateSettings({
    required double commissionPercentage,
    required double audioCallRate,
    required double videoCallRate,
    required double chatMessageRate,
  }) async {
    try {
      final response = await _dio.put(
        '/users/settings',
        data: {
          'commissionPercentage': commissionPercentage,
          'audioCallRate': audioCallRate,
          'videoCallRate': videoCallRate,
          'chatMessageRate': chatMessageRate,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Update Settings Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllUsers() async {
    try {
      final response = await _dio.get('/users');
      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        List<dynamic> listData = [];
        if (rawData is List) {
          listData = rawData;
        } else if (rawData is Map && rawData['value'] is List) {
          listData = rawData['value'];
        } else if (rawData is Map && rawData['data'] is List) {
          listData = rawData['data'];
        }
        return listData.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } catch (e) {
      print('Get All Users Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> toggleBlockUser(String userId, {bool? isBlocked}) async {
    try {
      final response = await _dio.put(
        '/users/$userId/block',
        data: isBlocked != null ? {'isBlocked': isBlocked} : {},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Toggle Block User Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getPayoutRequests() async {
    try {
      final response = await _dio.get('/users/payout-requests');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } catch (e) {
      print('Get Payout Requests Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> approvePayoutRequest(String payoutId, {String? transactionReference}) async {
    try {
      final response = await _dio.put(
        '/users/payout-requests/$payoutId/approve',
        data: transactionReference != null ? {'transactionReference': transactionReference} : {},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Approve Payout Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> rejectPayoutRequest(String payoutId, {String? rejectionReason}) async {
    try {
      final response = await _dio.put(
        '/users/payout-requests/$payoutId/reject',
        data: rejectionReason != null ? {'rejectionReason': rejectionReason} : {},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Reject Payout Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getBanners() async {
    try {
      final response = await _dio.get('/users/banners');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } catch (e) {
      print('Get Banners Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createBanner({
    required String title,
    required String imageUrl,
    String? redirectUrl,
    bool isActive = true,
  }) async {
    try {
      final response = await _dio.post(
        '/users/banners',
        data: {
          'title': title,
          'imageUrl': imageUrl,
          'redirectUrl': redirectUrl ?? '/recharge',
          'isActive': isActive,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Create Banner Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> toggleBannerStatus(String bannerId, {required bool isActive}) async {
    try {
      final response = await _dio.put(
        '/users/banners/$bannerId/status',
        data: {'isActive': isActive},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Toggle Banner Status Error: $e');
      return null;
    }
  }

  Future<bool> deleteBanner(String bannerId) async {
    try {
      final response = await _dio.delete('/users/banners/$bannerId');
      return response.statusCode == 200;
    } catch (e) {
      print('Delete Banner Error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> getLiveCalls() async {
    try {
      final response = await _dio.get('/calls/live');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } catch (e) {
      print('Get Live Calls Error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getAllCallHistory() async {
    try {
      final response = await _dio.get('/calls/admin-history');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return null;
    } catch (e) {
      print('Get All Call History Error: $e');
      return null;
    }
  }

  Future<bool> forceEndCall(String callId) async {
    try {
      final response = await _dio.post('/calls/force-end', data: {'callId': callId});
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Force End Call Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getAdminStats() async {
    try {
      final response = await _dio.get('/calls/admin-stats');
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return null;
    } catch (e) {
      print('Get Admin Stats Error: $e');
      return null;
    }
  }
}
