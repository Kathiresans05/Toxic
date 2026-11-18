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

  // Exact Color Palette sampled from reference design (Image 2)
  static const Color _bgWarmPeach = Color(0xFFFEE8D1); // Sampled #FEE8D1
  static const Color _brandGreen = Color(0xFF0C4F3E);  // Sampled #0C4F3E
  static const Color _accentGold = Color(0xFFE5A93B);
  static const Color _darkNavyHeading = Color(0xFF0B3543); // Sampled #0B3543
  static const Color _registerGold = Color(0xFFC89153); // Sampled #C89153
  static const Color _textMuted = Color(0xFF5E5750);
  static const Color _borderColor = Color(0xFFF5DFC9);

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
                  color: _brandGreen,
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
      backgroundColor: _bgWarmPeach,
      body: Stack(
        children: [
          // Ambient Warm Golden Corner Swooshes (Top background curves)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 140,
            child: CustomPaint(
              painter: _TopCornerSwooshesPainter(),
            ),
          ),

          SafeArea(
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
                          const SizedBox(height: 6),

                          // Top Navigation Back Button if popped
                          if (Navigator.canPop(context))
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 14),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: _brandGreen,
                                    size: 20,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ),
                            )
                          else
                            const SizedBox(height: 8),

                          // 1. Top Brand Logo & Tagline (Matches the FIC Hub format)
                          _buildBrandHeader(),

                          const SizedBox(height: 12),

                          // 2. Realistic Photo Banner with Sweeping Emerald Wave
                          _buildRealisticPhotoHeroBanner(),

                          // 3. Form Body
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 18),

                                // "Welcome Back" Heading
                                const Text(
                                  'Welcome Back',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: _darkNavyHeading,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Sign in to your ConnectaX account',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: _textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Input 1: Mobile / Email Pill Card
                                _buildPillInputField(
                                  controller: _identifierController,
                                  hintText: 'Mobile Number or Email',
                                  icon: Icons.mail_outline_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                const SizedBox(height: 16),

                                // Input 2: Password Pill Card with Eye toggle
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
                                      color: _brandGreen.withValues(alpha: 0.85),
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

                                // Main "Sign In ➔" Emerald Pill Button
                                _buildSignInButton(),

                                // Server wakeup feedback
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

                                // Register Now Redirection
                                _buildRegisterRow(),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // 4. Bottom Emerald & Gold Curved Footer
                          _buildBottomWaveFooter(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Top Brand Logo & Tagline (Matches the FIC Hub format)
  Widget _buildBrandHeader() {
    return Column(
      children: [
        // Stylized Brand Monogram & Title
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Monogram Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _brandGreen,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: _brandGreen.withValues(alpha: 0.3),
                    blurRadius: 10,
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
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'BUSINESS HUB',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: _brandGreen,
                    letterSpacing: 2.2,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Tagline: Connect • Discover • Grow
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Connect',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _brandGreen,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '•',
                style: TextStyle(color: _accentGold, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Discover',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _brandGreen,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '•',
                style: TextStyle(color: _accentGold, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              'Grow',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: _brandGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Realistic Photo Hero Banner with Sunset Skyline & Sweeping Emerald Wave
  Widget _buildRealisticPhotoHeroBanner() {
    return SizedBox(
      height: 185,
      width: double.infinity,
      child: ClipPath(
        clipper: _BannerBottomWaveClipper(),
        child: Stack(
          children: [
            // 1. Real Photography Image of Girls & Boys Professionals at Sunset
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_hero.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
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
                  );
                },
              ),
            ),

            // 2. Soft sunset atmosphere overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
            ),

            // 3. The Signature Bold Emerald Green & Gold Wave on the Left & Bottom
            Positioned.fill(
              child: CustomPaint(
                painter: _HeroEmeraldWavePainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// White Pill Input Field with Icon, Divider & Placeholder
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
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: _borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E431E).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 18),
          Icon(icon, color: _brandGreen, size: 22),
          const SizedBox(width: 12),
          // Vertical divider line
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
            borderRadius: BorderRadius.circular(30),
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
              fontSize: 14.5,
              color: _registerGold,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom Wave to frame the bottom of the screen
  Widget _buildBottomWaveFooter() {
    return SizedBox(
      height: 38,
      width: double.infinity,
      child: CustomPaint(
        painter: _BottomWavePainter(),
      ),
    );
  }
}

// -------------------------------------------------------------
// CUSTOM PAINTERS & CLIPPERS (Exact match to reference design)
// -------------------------------------------------------------

/// Top corner ambient golden swooshes
class _TopCornerSwooshesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final swooshPaint = Paint()
      ..color = const Color(0xFFF7D5B0).withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    // Top Right ambient wave
    final rightPath = Path();
    rightPath.moveTo(size.width * 0.65, 0);
    rightPath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.65,
      size.width,
      size.height * 0.40,
    );
    rightPath.lineTo(size.width, 0);
    rightPath.close();
    canvas.drawPath(rightPath, swooshPaint);

    // Top Left subtle wave
    final leftPath = Path();
    leftPath.moveTo(0, 0);
    leftPath.quadraticBezierTo(
      size.width * 0.20,
      size.height * 0.50,
      0,
      size.height * 0.85,
    );
    leftPath.close();
    canvas.drawPath(leftPath, swooshPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Bottom clipper for the hero banner (gentle, organic wave cut)
class _BannerBottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);

    // Smooth sweeping bottom curve
    final firstControl = Offset(size.width * 0.35, size.height + 12);
    final firstEnd = Offset(size.width * 0.68, size.height - 24);
    path.quadraticBezierTo(firstControl.dx, firstControl.dy, firstEnd.dx, firstEnd.dy);

    final secondControl = Offset(size.width * 0.88, size.height - 46);
    final secondEnd = Offset(size.width, size.height - 18);
    path.quadraticBezierTo(secondControl.dx, secondControl.dy, secondEnd.dx, secondEnd.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Sweeping Bold Emerald Green Wave & Golden Ribbon on the Hero Banner (Image 2 match)
class _HeroEmeraldWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Warm Golden Ribbon Accent
    final goldPaint = Paint()
      ..color = const Color(0xFFE5A93B)
      ..style = PaintingStyle.fill;

    final goldPath = Path();
    goldPath.moveTo(0, size.height * 0.44);
    goldPath.quadraticBezierTo(
      size.width * 0.12,
      size.height * 0.68,
      size.width * 0.38,
      size.height * 0.82,
    );
    goldPath.quadraticBezierTo(
      size.width * 0.68,
      size.height * 0.94,
      size.width,
      size.height * 0.72,
    );
    goldPath.lineTo(size.width, size.height * 0.78);
    goldPath.quadraticBezierTo(
      size.width * 0.68,
      size.height * 1.0,
      size.width * 0.38,
      size.height * 0.88,
    );
    goldPath.quadraticBezierTo(
      size.width * 0.12,
      size.height * 0.74,
      0,
      size.height * 0.52,
    );
    goldPath.close();
    canvas.drawPath(goldPath, goldPaint);

    // 2. Bold Solid Emerald Green Wave covering the left-bottom quarter
    final greenPaint = Paint()
      ..color = const Color(0xFF0F4D3C)
      ..style = PaintingStyle.fill;

    final greenPath = Path();
    greenPath.moveTo(0, size.height * 0.48);
    greenPath.quadraticBezierTo(
      size.width * 0.12,
      size.height * 0.72,
      size.width * 0.38,
      size.height * 0.86,
    );
    greenPath.quadraticBezierTo(
      size.width * 0.68,
      size.height * 0.98,
      size.width,
      size.height * 0.76,
    );
    greenPath.lineTo(size.width, size.height);
    greenPath.lineTo(0, size.height);
    greenPath.close();
    canvas.drawPath(greenPath, greenPaint);
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
      ..color = const Color(0xFFE5A93B).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final goldPath = Path();
    goldPath.moveTo(0, size.height);
    goldPath.lineTo(0, size.height * 0.52);
    goldPath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.18,
      size.width * 0.70,
      size.height * 0.62,
    );
    goldPath.quadraticBezierTo(
      size.width * 0.88,
      size.height * 0.82,
      size.width,
      size.height * 0.38,
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
    greenPath.lineTo(0, size.height * 0.68);
    greenPath.quadraticBezierTo(
      size.width * 0.40,
      size.height * 0.32,
      size.width * 0.75,
      size.height * 0.78,
    );
    greenPath.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.92,
      size.width,
      size.height * 0.52,
    );
    greenPath.lineTo(size.width, size.height);
    greenPath.close();
    canvas.drawPath(greenPath, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
