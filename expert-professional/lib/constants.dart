import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
}

class ExpertColors {
  static const Color background = Color(0xFF08080A);
  static const Color cardBg = Color(0xFF141418);
  static const Color cardSelectedBg = Color(0xFF1C1A14);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color primaryYellowDark = Color(0xFFFFB800);
  static const Color textMuted = Color(0xFF8A8A93);
  static const Color borderColor = Color(0xFF24242A);
}
