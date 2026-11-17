import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expert_customer/providers/auth_provider.dart';
import 'package:expert_customer/services/api_service.dart';
import 'package:expert_customer/screens/easy_auth_screen.dart';
import 'package:expert_customer/screens/main_layout_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  Timer? _coldStartTimer;
  int _elapsedSeconds = 0;

  // Color Palette inspired by the reference UI
  static const Color _bgCream = Color(0xFFFBF5ED);
  static const Color _brandGreen = Color(0xFF0F4D3C);
  static const Color _accentGold = Color(0xFFE5A93B);
  static const Color _darkTeal = Color(0xFF133E35);
  static const Color _textMuted = Color(0xFF6B6560);
  static const Color _borderColor = Color(0xFFE8DFD5);

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _prewarmBackend();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIdentifier = prefs.getString('saved_login_identifier');
      final savedRemember = prefs.getBool('remember_me_preference') ?? true;
      if (mounted) {
        setState(() {
          _rememberMe = savedRemember;
          if (savedIdentifier != null && savedIdentifier.isNotEmpty) {
            _identifierController.text = savedIdentifier;
          }
        });
      }
    } catch (_) {}
  }

  void _prewarmBackend() async {
    try {
      await ApiService().client.get('/categories');
    } catch (_) {}
  }

  @override
  void dispose() {
    _coldStartTimer?.cancel();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter Mobile Number/Email and Password'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Persist or clear remember me preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me_preference', _rememberMe);
      if (_rememberMe) {
        await prefs.setString('saved_login_identifier', identifier);
      } else {
        await prefs.remove('saved_login_identifier');
      }
    } catch (_) {}

    setState(() {
      _isLoading = true;
      _elapsedSeconds = 0;
    });

    _coldStartTimer?.cancel();
    _coldStartTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });

    final success = await Provider.of<AuthProvider>(context, listen: false)
        .login(identifier, password);

    _coldStartTimer?.cancel();

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Invalid credentials. Check mobile/email or try password: password123',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _darkTeal,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your registered mobile number or email. You can also sign up quickly if you are new.',
                style: TextStyle(fontSize: 14, color: _textMuted, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const EasyAuthScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Quick Register with OTP / Mobile ➔',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: _bgCream,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset + 20 : 0),
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Top Navigation / Back button if navigated from splash
                      if (Navigator.canPop(context))
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, top: 8),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: _darkTeal,
                                size: 20,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 12),

                      // Brand Logo Header
                      _buildHeaderLogo(),

                      const SizedBox(height: 12),

                      // Scenic Wave Hero Banner with Consultation & Skyline art
                      _buildScenicHeroBanner(),

                      // Form Body
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Welcome Back Heading
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: _darkTeal,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in to your ConnectaX account',
                              style: TextStyle(
                                fontSize: 14,
                                color: _textMuted,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // Mobile / Email Field (White Rounded Pill)
                            _buildPillInputField(
                              controller: _identifierController,
                              hintText: 'Mobile Number or Email',
                              icon: Icons.mail_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 16),

                            // Password Field (White Rounded Pill)
                            _buildPillInputField(
                              controller: _passwordController,
                              hintText: 'Password',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: _brandGreen.withValues(alpha: 0.8),
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Remember Me & Forgot Password Row
                            _buildOptionsRow(),

                            const SizedBox(height: 22),

                            // Sign In Button (Deep Emerald Green Pill)
                            _buildSignInButton(),

                            // Server wakeup status (Render cold start notice)
                            if (_isLoading && _elapsedSeconds >= 2) ...[
                              const SizedBox(height: 12),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _accentGold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Connecting to server... (${_elapsedSeconds}s)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _textMuted,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Register Redirection Row
                            _buildRegisterRow(),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Decorative Wave Footer
                      _buildBottomWaveFooter(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Top Brand Logo & Tagline (Matches the FIC Business Hub style)
  Widget _buildHeaderLogo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stylized Logo Monogram
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _brandGreen,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _brandGreen.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'C',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    'X',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: _accentGold,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'CONNECTAX',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _brandGreen,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  'EXPERT & CONSULTANT HUB',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: _darkTeal,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Connect • Discover • Grow Tagline
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Connect',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _darkTeal,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Text('•', style: TextStyle(color: _accentGold, fontSize: 14)),
            ),
            Text(
              'Discover',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _darkTeal,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 7),
              child: Text('•', style: TextStyle(color: _accentGold, fontSize: 14)),
            ),
            Text(
              'Grow',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _darkTeal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Scenic Hero Banner with Golden Sunset Skyline & Double Wave Ribbons
  Widget _buildScenicHeroBanner() {
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Stack(
        children: [
          // Sunset Landscape Art with Custom Curved Clipper
          Positioned.fill(
            child: ClipPath(
              clipper: _TopWaveClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFFAF2),
                      Color(0xFFFFE0B2),
                      Color(0xFFFFB74D),
                      Color(0xFFF57C00),
                    ],
                  ),
                ),
                child: CustomPaint(
                  painter: _SkylineSilhouettesPainter(),
                ),
              ),
            ),
          ),

          // Lower Wave Ribbon (Gold & Deep Emerald Green)
          Positioned.fill(
            child: CustomPaint(
              painter: _WaveRibbonPainter(),
            ),
          ),
        ],
      ),
    );
  }

  /// White Rounded Pill Input Field with Icon, Divider & Placeholder
  Widget _buildPillInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Icon(icon, color: _brandGreen, size: 22),
          const SizedBox(width: 12),
          // Subtle vertical divider line
          Container(
            width: 1.2,
            height: 22,
            color: Colors.grey.shade300,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(
                color: Color(0xFF1B2E2B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (suffixIcon != null) ...[
            suffixIcon,
            const SizedBox(width: 6),
          ] else
            const SizedBox(width: 16),
        ],
      ),
    );
  }

  /// Remember Me Checkbox and Forgot Password Row
  Widget _buildOptionsRow() {
    return Row(
      children: [
        // Custom Styled Checkbox
        InkWell(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _rememberMe ? _brandGreen : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _rememberMe ? _brandGreen : Colors.grey.shade400,
                      width: 1.6,
                    ),
                  ),
                  child: _rememberMe
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 9),
                const Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E3A),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Forgot Password link
        GestureDetector(
          onTap: _showForgotPasswordDialog,
          child: const Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: _brandGreen,
            ),
          ),
        ),
      ],
    );
  }

  /// Main Sign In Button (Pill shaped, Deep Emerald Green)
  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: _brandGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _brandGreen.withValues(alpha: 0.6),
          elevation: 4,
          shadowColor: _brandGreen.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '→',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Register Now Redirection Row
  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'New to ConnectaX? ',
          style: TextStyle(
            fontSize: 14,
            color: _textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const EasyAuthScreen()),
            );
          },
          child: const Text(
            'Register Now',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFC77717),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  /// Elegant Bottom Wave to frame the bottom of the screen
  Widget _buildBottomWaveFooter() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: CustomPaint(
        painter: _BottomWavePainter(),
      ),
    );
  }
}

