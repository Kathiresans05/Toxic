import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/providers/auth_provider.dart';
import 'package:expert_customer/providers/theme_provider.dart';
import 'package:expert_customer/services/api_service.dart';
import 'package:expert_customer/screens/recharge_screen.dart';
import 'package:expert_customer/screens/call_screen.dart';
import 'package:expert_customer/screens/dashboard_screens.dart'; // For SearchExpertsScreen
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _onlineExperts = [];
  bool _isLoadingExperts = true;

  // Signature Luxury Brand Color Palette
  static const Color _bgWarmPeach = Color(0xFFFEE8D1);
  static const Color _brandGreen = Color(0xFF0C4F3E);
  static const Color _accentGold = Color(0xFFE5A93B);
  static const Color _darkNavy = Color(0xFF0B3543);
  static const Color _cardBorder = Color(0xFFF5DFC9);

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchExperts();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) _fetchExperts(isBackground: true);
    });
  }

  StreamSubscription? _expertsSub;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _expertsSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchExperts({bool isBackground = false}) async {
    _expertsSub?.cancel();
    try {
      final list = await _apiService.getOnlineExperts();
      if (mounted) {
        setState(() {
          _onlineExperts = list;
          _isLoadingExperts = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching experts from backend: $e');
      if (mounted && !isBackground) {
        setState(() {
          _isLoadingExperts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user ?? {};
    final name = user['name'] ?? 'User';
    final balance =
        double.tryParse(user['walletBalance']?.toString() ?? '0') ?? 0.0;
    final bool isVip = user['isVip'] == true;
    final userLangs = authProvider.preferredLanguages
        .map((l) => l.toLowerCase())
        .toList();

    final sortedOnlineExperts = List<dynamic>.from(_onlineExperts);
    sortedOnlineExperts.sort((a, b) {
      final isOnlineA = a['available'] == true || a['isOnline'] == true;
      final isOnlineB = b['available'] == true || b['isOnline'] == true;
      if (isOnlineA != isOnlineB) {
        return isOnlineA ? -1 : 1;
      }

      final langsA =
          (a['languages'] as List<dynamic>?)
              ?.map((l) => l.toString().toLowerCase())
              .toList() ??
          [];
      final langsB =
          (b['languages'] as List<dynamic>?)
              ?.map((l) => l.toString().toLowerCase())
              .toList() ??
          [];

      final hasMatchA = langsA.any((l) => userLangs.contains(l));
      final hasMatchB = langsB.any((l) => userLangs.contains(l));

      if (hasMatchA != hasMatchB) {
        return hasMatchA ? -1 : 1;
      }
      final ra =
          double.tryParse(
            (a['ratingAverage'] ?? a['rating'])?.toString() ?? '0',
          ) ??
          0.0;
      final rb =
          double.tryParse(
            (b['ratingAverage'] ?? b['rating'])?.toString() ?? '0',
          ) ??
          0.0;
      return rb.compareTo(ra);
    });

    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: _bgWarmPeach,
      body: Stack(
        children: [
          // Signature Warm Apricot Peach Canvas
          Positioned.fill(
            child: Container(
              color: _bgWarmPeach,
            ),
          ),
          RefreshIndicator(
            color: _brandGreen,
            onRefresh: () async {
              await authProvider.refreshProfile();
              await _fetchExperts();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExecutiveGreenTopSection(
                    context,
                    name,
                    isVip,
                    balance,
                    topPadding,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          context,
                          'Top Featured Experts 🔥',
                          onSeeAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SearchExpertsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildFeaturedExpertsHorizontal(
                          context,
                          sortedOnlineExperts,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          context,
                          'Available Online Experts 🟢',
                          onSeeAll: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SearchExpertsScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildRealtimeExpertList(context, sortedOnlineExperts),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutiveGreenTopSection(
    BuildContext context,
    String name,
    bool isVip,
    double balance,
    double topPadding,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF072B20),
            Color(0xFF0C4F3E),
            Color(0xFF0B3543),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: _brandGreen.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: topPadding + 10,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Brand Row (ConnectaX Monogram + Luxury Golden Wallet) - Responsive & Zero Overflow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: CX Monogram + ConnectaX Branding + Tagline (Flexible to prevent any overflow)
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF072B20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _accentGold,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _brandGreen.withValues(alpha: 0.4),
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
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            'X',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: _accentGold,
                              letterSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'ConnectaX',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isVip) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF59E0B),
                                        Color(0xFFD97706),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'Connect • Discover • Grow',
                            style: TextStyle(
                              color: Color(0xFFF3DEC8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Right: Luxury Golden Wallet Pill (Compact & Zero Overflow)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RechargeScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5.5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 13,
                          color: Color(0xFFD97706),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'WALLET',
                            style: TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 7.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                          Text(
                            '₹${balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF78350F),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    required VoidCallback onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _darkNavy,
            fontSize: 18.5,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _brandGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text(
                  'View All',
                  style: TextStyle(
                    color: _brandGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _brandGreen,
                  size: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showOfflineCreatorModal(BuildContext context, String creatorName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131823) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌙', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '$creatorName is Currently Offline',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: Text(
                  '$creatorName is taking a break and not taking live calls right now. You can get notified as soon as they come online!',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark
                        ? Colors.grey.shade400
                        : const Color(0xFF64748B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '🔔 We will notify you when $creatorName comes online!',
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: _brandGreen,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Notify Me When Online 🔔',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchExpertsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.phone_in_talk_rounded,
                    color: _brandGreen,
                    size: 18,
                  ),
                  label: const Text(
                    'Browse Active Online Experts 🟢',
                    style: TextStyle(
                      color: _brandGreen,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: _brandGreen,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExpertQuickCallSheet(
    BuildContext context,
    Map<String, dynamic> expert,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final user = expert['user'] is Map ? expert['user'] : {};
    final name = user['fullName'] ?? user['name'] ?? expert['name'] ?? 'Expert';
    final avatar =
        user['avatarUrl'] ?? user['profilePhotoUrl'] ?? expert['avatar'] ?? '';
    final headline = (expert['headline'] ?? 'Creator & Consultant').toString();
    final rating =
        double.tryParse(
          (expert['ratingAverage'] ?? expert['rating'])?.toString() ?? '5.0',
        ) ??
        5.0;
    final rate =
        double.tryParse(
          (expert['audioRatePerMin'] ?? expert['pricePerMinute'])?.toString() ??
              '5.0',
        ) ??
        5.0;
    final videoRate =
        double.tryParse(expert['videoRatePerMin']?.toString() ?? '') ??
        (rate * 1.5);
    final expertId =
        (expert['id'] != null && expert['id'].toString().isNotEmpty)
        ? expert['id'].toString()
        : (user['id']?.toString() ?? '');
    final isVerified = user['verified'] == true || expert['isVerified'] == true || expert['verified'] == true;
    List<String> expertLangs = [];
    if (expert['languages'] is List) {
      expertLangs = (expert['languages'] as List).map((l) => l.toString().trim()).where((l) => l.isNotEmpty).toList();
    } else if (expert['languages'] is String && (expert['languages'] as String).trim().isNotEmpty) {
      expertLangs = (expert['languages'] as String).split(',').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    } else if (user['preferredLanguage'] != null && user['preferredLanguage'].toString().trim().isNotEmpty) {
      expertLangs = [user['preferredLanguage'].toString().trim()];
    }
    final languages = expertLangs.isNotEmpty ? expertLangs.join(', ') : 'All Languages';
    final isOnline = (expert['available'] ?? expert['isOnline']) == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131823) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle drag bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),

              // Expert Avatar with ring and live status dot
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      backgroundImage: avatar.isNotEmpty
                          ? NetworkImage(avatar)
                          : null,
                      child: avatar.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'E',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w900,
                                fontSize: 26,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 4,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isOnline
                            ? const Color(0xFF10B981)
                            : const Color(0xFF94A3B8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF131823)
                              : Colors.white,
                          width: 2.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Name + Verified Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (isVerified) ...[
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.verified_rounded,
                      color: Color(0xFF3B82F6),
                      size: 18,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                headline,
                style: TextStyle(
                  color: isDark
                      ? Colors.grey.shade400
                      : const Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              // Rating + Languages pill
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF59E0B),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$rating Rating',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      languages,
                      style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade300
                            : const Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Call Actions (Audio & Video)
              Row(
                children: [
                  // Audio Call Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (!isOnline) {
                          _showOfflineCreatorModal(context, name);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CallScreen(
                              expertName: name,
                              expertId: expertId,
                              pricePerMinute: rate,
                              callType: 'audio',
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        isOnline
                            ? Icons.phone_in_talk_rounded
                            : Icons.phone_disabled_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isOnline ? 'Audio Call' : 'Offline',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${rate.toStringAsFixed(0)}/min',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOnline
                            ? _brandGreen
                            : const Color(0xFF94A3B8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Video Call Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (!isOnline) {
                          _showOfflineCreatorModal(context, name);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CallScreen(
                              expertName: name,
                              expertId: expertId,
                              pricePerMinute: videoRate,
                              callType: 'video',
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        isOnline
                            ? Icons.videocam_rounded
                            : Icons.videocam_off_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isOnline ? 'Video Call' : 'Offline',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₹${videoRate.toStringAsFixed(0)}/min',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOnline
                            ? _darkNavy
                            : const Color(0xFF94A3B8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  LinearGradient _getAvatarGradient(String name) {
    final lower = name.trim().toLowerCase();
    int hash = 0;
    for (int i = 0; i < lower.length; i++) {
      hash = (hash * 31 + lower.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    final index = hash % 6;
    switch (index) {
      case 0:
        return const LinearGradient(
          colors: [Color(0xFFE11D48), Color(0xFFFB7185)],
        ); // Rose / Coral
      case 1:
        return const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        ); // Purple / Violet
      case 2:
        return const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
        ); // Ocean / Cyan
      case 3:
        return const LinearGradient(
          colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
        ); // Warm Amber / Gold
      case 4:
        return const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF818CF8)],
        ); // Royal Indigo / Blue
      default:
        return const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF2DD4BF)],
        ); // Teal / Turquoise
    }
  }

  Widget _buildFeaturedExpertsHorizontal(
    BuildContext context,
    List<dynamic> sortedExperts,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    if (_isLoadingExperts) {
      return const SizedBox(
        height: 90,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final list = sortedExperts;

    if (list.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 98,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final expert = list[index];
          final user = expert['user'] is Map ? expert['user'] : {};
          final name =
              user['fullName'] ?? user['name'] ?? expert['name'] ?? 'Expert';
          final avatar =
              user['avatarUrl'] ??
              user['profilePhotoUrl'] ??
              expert['avatar'] ??
              '';
          final firstName = name.toString().split(' ').first;
          final isOnline =
              expert['available'] == true || expert['isOnline'] == true;

          return GestureDetector(
            onTap: () => _showExpertQuickCallSheet(context, expert),
            child: Container(
              margin: const EdgeInsets.only(right: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      // Gradient Border Ring
                      Container(
                        padding: const EdgeInsets.all(2.8),
                        decoration: BoxDecoration(
                          gradient: _getAvatarGradient(name),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE2E8F0),
                            backgroundImage: avatar.isNotEmpty
                                ? NetworkImage(avatar)
                                : null,
                            child: avatar.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: _getAvatarGradient(name),
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : 'E',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      // Live green / offline grey status dot on bottom right (Image 2 style)
                      Positioned(
                        right: 1,
                        bottom: 1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? const Color(0xFF10B981)
                                : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF8FAFC),
                              width: 2.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    firstName,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRealtimeExpertList(
    BuildContext context,
    List<dynamic> sortedExperts,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final textSubColor = isDark
        ? Colors.grey.shade400
        : AppTheme.lightTextSecondary;

    if (_isLoadingExperts) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (sortedExperts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder,
          ),
        ),
        child: Center(
          child: Text(
            'No experts currently online',
            style: TextStyle(color: textSubColor, fontSize: 13),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedExperts.length,
      itemBuilder: (context, index) {
        final expert = sortedExperts[index];
        final user = expert['user'] is Map ? expert['user'] : {};
        final name =
            user['fullName'] ?? user['name'] ?? expert['name'] ?? 'Expert';
        final avatar =
            user['avatarUrl'] ??
            user['profilePhotoUrl'] ??
            expert['avatar'] ??
            '';
        final headline = (expert['headline'] ?? 'Creator & Consultant')
            .toString();
        final rating =
            double.tryParse(
              (expert['ratingAverage'] ?? expert['rating'])?.toString() ??
                  '5.0',
            ) ??
            5.0;
        final rate =
            double.tryParse(
              (expert['audioRatePerMin'] ?? expert['pricePerMinute'])
                      ?.toString() ??
                  '5.0',
            ) ??
            5.0;
        final videoRate =
            double.tryParse(expert['videoRatePerMin']?.toString() ?? '') ??
            (rate * 2.0);
        final expertId =
            (expert['id'] != null && expert['id'].toString().isNotEmpty)
            ? expert['id'].toString()
            : (user['id']?.toString() ?? '');
        final isVerified = user['verified'] == true || expert['isVerified'] == true || expert['verified'] == true;
        List<String> expertLangs = [];
        if (expert['languages'] is List) {
          expertLangs = (expert['languages'] as List).map((l) => l.toString().trim()).where((l) => l.isNotEmpty).toList();
        } else if (expert['languages'] is String && (expert['languages'] as String).trim().isNotEmpty) {
          expertLangs = (expert['languages'] as String).split(',').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
        } else if (user['preferredLanguage'] != null && user['preferredLanguage'].toString().trim().isNotEmpty) {
          expertLangs = [user['preferredLanguage'].toString().trim()];
        }
        final languages = expertLangs.isNotEmpty ? expertLangs.join(', ') : 'All Languages';
        final tier = (expert['tier'] ?? 'STANDARD').toString().toUpperCase();
        final isElite = tier == 'ELITE';
        final isOnline = (expert['available'] ?? expert['isOnline']) == true;

        return InkWell(
          onTap: () => _showExpertQuickCallSheet(context, expert),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _cardBorder.withValues(alpha: 0.7),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top section: Avatar, Info, and Star Rating Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dual-ring Avatar with Online Dot
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isOnline
                                  ? const Color(0xFF10B981).withValues(alpha: 0.6)
                                  : Colors.grey.shade300,
                              width: 1.8,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 23,
                            backgroundColor: const Color(0xFFF1F5F9),
                            backgroundImage: avatar.isNotEmpty
                                ? NetworkImage(avatar)
                                : null,
                            child: avatar.isEmpty
                                ? Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: _getAvatarGradient(name),
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.isNotEmpty ? name[0].toUpperCase() : 'E',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    // Creator Name, Headline & Tags
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15.5,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isElite) ...[
                                const SizedBox(width: 4),
                                const Text('👑', style: TextStyle(fontSize: 11)),
                              ] else if (isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: _brandGreen,
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 1.5),
                          Text(
                            headline,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.5),
                          Row(
                            children: [
                              // Online status pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? const Color(0xFFD1FAE5)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 2.5,
                                      backgroundColor: isOnline
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 3.5),
                                    Text(
                                      isOnline ? 'Online' : 'Offline',
                                      style: TextStyle(
                                        color: isOnline
                                            ? const Color(0xFF059669)
                                            : const Color(0xFF64748B),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              // Languages pill
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7).withValues(alpha: 0.65),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    languages,
                                    style: const TextStyle(
                                      color: Color(0xFF475569),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Rating Pill Badge (Top Right)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.5,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFD97706),
                            size: 13,
                          ),
                          const SizedBox(width: 2.5),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(
                  height: 1,
                  thickness: 0.8,
                  color: Color(0xFFF1F5F9),
                ),
                const SizedBox(height: 8),

                // Bottom section: Price on Left, Call & Video Buttons on Right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Price Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '₹${rate.toInt() == rate ? rate.toInt() : rate.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const TextSpan(
                                text: '/min',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Video: ₹${videoRate.toInt() == videoRate ? videoRate.toInt() : videoRate.toStringAsFixed(0)}/min',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Action Buttons (Call + Video capsule buttons side-by-side)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Call button
                        InkWell(
                          onTap: () {
                            if (!isOnline) {
                              _showOfflineCreatorModal(context, name);
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(
                                  expertName: name,
                                  expertId: expertId,
                                  pricePerMinute: rate,
                                  callType: 'audio',
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? const Color(0xFF0D5D43)
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isOnline
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF0D5D43).withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOnline
                                      ? Icons.call_rounded
                                      : Icons.phone_disabled_rounded,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Call',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Video button
                        InkWell(
                          onTap: () {
                            if (!isOnline) {
                              _showOfflineCreatorModal(context, name);
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(
                                  expertName: name,
                                  expertId: expertId,
                                  pricePerMinute: videoRate,
                                  callType: 'video',
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? const Color(0xFF0E3E4D)
                                  : const Color(0xFFCBD5E1),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isOnline
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF0E3E4D).withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOnline
                                      ? Icons.videocam_rounded
                                      : Icons.videocam_off_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                const Text(
                                  'Video',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
