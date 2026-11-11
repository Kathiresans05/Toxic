import 'package:expert_customer/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>?> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.client.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    return await _apiService.getProfile();
  }
}