// -------------------------------------------------------------
// CUSTOM CLIPPERS & PAINTERS FOR ARTISTIC WAVES & SKYLINE
// -------------------------------------------------------------

/// Wave shape clipper for the upper banner
class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 35);

    // Flowing smooth wave: curves downwards in the left-center, then swoops gracefully
    final firstControl = Offset(size.width * 0.32, size.height + 15);
    final firstEnd = Offset(size.width * 0.65, size.height - 25);
    path.quadraticBezierTo(firstControl.dx, firstControl.dy, firstEnd.dx, firstEnd.dy);

    final secondControl = Offset(size.width * 0.88, size.height - 50);
    final secondEnd = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(secondControl.dx, secondControl.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Paints skyline silhouettes, glowing sunrise, and professional figures
class _SkylineSilhouettesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Glowing Sunset Disc
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          const Color(0xFFFFD54F).withValues(alpha: 0.6),
          const Color(0xFFFFB300).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.52, size.height * 0.42),
        radius: 65,
      ));
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.42), 65, sunPaint);

    // 2. City High-Rise Silhouettes
    final buildingPaint = Paint()
      ..color = const Color(0xFF0F4D3C).withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    // Distant high rises
    canvas.drawRect(Rect.fromLTWH(size.width * 0.05, size.height * 0.35, 26, size.height * 0.65), buildingPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.13, size.height * 0.28, 22, size.height * 0.72), buildingPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.22, size.height * 0.40, 30, size.height * 0.60), buildingPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.72, size.height * 0.30, 24, size.height * 0.70), buildingPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.80, size.height * 0.22, 28, size.height * 0.78), buildingPaint);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.89, size.height * 0.38, 24, size.height * 0.62), buildingPaint);

    // 3. Terrace railing line
    final terracePaint = Paint()
      ..color = const Color(0xFF0F4D3C).withValues(alpha: 0.45)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.82),
      Offset(size.width * 0.85, size.height * 0.82),
      terracePaint,
    );

    // 4. Silhouettes of people / consultants standing together
    final peoplePaint = Paint()
      ..color = const Color(0xFF0D3D30).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    void drawPerson(double centerX, double groundY, double scale) {
      // Head
      canvas.drawCircle(Offset(centerX, groundY - 26 * scale), 4.2 * scale, peoplePaint);
      // Body / Suit
      final bodyPath = Path();
      bodyPath.moveTo(centerX - 4.5 * scale, groundY - 20 * scale);
      bodyPath.lineTo(centerX + 4.5 * scale, groundY - 20 * scale);
      bodyPath.lineTo(centerX + 6.0 * scale, groundY);
      bodyPath.lineTo(centerX - 6.0 * scale, groundY);
      bodyPath.close();
      canvas.drawPath(bodyPath, peoplePaint);
    }

    final ground = size.height * 0.82;
    drawPerson(size.width * 0.38, ground, 1.0);
    drawPerson(size.width * 0.46, ground, 1.08);
    drawPerson(size.width * 0.54, ground, 1.05);
    drawPerson(size.width * 0.62, ground, 0.98);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints the layered Gold & Emerald wave ribbons framing the banner
