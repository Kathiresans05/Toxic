import 'package:flutter_test/flutter_test.dart';
import 'package:expert_customer/services/api_service.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    test('ApiService singleton instance returns same instance', () {
      final instance1 = ApiService();
      final instance2 = ApiService();
      expect(instance1, same(instance2));
    });

    test('ApiService has valid Dio client configured', () {
      expect(apiService.client, isNotNull);
      expect(apiService.client.options.connectTimeout, const Duration(seconds: 10));
      expect(apiService.client.options.headers['Content-Type'], 'application/json');
    });

    test('sendOtp returns false gracefully on network failure without throwing unhandled exception', () async {
      final result = await apiService.sendOtp('9999999999');
      // When backend is offline, error is caught and returns false
      expect(result, isFalse);
    });

    test('verifyOtp returns null gracefully on network failure without throwing unhandled exception', () async {
      final result = await apiService.verifyOtp('9999999999', '1234');
      // When backend is offline, error is caught and returns null
      expect(result, isNull);
    });

    test('getOnlineExperts returns empty list gracefully on network failure', () async {
      final result = await apiService.getOnlineExperts();
      expect(result, isEmpty);
    });

    test('reportCall returns false gracefully on offline backend without crashing', () async {
      final result = await apiService.reportCall(
        callId: 'test_call_123',
        reason: 'Abusive language',
        details: 'Testing safety reporting',
        targetType: 'CREATOR',
      );
      expect(result, isFalse);
    });
  });
}

