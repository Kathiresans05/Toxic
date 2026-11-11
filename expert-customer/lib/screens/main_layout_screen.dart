import 'package:flutter/material.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/screens/home_screen.dart';
import 'package:expert_customer/screens/dashboard_screens.dart'; // For SearchExpertsScreen
import 'package:expert_customer/screens/wallet_screens.dart';
import 'package:expert_customer/screens/user_profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const SearchExpertsScreen(), // Explore
      const WalletHomeScreen(),
      const UserProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = Theme.of(context).scaffoldBackgroundColor;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : AppTheme.lightCardBorder;

    return Scaffold(
      backgroundColor: navBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(color: borderColor, width: 1.0),
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, -2),
            )
          ]
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(
                  context: context,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildTabItem(
                  context: context,
                  icon: Icons.search_rounded,
                  label: 'Explore',
                  index: 1,
                ),
                _buildTabItem(
                  context: context,
                  icon: Icons.account_balance_wallet_outlined,
                  selectedIcon: Icons.account_balance_wallet_rounded,
                  label: 'Wallet',
                  index: 2,
                ),
                _buildTabItem(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required IconData icon,
    IconData? selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? Colors.grey.shade500 : AppTheme.lightTextSecondary;
    final color = isSelected ? AppTheme.secondary : unselectedColor;
    final displayIcon = (isSelected && selectedIcon != null) ? selectedIcon : icon;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        splashColor: AppTheme.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(displayIcon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
