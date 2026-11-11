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

    final textColor = Theme.of(context).colorScheme.onSurface;
    final iconColor = isDark ? Colors.white70 : AppTheme.lightTextSecondary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.only(top: 20, bottom: 35, left: 24, right: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.black12,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                            if (isVip)
                              const Positioned(
                                top: 0,
                                right: 0,
                                child: Text('👑', style: TextStyle(fontSize: 22)),
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
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isVip) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star, color: Color(0xFFFFD54F), size: 12),
                                          SizedBox(width: 3),
                                          Text('VIP', style: TextStyle(color: Color(0xFFFFD54F), fontSize: 11, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mobile,
                                style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.black),
                          onPressed: () {
                            authProvider.refreshProfile();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile refreshed from database')),
                            );
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Balance info chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Wallet Balance:', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                          Text(
                            '₹ ${walletBalance.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // VIP Pass Upgrade Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF2C2405), Color(0xFF141418)]
                          : const [Color(0xFFFFF8E7), Color(0xFFFFF0DC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isVip ? 'VIP Membership Active 🎉' : 'Become a VIP Member',
                              style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isVip ? 'Enjoy 10% Extra Wallet Bonus & VIP Badge!' : 'Get 10% Extra Bonus on Recharges for ₹199/mo',
                              style: TextStyle(color: isDark ? Colors.grey : AppTheme.lightTextSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showVipUpgradeDialog(context, authProvider, isVip);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD54F),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: Text(
                          isVip ? 'Manage' : 'Join VIP',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Menu Items
              _buildMenuItem(
                context,
                icon: Icons.person_outline,
                title: 'My Profile',
                iconColor: iconColor,
                titleColor: textColor,
                onTap: () {
                  _showProfileDetailsDialog(context, name, mobile, referralCode, role, walletBalance);
                },
              ),
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
              _buildMenuItem(
                context,
                icon: Icons.history,
                title: 'Call & Transaction History',
                iconColor: iconColor,
                titleColor: textColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TransactionsScreen()));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.favorite_outline,
                title: 'My Favorites',
                iconColor: iconColor,
                titleColor: textColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FavoritesScreen()));
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.card_giftcard,
                title: 'Refer & Earn',
                iconColor: iconColor,
                titleColor: textColor,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ReferralProgramScreen()));
                },
              ),
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

              // Theme Switch Menu Item
              ListTile(
                leading: Icon(
                  isDark ? Icons.brightness_2_outlined : Icons.wb_sunny_outlined,
                  color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFD97706),
                ),
                title: Text(
                  'App Theme',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  isDark ? 'Dark Mode (Active)' : 'Light Cream Mode (Active)',
                  style: TextStyle(color: isDark ? Colors.grey : AppTheme.lightTextSecondary, fontSize: 12),
                ),
                trailing: Switch(
                  value: !isDark,
                  activeThumbColor: AppTheme.primary,
                  onChanged: (val) {
                    themeProvider.toggleTheme();
                  },
                ),
              ),

              _buildMenuItem(
                context,
                icon: Icons.logout,
                title: 'Logout',
                titleColor: Colors.redAccent,
                iconColor: Colors.redAccent,
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.white70,
    Color titleColor = Colors.white,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white38 : Colors.black38, size: 16),
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
            child: const Text('Close', style: TextStyle(color: AppTheme.secondary)),
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
              backgroundColor: const Color(0xFFFFD54F),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isVip ? 'Cancel VIP' : 'Activate VIP (₹199)', style: const TextStyle(fontWeight: FontWeight.bold)),
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
