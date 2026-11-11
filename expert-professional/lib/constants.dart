import 'package:flutter/material.dart';

class AppConstants {
  // Live Cloud Production URL (Render HTTPS)
  static const String liveCloudUrl = 'https://toxic-g6q7.onrender.com/api/v1';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    return liveCloudUrl;
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
