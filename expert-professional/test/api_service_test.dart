import 'package:flutter_test/flutter_test.dart';
import 'package:expert_professional/services/api_service.dart';

void main() {
  group('Professional ApiService Tests', () {
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

    test('loginWithEmail returns null gracefully on offline backend', () async {
      final result = await apiService.loginWithEmail('creator@connectax.com', 'password123');
      expect(result, isNull);
    });

    test('toggleExpertStatus returns null gracefully on offline backend', () async {
      final result = await apiService.toggleExpertStatus(true);
      expect(result, isNull);
    });

    test('reportCall returns false gracefully on offline backend without crashing', () async {
      final result = await apiService.reportCall(
        callId: 'test_call_456',
        reason: 'Vulgar / Abusive behavior',
        details: 'Testing creator incident reporting',
        targetType: 'CUSTOMER',
      );
      expect(result, isFalse);
    });
  });
}
