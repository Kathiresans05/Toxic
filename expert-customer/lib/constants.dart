class AppConstants {
  // Live Cloud Production URL (Render HTTPS)
  static const String liveCloudUrl = 'https://toxic-g6q7.onrender.com/api/v1';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    return liveCloudUrl;
  }

  static const String razorpayKeyId = 'rzp_test_TMsSHx6MC6SMoJ';
}
