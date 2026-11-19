import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/providers/auth_provider.dart';
import 'package:expert_customer/providers/theme_provider.dart';
import 'package:expert_customer/screens/wallet_screens.dart';
import 'package:expert_customer/screens/transactions_screen.dart';
import 'package:expert_customer/screens/profile_screens.dart';
import 'package:expert_customer/screens/login_screen.dart';
import 'package:expert_customer/screens/language_selection_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final user = authProvider.user ?? {};
    final String name = (user['name'] != null && (user['name'] as String).trim().isNotEmpty)
        ? user['name']
        : (user['mobileNumber'] != null ? 'User (${user['mobileNumber']})' : 'ConnectaX User');
    final String mobile = user['mobileNumber'] ?? user['email'] ?? '+91 --';
    final String referralCode = user['referralCode'] ?? 'N/A';
    final String role = user['role'] ?? 'CUSTOMER';
    final double walletBalance = double.tryParse(user['walletBalance']?.toString() ?? '0') ?? 0.0;

    final bool isVip = user['isVip'] == true;

    final textColor = isDark ? Colors.white : const Color(0xFF0B3543);
    final iconColor = const Color(0xFF0C4F3E);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFEE8D1),
      body: Stack(
        children: [
          // Warm Apricot Peach Background matching Login & Dashboard
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFEE8D1),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top Executive Header Card in Deep Emerald Green
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0C4F3E), Color(0xFF073328)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF073328).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.only(top: 20, bottom: 28, left: 20, right: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0C4F3E),
                                    ),
                                  ),
                                ),
                                if (isVip)
                                  const Positioned(
                                    top: -2,
                                    right: -2,
                                    child: Text('👑', style: TextStyle(fontSize: 20)),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
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
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isVip) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE5A93B),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.star, color: Colors.black, size: 12),
                                              SizedBox(width: 3),
                                              Text(
                                                'VIP',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    mobile,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                                  color: const Color(0xFFE5A93B),
                                  size: 20,
                                ),
                                tooltip: 'Switch Theme',
                                onPressed: () {
                                  themeProvider.toggleTheme();
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                                tooltip: 'Refresh Profile',
                                onPressed: () {
                                  authProvider.refreshProfile();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Profile refreshed from database')),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Wallet Balance Banner in Frosted Glass
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFE5A93B), size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Wallet Balance:',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '₹ ${walletBalance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFFE5A93B),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // VIP Pass Upgrade Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFF5DFC9)),
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
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5A93B).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Text('👑', style: TextStyle(fontSize: 26)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isVip ? 'VIP Membership Active 🎉' : 'Become a VIP Member',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : const Color(0xFF0B3543),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isVip ? '10% Extra Wallet Bonus & VIP Badge Active' : 'Get 10% Extra Bonus on Recharges for ₹199/mo',
                                  style: TextStyle(
                                    color: isDark ? Colors.grey : const Color(0xFF64748B),
                                    fontSize: 11,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _showVipUpgradeDialog(context, authProvider, isVip);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0C4F3E),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              isVip ? 'Manage' : 'Join VIP',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Menu Section 1: Account & Activities
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFF5DFC9)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6E431E).withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            context,
                            icon: Icons.person_outline_rounded,
                            title: 'My Profile',
                            iconColor: iconColor,
                            titleColor: textColor,
                            onTap: () {
                              _showProfileDetailsDialog(context, name, mobile, referralCode, role, walletBalance);
                            },
                          ),
                          _buildDivider(isDark),
                          _buildMenuItem(
                            context,
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Wallet',
                            iconColor: iconColor,
                            titleColor: textColor,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const WalletHomeScreen()));
                            },
                          ),
                          _buildDivider(isDark),
                          _buildMenuItem(
                            context,
                            icon: Icons.history_rounded,
                            title: 'Call & Transaction History',
                            iconColor: iconColor,
                            titleColor: textColor,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen()));
                            },
                          ),
                          _buildDivider(isDark),
                          _buildMenuItem(
                            context,
                            icon: Icons.favorite_outline_rounded,
                            title: 'My Favorites',
                            iconColor: iconColor,
                            titleColor: textColor,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Menu Section 2: Preferences & Settings
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFF5DFC9)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6E431E).withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            context,
                            icon: Icons.card_giftcard_rounded,
                            title: 'Refer & Earn',
                            iconColor: iconColor,
                            titleColor: textColor,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralProgramScreen()));
                            },
                          ),
                          _buildDivider(isDark),
                          _buildMenuItem(
                            context,
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            iconColor: iconColor,
                            titleColor: textColor,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
                            },
                          ),
                          _buildDivider(isDark),
                          _buildMenuItem(
                            context,
                            icon: Icons.translate_rounded,
                            title: 'My Preferred Languages',
                            iconColor: iconColor,
                            titleColor: textColor,
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()));
                            },
                          ),
                          _buildDivider(isDark),
                          // Theme Switch Tile inside Card
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            leading: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0C4F3E).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isDark ? Icons.brightness_2_outlined : Icons.wb_sunny_outlined,
                                color: const Color(0xFF0C4F3E),
                                size: 20,
                              ),
                            ),
                            title: Text(
                              'App Theme',
                              style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              isDark ? 'Dark Mode (Active)' : 'Light Cream Mode (Active)',
                              style: TextStyle(color: isDark ? Colors.grey : const Color(0xFF64748B), fontSize: 12),
                            ),
                            trailing: Switch(
                              value: !isDark,
                              activeColor: const Color(0xFF0C4F3E),
                              onChanged: (val) {
                                themeProvider.toggleTheme();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Menu Section 3: Logout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFF5DFC9)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6E431E).withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildMenuItem(
                        context,
                        icon: Icons.logout_rounded,
                        title: 'Logout',
                        titleColor: const Color(0xFFDC2626),
                        iconColor: const Color(0xFFDC2626),
                        onTap: () async {
                          await authProvider.logout();
                          if (!context.mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      endIndent: 16,
      color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF5DFC9).withValues(alpha: 0.6),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF0C4F3E),
    Color titleColor = const Color(0xFF0B3543),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDestructive = titleColor == const Color(0xFFDC2626);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDestructive
              ? const Color(0xFFDC2626).withValues(alpha: 0.08)
              : const Color(0xFF0C4F3E).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        color: isDark ? Colors.white30 : const Color(0xFFC89153),
        size: 14,
      ),
      onTap: onTap,
    );
  }

  void _showProfileDetailsDialog(
    BuildContext context,
    String name,
    String mobile,
    String referralCode,
    String role,
    double walletBalance,
  ) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('My Profile Details', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, 'Name:', name),
            const SizedBox(height: 10),
            _buildDetailRow(context, 'Mobile / Email:', mobile),
            const SizedBox(height: 10),
            _buildDetailRow(context, 'Role:', role),
            const SizedBox(height: 10),
            _buildDetailRow(context, 'Referral Code:', referralCode),
            const SizedBox(height: 10),
            _buildDetailRow(context, 'Wallet Balance:', '₹ ${walletBalance.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF0C4F3E), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.grey : AppTheme.lightTextSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  void _showVipUpgradeDialog(BuildContext context, AuthProvider authProvider, bool isVip) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Text(
              isVip ? 'VIP Membership' : 'Join ConnectaX VIP',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isVip
                  ? 'Your VIP membership is active! Enjoy 10% extra bonus on every wallet recharge.'
                  : 'Upgrade to ConnectaX VIP for ₹199/month and get:',
              style: TextStyle(color: isDark ? Colors.white70 : AppTheme.lightTextSecondary, fontSize: 14),
            ),
            const SizedBox(height: 15),
            _buildVipFeature(context, '✨ 10% Extra Cashback on all Wallet Recharges'),
            _buildVipFeature(context, '✨ Exclusive VIP Crown Badge on your profile'),
            _buildVipFeature(context, '✨ Priority Customer Support 24/7'),
            _buildVipFeature(context, '✨ Early access to new expert categories'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newVipStatus = !isVip;
              await authProvider.updateVipStatus(newVipStatus);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(newVipStatus ? '🎉 Congratulations! You are now a VIP Member!' : 'VIP status cancelled.'),
                    backgroundColor: newVipStatus ? Colors.green : Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C4F3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              isVip ? 'Cancel VIP' : 'Activate VIP (₹199)',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVipFeature(BuildContext context, String text) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }
}
