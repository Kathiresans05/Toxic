import 'package:flutter/foundation.dart';

class AppConstants {
  // Your computer's current Wi-Fi IP address
  static const String localIp = '192.168.100.106';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }

    // Connects to your computer's Spring Boot backend on port 8080
    return 'http://$localIp:8080/api/v1';
  }

  static const String razorpayKeyId = 'rzp_test_TMsSHx6MC6SMoJ';
}
