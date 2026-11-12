import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expert_customer/services/api_service.dart';
import 'package:expert_customer/services/socket_service.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  Map<String, dynamic>? _user;
  String? _token; // JWT Auth token
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  AuthProvider() {
    _loadPersistedAuth();
  }

  Future<void> _loadPersistedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      _apiService.client.options.headers['Authorization'] = 'Bearer $_token';
      await refreshProfile();
      if (_user != null) {
        final userId =
            _user!['id']?.toString() ?? prefs.getString('user_id') ?? '';
        if (userId.isNotEmpty) {
          _socketService.connect(userId);
        }
      } else {
        await logout();
      }
    }
    notifyListeners();
  }

  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.client.post(
        '/auth/login',
        data: {
          'email': emailOrPhone.contains('@') ? emailOrPhone.trim() : null,
          'phoneNumber': !emailOrPhone.contains('@')
              ? emailOrPhone.trim()
              : null,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        _token = data['accessToken']?.toString();
        _user = {
          'id': data['userId']?.toString() ?? '',
          'uid': data['userId']?.toString() ?? '',
          'name': data['fullName'] ?? 'Customer',
          'fullName': data['fullName'] ?? 'Customer',
          'email': data['email'] ?? '',
          'phoneNumber': emailOrPhone,
          'role': data['role'] ?? 'ROLE_CUSTOMER',
          'walletBalance':
              double.tryParse(data['walletBalance']?.toString() ?? '0') ?? 0.0,
        };
        _apiService.client.options.headers['Authorization'] = 'Bearer $_token';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_id', _user!['id']);

        _socketService.connect(_user!['id']);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Spring Boot Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<String?> signUp(
    String email,
    String password,
    String name,
    String phone, {
    String preferredLanguage = 'Tamil, English',
  }) async {
    _isLoading = true;
    notifyListeners();

    final cleanEmail = email.contains('@')
        ? email.trim()
        : '${phone.trim()}@expert.com';

    try {
      final response = await _apiService.client.post(
        '/auth/register',
        data: {
          'fullName': name.trim(),
          'email': cleanEmail,
          'phoneNumber': phone.trim(),
          'password': password,
          'role': 'ROLE_CUSTOMER',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        _token = data['accessToken']?.toString();
        _user = {
          'id': data['userId']?.toString() ?? '',
          'uid': data['userId']?.toString() ?? '',
          'name': data['fullName'] ?? name,
          'fullName': data['fullName'] ?? name,
          'email': data['email'] ?? cleanEmail,
          'phoneNumber': phone,
          'role': data['role'] ?? 'ROLE_CUSTOMER',
          'preferredLanguage': preferredLanguage,
          'walletBalance':
              double.tryParse(data['walletBalance']?.toString() ?? '0') ?? 0.0,
        };
        _apiService.client.options.headers['Authorization'] = 'Bearer $_token';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_id', _user!['id']);

        _socketService.connect(_user!['id']);

        _isLoading = false;
        notifyListeners();
        return null; // null means success
      }
    } on DioException catch (e) {
      debugPrint('Spring Boot SignUp Dio error: ${e.type} ${e.response?.data}');
      _isLoading = false;
      notifyListeners();
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        return 'Server is waking up. Please wait 30-60 seconds and try again.';
      }
      final data = e.response?.data;
      final errorMsg = (data != null && data is Map && data['message'] != null)
          ? data['message'].toString()
          : '';
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 409 ||
          errorMsg.toLowerCase().contains('already') ||
          errorMsg.toLowerCase().contains('in use') ||
          errorMsg.toLowerCase().contains('exists')) {
        // Existing user: seamlessly log them in with the provided credentials
        final loginSuccess = await login(cleanEmail, password);
        if (loginSuccess) {
          return null; // Seamless login success!
        } else {
          return 'This mobile number is already registered. Please enter the correct password.';
        }
      }
      if (errorMsg.isNotEmpty) {
        return errorMsg;
      }
      return 'Registration failed (${e.response?.statusCode ?? 'Network error'}). Please try again.';
    } catch (e) {
      debugPrint('Spring Boot SignUp error: $e');
      _isLoading = false;
      notifyListeners();
      return 'Registration failed: $e';
    }

    _isLoading = false;
    notifyListeners();
    return 'An unknown error occurred';
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    _apiService.client.options.headers.remove('Authorization');
    _socketService.disconnect();
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      final updatedUser = await _apiService.getProfile();
      if (updatedUser != null) {
        _user = {
          ...?_user,
          ...updatedUser,
          'name': updatedUser['fullName'] ?? _user?['name'],
        };
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh error: $e');
    }
  }

  Future<bool> rechargeWallet(double amount) async {
    _isLoading = true;
    notifyListeners();

    Map<String, dynamic>? response;
    try {
      response = await _apiService.rechargeWallet(amount);
    } catch (_) {}

    if (response != null && response['success'] == true) {
      if (response['newBalance'] != null) {
        _user ??= {};
        _user!['walletBalance'] =
            double.tryParse(response['newBalance'].toString()) ?? 0.0;
      }
      await refreshProfile();
    } else {
      _user ??= {};
      final String uid = _user!['id'] ?? _user!['uid'] ?? 'cust_1';
      final currentBalance =
          double.tryParse(_user!['walletBalance']?.toString() ?? '0') ?? 0.0;
      final newBalance = currentBalance + amount;
      _user!['walletBalance'] = newBalance;
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> verifyAndRechargeWallet({
    required String orderId,
    required String paymentId,
    required String signature,
    required double amount,
  }) async {
    _isLoading = true;
    notifyListeners();
    var response = await _apiService.verifyRazorpayPayment(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
      amount: amount,
    );
    if (response == null) {
      return await rechargeWallet(amount);
    }
    _isLoading = false;
    _user = response;
    notifyListeners();
    return true;
  }

  Future<void> updateVipStatus(bool isVip) async {
    _user ??= {};
    _user!['isVip'] = isVip;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_vip', isVip);
    } catch (e) {
      debugPrint('Error updating VIP status: $e');
    }
  }

  List<String> get preferredLanguages {
    if (_user != null && _user!['preferredLanguages'] != null) {
      final langs = _user!['preferredLanguages'];
      if (langs is List) {
        return List<String>.from(langs.map((l) => l.toString()));
      }
    }
    return ['Tamil', 'English'];
  }

  Future<void> updatePreferredLanguages(List<String> languages) async {
    _user ??= {};
    _user!['preferredLanguages'] = languages;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('preferred_languages', languages);
    } catch (e) {
      debugPrint('Error updating preferred languages: $e');
    }
  }
}
