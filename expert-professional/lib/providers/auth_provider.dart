import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expert_professional/services/api_service.dart';
import 'package:expert_professional/services/socket_service.dart';
import 'dart:async';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();
  
  Map<String, dynamic>? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;
  bool get isInitialized => _isInitialized;

  AuthProvider() {
    _loadPersistedAuth();
  }

  void _listenToUserDoc() {
    // User profile is synchronized via REST API (refreshProfile) and WebSocket
  }

  Future<void> _loadPersistedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    if (_token == 'mock_expert_uid') {
      _token = null;
      await prefs.remove('auth_token');
    }

    if (_token != null) {
      _apiService.client.options.headers['Authorization'] = 'Bearer $_token';
      try {
        final profile = await _apiService.getExpertProfile();
        if (profile != null) {
          final userId = profile['id']?.toString() ?? (profile['user'] is Map ? profile['user']['id']?.toString() : null) ?? _token!;
          _user = {
            'id': userId,
            'uid': userId,
            'name': (profile['user'] is Map ? profile['user']['fullName'] : null) ?? 'Creator',
            'headline': profile['headline'] ?? 'Consultant',
            'audioRate': profile['audioRatePerMin'] ?? 10.0,
            'videoRate': profile['videoRatePerMin'] ?? 20.0,
            'isApproved': profile['approved'] ?? false,
          };
          _socketService.connect(userId);
        } else {
          await logout();
        }
      } catch (e) {
        debugPrint('Error loading persisted expert profile: $e');
      }
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) => loginWithEmail(identifier, password);

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiService.client.post('/auth/login', data: {
        'email': email.contains('@') ? email.trim() : null,
        'phoneNumber': !email.contains('@') ? email.trim() : null,
        'password': password,
      });
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        _token = data['accessToken']?.toString();
        _user = {
          'id': data['userId']?.toString() ?? '',
          'uid': data['userId']?.toString() ?? '',
          'name': data['fullName'] ?? 'Creator',
          'email': data['email'] ?? '',
          'role': data['role'] ?? 'ROLE_CREATOR',
          'walletBalance': 0.0,
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
      debugPrint('Spring Boot Creator Login error: $e');
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp(String email, String password, String name, String phone) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final cleanEmail = email.contains('@') ? email.trim() : '${phone.trim()}@expert.com';
      final response = await _apiService.client.post('/auth/register', data: {
        'fullName': name.trim(),
        'email': cleanEmail,
        'phoneNumber': phone.trim(),
        'password': password,
        'role': 'ROLE_CREATOR',
      });
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        _token = data['accessToken']?.toString();
        _user = {
          'id': data['userId']?.toString() ?? '',
          'uid': data['userId']?.toString() ?? '',
          'name': data['fullName'] ?? name,
          'email': data['email'] ?? cleanEmail,
          'phone': phone,
          'role': 'ROLE_CREATOR',
          'walletBalance': 0.0,
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
      debugPrint('Spring Boot Creator SignUp error: $e');
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
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

  Future<void> updateRegisteredUser(String uid, Map<String, dynamic> expertData) async {
    _token = uid;
    _user = {...?_user, ...expertData, 'id': uid};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', uid);
    _listenToUserDoc();
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    try {
      if (_token != null) {
        final profile = await _apiService.getExpertProfile();
        if (profile != null) {
          final userId = profile['id']?.toString() ?? (profile['user'] is Map ? profile['user']['id']?.toString() : null) ?? _token!;
          _user = {
            'id': userId,
            'name': profile['user'] is Map ? profile['user']['fullName'] : (profile['name'] ?? 'Creator'),
            'email': profile['user'] is Map ? profile['user']['email'] : (profile['email'] ?? ''),
            'phone': profile['user'] is Map ? profile['user']['phoneNumber'] : (profile['phoneNumber'] ?? ''),
            'walletBalance': profile['walletBalance'] ?? 0.0,
            'audioRate': profile['audioRatePerMin'] ?? 10.0,
            'videoRate': profile['videoRatePerMin'] ?? 20.0,
            'isApproved': profile['approved'] ?? false,
          };
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Refresh error: $e');
    }
  }
}