class _WaveRibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Warm Gold ribbon
    final goldPaint = Paint()
      ..color = const Color(0xFFE5A93B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final goldPath = Path();
    goldPath.moveTo(0, size.height - 30);
    goldPath.quadraticBezierTo(
      size.width * 0.32,
      size.height + 20,
      size.width * 0.65,
      size.height - 20,
    );
    goldPath.quadraticBezierTo(
      size.width * 0.88,
      size.height - 45,
      size.width,
      size.height - 15,
    );
    canvas.drawPath(goldPath, goldPaint);

    // 2. Deep Emerald Green ribbon
    final greenPaint = Paint()
      ..color = const Color(0xFF0F4D3C)
      ..style = PaintingStyle.fill;

    final greenPath = Path();
    greenPath.moveTo(0, size.height - 26);
    greenPath.quadraticBezierTo(
      size.width * 0.32,
      size.height + 24,
      size.width * 0.65,
      size.height - 16,
    );
    greenPath.quadraticBezierTo(
      size.width * 0.88,
      size.height - 41,
      size.width,
      size.height - 11,
    );
    greenPath.lineTo(size.width, size.height);
    greenPath.lineTo(0, size.height);
    greenPath.close();

    // Fill only a slender sweep
    final sweepPath = Path();
    sweepPath.moveTo(0, size.height - 24);
    sweepPath.quadraticBezierTo(
      size.width * 0.32,
      size.height + 24,
      size.width * 0.65,
      size.height - 16,
    );
    sweepPath.quadraticBezierTo(
      size.width * 0.88,
      size.height - 41,
      size.width,
      size.height - 11,
    );
    sweepPath.lineTo(size.width, size.height - 3);
    sweepPath.quadraticBezierTo(
      size.width * 0.88,
      size.height - 33,
      size.width * 0.65,
      size.height - 8,
    );
    sweepPath.quadraticBezierTo(
      size.width * 0.32,
      size.height + 32,
      0,
      size.height - 16,
    );
    sweepPath.close();

    canvas.drawPath(sweepPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints the subtle matching waves at the bottom of the screen
class _BottomWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Subtle gold curve
    final goldPaint = Paint()
      ..color = const Color(0xFFE5A93B).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    final goldPath = Path();
    goldPath.moveTo(0, size.height);
    goldPath.lineTo(0, size.height * 0.55);
    goldPath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.20,
      size.width * 0.70,
      size.height * 0.65,
    );
    goldPath.quadraticBezierTo(
      size.width * 0.88,
      size.height * 0.85,
      size.width,
      size.height * 0.40,
    );
    goldPath.lineTo(size.width, size.height);
    goldPath.close();
    canvas.drawPath(goldPath, goldPaint);

    // 2. Emerald wave
    final greenPaint = Paint()
      ..color = const Color(0xFF0F4D3C)
      ..style = PaintingStyle.fill;

    final greenPath = Path();
    greenPath.moveTo(0, size.height);
    greenPath.lineTo(0, size.height * 0.70);
    greenPath.quadraticBezierTo(
      size.width * 0.40,
      size.height * 0.35,
      size.width * 0.75,
      size.height * 0.80,
    );
    greenPath.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.95,
      size.width,
      size.height * 0.55,
    );
    greenPath.lineTo(size.width, size.height);
    greenPath.close();
    canvas.drawPath(greenPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
