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

  @override
  void initState() {
    super.initState();
    _fetchExperts();
  }

  StreamSubscription? _expertsSub;

  @override
  void dispose() {
    _expertsSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchExperts() async {
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
      if (mounted) {
        setState(() {
          _isLoadingExperts = false;
        });
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user ?? {};
    final name = user['name'] ?? 'User';
    final balance = double.tryParse(user['walletBalance']?.toString() ?? '0') ?? 0.0;
    final bool isVip = user['isVip'] == true;
    final userLangs = authProvider.preferredLanguages.map((l) => l.toLowerCase()).toList();

    final sortedOnlineExperts = List<dynamic>.from(_onlineExperts);
    sortedOnlineExperts.sort((a, b) {
      final langsA = (a['languages'] as List<dynamic>?)?.map((l) => l.toString().toLowerCase()).toList() ?? [];
      final langsB = (b['languages'] as List<dynamic>?)?.map((l) => l.toString().toLowerCase()).toList() ?? [];

      final hasMatchA = langsA.any((l) => userLangs.contains(l));
      final hasMatchB = langsB.any((l) => userLangs.contains(l));

      if (hasMatchA != hasMatchB) {
        return hasMatchA ? -1 : 1;
      }
      final ra = double.tryParse((a['ratingAverage'] ?? a['rating'])?.toString() ?? '0') ?? 0.0;
      final rb = double.tryParse((b['ratingAverage'] ?? b['rating'])?.toString() ?? '0') ?? 0.0;
      return rb.compareTo(ra);
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await authProvider.refreshProfile();
            await _fetchExperts();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, name, isVip),
                const SizedBox(height: 18),
                _buildWalletHeroCard(balance),
                const SizedBox(height: 14),
                _buildLiveActivityTicker(context),
                const SizedBox(height: 20),
                _buildSectionHeader(context, 'Top Featured Experts 🔥', onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchExpertsScreen()),
                  );
                }),
                const SizedBox(height: 12),
                _buildFeaturedExpertsHorizontal(context, sortedOnlineExperts),
                const SizedBox(height: 22),
                _buildSectionHeader(context, 'Consultation Categories 💡', onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchExpertsScreen()),
                  );
                }),
                const SizedBox(height: 12),
                _buildCategoriesRow(context),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Available Online Experts 🟢', onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchExpertsScreen()),
                  );
                }),
                const SizedBox(height: 12),
                _buildRealtimeExpertList(context, sortedOnlineExperts),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, bool isVip) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFEC4899)]),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                if (isVip)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: Text('👑', style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getGreeting(), style: TextStyle(color: isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary, fontSize: 12)),
                Row(
                  children: [
                    Text(name, style: TextStyle(color: textColor, fontSize: 19, fontWeight: FontWeight.bold)),
                    if (isVip) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('VIP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Theme Toggle Button
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? Colors.white12 : AppTheme.lightCardBorder),
              ),
              child: IconButton(
                onPressed: () => themeProvider.toggleTheme(),
                icon: Icon(
                  isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                  color: isDark ? const Color(0xFFFFD54F) : const Color(0xFF6366F1),
                  size: 19,
                ),
                tooltip: 'Switch Theme',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWalletHeroCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB800), Color(0xFFFF9100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB800).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_rounded, color: Colors.black87, size: 18),
                  SizedBox(width: 6),
                  Text('Wallet Balance', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),
              Text('₹ ${balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.w900)),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RechargeScreen()),
              );
            },
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text('Recharge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveActivityTicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _onlineExperts.isNotEmpty 
                  ? '${_onlineExperts.length} Expert${_onlineExperts.length > 1 ? "s" : ""} Online • Connect instantly'
                  : 'Connect with certified experts • 24/7 Support',
              style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.bolt_rounded, color: Color(0xFFEC4899), size: 18),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, {required VoidCallback onSeeAll}) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: textColor, fontSize: 17, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text('View All ➔', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildFeaturedExpertsHorizontal(BuildContext context, List<dynamic> sortedExperts) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final textSubColor = isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary;

    if (_isLoadingExperts) {
      return const SizedBox(
        height: 170,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    final list = sortedExperts;

    if (list.isEmpty) {
      return Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, color: textSubColor, size: 32),
              const SizedBox(height: 6),
              Text(
                'No experts available yet',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                'New experts will appear here once registered & approved',
                style: TextStyle(color: textSubColor, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 175,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final expert = list[index];
          final user = expert['user'] is Map ? expert['user'] : {};
          final name = user['fullName'] ?? user['name'] ?? expert['name'] ?? 'Expert';
          final avatar = user['avatarUrl'] ?? user['profilePhotoUrl'] ?? expert['avatar'] ?? '';
          final rating = double.tryParse((expert['ratingAverage'] ?? expert['rating'])?.toString() ?? '5.0') ?? 5.0;
          final rate = double.tryParse((expert['audioRatePerMin'] ?? expert['pricePerMinute'])?.toString() ?? '5.0') ?? 5.0;
          final expertId = (expert['id'] != null && expert['id'].toString().isNotEmpty) ? expert['id'].toString() : (user['id']?.toString() ?? '');
          final tier = (expert['tier'] ?? 'STANDARD').toString().toUpperCase();
          final isElite = tier == 'ELITE';

          return Container(
            width: 145,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF10B981)]),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                        backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                        child: avatar.isEmpty
                            ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'E', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16))
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).cardColor, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isElite) ...[
                      const SizedBox(width: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('👑', style: TextStyle(fontSize: 8)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 13),
                    Text('$rating', style: TextStyle(color: textSubColor, fontSize: 11, fontWeight: FontWeight.bold)),
                    Text(' • ₹${rate.toStringAsFixed(0)}/m', style: const TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.call_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CallScreen(
                                expertName: name,
                                expertId: expertId,
                                pricePerMinute: rate * 1.5,
                                callType: 'video',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6366F1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesRow(BuildContext context) {
    final categories = [
      {'name': 'Breakup & Heartbreak', 'icon': Icons.heart_broken_outlined},
      {'name': 'Vent Out & Confessions', 'icon': Icons.chat_bubble_outline_rounded},
      {'name': 'Friendly Listener', 'icon': Icons.headset_mic_outlined},
      {'name': 'Love & Relationship', 'icon': Icons.favorite_border_rounded},
      {'name': 'Late Night Talks', 'icon': Icons.nightlight_round},
      {'name': 'Loneliness & Stress', 'icon': Icons.spa_outlined},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((c) {
          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchExpertsScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder),
                ),
                child: Row(
                  children: [
                    Icon(c['icon'] as IconData, color: AppTheme.primary, size: 17),
                    const SizedBox(width: 8),
                    Text(c['name'] as String, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRealtimeExpertList(BuildContext context, List<dynamic> sortedExperts) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final textSubColor = isDark ? Colors.grey.shade400 : AppTheme.lightTextSecondary;

    if (_isLoadingExperts) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (sortedExperts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder),
        ),
        child: Center(
          child: Text('No experts currently online', style: TextStyle(color: textSubColor, fontSize: 13)),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedExperts.length,
      separatorBuilder: (_, _) => Divider(height: 1, color: isDark ? AppTheme.darkCardBorder : AppTheme.lightCardBorder),
      itemBuilder: (context, index) {
        final expert = sortedExperts[index];
        final user = expert['user'] is Map ? expert['user'] : {};
        final name = user['fullName'] ?? user['name'] ?? expert['name'] ?? 'Expert';
        final avatar = user['avatarUrl'] ?? user['profilePhotoUrl'] ?? expert['avatar'] ?? '';
        final rating = double.tryParse((expert['ratingAverage'] ?? expert['rating'])?.toString() ?? '5.0') ?? 5.0;
        final rate = double.tryParse((expert['audioRatePerMin'] ?? expert['pricePerMinute'])?.toString() ?? '5.0') ?? 5.0;
        final expertId = (expert['id'] != null && expert['id'].toString().isNotEmpty) ? expert['id'].toString() : (user['id']?.toString() ?? '');
        final languages = (expert['languages'] as List<dynamic>?)?.join(', ') ?? 'Tamil, English';
        final tier = (expert['tier'] ?? 'STANDARD').toString().toUpperCase();
        final isElite = tier == 'ELITE';

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // Circle Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                    child: avatar.isEmpty
                        ? Text(name.isNotEmpty ? name[0].toUpperCase() : 'E', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16))
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 5),
                        if (isElite)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('👑 ELITE', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold)),
                          )
                        else
                          const Icon(Icons.verified, color: AppTheme.primary, size: 14),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Relationship • $languages',
                      style: TextStyle(color: textSubColor, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                        const SizedBox(width: 2),
                        Text('$rating', style: TextStyle(color: textSubColor, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('₹${rate.toStringAsFixed(0)}/min', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Call Action Buttons
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981), // Emerald Green Audio Call
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.call_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 5),
                          Text('Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallScreen(
                            expertName: name,
                            expertId: expertId,
                            pricePerMinute: rate * 1.5,
                            callType: 'video',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.videocam_rounded, color: Color(0xFF6366F1), size: 16),
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
}
