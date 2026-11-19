import 'package:flutter/material.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/screens/home_screen.dart';
import 'package:expert_customer/screens/dashboard_screens.dart'; // For SearchExpertsScreen
import 'package:expert_customer/screens/activity_screen.dart'; // For Call History & Favorites
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
      const SearchExpertsScreen(), // Call / Explore
      const ActivityScreen(), // Call History & Favorites
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

    return Scaffold(
      backgroundColor: navBg,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBF7),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFF5DFC9),
              width: 1.2,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0xFF6E431E).withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(
                  context: context,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                ),
                _buildTabItem(
                  context: context,
                  icon: Icons.call_outlined,
                  selectedIcon: Icons.call_rounded,
                  label: 'Call',
                  index: 1,
                ),
                _buildTabItem(
                  context: context,
                  icon: Icons.history_rounded,
                  selectedIcon: Icons.history_rounded,
                  label: 'Activity',
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
    final unselectedColor = isDark ? Colors.grey.shade500 : const Color(0xFF8B7E74);
    final color = isSelected ? const Color(0xFF0C4F3E) : unselectedColor;
    final displayIcon = (isSelected && selectedIcon != null) ? selectedIcon : icon;

    return Expanded(
      child: InkWell(
        onTap: () => _onTabTapped(index),
        splashColor: const Color(0xFF0C4F3E).withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF0C4F3E).withValues(alpha: 0.4) : const Color(0xFF0C4F3E).withValues(alpha: 0.1))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(displayIcon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
