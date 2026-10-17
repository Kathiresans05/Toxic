import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expert_admin/screens/dashboard_screens.dart';

// Color themes matching the luxury dark/gold ConnectaX Admin panel
class AdminColors {
  static const Color background = Color(0xFF08080A);
  static const Color cardBg = Color(0xFF141418);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color primaryYellowDark = Color(0xFFFFB800);
  static const Color textMuted = Color(0xFF8A8A93);
  static const Color borderColor = Color(0xFF24242A);
}

// -----------------------------------------------------------------------------
// Screen 1: Admin Login Screen (Image 1)
// -----------------------------------------------------------------------------
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'admin@connectax.com');
  final TextEditingController _passwordController = TextEditingController(text: '••••••••••••');
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 10),

              // Logo speech bubble with Headset
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AdminColors.primaryYellow,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.headset_mic_rounded,
                      color: Colors.black,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title "ConnectaX"
              const Text(
                'ConnectaX',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Admin Panel',
                style: TextStyle(
                  color: AdminColors.primaryYellow,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 32),

              // Admin Login Headers
              const Text(
                'Admin Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome back! Please login to continue',
                style: TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              // Email input
              _buildInputLabel('Email Address'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  hintText: 'admin@connectax.com',
                ),
              ),
              const SizedBox(height: 20),

              // Password input
              _buildInputLabel('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration(
                  hintText: 'Enter Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AdminColors.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Remember me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AdminColors.primaryYellow,
                          checkColor: Colors.black,
                          side: const BorderSide(color: AdminColors.textMuted),
                          onChanged: (val) {
                            setState(() {
                              _rememberMe = val ?? true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember me',
                        style: TextStyle(color: AdminColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AdminColors.primaryYellow,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminTwoFactorScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Secure Admin Access tag
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, color: AdminColors.primaryYellow, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Secure Admin Access',
                    style: TextStyle(color: AdminColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: AdminColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: AdminColors.cardBg,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AdminColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AdminColors.primaryYellow),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Screen 2: Admin Two Factor Verification Screen (Image 2)
// -----------------------------------------------------------------------------
class AdminTwoFactorScreen extends StatefulWidget {
  const AdminTwoFactorScreen({super.key});

  @override
  State<AdminTwoFactorScreen> createState() => _AdminTwoFactorScreenState();
}

class _AdminTwoFactorScreenState extends State<AdminTwoFactorScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) {
    final values = ['2', '4', '7', '1', '6', '3'];
    return TextEditingController(text: values[index]);
  });
  int _secondsRemaining = 25;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 10),

              // Title "Two Factor Authentication"
              const Text(
                'Two Factor Authentication',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 36),

              // Glowing Lock Shield
              Center(
                child: Container(
                  width: 110,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(
                        color: AdminColors.primaryYellow.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: CustomPaint(
                    painter: ShieldLockPainter(),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Headers
              const Text(
                'Enter 6 digit code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We have sent a 6 digit OTP to',
                style: TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '+91 98765 43210',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // 6 Digits Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (idx) {
                  return SizedBox(
                    width: 48,
                    height: 52,
                    child: TextField(
                      controller: _controllers[idx],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: AdminColors.cardBg,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AdminColors.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AdminColors.primaryYellow),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Countdown text
              Text(
                'Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),

              // Verify & Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to AdminDashboardScreen inside dashboard_screens.dart
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                      (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Verify & Login',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Shield Lock drawing
class ShieldLockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AdminColors.primaryYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    // Shield outer shape path
    path.moveTo(size.width * 0.5, 0);
    path.quadraticBezierTo(size.width * 0.9, 0, size.width, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.95, size.height * 0.75, size.width * 0.5, size.height);
    path.quadraticBezierTo(size.width * 0.05, size.height * 0.75, 0, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.1, 0, size.width * 0.5, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Draw Lock icon inside the shield shape
    final lockPaint = Paint()
      ..color = AdminColors.primaryYellow
      ..style = PaintingStyle.fill;

    // Lock shackle (arch)
    final shacklePaint = Paint()
      ..color = AdminColors.primaryYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width * 0.5, size.height * 0.52);

    // Shackle arch
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, center.dy - 6), radius: 10),
      3.14,
      3.14,
      false,
      shacklePaint,
    );

    // Lock body box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(center.dx, center.dy + 8), width: 26, height: 20),
        const Radius.circular(4),
      ),
      lockPaint,
    );

    // Lock hole
    final holePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, center.dy + 6), 3, holePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(center.dx, center.dy + 11), width: 2, height: 6), holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
