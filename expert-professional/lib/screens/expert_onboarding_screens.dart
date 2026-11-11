import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_professional/providers/auth_provider.dart';
import 'package:expert_professional/services/api_service.dart';
import 'package:expert_professional/screens/expert_dashboard_screen.dart';

// Color Palette Constants
class ExpertColors {
  static const Color background = Color(0xFF08080A);
  static const Color cardBg = Color(0xFF141418);
  static const Color cardSelectedBg = Color(0xFF1C1A14);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color primaryYellowDark = Color(0xFFFFB800);
  static const Color textWhite = Colors.white;
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderColor = Color(0xFF26262B);
}

// Custom Wave Painter for Landing Background
class GoldWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ExpertColors.primaryYellow.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.45);
    path1.cubicTo(
      size.width * 0.3, size.height * 0.35,
      size.width * 0.7, size.height * 0.55,
      size.width, size.height * 0.4,
    );
    canvas.drawPath(path1, paint);

    final paint2 = Paint()
      ..color = ExpertColors.primaryYellow.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.48);
    path2.cubicTo(
      size.width * 0.25, size.height * 0.58,
      size.width * 0.75, size.height * 0.38,
      size.width, size.height * 0.52,
    );
    canvas.drawPath(path2, paint2);

    final paint3 = Paint()
      ..color = ExpertColors.primaryYellow.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path3 = Path();
    path3.moveTo(0, size.height * 0.52);
    path3.cubicTo(
      size.width * 0.4, size.height * 0.62,
      size.width * 0.6, size.height * 0.42,
      size.width, size.height * 0.58,
    );
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// SCREEN 1: Expert Landing Screen
// -----------------------------------------------------------------------------
class ExpertLandingScreen extends StatelessWidget {
  const ExpertLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print(">>> CONNECTAX_DEBUG: ExpertLandingScreen.build() called!");
    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: Stack(
        children: [
          // Background Waves
          Positioned.fill(
            child: CustomPaint(
              painter: GoldWavesPainter(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Header Logo with Sparkle Glow
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ExpertColors.primaryYellow,
                          boxShadow: [
                            BoxShadow(
                              color: ExpertColors.primaryYellow.withValues(alpha: 0.4),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.headset_mic_rounded,
                            size: 65,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.amberAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            size: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Title: ConnectaX
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Connecta',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: ExpertColors.textWhite,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'X',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            color: ExpertColors.primaryYellow,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tagline
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(fontSize: 16, height: 1.5),
                      children: [
                        TextSpan(
                          text: 'Share Your ',
                          style: TextStyle(color: ExpertColors.textWhite),
                        ),
                        TextSpan(
                          text: 'Knowledge',
                          style: TextStyle(
                            color: ExpertColors.primaryYellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '.\nEarn. Inspire. Grow.',
                          style: TextStyle(color: ExpertColors.textWhite),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Overlapping Avatars Row & Join Text
                  Column(
                    children: [
                      SizedBox(
                        height: 44,
                        width: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: List.generate(5, (index) {
                            final avatarColors = [
                              Colors.blueGrey,
                              Colors.amber.shade700,
                              Colors.teal.shade700,
                              Colors.purple.shade700,
                              Colors.deepOrange.shade700,
                            ];
                            final avatarIcons = [
                              Icons.person,
                              Icons.person_3,
                              Icons.person_4,
                              Icons.face,
                              Icons.account_circle,
                            ];
                            return Positioned(
                              left: index * 26.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: ExpertColors.background, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: avatarColors[index],
                                  child: Icon(avatarIcons[index], size: 20, color: Colors.white),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Join 10K+ Expert',
                        style: TextStyle(
                          color: ExpertColors.primaryYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Primary Button: Get Started
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TellUsAboutYouScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ExpertColors.primaryYellow,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Footer: Already an Expert? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already an Expert? ',
                        style: TextStyle(color: ExpertColors.textMuted, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ExpertLoginScreen()),
                          );
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: ExpertColors.primaryYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 2: Why Become an Expert Screen
// -----------------------------------------------------------------------------
class WhyBecomeExpertScreen extends StatelessWidget {
  const WhyBecomeExpertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Bar with Skip
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                      );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: ExpertColors.textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Why Become\nan ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ExpertColors.textWhite,
                          height: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: 'Expert?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: ExpertColors.primaryYellow,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Helping others, made\nsimple and rewarding.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ExpertColors.textMuted,
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 24),

                // Hero Graphic: Center Avatar with surrounding glowing floating badges
                SizedBox(
                  height: 180,
                  width: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Ring
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: ExpertColors.primaryYellow.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                      ),

                      // Central Avatar Image Graphic
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber.shade900.withValues(alpha: 0.3),
                          border: Border.all(
                            color: ExpertColors.primaryYellow,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ExpertColors.primaryYellow.withValues(alpha: 0.3),
                              blurRadius: 25,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_pin_rounded,
                            size: 70,
                            color: ExpertColors.primaryYellow,
                          ),
                        ),
                      ),

                      // Top Left Floating Badge
                      Positioned(
                        left: 15,
                        top: 20,
                        child: _buildBadgeIcon(Icons.groups_rounded),
                      ),
                      // Top Right Floating Badge
                      Positioned(
                        right: 15,
                        top: 20,
                        child: _buildBadgeText('₹'),
                      ),
                      // Bottom Left Floating Badge
                      Positioned(
                        left: 15,
                        bottom: 20,
                        child: _buildBadgeIcon(Icons.shield_outlined),
                      ),
                      // Bottom Right Floating Badge
                      Positioned(
                        right: 15,
                        bottom: 20,
                        child: _buildBadgeIcon(Icons.military_tech_outlined),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Feature List Items (simple Column instead of Expanded ListView)
                const Column(
                  children: [
                    _FeatureTile(
                      icon: Icons.person_search_rounded,
                      title: 'Flexible Earning',
                      subtitle: 'Earn on your own time',
                    ),
                    SizedBox(height: 14),
                    _FeatureTile(
                      icon: Icons.record_voice_over_rounded,
                      title: 'Share Your Expertise',
                      subtitle: 'Help people and build trust',
                    ),
                    SizedBox(height: 14),
                    _FeatureTile(
                      icon: Icons.trending_up_rounded,
                      title: 'Grow Your Brand',
                      subtitle: 'Get verified and reach more',
                    ),
                    SizedBox(height: 14),
                    _FeatureTile(
                      icon: Icons.verified_user_rounded,
                      title: 'Secure & Reliable',
                      subtitle: '100% secure payments',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Page Indicators (3 dots)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 8,
                      decoration: BoxDecoration(
                        color: ExpertColors.primaryYellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: ExpertColors.primaryYellow.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: ExpertColors.primaryYellow.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Primary Button: Next
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TellUsAboutYouScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ExpertColors.primaryYellow,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        shape: BoxShape.circle,
        border: Border.all(color: ExpertColors.primaryYellow.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(icon, color: ExpertColors.primaryYellow, size: 20),
    );
  }

  Widget _buildBadgeText(String text) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        shape: BoxShape.circle,
        border: Border.all(color: ExpertColors.primaryYellow.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: ExpertColors.primaryYellow,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            color: ExpertColors.primaryYellow,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ExpertColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: ExpertColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 3: Choose Your Expert Role Screen
// -----------------------------------------------------------------------------
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Relationship Expert',
      'subtitle': 'Help in love, marriage &\nrelationships',
      'icon': Icons.favorite_rounded,
    },
    {
      'title': 'Career Expert',
      'subtitle': 'Guide in career, jobs &\ngrowth',
      'icon': Icons.work_rounded,
    },
    {
      'title': 'Life Coach',
      'subtitle': 'Motivate and guide for\nbetter life',
      'icon': Icons.lightbulb_rounded,
    },
    {
      'title': 'Other Expert',
      'subtitle': 'Other categories',
      'icon': Icons.grid_view_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back Arrow
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),

              // Heading
              Center(
                child: Column(
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Choose Your\n',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: ExpertColors.textWhite,
                              height: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: 'Expert Role',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: ExpertColors.primaryYellow,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select the role that best\ndescribes you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ExpertColors.textMuted,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Role Cards List
              Expanded(
                child: ListView.separated(
                  itemCount: _roles.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedIndex == index;
                    final role = _roles[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: isSelected ? ExpertColors.cardSelectedBg : ExpertColors.cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? ExpertColors.primaryYellow
                                : ExpertColors.borderColor,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: ExpertColors.primaryYellow.withValues(alpha: 0.15),
                                    blurRadius: 15,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            // Left Icon Badge
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? ExpertColors.primaryYellow
                                    : ExpertColors.borderColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                role['icon'] as IconData,
                                color: isSelected ? Colors.black : ExpertColors.primaryYellow,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Role Titles
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    role['title'] as String,
                                    style: const TextStyle(
                                      color: ExpertColors.textWhite,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    role['subtitle'] as String,
                                    style: const TextStyle(
                                      color: ExpertColors.textMuted,
                                      fontSize: 13,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Selected Checkmark Badge
                            if (isSelected)
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: ExpertColors.primaryYellow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Primary Button: Next
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TellUsAboutYouScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ExpertColors.primaryYellow,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 4: Expert Login Screen (Welcome Back)
// -----------------------------------------------------------------------------
class ExpertLoginScreen extends StatefulWidget {
  const ExpertLoginScreen({super.key});

  @override
  State<ExpertLoginScreen> createState() => _ExpertLoginScreenState();
}

class _ExpertLoginScreenState extends State<ExpertLoginScreen> {
  final TextEditingController _loginPhoneController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _loginPhoneController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final phone = _loginPhoneController.text.trim().replaceAll(' ', '');
    final password = _loginPasswordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Mobile Number and Password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(phone, password);
    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ExpertDashboardScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Mobile Number or Password. Please check your credentials.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _quickEnter() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ExpertDashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Back, Logo Badge, and Quick Enter Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: ExpertColors.primaryYellow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.headset_mic_rounded, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Expert Console',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _quickEnter,
                    icon: const Icon(Icons.bolt, color: ExpertColors.primaryYellow, size: 18),
                    label: const Text(
                      'Quick Enter 🚀',
                      style: TextStyle(
                        color: ExpertColors.primaryYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Title Header
              const Text(
                'Welcome Back! 👋',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: ExpertColors.textWhite,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Login with your mobile number to manage live calls',
                style: TextStyle(
                  color: ExpertColors.textMuted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 36),

              // Mobile Number Input
              _buildInputField(
                label: 'Mobile Number',
                controller: _loginPhoneController,
                hint: 'e.g. 6789067890',
                icon: Icons.phone_android_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),

              // Password Input
              _buildInputField(
                label: 'Password',
                controller: _loginPasswordController,
                hint: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                isObscured: _loginObscurePassword,
                onToggleVisibility: () {
                  setState(() => _loginObscurePassword = !_loginObscurePassword);
                },
              ),
              const SizedBox(height: 32),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ExpertColors.primaryYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Login & Enter Console ➔',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Direct Access link
              Center(
                child: TextButton(
                  onPressed: _quickEnter,
                  child: const Text(
                    '⚡ Direct Access as Verified Expert',
                    style: TextStyle(color: ExpertColors.primaryYellow, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Footer: New Expert? Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'New Expert? ',
                    style: TextStyle(color: ExpertColors.textMuted, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TellUsAboutYouScreen()),
                      );
                    },
                    child: const Text(
                      'Onboard / Register',
                      style: TextStyle(
                        color: ExpertColors.primaryYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: ExpertColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ExpertColors.borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: ExpertColors.primaryYellow, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: isPassword && isObscured,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: ExpertColors.textMuted, fontSize: 15),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (isPassword)
                IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey,
                    size: 22,
                  ),
                  onPressed: onToggleVisibility,
                ),
            ],
          ),
        ),
      ],
    );
  }
}



// -----------------------------------------------------------------------------
// SCREEN 5: Create Your Account Screen
// -----------------------------------------------------------------------------
class CreateYourAccountScreen extends StatefulWidget {
  const CreateYourAccountScreen({super.key});

  @override
  State<CreateYourAccountScreen> createState() => _CreateYourAccountScreenState();
}

class _CreateYourAccountScreenState extends State<CreateYourAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistering = false;

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().replaceAll(' ', '');
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUp(email, password, name, phone);

    if (success) {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TellUsAboutYouScreen()),
        );
      }
    } else {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sign up. Email might already be in use.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),

              // Title
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Let\'s get you started',
                      style: TextStyle(
                        color: ExpertColors.textMuted,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Full Name
              _buildFieldLabel('Full Name'),
              _buildInputContainer(
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: ExpertColors.textMuted, fontSize: 15),
                    prefixIcon: Icon(Icons.person_outline_rounded, color: Colors.white60),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Mobile Number
              _buildFieldLabel('Mobile Number'),
              _buildInputContainer(
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.phone_outlined, color: Colors.white60),
                    const SizedBox(width: 12),
                    const Text(
                      '+91',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(height: 20, width: 1, color: Colors.white24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Enter mobile number',
                          hintStyle: TextStyle(color: ExpertColors.textMuted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Email (Optional)
              _buildFieldLabel('Email (Optional)'),
              _buildInputContainer(
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter your email address',
                    hintStyle: TextStyle(color: ExpertColors.textMuted, fontSize: 15),
                    prefixIcon: Icon(Icons.mail_outline_rounded, color: Colors.white60),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Create Password
              _buildFieldLabel('Create Password'),
              _buildInputContainer(
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Create a password',
                    hintStyle: const TextStyle(color: ExpertColors.textMuted, fontSize: 15),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white60),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white60,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Confirm Password
              _buildFieldLabel('Confirm Password'),
              _buildInputContainer(
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Confirm your password',
                    hintStyle: const TextStyle(color: ExpertColors.textMuted, fontSize: 15),
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.white60),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white60,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isRegistering ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ExpertColors.primaryYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isRegistering
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Register',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Footer: Already have an account? Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: ExpertColors.textMuted, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ExpertLoginScreen()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: ExpertColors.primaryYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ExpertColors.borderColor),
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 6: Tell Us About You Screen
// -----------------------------------------------------------------------------
class TellUsAboutYouScreen extends StatefulWidget {
  const TellUsAboutYouScreen({super.key});

  @override
  State<TellUsAboutYouScreen> createState() => _TellUsAboutYouScreenState();
}

class _TellUsAboutYouScreenState extends State<TellUsAboutYouScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _audioRateController = TextEditingController(text: '5');
  final TextEditingController _videoRateController = TextEditingController(text: '10');

  bool _obscurePassword = true;

  final Set<String> _selectedExpertise = {};
  final Set<String> _selectedLanguages = {'Tamil', 'English'};
  final String _selectedExperience = '3-5 Years';
  bool _isLoading = false;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user ?? {};
      if (user['name'] != null && user['name'].toString().trim().isNotEmpty && user['name'] != 'Expert Consultant') {
        _nameController.text = user['name'].toString();
      }
      if (user['phone'] != null && user['phone'].toString().trim().isNotEmpty && user['phone'] != '9876543210') {
        _phoneController.text = user['phone'].toString();
      } else if (user['mobileNumber'] != null && user['mobileNumber'].toString().trim().isNotEmpty) {
        _phoneController.text = user['mobileNumber'].toString();
      }
      if (user['bio'] != null && user['bio'].toString().trim().isNotEmpty) {
        _bioController.text = user['bio'].toString();
      }
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _audioRateController.dispose();
    _videoRateController.dispose();
    super.dispose();
  }

  final List<String> _categories = [
    'Breakup & Heartbreak',
    'Vent Out & Confessions',
    'Friendly Listener',
    'Loneliness & Stress',
    'Love & Relationship',
    'Late Night Talks',
    'Career & Student Stress',
    'Life Motivation',
  ];

  final List<String> _languages = [
    'Tamil',
    'English',
    'Hindi',
    'Telugu',
    'Malayalam',
    'Kannada',
  ];

  Future<void> _submitExpressRegistration() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final bio = _bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty || cleanPhone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }
    final enteredPassword = _passwordController.text.trim();
    if (enteredPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a password for your account')),
      );
      return;
    }
    if (enteredPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }
    if (_selectedExpertise.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category of expertise')),
      );
      return;
    }
    if (_selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one language')),
      );
      return;
    }
    final effectiveBio = bio.isEmpty ? 'Friendly listener & companion' : bio;

    setState(() {
      _isLoading = true;
    });

    try {
      final audioRate = double.tryParse(_audioRateController.text.trim()) ?? 5.0;
      final videoRate = double.tryParse(_videoRateController.text.trim()) ?? 10.0;
      final years = int.tryParse(_selectedExperience.split('-').first.replaceAll('+', '')) ?? 5;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // 1. Live Spring Boot Registration for Creator with user-entered password
      final cleanEmail = '$cleanPhone@connectax.expert';
      final effectivePassword = enteredPassword;

      bool ok = await authProvider.signUp(
        cleanEmail,
        effectivePassword,
        name,
        cleanPhone,
      );

      // If account already exists with this phone/email, log in
      if (!ok) {
        ok = await authProvider.login(cleanPhone, effectivePassword);
      }

      // 2. Update Creator Profile in PostgreSQL (bio, rates, experience)
      try {
        final apiService = ApiService();
        await apiService.updateExpertProfile(
          bio: effectiveBio,
          experienceYears: years,
          languages: _selectedLanguages.toList(),
          audioRate: audioRate,
          videoRate: videoRate,
        );
      } catch (e) {
        debugPrint('Backend API update error: $e');
      }

      // 3. Refresh profile so dashboard immediately displays real Creator name
      await authProvider.refreshProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration complete! Welcome $name.')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ExpertDashboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 48.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ExpertColors.primaryYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ExpertColors.primaryYellow, width: 0.8),
                    ),
                    child: const Text(
                      'Express Registration ⚡',
                      style: TextStyle(color: ExpertColors.primaryYellow, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Heading
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Complete Expert\n',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Profile Setup ✨',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: ExpertColors.primaryYellow,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Fill all details on this single page & get instant access to dashboard.',
                style: TextStyle(color: ExpertColors.textMuted, fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Personal Info: Full Name & Phone Number
              const Text(
                '1. Personal Details',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: ExpertColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ExpertColors.borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: ExpertColors.textMuted, fontSize: 13),
                    hintText: 'Enter your full name',
                    hintStyle: TextStyle(color: ExpertColors.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.person_outline, color: ExpertColors.primaryYellow, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: ExpertColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ExpertColors.borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: TextStyle(color: ExpertColors.textMuted, fontSize: 13),
                    hintText: 'Enter 10-digit mobile number',
                    hintStyle: TextStyle(color: ExpertColors.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.phone_outlined, color: ExpertColors.primaryYellow, size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: ExpertColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ExpertColors.borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Create Password',
                    labelStyle: const TextStyle(color: ExpertColors.textMuted, fontSize: 13),
                    hintText: 'Minimum 6 characters',
                    hintStyle: const TextStyle(color: ExpertColors.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: ExpertColors.primaryYellow, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: ExpertColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Category Selection
              const Text(
                '2. Select Categories of Expertise',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedExpertise.contains(cat);
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: ExpertColors.primaryYellow,
                    backgroundColor: ExpertColors.cardBg,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? ExpertColors.primaryYellow : ExpertColors.borderColor,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedExpertise.add(cat);
                        } else {
                          _selectedExpertise.remove(cat);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Languages
              const Text(
                '3. Languages Spoken',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _languages.map((lang) {
                  final isSelected = _selectedLanguages.contains(lang);
                  return ChoiceChip(
                    label: Text(lang),
                    selected: isSelected,
                    selectedColor: ExpertColors.primaryYellow,
                    backgroundColor: ExpertColors.cardBg,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? ExpertColors.primaryYellow : ExpertColors.borderColor,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedLanguages.add(lang);
                        } else if (_selectedLanguages.length > 1) {
                          _selectedLanguages.remove(lang);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // About Yourself & Profile Summary
              const Text(
                '4. About Yourself & Profile Summary',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: ExpertColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ExpertColors.borderColor),
                ),
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _bioController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Write a brief summary about yourself and how you assist clients...',
                    hintStyle: TextStyle(color: ExpertColors.textMuted, fontSize: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Single 1-Tap Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitExpressRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ExpertColors.primaryYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                'Complete Registration & Enter Console',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 7: Documents Verification Screen
// -----------------------------------------------------------------------------
class DocumentsVerificationScreen extends StatefulWidget {
  const DocumentsVerificationScreen({super.key});

  @override
  State<DocumentsVerificationScreen> createState() => _DocumentsVerificationScreenState();
}

class _DocumentsVerificationScreenState extends State<DocumentsVerificationScreen> {
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _panController = TextEditingController();

  bool _aadhaarUploaded = false;
  bool _panUploaded = false;
  bool _selfieUploaded = false;

  bool _isUploadingAadhaar = false;
  bool _isUploadingPan = false;
  bool _isUploadingSelfie = false;
  bool _isSubmitting = false;

  void _simulateUpload(String type) {
    setState(() {
      if (type == 'Aadhaar') _isUploadingAadhaar = true;
      if (type == 'PAN') _isUploadingPan = true;
      if (type == 'Selfie') _isUploadingSelfie = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (type == 'Aadhaar') {
          _isUploadingAadhaar = false;
          _aadhaarUploaded = true;
        }
        if (type == 'PAN') {
          _isUploadingPan = false;
          _panUploaded = true;
        }
        if (type == 'Selfie') {
          _isUploadingSelfie = false;
          _selfieUploaded = true;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$type uploaded successfully!')),
      );
    });
  }

  void _submit() async {
    final aadhaar = _aadhaarController.text.trim();
    final pan = _panController.text.trim().toUpperCase();

    if (aadhaar.isEmpty || aadhaar.length != 12 || int.tryParse(aadhaar) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 12-digit Aadhaar Card number')),
      );
      return;
    }

    if (pan.isEmpty || pan.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-character PAN Card number')),
      );
      return;
    }

    if (!_aadhaarUploaded || !_panUploaded || !_selfieUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload all required documents and selfie')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final apiService = ApiService();
    final response = await apiService.updateExpertProfile(
      aadhaarNumber: aadhaar,
      panNumber: pan,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (response != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationSubmittedScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit documents. Please check backend connection.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: _isSubmitting
            ? const Center(child: CircularProgressIndicator(color: ExpertColors.primaryYellow))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),

                    // Heading
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'Documents Verification',
                            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Upload documents to get verified',
                            style: TextStyle(color: ExpertColors.textMuted, fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Aadhaar Number input field
                    _buildFieldLabel('Aadhaar Card Number'),
                    _buildInputContainer(
                      child: TextField(
                        controller: _aadhaarController,
                        keyboardType: TextInputType.number,
                        maxLength: 12,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: 'Enter 12-digit Aadhaar number',
                          hintStyle: TextStyle(color: ExpertColors.textMuted, fontSize: 14),
                          prefixIcon: Icon(Icons.badge_outlined, color: Colors.white60),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // PAN Number input field
                    _buildFieldLabel('PAN Card Number'),
                    _buildInputContainer(
                      child: TextField(
                        controller: _panController,
                        style: const TextStyle(color: Colors.white),
                        maxLength: 10,
                        decoration: const InputDecoration(
                          counterText: '',
                          hintText: 'Enter 10-character PAN number',
                          hintStyle: TextStyle(color: ExpertColors.textMuted, fontSize: 14),
                          prefixIcon: Icon(Icons.credit_card_outlined, color: Colors.white60),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Document Cards
                    _buildUploadRow(
                      icon: Icons.badge_outlined,
                      title: 'Aadhaar Card',
                      subtitle: _aadhaarUploaded ? 'Aadhaar uploaded' : 'Upload front side',
                      isUploaded: _aadhaarUploaded,
                      isUploading: _isUploadingAadhaar,
                      onUpload: () => _simulateUpload('Aadhaar'),
                    ),
                    const SizedBox(height: 16),
                    _buildUploadRow(
                      icon: Icons.credit_card_outlined,
                      title: 'PAN Card',
                      subtitle: _panUploaded ? 'PAN uploaded' : 'Upload PAN card',
                      isUploaded: _panUploaded,
                      isUploading: _isUploadingPan,
                      onUpload: () => _simulateUpload('PAN'),
                    ),
                    const SizedBox(height: 16),
                    _buildUploadRow(
                      icon: Icons.face_retouching_natural_outlined,
                      title: 'Selfie',
                      subtitle: _selfieUploaded ? 'Selfie uploaded' : 'Take a clear selfie',
                      isUploaded: _selfieUploaded,
                      isUploading: _isUploadingSelfie,
                      onUpload: () => _simulateUpload('Selfie'),
                    ),
                    const SizedBox(height: 20),

                    // Security block
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline_rounded, color: Colors.blue.shade400, size: 28),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Your documents are 100% secure and will not be shared.',
                              style: TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ExpertColors.primaryYellow,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInputContainer({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ExpertColors.borderColor),
      ),
      child: child,
    );
  }

  Widget _buildUploadRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isUploaded,
    required bool isUploading,
    required VoidCallback onUpload,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ExpertColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.amber.shade900.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: ExpertColors.primaryYellow, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isUploaded ? Colors.greenAccent : ExpertColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ExpertColors.borderColor,
              shape: BoxShape.circle,
            ),
            child: isUploading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: ExpertColors.primaryYellow, strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      isUploaded ? Icons.check_circle : Icons.file_upload_outlined,
                      color: isUploaded ? Colors.greenAccent : ExpertColors.primaryYellow,
                      size: 22,
                    ),
                    onPressed: isUploaded ? null : onUpload,
                  ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SCREEN 8: Registration Submitted Screen
// -----------------------------------------------------------------------------
class RegistrationSubmittedScreen extends StatelessWidget {
  const RegistrationSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Seal starburst checkmark graphic
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ExpertColors.primaryYellow.withValues(alpha: 0.3),
                          blurRadius: 35,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  // Starburst Badge
                  const Icon(
                    Icons.verified_rounded,
                    size: 130,
                    color: ExpertColors.primaryYellow,
                  ),
                  const Icon(
                    Icons.check,
                    size: 55,
                    color: Colors.black,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                'Registration Submitted!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Your application is under review. We will notify you once your account is approved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ExpertColors.textMuted,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(),

              // Go to Dashboard
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(color: ExpertColors.primaryYellow),
                      ),
                    );

                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    await authProvider.refreshProfile();

                    if (context.mounted) {
                      Navigator.pop(context); // Dismiss loader
                      final user = authProvider.user ?? {};
                      final isApproved = user['isApproved'] == true;

                      if (isApproved) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const ExpertDashboardScreen()),
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Your application is still under review. Please wait for admin approval.'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ExpertColors.primaryYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Go to Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Log Out
              TextButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ExpertLandingScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: ExpertColors.primaryYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
