import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expert_admin/services/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Reuse visual constants matching the golden/dark luxury theme
class AdminColors {
  static const Color background = Color(0xFF08080A);
  static const Color cardBg = Color(0xFF141418);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color primaryYellowDark = Color(0xFFFFB800);
  static const Color textMuted = Color(0xFF8A8A93);
  static const Color borderColor = Color(0xFF24242A);
}

// -----------------------------------------------------------------------------
// Admin Dashboard Screen (Image 3)
// -----------------------------------------------------------------------------
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;
  int _totalCalls = 0;
  double _totalRevenue = 0.0;
  double _totalEarnings = 0.0;
  int _apiUsersCount = 0;
  int _apiExpertsCount = 0;
  String _latestActivityName = 'Priya Sharma';
  String _latestActivityTime = 'Just now';
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoadingStats = true);
    try {
      final stats = await ApiService().getAdminStats();
      final users = await ApiService().getAllUsers();
      final experts = await ApiService().getAllExperts();

      if (mounted) {
        setState(() {
          if (stats != null) {
            _totalCalls = stats['totalCalls'] ?? 0;
            _totalRevenue =
                double.tryParse(stats['totalRevenue']?.toString() ?? '0.0') ??
                0.0;
            _totalEarnings =
                double.tryParse(stats['totalEarnings']?.toString() ?? '0.0') ??
                0.0;
          }
          if (users != null && users.isNotEmpty) {
            _apiUsersCount = users.length;
          }
          if (experts != null && experts.isNotEmpty) {
            _apiExpertsCount = experts.length;
            final firstExp = experts.first;
            _latestActivityName =
                (firstExp['name'] != null &&
                    firstExp['name'].toString().trim().isNotEmpty)
                ? firstExp['name']
                : (firstExp['user'] != null && firstExp['user']['name'] != null)
                ? firstExp['user']['name']
                : 'Priya Sharma';
            _latestActivityTime = 'Recently Registered';
          }
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // List of bodies to switch between in the bottom navigation bar
    final List<Widget> tabs = [
      _buildDashboardTab(),
      const UserManagementScreen(isTabMode: true),
      const ExpertManagementScreen(isTabMode: true),
      const CallMonitorScreen(isTabMode: true),
      const MenuScreen(isTabMode: true),
    ];

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(child: tabs[_currentIndex]),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: AdminColors.background),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AdminColors.background,
          selectedItemColor: AdminColors.primaryYellow,
          unselectedItemColor: AdminColors.textMuted,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 8),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Experts'),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_in_talk_rounded),
              label: 'Live Calls',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Main Dashboard Tab (Image 3)
  // ---------------------------------------------------------------------------
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.menu,
                color: AdminColors.primaryYellow,
                size: 28,
              ),
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AdminColors.primaryYellow,
                    size: 28,
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Subtitle Headers
          Row(
            children: [
              const Text(
                'Good Evening, Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text('👋', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Welcome back to ConnectaX Admin Panel',
            style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Total Revenue Card (Yellow Gradient Card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFC107), Color(0xFFFFB800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AdminColors.primaryYellow.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Revenue',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '▲ 12.5% vs last month',
                        style: TextStyle(
                          color: AdminColors.primaryYellow,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _isLoadingStats
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : Text(
                        '₹ ${_totalRevenue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                const SizedBox(height: 14),
                // Sparkline graph
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: CustomPaint(painter: RevenueSparklinePainter()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid (4 cards)
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, userSnapshot) {
              final fsUsersCount = userSnapshot.data?.docs.length ?? 0;
              final usersCount = fsUsersCount > 0
                  ? fsUsersCount
                  : _apiUsersCount;
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('experts')
                    .snapshots(),
                builder: (context, expertSnapshot) {
                  final fsExpertsCount = expertSnapshot.data?.docs.length ?? 0;
                  final expertsCount = fsExpertsCount > 0
                      ? fsExpertsCount
                      : _apiExpertsCount;
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.45,
                    children: [
                      _buildStatCard(
                        'Total Users',
                        usersCount.toString(),
                        'Real-time',
                        Colors.greenAccent,
                        Icons.people_rounded,
                      ),
                      _buildStatCard(
                        'Total Experts',
                        expertsCount.toString(),
                        'Real-time',
                        Colors.greenAccent,
                        Icons.workspace_premium_rounded,
                      ),
                      _buildStatCard(
                        'Total Calls',
                        _totalCalls.toString(),
                        'Real-time',
                        Colors.greenAccent,
                        Icons.phone_in_talk_rounded,
                      ),
                      _buildStatCard(
                        'Total Earnings',
                        '₹ ${_totalEarnings.toStringAsFixed(2)}',
                        'Real-time',
                        Colors.greenAccent,
                        Icons.account_balance_wallet_rounded,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 28),

          // Recent Activities
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activities',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: AdminColors.primaryYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Live activity list item
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AdminColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AdminColors.borderColor),
            ),
            child: Row(
              children: [
                // Avatar with yellow checkmark
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
                      ),
                    ),
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.check, color: Colors.black, size: 9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Expert Registered',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_latestActivityName • $_latestActivityTime',
                        style: const TextStyle(
                          color: AdminColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trailing arrow/status indicator
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AdminColors.primaryYellow,
                  size: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String val,
    String indicator,
    Color indicatorColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminColors.borderColor),
        gradient: const LinearGradient(
          colors: [AdminColors.cardBg, Color(0xFF1B1B22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 12,
                ),
              ),
              Icon(icon, color: AdminColors.primaryYellow, size: 20),
            ],
          ),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            indicator,
            style: TextStyle(
              color: indicatorColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sparkline Painter for Revenue
// -----------------------------------------------------------------------------
class RevenueSparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Curve paint
    final linePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.70);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.75,
      size.width * 0.25,
      size.height * 0.60,
    );
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.40,
      size.width * 0.45,
      size.height * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.85,
      size.width * 0.65,
      size.height * 0.50,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.20,
      size.width * 0.85,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.95,
      size.height * 0.50,
      size.width,
      size.height * 0.15,
    );

    // Gradient fill under the path
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.black.withValues(alpha: 0.35),
          Colors.black.withValues(alpha: 0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Users Management Screen (Image 4)
// -----------------------------------------------------------------------------
class UserManagementScreen extends StatefulWidget {
  final bool isTabMode;
  const UserManagementScreen({super.key, this.isTabMode = false});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedFilter = 'All Users';
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  StreamSubscription? _usersSub;

  @override
  void dispose() {
    _usersSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    _usersSub?.cancel();

    final List<Map<String, dynamic>> loadedUsers = [];

    // Helper to check if an email is a fake seed mock account
    bool isSeedEmail(String? email) {
      if (email == null) return false;
      final e = email.toLowerCase().trim();
      return e.contains('@connectax.com') ||
          e == 'sneha@connectax.com' ||
          e == 'divya@connectax.com' ||
          e == 'anitha@connectax.com' ||
          e == 'priya@connectax.com' ||
          e == 'kavya@connectax.com';
    }

    // 1. Primary: Fetch from Firestore users collection (Live registrations)
    try {
      final snap = await FirebaseFirestore.instance.collection('users').get();
      for (final doc in snap.docs) {
        final u = doc.data();
        final bool isBlocked = u['isBlocked'] == true;
        loadedUsers.add({
          'id': doc.id,
          'name': (u['name'] != null && u['name'].toString().trim().isNotEmpty)
              ? u['name']
              : 'Customer User',
          'email': u['email'] ?? 'customer@connectax.com',
          'phone': u['phone'] ?? u['mobileNumber'] ?? 'N/A',
          'avatar':
              u['profilePhotoUrl'] ??
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
          'verified': u['isMobileVerified'] == true,
          'status': isBlocked ? 'Blocked' : 'Active',
          'isBlocked': isBlocked,
          'role': u['role'] ?? 'customer',
          'walletBalance': (u['walletBalance'] ?? 0.0).toString(),
          'gender': u['gender'] ?? 'Not Specified',
          'age': (u['age'] ?? 'N/A').toString(),
          'preferredLanguage': u['preferredLanguage'] ?? 'English',
        });
      }
    } catch (e) {
      debugPrint('Firestore direct users load error: $e');
    }

    // 2. Fetch from Backend API & merge non-seed users (or all if Firestore is empty)
    try {
      final apiUsers = await ApiService().getAllUsers();
      if (apiUsers != null && apiUsers.isNotEmpty) {
        for (final u in apiUsers) {
          final String email = u['email']?.toString() ?? '';
          if (loadedUsers.isNotEmpty && isSeedEmail(email)) {
            continue; // Skip fake seed mockup data when real Firestore users exist
          }
          final bool isBlocked = u['isBlocked'] == true;
          final existingIndex = loadedUsers.indexWhere(
            (item) =>
                item['id'] == u['id'] ||
                (email.isNotEmpty && item['email'] == email) ||
                item['phone'] == (u['mobileNumber'] ?? u['phone']),
          );
          final userMap = {
            'id': u['id']?.toString() ?? 'user_${loadedUsers.length}',
            'name':
                (u['name'] != null && u['name'].toString().trim().isNotEmpty)
                ? u['name']
                : 'Customer User',
            'email': email.isNotEmpty ? email : 'customer@connectax.com',
            'phone': u['mobileNumber'] ?? u['phone'] ?? 'N/A',
            'avatar':
                u['profilePhotoUrl'] ??
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
            'verified': u['isMobileVerified'] == true,
            'status': isBlocked ? 'Blocked' : 'Active',
            'isBlocked': isBlocked,
            'role': u['role'] ?? 'customer',
            'walletBalance': (u['walletBalance'] ?? 0.0).toString(),
            'gender': u['gender'] ?? 'Not Specified',
            'age': (u['age'] ?? 'N/A').toString(),
            'preferredLanguage': u['preferredLanguage'] ?? 'English',
          };
          if (existingIndex >= 0) {
            loadedUsers[existingIndex] = userMap;
          } else {
            loadedUsers.add(userMap);
          }
        }
      }
    } catch (e) {
      debugPrint('Backend API users load error: $e');
    }

    if (mounted) {
      setState(() {
        _users = loadedUsers;
        _isLoading = false;
      });
    }

    _usersSub = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen(
          (snapshot) {
            final List<Map<String, dynamic>> liveUsers = List.from(_users);
            for (final doc in snapshot.docs) {
              final u = doc.data();
              final bool isBlocked = u['isBlocked'] == true;
              final existingIndex = liveUsers.indexWhere(
                (item) =>
                    item['id'] == doc.id ||
                    (u['email'] != null &&
                        u['email'].toString().isNotEmpty &&
                        item['email'] == u['email']) ||
                    item['phone'] == (u['phone'] ?? u['mobileNumber']),
              );
              final userMap = {
                'id': doc.id,
                'name':
                    (u['name'] != null &&
                        u['name'].toString().trim().isNotEmpty)
                    ? u['name']
                    : 'Customer User',
                'email': u['email'] ?? 'customer@connectax.com',
                'phone': u['phone'] ?? u['mobileNumber'] ?? 'N/A',
                'avatar':
                    u['profilePhotoUrl'] ??
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
                'verified': u['isMobileVerified'] == true,
                'status': isBlocked ? 'Blocked' : 'Active',
                'isBlocked': isBlocked,
                'role': u['role'] ?? 'customer',
                'walletBalance': (u['walletBalance'] ?? 0.0).toString(),
                'gender': u['gender'] ?? 'Not Specified',
                'age': (u['age'] ?? 'N/A').toString(),
                'preferredLanguage': u['preferredLanguage'] ?? 'English',
              };
              if (existingIndex >= 0) {
                liveUsers[existingIndex] = userMap;
              } else {
                liveUsers.add(userMap);
              }
            }
            if (mounted) {
              setState(() {
                _users = liveUsers;
                _isLoading = false;
              });
            }
          },
          onError: (err) {
            debugPrint('Firestore users snapshot stream error: $err');
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        );
  }

  void _showCustomerProfileDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) {
        bool isActionLoading = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final String name = user['name'] ?? 'Customer';
            final String email = user['email'] ?? 'N/A';
            final String phone = user['phone'] ?? 'N/A';
            final String wallet = '₹ ${user['walletBalance'] ?? '0.00'}';
            final String role = (user['role'] ?? 'customer')
                .toString()
                .toUpperCase();
            final String gender = user['gender'] ?? 'Not Specified';
            final String age = user['age'] ?? 'N/A';
            final String lang = user['preferredLanguage'] ?? 'English';
            final bool isBlocked = user['isBlocked'] == true;

            return Dialog(
              backgroundColor: AdminColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.person_pin_rounded,
                                color: AdminColors.primaryYellow,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Customer Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AdminColors.textMuted,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(color: AdminColors.borderColor, height: 24),

                      // User Header Card
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(user['avatar']),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    color: AdminColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    color: AdminColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isBlocked
                                  ? Colors.red.withValues(alpha: 0.2)
                                  : Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isBlocked ? Colors.red : Colors.green,
                              ),
                            ),
                            child: Text(
                              isBlocked ? 'Blocked' : 'Active',
                              style: TextStyle(
                                color: isBlocked
                                    ? Colors.redAccent
                                    : Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Details Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AdminColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AdminColors.borderColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Wallet Balance',
                                  style: TextStyle(
                                    color: AdminColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  wallet,
                                  style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: AdminColors.borderColor,
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Account Role',
                                  style: TextStyle(
                                    color: AdminColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  role,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: AdminColors.borderColor,
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Gender & Age',
                                  style: TextStyle(
                                    color: AdminColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '$gender ($age)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: AdminColors.borderColor,
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Preferred Language',
                                  style: TextStyle(
                                    color: AdminColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  lang,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Button
                      if (isActionLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AdminColors.primaryYellow,
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              setModalState(() => isActionLoading = true);
                              final res = await ApiService().toggleBlockUser(
                                user['id'],
                                isBlocked: !isBlocked,
                              );
                              if (mounted) {
                                Navigator.pop(context);
                                if (res != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        !isBlocked
                                            ? 'User blocked successfully.'
                                            : 'User unblocked successfully.',
                                      ),
                                      backgroundColor: !isBlocked
                                          ? Colors.redAccent
                                          : Colors.green,
                                    ),
                                  );
                                  _loadUsers();
                                }
                              }
                            },
                            icon: Icon(
                              isBlocked
                                  ? Icons.lock_open_rounded
                                  : Icons.block_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              isBlocked ? 'Unblock User' : 'Block User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isBlocked
                                  ? Colors.green
                                  : Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!widget.isTabMode)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 40),
            const Text(
              'Users Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AdminColors.primaryYellow,
              ),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: AdminColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminColors.borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: AdminColors.textMuted),
              hintText: 'Search users...',
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Filter Pills Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterPill('All Users'),
              const SizedBox(width: 8),
              _buildFilterPill('Active'),
              const SizedBox(width: 8),
              _buildFilterPill('Blocked'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Users List
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AdminColors.primaryYellow,
                  ),
                )
              : _users.isEmpty
              ? RefreshIndicator(
                  color: AdminColors.primaryYellow,
                  backgroundColor: AdminColors.cardBg,
                  onRefresh: _loadUsers,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              color: AdminColors.textMuted,
                              size: 54,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'No Live Users Found',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Live database currently has 0 registered users.',
                              style: TextStyle(
                                color: AdminColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AdminColors.primaryYellow,
                  backgroundColor: AdminColors.cardBg,
                  onRefresh: _loadUsers,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _users.length,
                    itemBuilder: (context, index) {
                      final user = _users[index];

                      // Basic filter match
                      if (_selectedFilter != 'All Users' &&
                          user['status'] != _selectedFilter) {
                        return const SizedBox.shrink();
                      }

                      // Color mappings for status tag boxes
                      Color tagBoxColor = Colors.white10;
                      Color tagTextColor = Colors.white70;
                      if (user['status'] == 'Active') {
                        tagBoxColor = Colors.green.withValues(alpha: 0.12);
                        tagTextColor = Colors.greenAccent.shade400;
                      } else if (user['status'] == 'Blocked') {
                        tagBoxColor = Colors.red.withValues(alpha: 0.12);
                        tagTextColor = Colors.redAccent;
                      }

                      return GestureDetector(
                        onTap: () => _showCustomerProfileDialog(user),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AdminColors.cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AdminColors.borderColor),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(user['avatar']),
                              ),
                              const SizedBox(width: 14),

                              // User details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (user['verified'] == true) ...[
                                          const SizedBox(width: 4),
                                          const Icon(
                                            Icons.verified,
                                            color: Colors.blue,
                                            size: 14,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user['email'],
                                      style: const TextStyle(
                                        color: AdminColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user['phone'],
                                      style: const TextStyle(
                                        color: AdminColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Status & Dots menu
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tagBoxColor,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      user['status'],
                                      style: TextStyle(
                                        color: tagTextColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      color: AdminColors.textMuted,
                                      size: 20,
                                    ),
                                    color: AdminColors.cardBg,
                                    onSelected: (value) async {
                                      if (value == 'profile') {
                                        _showCustomerProfileDialog(user);
                                      } else if (value == 'block') {
                                        final bool isBlocked =
                                            user['isBlocked'] == true;
                                        final res = await ApiService()
                                            .toggleBlockUser(
                                              user['id'],
                                              isBlocked: !isBlocked,
                                            );
                                        if (mounted && res != null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                !isBlocked
                                                    ? 'User blocked successfully.'
                                                    : 'User unblocked successfully.',
                                              ),
                                              backgroundColor: !isBlocked
                                                  ? Colors.redAccent
                                                  : Colors.green,
                                            ),
                                          );
                                          _loadUsers();
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem<String>(
                                        value: 'profile',
                                        child: Text(
                                          'View Profile & Details',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'block',
                                        child: Text(
                                          user['isBlocked'] == true
                                              ? 'Unblock User'
                                              : 'Block User',
                                          style: TextStyle(
                                            color: user['isBlocked'] == true
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
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
                  ),
                ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: listContent);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: listContent),
      ),
    );
  }

  Widget _buildFilterPill(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AdminColors.primaryYellow : Colors.white24,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Expert KYC / Experts Management Screen (Image 1)
// -----------------------------------------------------------------------------
class ExpertManagementScreen extends StatefulWidget {
  final bool isTabMode;
  const ExpertManagementScreen({super.key, this.isTabMode = false});

  @override
  State<ExpertManagementScreen> createState() => _ExpertManagementScreenState();
}

class _ExpertManagementScreenState extends State<ExpertManagementScreen> {
  String _selectedFilter = 'All Experts';
  List<Map<String, dynamic>> _experts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExperts();
  }

  StreamSubscription? _expertsSub;

  @override
  void dispose() {
    _expertsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadExperts() async {
    setState(() => _isLoading = true);
    _expertsSub?.cancel();

    final List<Map<String, dynamic>> loadedExperts = [];

    bool isSeedExpert(Map<String, dynamic> e) {
      final email = (e['user']?['email'] ?? e['email'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final name = (e['user']?['name'] ?? e['name'] ?? '').toString().trim();
      return email.contains('@connectax.com') ||
          name == 'Priya Sharma' ||
          name == 'Kavya Raman' ||
          name == 'Divya Nair';
    }

    // 1. Primary: Fetch from Firestore & Merge (Real registered experts)
    try {
      final snap = await FirebaseFirestore.instance.collection('experts').get();
      for (final doc in snap.docs) {
        final e = doc.data();
        final isApproved = e['isApproved'] == true;
        final String name =
            (e['name'] != null && e['name'].toString().trim().isNotEmpty)
            ? e['name']
            : (e['user'] != null &&
                  e['user']['name'] != null &&
                  e['user']['name'].toString().trim().isNotEmpty)
            ? e['user']['name']
            : (e['phone'] != null && e['phone'].toString().trim().isNotEmpty)
            ? 'Expert (${e['phone']})'
            : 'Expert';
        loadedExperts.add({
          'id': doc.id,
          'name': name,
          'skill': (e['bio'] != null && e['bio'].toString().isNotEmpty)
              ? e['bio']
              : 'Consultant',
          'rating': (e['rating'] ?? 5.0).toString(),
          'reviews': '0',
          'avatar':
              e['profilePhotoUrl'] ??
              e['avatar'] ??
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
          'verified': isApproved,
          'hasWarning': false,
          'status': isApproved ? 'Approved' : 'Pending',
          'aadhaarNumber': e['aadhaarNumber'],
          'aadhaarDocUrl': e['aadhaarDocUrl'],
          'panNumber': e['panNumber'],
          'panDocUrl': e['panDocUrl'],
          'voiceSampleUrl': e['voiceSampleUrl'],
          'experienceYears': e['experienceYears'],
          'languages': e['languages'],
          'bio': e['bio'],
          'user': e,
        });
      }
    } catch (e) {
      debugPrint('Firestore direct experts load error: $e');
    }

    // 2. Fetch from NestJS Backend API & merge non-seed accounts
    try {
      final apiExperts = await ApiService().getAllExperts();
      if (apiExperts != null && apiExperts.isNotEmpty) {
        for (final e in apiExperts) {
          if (loadedExperts.isNotEmpty && isSeedExpert(e)) {
            continue; // Skip fake seed mockup data when real Firestore experts exist
          }
          final isApproved = e['isApproved'] == true;
          final String name =
              (e['user'] != null &&
                  e['user']['name'] != null &&
                  e['user']['name'].toString().trim().isNotEmpty)
              ? e['user']['name']
              : (e['name'] != null && e['name'].toString().trim().isNotEmpty)
              ? e['name']
              : 'Expert';
          final existingIndex = loadedExperts.indexWhere(
            (item) => item['id'] == e['id'] || item['name'] == name,
          );
          final expMap = {
            'id': e['id']?.toString() ?? 'exp_${loadedExperts.length}',
            'name': name,
            'skill': (e['bio'] != null && e['bio'].toString().isNotEmpty)
                ? e['bio']
                : 'Consultant',
            'rating': (e['rating'] ?? 5.0).toString(),
            'reviews': '0',
            'avatar':
                e['profilePhotoUrl'] ??
                e['user']?['profilePhotoUrl'] ??
                e['avatar'] ??
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
            'verified': isApproved,
            'hasWarning': false,
            'status': isApproved ? 'Approved' : 'Pending',
            'aadhaarNumber': e['aadhaarNumber'],
            'aadhaarDocUrl': e['aadhaarDocUrl'],
            'panNumber': e['panNumber'],
            'panDocUrl': e['panDocUrl'],
            'voiceSampleUrl': e['voiceSampleUrl'],
            'experienceYears': e['experienceYears'],
            'languages': e['languages'],
            'bio': e['bio'],
            'user': e['user'] ?? e,
          };
          if (existingIndex >= 0) {
            loadedExperts[existingIndex] = expMap;
          } else {
            loadedExperts.add(expMap);
          }
        }
      }
    } catch (e) {
      debugPrint('Backend API experts load error: $e');
    }

    if (mounted) {
      setState(() {
        _experts = loadedExperts;
        _isLoading = false;
      });
    }

    _expertsSub = FirebaseFirestore.instance
        .collection('experts')
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final List<Map<String, dynamic>> liveExperts = List.from(
                _experts,
              );
              for (final doc in snapshot.docs) {
                final e = doc.data();
                final isApproved = e['isApproved'] == true;
                final String name =
                    (e['name'] != null &&
                        e['name'].toString().trim().isNotEmpty)
                    ? e['name']
                    : (e['user'] != null &&
                          e['user']['name'] != null &&
                          e['user']['name'].toString().trim().isNotEmpty)
                    ? e['user']['name']
                    : (e['phone'] != null &&
                          e['phone'].toString().trim().isNotEmpty)
                    ? 'Expert (${e['phone']})'
                    : 'Expert';
                final expMap = {
                  'id': doc.id,
                  'name': name,
                  'skill': (e['bio'] != null && e['bio'].toString().isNotEmpty)
                      ? e['bio']
                      : 'Consultant',
                  'rating': (e['rating'] ?? 5.0).toString(),
                  'reviews': '0',
                  'avatar':
                      e['profilePhotoUrl'] ??
                      e['avatar'] ??
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
                  'verified': isApproved,
                  'hasWarning': false,
                  'status': isApproved ? 'Approved' : 'Pending',
                  'aadhaarNumber': e['aadhaarNumber'],
                  'aadhaarDocUrl': e['aadhaarDocUrl'],
                  'panNumber': e['panNumber'],
                  'panDocUrl': e['panDocUrl'],
                  'voiceSampleUrl': e['voiceSampleUrl'],
                  'experienceYears': e['experienceYears'],
                  'languages': e['languages'],
                  'bio': e['bio'],
                  'user': e,
                };
                final existingIndex = liveExperts.indexWhere(
                  (item) => item['id'] == doc.id || item['name'] == name,
                );
                if (existingIndex >= 0) {
                  liveExperts[existingIndex] = expMap;
                } else {
                  liveExperts.add(expMap);
                }
              }
              if (mounted) {
                setState(() {
                  _experts = liveExperts;
                  _isLoading = false;
                });
              }
            }
          },
          onError: (err) {
            debugPrint('Firestore experts snapshot stream error: $err');
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
        );
  }

  void _showKycReviewDialog(Map<String, dynamic> expert) {
    showDialog(
      context: context,
      builder: (context) {
        bool isActionLoading = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final String name = expert['name'] ?? 'Expert Candidate';
            final String email =
                expert['user']?['email'] ?? 'expert@connectax.com';
            final String mobile = expert['user']?['mobileNumber'] ?? 'N/A';
            final String aadhaar =
                (expert['aadhaarNumber'] != null &&
                    expert['aadhaarNumber'].toString().isNotEmpty)
                ? expert['aadhaarNumber']
                : '9842-1234-5678';
            final String pan =
                (expert['panNumber'] != null &&
                    expert['panNumber'].toString().isNotEmpty)
                ? expert['panNumber']
                : 'ABCDE1234F';
            final String aadhaarDoc =
                (expert['aadhaarDocUrl'] != null &&
                    expert['aadhaarDocUrl'].toString().isNotEmpty)
                ? expert['aadhaarDocUrl']
                : 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=600';
            final String panDoc =
                (expert['panDocUrl'] != null &&
                    expert['panDocUrl'].toString().isNotEmpty)
                ? expert['panDocUrl']
                : 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600';
            final String voiceUrl = expert['voiceSampleUrl'] ?? '';
            final String bio =
                (expert['bio'] != null && expert['bio'].toString().isNotEmpty)
                ? expert['bio']
                : 'No bio provided.';
            final String status = expert['status'] ?? 'Pending';
            final List<dynamic> languages = (expert['languages'] is List)
                ? expert['languages']
                : ['English', 'Tamil'];
            final String expYears = '${expert['experienceYears'] ?? 5} Years';

            return Dialog(
              backgroundColor: AdminColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 550),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: AdminColors.primaryYellow,
                                size: 24,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Expert KYC Review',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AdminColors.textMuted,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(color: AdminColors.borderColor, height: 24),

                      // Profile Card Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              expert['avatar'] ?? 'https://i.pravatar.cc/150',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    color: AdminColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  mobile,
                                  style: const TextStyle(
                                    color: AdminColors.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Approved'
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : (status == 'Rejected'
                                        ? Colors.red.withValues(alpha: 0.2)
                                        : AdminColors.primaryYellow.withValues(
                                            alpha: 0.2,
                                          )),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: status == 'Approved'
                                    ? Colors.green
                                    : (status == 'Rejected'
                                          ? Colors.red
                                          : AdminColors.primaryYellow),
                              ),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: status == 'Approved'
                                    ? Colors.greenAccent
                                    : (status == 'Rejected'
                                          ? Colors.redAccent
                                          : AdminColors.primaryYellow),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Section 1: Verification Identity Docs
                      const Text(
                        'VERIFICATION DOCUMENTS',
                        style: TextStyle(
                          color: AdminColors.primaryYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AdminColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AdminColors.borderColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.badge_outlined,
                                      color: AdminColors.textMuted,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Aadhaar Card',
                                      style: TextStyle(
                                        color: AdminColors.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      aadhaar,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _showDocumentPreviewDialog(
                                            'Aadhaar Card Document',
                                            aadhaarDoc,
                                            aadhaar,
                                          ),
                                      icon: const Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 12,
                                        color: AdminColors.primaryYellow,
                                      ),
                                      label: const Text(
                                        'View Doc',
                                        style: TextStyle(
                                          color: AdminColors.primaryYellow,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AdminColors.primaryYellow,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(
                              color: AdminColors.borderColor,
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.credit_card_rounded,
                                      color: AdminColors.textMuted,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'PAN Card',
                                      style: TextStyle(
                                        color: AdminColors.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      pan,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _showDocumentPreviewDialog(
                                            'PAN Card Document',
                                            panDoc,
                                            pan,
                                          ),
                                      icon: const Icon(
                                        Icons.remove_red_eye_outlined,
                                        size: 12,
                                        color: AdminColors.primaryYellow,
                                      ),
                                      label: const Text(
                                        'View Doc',
                                        style: TextStyle(
                                          color: AdminColors.primaryYellow,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: AdminColors.primaryYellow,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(
                              color: AdminColors.borderColor,
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.mic_rounded,
                                      color: AdminColors.textMuted,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Voice Bio Sample',
                                      style: TextStyle(
                                        color: AdminColors.textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Playing voice sample: ${voiceUrl.isNotEmpty ? voiceUrl : "audio_track.mp3"}',
                                        ),
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.play_arrow_rounded,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  label: const Text(
                                    'Play Audio',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AdminColors.primaryYellow,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section 2: Professional Details
                      const Text(
                        'PROFESSIONAL DETAILS',
                        style: TextStyle(
                          color: AdminColors.primaryYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AdminColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AdminColors.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Experience',
                                  style: TextStyle(
                                    color: AdminColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  expYears,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Languages',
                                  style: TextStyle(
                                    color: AdminColors.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  languages.join(', '),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Bio / Summary',
                              style: TextStyle(
                                color: AdminColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              bio,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      if (isActionLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AdminColors.primaryYellow,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  setModalState(() => isActionLoading = true);
                                  final res = await ApiService().approveExpert(
                                    expert['id'],
                                    isApproved: false,
                                  );
                                  if (mounted) {
                                    Navigator.pop(context);
                                    if (res != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Expert application rejected.',
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      _loadExperts();
                                    }
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Reject Application',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  setModalState(() => isActionLoading = true);
                                  final res = await ApiService().approveExpert(
                                    expert['id'],
                                    isApproved: true,
                                  );
                                  if (mounted) {
                                    Navigator.pop(context);
                                    if (res != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Expert approved & verified successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      _loadExperts();
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Approve Expert',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDocumentPreviewDialog(
    String title,
    String imageUrl,
    String docNumber,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AdminColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: AdminColors.primaryYellow,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AdminColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Doc No: $docNumber',
                style: const TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(color: AdminColors.borderColor, height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 220,
                    color: AdminColors.background,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_drive_file_outlined,
                            color: AdminColors.textMuted,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Uploaded Document File Preview',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!widget.isTabMode)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 40),
            const Text(
              'Experts Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: AdminColors.primaryYellow,
              ),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: AdminColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminColors.borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const TextField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: AdminColors.textMuted),
              hintText: 'Search experts...',
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Filter Pills Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterPill('All Experts'),
              const SizedBox(width: 8),
              _buildFilterPill('Approved'),
              const SizedBox(width: 8),
              _buildFilterPill('Pending'),
              const SizedBox(width: 8),
              _buildFilterPill('Rejected'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Experts List
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AdminColors.primaryYellow,
                  ),
                )
              : _experts.isEmpty
              ? RefreshIndicator(
                  color: AdminColors.primaryYellow,
                  backgroundColor: AdminColors.cardBg,
                  onRefresh: _loadExperts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.workspace_premium_outlined,
                              color: AdminColors.textMuted,
                              size: 54,
                            ),
                            SizedBox(height: 14),
                            Text(
                              'No Live Experts Found',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Live database currently has 0 registered experts.',
                              style: TextStyle(
                                color: AdminColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AdminColors.primaryYellow,
                  backgroundColor: AdminColors.cardBg,
                  onRefresh: _loadExperts,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _experts.length,
                    itemBuilder: (context, index) {
                      final expert = _experts[index];

                      // Filter match
                      if (_selectedFilter != 'All Experts' &&
                          expert['status'] != _selectedFilter) {
                        return const SizedBox.shrink();
                      }

                      // Color mapping for status tags
                      Color tagColor = Colors.white70;
                      if (expert['status'] == 'Approved') {
                        tagColor = Colors.greenAccent.shade400;
                      } else if (expert['status'] == 'Pending') {
                        tagColor = AdminColors.primaryYellow;
                      } else if (expert['status'] == 'Rejected') {
                        tagColor = Colors.redAccent;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AdminColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AdminColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            // Avatar with badge indicator
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundImage: NetworkImage(
                                    expert['avatar'],
                                  ),
                                ),
                                if (expert['verified'] == true)
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 8,
                                    ),
                                  )
                                else if (expert['hasWarning'] == true)
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AdminColors.primaryYellow,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.bolt,
                                      color: Colors.black,
                                      size: 8,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 14),

                            // Skill/Review Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        expert['name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (expert['verified'] == true) ...[
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                          size: 14,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    expert['skill'],
                                    style: const TextStyle(
                                      color: AdminColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: AdminColors.primaryYellow,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${expert['rating']} ',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '(${expert['reviews']})',
                                        style: const TextStyle(
                                          color: AdminColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Status and action dots
                            Row(
                              children: [
                                Text(
                                  expert['status'] == 'Rejected'
                                      ? '• Rejected'
                                      : expert['status'],
                                  style: TextStyle(
                                    color: tagColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: AdminColors.textMuted,
                                    size: 20,
                                  ),
                                  color: AdminColors.cardBg,
                                  onSelected: (value) async {
                                    if (value == 'review' ||
                                        value == 'details' ||
                                        value == 'approve') {
                                      _showKycReviewDialog(expert);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    const PopupMenuItem<String>(
                                      value: 'review',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.verified_user,
                                            color: AdminColors.primaryYellow,
                                            size: 16,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Review KYC & Verify',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'details',
                                      child: Text(
                                        'View Details',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: listContent);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: listContent),
      ),
    );
  }

  Widget _buildFilterPill(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AdminColors.primaryYellow : Colors.white24,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Transactions Screen (Image 2)
// -----------------------------------------------------------------------------
class TransactionsScreen extends StatefulWidget {
  final bool isTabMode;
  const TransactionsScreen({super.key, this.isTabMode = false});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _transactions = [
    {
      'type': 'Recharge',
      'party': 'By Kathiresan',
      'time': 'Today, 09:30 AM',
      'amount': '+ ₹500.00',
      'isPositive': true,
      'status': 'Success',
    },
    {
      'type': 'Earnings',
      'party': 'By John Doe',
      'time': 'Today, 08:45 AM',
      'amount': '+ ₹1,250.00',
      'isPositive': true,
      'status': 'Success',
    },
    {
      'type': 'Withdrawal',
      'party': 'To Ancy Joseph',
      'time': 'Today, 07:20 AM',
      'amount': '- ₹800.00',
      'isPositive': false,
      'status': 'Proceeding',
    },
    {
      'type': 'Recharge',
      'party': 'By Priya Sharma',
      'time': 'Yesterday, 10:15 PM',
      'amount': '+ ₹300.00',
      'isPositive': true,
      'status': 'Success',
    },
    {
      'type': 'Withdrawal',
      'party': 'To Rahul Sharma',
      'time': 'Yesterday, 06:30 PM',
      'amount': '- ₹1,000.00',
      'isPositive': false,
      'status': 'Success',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!widget.isTabMode)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 40),
            const Text(
              'Transactions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 20),

        // Filter Pills Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterPill('All'),
              const SizedBox(width: 8),
              _buildFilterPill('Recharge'),
              const SizedBox(width: 8),
              _buildFilterPill('Earnings'),
              const SizedBox(width: 8),
              _buildFilterPill('Withdrawals'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFC107), Color(0xFFFFB800)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Transactions',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '₹ 15,78,320',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '↑ 13.6% vs last month',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Stacks of Gold Coins Graphic
              SizedBox(
                width: 80,
                height: 70,
                child: CustomPaint(painter: GoldCoinsPainter()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Transactions List
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _transactions.length,
            itemBuilder: (context, index) {
              final tx = _transactions[index];

              // Filter match
              if (_selectedFilter != 'All') {
                if (_selectedFilter == 'Withdrawals' &&
                    tx['type'] != 'Withdrawal') {
                  return const SizedBox.shrink();
                }
                if (_selectedFilter != 'Withdrawals' &&
                    tx['type'] != _selectedFilter) {
                  return const SizedBox.shrink();
                }
              }

              // Define leading avatar and colors
              IconData leadIcon = Icons.arrow_downward;
              Color iconBg = Colors.amber.withValues(alpha: 0.12);
              Color iconColor = AdminColors.primaryYellow;

              if (tx['type'] == 'Recharge') {
                leadIcon = Icons.account_balance_wallet_outlined;
                iconBg = Colors.amber.withValues(alpha: 0.12);
                iconColor = AdminColors.primaryYellow;
              } else if (tx['type'] == 'Earnings') {
                leadIcon = Icons.phone_in_talk_outlined;
                iconBg = Colors.green.withValues(alpha: 0.12);
                iconColor = Colors.greenAccent;
              } else if (tx['type'] == 'Withdrawal') {
                leadIcon = Icons.outbox_rounded;
                iconBg = Colors.purple.withValues(alpha: 0.12);
                iconColor = Colors.purpleAccent;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AdminColors.borderColor),
                ),
                child: Row(
                  children: [
                    // Avatar icon block
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: iconBg,
                      child: Icon(leadIcon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),

                    // Party / details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx['type'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tx['party'],
                            style: const TextStyle(
                              color: AdminColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            tx['time'],
                            style: const TextStyle(
                              color: AdminColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Amount & status pill
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text(
                              tx['amount'],
                              style: TextStyle(
                                color: tx['isPositive']
                                    ? Colors.greenAccent.shade400
                                    : Colors.redAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              tx['isPositive']
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: tx['isPositive']
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                              size: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: tx['status'] == 'Success'
                                  ? Colors.greenAccent
                                  : AdminColors.primaryYellow,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tx['status'],
                              style: TextStyle(
                                color: tx['status'] == 'Success'
                                    ? Colors.greenAccent
                                    : AdminColors.primaryYellow,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: listContent);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: listContent),
      ),
    );
  }

  Widget _buildFilterPill(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AdminColors.primaryYellow : Colors.white24,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// Painter to draw cylinders representing gold coins (Image 2)
class GoldCoinsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Helper to draw a single coin cylinder
    void drawCoin(double cx, double cy, double rx, double ry, double height) {
      // Bottom ellipse base
      final path = Path();
      path.moveTo(cx - rx, cy);
      path.lineTo(cx - rx, cy + height);
      path.arcToPoint(
        Offset(cx + rx, cy + height),
        radius: Radius.elliptical(rx, ry),
        rotation: 0,
        largeArc: false,
        clockwise: false,
      );
      path.lineTo(cx + rx, cy);
      path.arcToPoint(
        Offset(cx - rx, cy),
        radius: Radius.elliptical(rx, ry),
        rotation: 0,
        largeArc: false,
        clockwise: true,
      );
      path.close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, borderPaint);

      // Top ellipse cap
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        borderPaint,
      );
    }

    // Stack 1 (Right stack, tall)
    drawCoin(55, 36, 18, 7, 8);
    drawCoin(55, 28, 18, 7, 8);
    drawCoin(55, 20, 18, 7, 8);

    // Stack 2 (Left stack, short)
    drawCoin(25, 48, 18, 7, 8);
    drawCoin(25, 40, 18, 7, 8);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Analytics Screen (Image 3)
// -----------------------------------------------------------------------------
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Analytics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 24),

              // Date Dropdown Selector
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AdminColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AdminColors.borderColor),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: AdminColors.primaryYellow,
                        size: 16,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'May 21 - May 27, 2024',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AdminColors.textMuted,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Revenue Overview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AdminColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Revenue Overview',
                          style: TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            '▲ 12.5%',
                            style: TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '₹ 2,45,780',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Line chart with grid
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: CustomPaint(painter: AnalyticsChartPainter()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Top Categories Card (Donut chart & Legend details)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AdminColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Categories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        // Left side Donut custom painted chart
                        SizedBox(
                          width: 110,
                          height: 110,
                          child: CustomPaint(painter: CategoriesPiePainter()),
                        ),
                        const SizedBox(width: 28),

                        // Right side legends details list
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LegendRow(
                                color: AdminColors.primaryYellow,
                                label: 'Relationship',
                                percentage: '38%',
                              ),
                              LegendRow(
                                color: Colors.blueAccent,
                                label: 'Career',
                                percentage: '24%',
                              ),
                              LegendRow(
                                color: Colors.amber,
                                label: 'Life Coach',
                                percentage: '18%',
                              ),
                              LegendRow(
                                color: Colors.tealAccent,
                                label: 'Motivation',
                                percentage: '12%',
                              ),
                              LegendRow(
                                color: Colors.lightGreenAccent,
                                label: 'Business',
                                percentage: '8%',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// Legend row widget
class LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String percentage;

  const LegendRow({
    super.key,
    required this.color,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            percentage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Detailed Custom Line Graph Painter with Grids and Coordinates (Image 3)
class AnalyticsChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AdminColors.primaryYellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final dotPaint = Paint()
      ..color = AdminColors.primaryYellow
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final gridPaint = Paint()
      ..color = Colors.white10
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // 1. Draw horizontal grid lines and Y-axis labels
    final List<double> yPositions = [0.15, 0.40, 0.65, 0.90];
    final List<String> yLabels = ['150K', '100K', '50K', '0'];

    double chartLeftPadding = 32.0;
    double chartBottomPadding = 20.0;
    double graphWidth = size.width - chartLeftPadding;
    double graphHeight = size.height - chartBottomPadding;

    for (int i = 0; i < yPositions.length; i++) {
      double y = graphHeight * yPositions[i];
      // Draw grid line
      canvas.drawLine(
        Offset(chartLeftPadding, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Draw label text
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(color: AdminColors.textMuted, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    // 2. Define coordinate values
    final List<double> xRatios = [0.0, 0.16, 0.33, 0.50, 0.66, 0.83, 1.0];
    final List<double> yRatios = [
      0.70,
      0.60,
      0.67,
      0.45,
      0.75,
      0.60,
      0.30,
    ]; // inverted y (0.0 is top)
    final List<String> xLabels = ['21', '22', '23', '24', '25', '26', '27'];

    final path = Path();
    final List<Offset> points = [];

    for (int i = 0; i < xRatios.length; i++) {
      double px = chartLeftPadding + (graphWidth * xRatios[i]);
      double py = graphHeight * yRatios[i];
      points.add(Offset(px, py));

      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }

      // Draw X labels
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(color: AdminColors.textMuted, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(px - 4, graphHeight + 6));
    }

    // 3. Draw gradient fill under curve path
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, graphHeight);
    fillPath.lineTo(points.first.dx, graphHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader =
          LinearGradient(
            colors: [
              AdminColors.primaryYellow.withValues(alpha: 0.18),
              AdminColors.primaryYellow.withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromLTRB(chartLeftPadding, 0, size.width, graphHeight),
          )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 4. Draw curve line
    canvas.drawPath(path, linePaint);

    // 5. Draw data points circles
    for (var pt in points) {
      canvas.drawCircle(pt, 4.5, dotPaint);
      canvas.drawCircle(pt, 4.5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Donut Pie chart custom painter (Image 3)
class CategoriesPiePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width * 0.5;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final strokeWidth = size.width * 0.22;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Segment values and colors
    final List<double> percentages = [0.38, 0.24, 0.18, 0.12, 0.08];
    final List<Color> colors = [
      AdminColors.primaryYellow,
      Colors.blueAccent,
      Colors.amber,
      Colors.tealAccent,
      Colors.lightGreenAccent,
    ];

    double startAngle = -1.57; // start at top (12 o'clock)

    for (int i = 0; i < percentages.length; i++) {
      paint.color = colors[i];
      double sweepAngle = percentages[i] * 6.28;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Inside hollow center gap
    final hollowPaint = Paint()
      ..color = AdminColors.cardBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - strokeWidth * 0.5, hollowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Settings / Reports Screen (Image 4)
// -----------------------------------------------------------------------------
class ReportsScreen extends StatelessWidget {
  final bool isTabMode;
  const ReportsScreen({super.key, this.isTabMode = false});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> reportOptions = [
      {
        'title': 'Earnings Report',
        'subtitle': 'View earnings analytics',
        'icon': Icons.trending_up,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
          );
        },
      },
      {
        'title': 'User Report',
        'subtitle': 'View user statistics',
        'icon': Icons.person_outline_rounded,
        'action': () {},
      },
      {
        'title': 'Expert Report',
        'subtitle': 'View expert performance',
        'icon': Icons.workspace_premium_outlined,
        'action': () {},
      },
      {
        'title': 'Call Report',
        'subtitle': 'View call analytics',
        'icon': Icons.phone_in_talk_outlined,
        'action': () {},
      },
      {
        'title': 'Transaction Report',
        'subtitle': 'View all transactions',
        'icon': Icons.account_balance_wallet_outlined,
        'action': () {},
      },
      {
        'title': 'Withdrawal Report',
        'subtitle': 'View withdrawal history',
        'icon': Icons.receipt_long_outlined,
        'action': () {},
      },
    ];

    final listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!isTabMode)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 40),
            const Text(
              'Reports',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 24),

        // Reports list options
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: reportOptions.length,
            itemBuilder: (context, index) {
              final opt = reportOptions[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AdminColors.borderColor),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AdminColors.borderColor,
                    child: Icon(
                      opt['icon'],
                      color: AdminColors.primaryYellow,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    opt['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    opt['subtitle'],
                    style: const TextStyle(
                      color: AdminColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AdminColors.textMuted,
                    size: 14,
                  ),
                  onTap: opt['action'],
                ),
              );
            },
          ),
        ),
      ],
    );

    if (isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: listContent);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: listContent),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Settings Screen (Image 1)
// -----------------------------------------------------------------------------
class SettingsScreen extends StatefulWidget {
  final bool isTabMode;
  const SettingsScreen({super.key, this.isTabMode = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _commissionController = TextEditingController(
    text: '20',
  );
  final TextEditingController _audioRateController = TextEditingController(
    text: '5.0',
  );
  final TextEditingController _videoRateController = TextEditingController(
    text: '8.0',
  );
  final TextEditingController _chatRateController = TextEditingController(
    text: '2.0',
  );
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final settings = await _apiService.getSettings();
    if (settings != null && mounted) {
      setState(() {
        _commissionController.text = (settings['commissionPercentage'] ?? 20)
            .toString();
        _audioRateController.text =
            (settings['audioCallRate'] ?? settings['defaultCallRate'] ?? 5.0)
                .toString();
        _videoRateController.text = (settings['videoCallRate'] ?? 8.0)
            .toString();
        _chatRateController.text = (settings['chatMessageRate'] ?? 2.0)
            .toString();
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    final comm = double.tryParse(_commissionController.text.trim()) ?? 20.0;
    final audio = double.tryParse(_audioRateController.text.trim()) ?? 5.0;
    final video = double.tryParse(_videoRateController.text.trim()) ?? 8.0;
    final chat = double.tryParse(_chatRateController.text.trim()) ?? 2.0;

    setState(() => _isSaving = true);
    final res = await _apiService.updateSettings(
      commissionPercentage: comm,
      audioCallRate: audio,
      videoCallRate: video,
      chatMessageRate: chat,
    );
    if (mounted) {
      setState(() => _isSaving = false);
      if (res != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Settings Saved! Audio: ₹${audio.toStringAsFixed(0)}/m, Video: ₹${video.toStringAsFixed(0)}/m, Chat: ₹${chat.toStringAsFixed(0)}/msg',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save settings')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> generalSettings = [
      {'title': 'App Settings', 'icon': Icons.settings_suggest_rounded},
      {'title': 'Payment Settings', 'icon': Icons.payment_rounded},
      {
        'title': 'Notification Settings',
        'icon': Icons.notifications_none_rounded,
      },
      {'title': 'Security Settings', 'icon': Icons.security_rounded},
    ];

    final List<Map<String, dynamic>> supportSettings = [
      {'title': 'Help & Support', 'icon': Icons.help_outline_rounded},
      {'title': 'Privacy Policy', 'icon': Icons.lock_outline_rounded},
      {'title': 'Terms & Conditions', 'icon': Icons.description_outlined},
      {'title': 'About ConnectaX', 'icon': Icons.info_outline_rounded},
    ];

    final listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!widget.isTabMode)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 40),
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 20),

        // Admin Mini Profile Card
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AdminColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AdminColors.borderColor),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'admin@connectax.com',
                        style: TextStyle(
                          color: AdminColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AdminColors.primaryYellow,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // List Content
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // Platform Commission & Pricing Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AdminColors.primaryYellow.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AdminColors.primaryYellow.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.percent_rounded,
                          color: AdminColors.primaryYellow,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Platform Commission & Service Rates',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Row 1: Commission & Audio Rate
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Admin Commission %',
                                style: TextStyle(
                                  color: AdminColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _commissionController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AdminColors.background,
                                  suffixText: '%',
                                  suffixStyle: const TextStyle(
                                    color: AdminColors.primaryYellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.borderColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.borderColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.primaryYellow,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Audio Call Rate (₹/min)',
                                style: TextStyle(
                                  color: AdminColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _audioRateController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AdminColors.background,
                                  prefixText: '₹ ',
                                  prefixStyle: const TextStyle(
                                    color: AdminColors.primaryYellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.borderColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.borderColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.primaryYellow,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Row 2: Video Rate & Chat Rate
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Video Call Rate (₹/min)',
                                style: TextStyle(
                                  color: AdminColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _videoRateController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AdminColors.background,
                                  prefixText: '₹ ',
                                  prefixStyle: const TextStyle(
                                    color: AdminColors.primaryYellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.borderColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.borderColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.primaryYellow,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chat Rate (₹/msg)',
                                style: TextStyle(
                                  color: AdminColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _chatRateController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: AdminColors.background,
                                  prefixText: '₹ ',
                                  prefixStyle: const TextStyle(
                                    color: AdminColors.primaryYellow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.borderColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.borderColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AdminColors.primaryYellow,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.primaryYellow,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Text(
                                'Save Platform Settings',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // General Settings
              const Text(
                'General Settings',
                style: TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...generalSettings.map(
                (item) => _buildSettingsTile(context, item),
              ),
              const SizedBox(height: 24),

              // Support & Others
              const Text(
                'Support & Others',
                style: TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...supportSettings.map(
                (item) => _buildSettingsTile(context, item),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: listContent);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: listContent),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AdminColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.borderColor),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(item['icon'], color: AdminColors.primaryYellow, size: 20),
        title: Text(
          item['title'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AdminColors.textMuted,
          size: 14,
        ),
        onTap: () {
          if (item['title'] == 'App Settings') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            );
          }
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Admin Profile Screen (Image 2)
// -----------------------------------------------------------------------------
class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Admin Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AdminColors.primaryYellow,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Avatar with camera icon overlay
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AdminColors.primaryYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 56,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AdminColors.primaryYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Admin Header Info
              const Text(
                'Admin User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'admin@connectax.com',
                style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 28),

              // Profile Info Card
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Profile Information',
                  style: TextStyle(
                    color: AdminColors.primaryYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AdminColors.borderColor),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Full Name', 'Admin User'),
                    const Divider(color: AdminColors.borderColor, height: 24),
                    _buildInfoRow('Phone Number', '+91 98765 43210'),
                    const Divider(color: AdminColors.borderColor, height: 24),
                    _buildInfoRow('Admin ID', 'ADM-1001'),
                    const Divider(color: AdminColors.borderColor, height: 24),
                    _buildInfoRow('Role', 'Super Admin'),
                    const Divider(color: AdminColors.borderColor, height: 24),
                    _buildInfoRow('Joined On', '01 Jan 2024, 10:30 AM'),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Reset stack to admin login screen
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.power_settings_new_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AdminColors.textMuted, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Payout Requests Screen (Expert Payout & Withdrawal Approvals)
// -----------------------------------------------------------------------------
class PayoutRequestsScreen extends StatefulWidget {
  final bool isTabMode;
  const PayoutRequestsScreen({super.key, this.isTabMode = false});

  @override
  State<PayoutRequestsScreen> createState() => _PayoutRequestsScreenState();
}

class _PayoutRequestsScreenState extends State<PayoutRequestsScreen> {
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _payouts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPayouts();
  }

  Future<void> _loadPayouts() async {
    setState(() => _isLoading = true);
    final list = await ApiService().getPayoutRequests();
    if (list != null && list.isNotEmpty) {
      final List<Map<String, dynamic>> livePayouts = [];
      for (final p in list) {
        livePayouts.add({
          'id': p['id'],
          'expertName': p['user']?['name'] ?? 'Expert Candidate',
          'email': p['user']?['email'] ?? 'N/A',
          'avatar':
              p['user']?['profilePhotoUrl'] ??
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
          'amount': '₹ ${p['amount'] ?? '0.00'}',
          'rawAmount': double.tryParse(p['amount']?.toString() ?? '0') ?? 0.0,
          'payoutMethod': p['payoutMethod'] ?? 'UPI',
          'accountDetails': p['accountDetails'] ?? 'rajesh@okicici',
          'status': p['status'] ?? 'PENDING',
          'rejectionReason': p['rejectionReason'] ?? '',
          'transactionReference': p['transactionReference'] ?? '',
          'date': p['createdAt'] != null
              ? p['createdAt'].toString().split('T').first
              : 'Today',
        });
      }
      if (mounted) {
        setState(() {
          _payouts = livePayouts;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _payouts = [
            {
              'id': 'mock-payout-1',
              'expertName': 'Expert Rajesh',
              'email': 'expert@connectax.com',
              'avatar':
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
              'amount': '₹ 1,500.00',
              'rawAmount': 1500.0,
              'payoutMethod': 'UPI',
              'accountDetails': 'rajesh@okicici',
              'status': 'PENDING',
              'rejectionReason': '',
              'transactionReference': '',
              'date': 'Today, 02:30 PM',
            },
            {
              'id': 'mock-payout-2',
              'expertName': 'Priya Ramesh',
              'email': 'priya@email.com',
              'avatar':
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
              'amount': '₹ 2,800.00',
              'rawAmount': 2800.0,
              'payoutMethod': 'Bank Transfer',
              'accountDetails': 'A/C: 987654321012, IFSC: SBIN0001234',
              'status': 'PAID',
              'rejectionReason': '',
              'transactionReference': 'UPI-PAY-984210',
              'date': 'Yesterday',
            },
          ];
          _isLoading = false;
        });
      }
    }
  }

  void _showApproveDialog(Map<String, dynamic> payout) {
    final TextEditingController refController = TextEditingController(
      text:
          'UPI-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
            SizedBox(width: 10),
            Text(
              'Approve & Pay Out',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expert: ${payout['expertName']}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount: ${payout['amount']}',
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Method: ${payout['payoutMethod']} (${payout['accountDetails']})',
              style: const TextStyle(
                color: AdminColors.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Transaction Reference / UTR No:',
              style: TextStyle(color: AdminColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: refController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AdminColors.background,
                hintText: 'Enter UPI / Bank Reference ID',
                hintStyle: const TextStyle(color: Colors.white24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AdminColors.borderColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AdminColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await ApiService().approvePayoutRequest(
                payout['id'],
                transactionReference: refController.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payout Marked as PAID successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadPayouts();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Confirm & Mark PAID',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> payout) {
    final TextEditingController reasonController = TextEditingController(
      text: 'Account details mismatch',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 24),
            SizedBox(width: 10),
            Text(
              'Reject Payout Request',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expert: ${payout['expertName']}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Amount: ${payout['amount']}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reason for Rejection:',
              style: TextStyle(color: AdminColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: reasonController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AdminColors.background,
                hintText: 'Enter reason (e.g. Invalid UPI ID / IFSC mismatch)',
                hintStyle: const TextStyle(color: Colors.white24),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AdminColors.borderColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AdminColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final res = await ApiService().rejectPayoutRequest(
                payout['id'],
                rejectionReason: reasonController.text.trim(),
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payout request rejected.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                _loadPayouts();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Reject Payout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!widget.isTabMode)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 40),
            const Text(
              'Expert Payout Requests',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: AdminColors.primaryYellow,
              ),
              onPressed: _loadPayouts,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Filter Pills Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterPill('All'),
              const SizedBox(width: 8),
              _buildFilterPill('PENDING'),
              const SizedBox(width: 8),
              _buildFilterPill('PAID'),
              const SizedBox(width: 8),
              _buildFilterPill('REJECTED'),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Payout List
        Expanded(
          child: _isLoading && _payouts.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AdminColors.primaryYellow,
                  ),
                )
              : RefreshIndicator(
                  color: AdminColors.primaryYellow,
                  backgroundColor: AdminColors.cardBg,
                  onRefresh: _loadPayouts,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _payouts.length,
                    itemBuilder: (context, index) {
                      final payout = _payouts[index];

                      // Filter match
                      if (_selectedFilter != 'All' &&
                          payout['status'] != _selectedFilter) {
                        return const SizedBox.shrink();
                      }

                      final String status = payout['status'] ?? 'PENDING';
                      Color statusBg = AdminColors.primaryYellow.withValues(
                        alpha: 0.15,
                      );
                      Color statusColor = AdminColors.primaryYellow;
                      if (status == 'PAID') {
                        statusBg = Colors.green.withValues(alpha: 0.15);
                        statusColor = Colors.greenAccent;
                      } else if (status == 'REJECTED') {
                        statusBg = Colors.red.withValues(alpha: 0.15);
                        statusColor = Colors.redAccent;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AdminColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AdminColors.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Expert Avatar, Name & Status
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundImage: NetworkImage(
                                    payout['avatar'],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        payout['expertName'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        payout['email'],
                                        style: const TextStyle(
                                          color: AdminColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: AdminColors.borderColor,
                              height: 24,
                            ),

                            // Payout Details Box
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Amount Requested',
                                      style: TextStyle(
                                        color: AdminColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      payout['amount'],
                                      style: const TextStyle(
                                        color: Colors.greenAccent,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Method: ${payout['payoutMethod']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      payout['accountDetails'],
                                      style: const TextStyle(
                                        color: AdminColors.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            if (status == 'PAID' &&
                                payout['transactionReference']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Ref ID: ${payout['transactionReference']}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                            ],

                            if (status == 'REJECTED' &&
                                payout['rejectionReason']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Reason: ${payout['rejectionReason']}',
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 11,
                                ),
                              ),
                            ],

                            // Action Buttons (For Pending Payouts)
                            if (status == 'PENDING') ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _showRejectDialog(payout),
                                      icon: const Icon(
                                        Icons.cancel_outlined,
                                        size: 16,
                                        color: Colors.redAccent,
                                      ),
                                      label: const Text(
                                        'Reject Payout',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.redAccent,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _showApproveDialog(payout),
                                      icon: const Icon(
                                        Icons.check_circle_outline,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Approve & Pay',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: listContent);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: listContent),
      ),
    );
  }

  Widget _buildFilterPill(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AdminColors.primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AdminColors.primaryYellow : Colors.white24,
          ),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Banner & Promotion Management Screen (Growth & Marketing Banners)
// -----------------------------------------------------------------------------
class BannerManagementScreen extends StatefulWidget {
  final bool isTabMode;
  const BannerManagementScreen({super.key, this.isTabMode = false});

  @override
  State<BannerManagementScreen> createState() => _BannerManagementScreenState();
}

class _BannerManagementScreenState extends State<BannerManagementScreen> {
  List<Map<String, dynamic>> _banners = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    setState(() => _isLoading = true);
    final list = await ApiService().getBanners();
    if (list != null && list.isNotEmpty) {
      final List<Map<String, dynamic>> liveBanners = [];
      for (final b in list) {
        liveBanners.add({
          'id': b['id'],
          'title': b['title'] ?? 'Promotional Offer',
          'imageUrl':
              b['imageUrl'] ??
              'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600',
          'redirectUrl': b['redirectUrl'] ?? '/recharge',
          'isActive': b['isActive'] == true,
        });
      }
      if (mounted) {
        setState(() {
          _banners = liveBanners;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _banners = [
            {
              'id': 'mock-banner-1',
              'title': 'Recharge ₹100 & Get ₹20 Cashback Bonus!',
              'imageUrl':
                  'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600',
              'redirectUrl': '/recharge',
              'isActive': true,
            },
            {
              'id': 'mock-banner-2',
              'title': 'Talk to Top Legal & Tech Experts at 50% Off!',
              'imageUrl':
                  'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=600',
              'redirectUrl': '/expert-list',
              'isActive': true,
            },
          ];
          _isLoading = false;
        });
      }
    }
  }

  void _showAddBannerDialog() {
    final titleController = TextEditingController(
      text: 'Recharge ₹200 & Get 15 Min Free Audio Call!',
    );
    final imageController = TextEditingController(
      text:
          'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600',
    );
    String selectedTarget = '/recharge';
    bool isActive = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: AdminColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.add_photo_alternate_rounded,
                color: AdminColors.primaryYellow,
                size: 24,
              ),
              SizedBox(width: 10),
              Text(
                'Create Offer Banner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Offer Title:',
                  style: TextStyle(color: AdminColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AdminColors.background,
                    hintText: 'Enter title (e.g. Recharge Offer)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminColors.borderColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Banner Image URL:',
                  style: TextStyle(color: AdminColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: imageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AdminColors.background,
                    hintText: 'https://...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminColors.borderColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Banner Click Target (Enga Open Aganum?):',
                  style: TextStyle(color: AdminColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedTarget,
                  dropdownColor: AdminColors.cardBg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AdminColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminColors.borderColor,
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: '/recharge',
                      child: Text('💳 Recharge Screen (Wallet Top-up)'),
                    ),
                    DropdownMenuItem(
                      value: '/expert-list',
                      child: Text('👥 Experts List Screen'),
                    ),
                    DropdownMenuItem(
                      value: '/profile',
                      child: Text('👤 User Profile Screen'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => selectedTarget = val);
                    }
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active Immediately',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: isActive,
                      activeThumbColor: AdminColors.primaryYellow,
                      onChanged: (val) => setModalState(() => isActive = val),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AdminColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final res = await ApiService().createBanner(
                  title: titleController.text.trim(),
                  imageUrl: imageController.text.trim(),
                  redirectUrl: selectedTarget,
                  isActive: isActive,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Banner Created Successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadBanners();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryYellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Publish Banner',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!widget.isTabMode)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            else
              const SizedBox(width: 40),
            const Text(
              'Banners & Offer Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: AdminColors.primaryYellow,
              ),
              onPressed: _loadBanners,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Add Banner Action Card
        GestureDetector(
          onTap: _showAddBannerDialog,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AdminColors.primaryYellow.withValues(alpha: 0.2),
                  AdminColors.cardBg,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AdminColors.primaryYellow),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_rounded,
                  color: AdminColors.primaryYellow,
                  size: 24,
                ),
                SizedBox(width: 10),
                Text(
                  'Create New Offer Banner 📢',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Banner List
        Expanded(
          child: _isLoading && _banners.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AdminColors.primaryYellow,
                  ),
                )
              : RefreshIndicator(
                  color: AdminColors.primaryYellow,
                  backgroundColor: AdminColors.cardBg,
                  onRefresh: _loadBanners,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      final banner = _banners[index];
                      final bool isActive = banner['isActive'] == true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AdminColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AdminColors.borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Banner Image Preview
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                              child: Image.network(
                                banner['imageUrl'],
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
                                  height: 130,
                                  color: Colors.grey.shade900,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white38,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          banner['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Switch(
                                        value: isActive,
                                        activeThumbColor: Colors.greenAccent,
                                        onChanged: (val) async {
                                          final res = await ApiService()
                                              .toggleBannerStatus(
                                                banner['id'],
                                                isActive: val,
                                              );
                                          if (mounted) {
                                            _loadBanners();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Target Route: ${banner['redirectUrl']}',
                                        style: const TextStyle(
                                          color: AdminColors.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                        onPressed: () async {
                                          final ok = await ApiService()
                                              .deleteBanner(banner['id']);
                                          if (mounted && ok) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('Banner Deleted'),
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                            );
                                            _loadBanners();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: listContent);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: listContent),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB: Live Active Calls & Call Logs Monitor Screen (📞)
// ---------------------------------------------------------------------------
class CallMonitorScreen extends StatefulWidget {
  final bool isTabMode;
  const CallMonitorScreen({super.key, this.isTabMode = false});

  @override
  State<CallMonitorScreen> createState() => _CallMonitorScreenState();
}

class _CallMonitorScreenState extends State<CallMonitorScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _liveCalls = [];
  List<Map<String, dynamic>> _allCallHistory = [];
  String _searchQuery = '';
  String _selectedStatusFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _fetchCallData();
  }

  Future<void> _fetchCallData() async {
    setState(() => _isLoading = true);
    final live = await _apiService.getLiveCalls();
    final history = await _apiService.getAllCallHistory();
    if (mounted) {
      setState(() {
        _liveCalls =
            live ??
            [
              {
                'id': 'call-mock-1',
                'customer': {'name': 'Ramesh Kumar', 'phone': '+91 9876543210'},
                'expert': {
                  'user': {'name': 'Dr. Ananya Sharma'},
                },
                'durationSeconds': 285,
                'amountCharged': 47.50,
                'expertEarning': 38.00,
                'status': 'ongoing',
                'createdAt': DateTime.now()
                    .subtract(const Duration(minutes: 4, seconds: 45))
                    .toIso8601String(),
              },
            ];
        _allCallHistory =
            history ??
            [
              {
                'id': 'call-hist-1',
                'customer': {'name': 'Ramesh Kumar', 'phone': '+91 9876543210'},
                'expert': {
                  'user': {'name': 'Dr. Ananya Sharma'},
                },
                'durationSeconds': 420,
                'amountCharged': 70.00,
                'expertEarning': 56.00,
                'adminCommission': 14.00,
                'status': 'completed',
                'createdAt': DateTime.now()
                    .subtract(const Duration(hours: 2))
                    .toIso8601String(),
              },
              {
                'id': 'call-hist-2',
                'customer': {'name': 'Priya Sundar', 'phone': '+91 9123456789'},
                'expert': {
                  'user': {'name': 'Karthik Raja'},
                },
                'durationSeconds': 180,
                'amountCharged': 30.00,
                'expertEarning': 24.00,
                'adminCommission': 6.00,
                'status': 'completed',
                'createdAt': DateTime.now()
                    .subtract(const Duration(days: 1))
                    .toIso8601String(),
              },
            ];
        _isLoading = false;
      });
    }
  }

  Future<void> _forceEndCall(String callId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AdminColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Force Disconnect Call?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to terminate this ongoing call for dispute resolution?',
          style: TextStyle(color: AdminColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AdminColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Disconnect Call ⏹️',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _apiService.forceEndCall(callId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Call terminated successfully.' : 'Call ended.',
            ),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
        _fetchCallData();
      }
    }
  }

  void _showListenLiveModal(Map<String, dynamic> call) {
    final customerName = call['customer']?['name'] ?? 'Customer';
    final expertName = call['expert']?['user']?['name'] ?? 'Expert';
    final channelName = call['channelName'] ?? 'live_channel';
    double volume = 0.8;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: AdminColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  color: Colors.greenAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Audio Monitoring 🎧',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Silent Admin Listener Mode',
                      style: TextStyle(
                        color: AdminColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.greenAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$customerName ↔ $expertName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Channel: $channelName',
                      style: const TextStyle(
                        color: AdminColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Animated Live Audio Visualizer Wave
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        12,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 4,
                          height: (12 + ((index % 5) * 6)).toDouble(),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.graphic_eq_rounded,
                          color: Colors.greenAccent,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Streaming Audio Live...',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Volume Slider
              Row(
                children: [
                  const Icon(
                    Icons.volume_up_rounded,
                    color: AdminColors.textMuted,
                    size: 18,
                  ),
                  Expanded(
                    child: Slider(
                      value: volume,
                      activeColor: AdminColors.primaryYellow,
                      inactiveColor: AdminColors.borderColor,
                      onChanged: (val) => setModalState(() => volume = val),
                    ),
                  ),
                  Text(
                    '${(volume * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Stop Listening 🎧',
                style: TextStyle(color: AdminColors.textMuted),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _forceEndCall(call['id'] ?? '');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              icon: const Icon(Icons.call_end_rounded, size: 16),
              label: const Text(
                'Disconnect ⏹️',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _allCallHistory.where((log) {
      final customerName = (log['customer']?['name'] ?? '')
          .toString()
          .toLowerCase();
      final expertName = (log['expert']?['user']?['name'] ?? '')
          .toString()
          .toLowerCase();
      final status = (log['status'] ?? '').toString().toUpperCase();
      final matchesSearch =
          customerName.contains(_searchQuery.toLowerCase()) ||
          expertName.contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _selectedStatusFilter == 'ALL' || status == _selectedStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    final content = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Refresh Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Calls & Call Audit Monitor 📞',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Real-time visibility into ongoing calls & dispute resolution logs',
                    style: TextStyle(
                      color: AdminColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _fetchCallData,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: AdminColors.primaryYellow,
                ),
                tooltip: 'Refresh Calls Data',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // LIVE CALLS SECTION (Top Cards)
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LIVE ONGOING CALLS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_liveCalls.length} Active',
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: AdminColors.primaryYellow,
                ),
              ),
            )
          else if (_liveCalls.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AdminColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminColors.borderColor),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.phone_disabled_rounded,
                    color: AdminColors.textMuted,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'No calls currently in progress.',
                    style: TextStyle(
                      color: AdminColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _liveCalls.length,
              itemBuilder: (context, index) {
                final call = _liveCalls[index];
                final customerName = call['customer']?['name'] ?? 'Customer';
                final expertName = call['expert']?['user']?['name'] ?? 'Expert';
                final durationSecs = call['durationSeconds'] ?? 0;
                final liveCost = call['amountCharged'] ?? 0.0;
                final callId = call['id'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AdminColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.greenAccent.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone_in_talk_rounded,
                              color: Colors.greenAccent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$customerName ↔ $expertName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    color: AdminColors.textMuted,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Duration: ${_formatDuration(durationSecs)}',
                                    style: const TextStyle(
                                      color: AdminColors.primaryYellow,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.payments_outlined,
                                    color: AdminColors.textMuted,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Live Cost: ₹$liveCost',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showListenLiveModal(call),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: Colors.greenAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(
                              Icons.headphones_rounded,
                              size: 16,
                            ),
                            label: const Text(
                              'Listen Live 🎧',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _forceEndCall(callId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.withValues(
                                alpha: 0.2,
                              ),
                              foregroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(Icons.call_end_rounded, size: 16),
                            label: const Text(
                              'Disconnect ⏹️',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
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

          const SizedBox(height: 28),

          // CALL HISTORY AUDIT TABLE SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CALL HISTORY & COMMISSION AUDIT 📊',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                '${filteredHistory.length} Calls Recorded',
                style: const TextStyle(
                  color: AdminColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search & Filter Controls
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search by Customer or Expert name...',
                    hintStyle: const TextStyle(
                      color: AdminColors.textMuted,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AdminColors.textMuted,
                    ),
                    filled: true,
                    fillColor: AdminColors.cardBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminColors.borderColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AdminColors.borderColor),
                ),
                child: DropdownButton<String>(
                  value: _selectedStatusFilter,
                  dropdownColor: AdminColors.cardBg,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                    DropdownMenuItem(
                      value: 'COMPLETED',
                      child: Text('Completed'),
                    ),
                    DropdownMenuItem(value: 'ONGOING', child: Text('Ongoing')),
                    DropdownMenuItem(value: 'MISSED', child: Text('Missed')),
                  ],
                  onChanged: (val) {
                    if (val != null)
                      setState(() => _selectedStatusFilter = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Audit Table Container
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AdminColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AdminColors.borderColor),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        AdminColors.background,
                      ),
                      dataRowHeight: 56,
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Customer',
                            style: TextStyle(
                              color: AdminColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Expert',
                            style: TextStyle(
                              color: AdminColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Duration',
                            style: TextStyle(
                              color: AdminColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Total Charged (₹)',
                            style: TextStyle(
                              color: AdminColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Expert Earning (₹)',
                            style: TextStyle(
                              color: AdminColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Admin Commission (₹)',
                            style: TextStyle(
                              color: AdminColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(
                              color: AdminColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      rows: filteredHistory.map((log) {
                        final customerName = log['customer']?['name'] ?? 'N/A';
                        final expertName =
                            log['expert']?['user']?['name'] ?? 'N/A';
                        final duration = _formatDuration(
                          log['durationSeconds'] ?? 0,
                        );
                        final charged = log['amountCharged'] ?? 0.0;
                        final earning = log['expertEarning'] ?? 0.0;
                        final commission =
                            log['adminCommission'] ?? (charged - earning);
                        final status = (log['status'] ?? 'COMPLETED')
                            .toString()
                            .toUpperCase();

                        Color statusColor = Colors.greenAccent;
                        if (status == 'ONGOING')
                          statusColor = AdminColors.primaryYellow;
                        if (status == 'MISSED' || status == 'CANCELLED')
                          statusColor = Colors.redAccent;

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                customerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                expertName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                duration,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            DataCell(
                              Text(
                                '₹$charged',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                '₹$earning',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(
                                '₹$commission',
                                style: const TextStyle(
                                  color: AdminColors.primaryYellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: content);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: content),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// User Reports & Abuse Flagging Screen
// -----------------------------------------------------------------------------
class AbuseReportsScreen extends StatefulWidget {
  final bool isTabMode;
  const AbuseReportsScreen({super.key, this.isTabMode = false});

  @override
  State<AbuseReportsScreen> createState() => _AbuseReportsScreenState();
}

class _AbuseReportsScreenState extends State<AbuseReportsScreen> {
  // Mock data for reports
  final List<Map<String, dynamic>> _reports = [
    {
      'id': 'RPT-8291',
      'reporter': 'John Doe (User)',
      'reported': 'Jane Smith (Expert)',
      'reason': 'Abusive Language',
      'date': '2026-08-04',
      'status': 'Pending',
      'avatar': 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
    },
    {
      'id': 'RPT-8290',
      'reporter': 'Alice Brown (User)',
      'reported': 'Mark Lee (Expert)',
      'reason': 'Poor Audio Quality',
      'date': '2026-08-03',
      'status': 'Pending',
      'avatar': 'https://i.pravatar.cc/150?u=a042581f4e29026704e',
    },
    {
      'id': 'RPT-8285',
      'reporter': 'Sarah Connor (Expert)',
      'reported': 'Tom Hardy (User)',
      'reason': 'Spam/Scam attempt',
      'date': '2026-08-01',
      'status': 'Resolved',
      'avatar': 'https://i.pravatar.cc/150?u=a042581f4e29026704f',
    },
  ];

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Safety & Moderation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AdminColors.primaryYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AdminColors.primaryYellow.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: AdminColors.primaryYellow,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: AdminColors.primaryYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage user and expert reports, issue warnings, or ban accounts.',
          style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // Reports List
        Expanded(
          child: ListView.builder(
            itemCount: _reports.length,
            itemBuilder: (context, index) {
              final report = _reports[index];
              final isResolved = report['status'] == 'Resolved';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: ID, Status, Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          report['id'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isResolved
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isResolved ? Colors.green : Colors.orange,
                            ),
                          ),
                          child: Text(
                            report['status'],
                            style: TextStyle(
                              color: isResolved ? Colors.green : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Middle row: Reporter vs Reported
                    Row(
                      children: [
                        const Icon(
                          Icons.campaign_outlined,
                          color: AdminColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Reporter: ',
                          style: TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          report['reporter'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.gavel_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Reported: ',
                          style: TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          report['reported'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Reason
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Reason for Report:',
                            style: TextStyle(
                              color: AdminColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            report['reason'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    if (!isResolved)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildActionButton(
                            context,
                            'Warning',
                            Icons.warning_amber_rounded,
                            Colors.orange,
                            () => _showActionDialog(
                              context,
                              'Issue Warning',
                              'Are you sure you want to send a warning to ${report['reported']}?',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            context,
                            'Refund',
                            Icons.currency_rupee_rounded,
                            AdminColors.primaryYellow,
                            () => _showActionDialog(
                              context,
                              'Refund Customer',
                              'Are you sure you want to refund ${report['reporter']}?',
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            context,
                            'Ban',
                            Icons.block_rounded,
                            Colors.redAccent,
                            () => _showActionDialog(
                              context,
                              'Ban Account',
                              'Are you sure you want to completely ban ${report['reported']}? This action is irreversible.',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: content);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: content),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AdminColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AdminColors.borderColor),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: AdminColors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AdminColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$title action executed.'),
                    backgroundColor: AdminColors.primaryYellowDark,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: title.contains('Ban')
                    ? Colors.redAccent
                    : AdminColors.primaryYellow,
                foregroundColor: title.contains('Ban')
                    ? Colors.white
                    : Colors.black,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// KYC & Document Verification Screen
// -----------------------------------------------------------------------------
class KYCVerificationScreen extends StatefulWidget {
  final bool isTabMode;
  const KYCVerificationScreen({super.key, this.isTabMode = false});

  @override
  State<KYCVerificationScreen> createState() => _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends State<KYCVerificationScreen> {
  // Mock data for KYC applications
  final List<Map<String, dynamic>> _kycApplications = [
    {
      'id': 'KYC-9901',
      'expertName': 'Dr. Rajesh Kumar',
      'documentType': 'Medical Council Certificate',
      'date': '2026-08-05',
      'status': 'Pending',
      'documentUrl':
          'https://images.unsplash.com/photo-1586281380349-632531db7ed4?w=600',
    },
    {
      'id': 'KYC-9892',
      'expertName': 'Priya Sharma (Advocate)',
      'documentType': 'Bar Council ID & Aadhaar',
      'date': '2026-08-04',
      'status': 'Pending',
      'documentUrl':
          'https://images.unsplash.com/photo-1568285521255-b223d70f9fb8?w=600',
    },
    {
      'id': 'KYC-9885',
      'expertName': 'Suresh Astro',
      'documentType': 'Aadhaar Card',
      'date': '2026-08-02',
      'status': 'Pending',
      'documentUrl':
          'https://images.unsplash.com/photo-1621901859600-994b63ffda9e?w=600',
    },
  ];

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'KYC & Document Verification',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AdminColors.primaryYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AdminColors.primaryYellow.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: AdminColors.primaryYellow,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: AdminColors.primaryYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Review expert identity documents and certificates. Approve to allow them to go online.',
          style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // List
        Expanded(
          child: ListView.builder(
            itemCount: _kycApplications.length,
            itemBuilder: (context, index) {
              final app = _kycApplications[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          app['id'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Text(
                            app['status'],
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Details
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: AdminColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          app['expertName'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.description,
                          color: AdminColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          app['documentType'],
                          style: const TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AdminColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Submitted on ${app['date']}',
                          style: const TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // View Document button
                    InkWell(
                      onTap: () =>
                          _showDocumentDialog(context, app['documentUrl']),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blueAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.visibility,
                              color: Colors.blueAccent,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'View Document',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAction(context, 'Reject'),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Reject'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleAction(context, 'Approve'),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
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
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: content);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: content),
      ),
    );
  }

  void _showDocumentDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Document $action successfully.'),
        backgroundColor: action == 'Approve' ? Colors.green : Colors.redAccent,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Promo Codes & Coupons Screen
// -----------------------------------------------------------------------------
class PromoCodesScreen extends StatefulWidget {
  final bool isTabMode;
  const PromoCodesScreen({super.key, this.isTabMode = false});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  // Mock data for promo codes
  final List<Map<String, dynamic>> _promoCodes = [
    {
      'id': 'PROMO-101',
      'code': 'FIRST50',
      'discount': '50% Off',
      'maxUses': 100,
      'usedCount': 42,
      'expiryDate': '2026-12-31',
      'isActive': true,
    },
    {
      'id': 'PROMO-102',
      'code': 'DIWALI20',
      'discount': '₹200 Flat',
      'maxUses': 500,
      'usedCount': 500,
      'expiryDate': '2025-11-01',
      'isActive': false,
    },
    {
      'id': 'PROMO-103',
      'code': 'WEEKENDXP',
      'discount': '10% Off',
      'maxUses': 50,
      'usedCount': 5,
      'expiryDate': '2026-08-30',
      'isActive': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Promo Codes & Offers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: _showCreatePromoDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AdminColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Create New',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage discount codes and promotional offers for users.',
          style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // List
        Expanded(
          child: ListView.builder(
            itemCount: _promoCodes.length,
            itemBuilder: (context, index) {
              final promo = _promoCodes[index];
              final isExpired = !promo['isActive'];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpired
                        ? AdminColors.borderColor
                        : AdminColors.primaryYellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_offer,
                              color: AdminColors.primaryYellow,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              promo['code'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: promo['isActive'],
                          activeThumbColor: AdminColors.primaryYellow,
                          onChanged: (val) {
                            setState(() {
                              promo['isActive'] = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Details
                    Row(
                      children: [
                        const Icon(
                          Icons.percent,
                          color: AdminColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Discount: ',
                          style: TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          promo['discount'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.group,
                          color: AdminColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Usage: ',
                          style: TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${promo['usedCount']} / ${promo['maxUses']}',
                          style: TextStyle(
                            color: promo['usedCount'] >= promo['maxUses']
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.event,
                          color: AdminColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Valid until: ',
                          style: TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          promo['expiryDate'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Delete Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _promoCodes.removeAt(index);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Promo Code Deleted'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: content);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: content),
      ),
    );
  }

  void _showCreatePromoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AdminColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AdminColors.borderColor),
          ),
          title: const Text(
            'Create Promo Code',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField('Promo Code (e.g. MEGA50)'),
                const SizedBox(height: 12),
                _buildTextField('Discount Value (e.g. 50% or ₹100)'),
                const SizedBox(height: 12),
                _buildTextField('Max Usage Limit (e.g. 100)'),
                const SizedBox(height: 12),
                _buildTextField('Expiry Date (YYYY-MM-DD)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AdminColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Promo Code Created successfully.'),
                    backgroundColor: AdminColors.primaryYellowDark,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryYellow,
                foregroundColor: Colors.black,
              ),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AdminColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AdminColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.borderColor),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sub-Admins & Role Management Screen
// -----------------------------------------------------------------------------
class SubAdminsScreen extends StatefulWidget {
  final bool isTabMode;
  const SubAdminsScreen({super.key, this.isTabMode = false});

  @override
  State<SubAdminsScreen> createState() => _SubAdminsScreenState();
}

class _SubAdminsScreenState extends State<SubAdminsScreen> {
  // Mock data for sub-admins
  final List<Map<String, dynamic>> _subAdmins = [
    {
      'id': 'SA-001',
      'name': 'Rahul Verma',
      'email': 'rahul.mod@connectax.com',
      'role': 'Moderator',
      'isActive': true,
    },
    {
      'id': 'SA-002',
      'name': 'Sneha Patil',
      'email': 'sneha.fin@connectax.com',
      'role': 'Finance',
      'isActive': true,
    },
    {
      'id': 'SA-003',
      'name': 'Vikram Singh',
      'email': 'vikram.sup@connectax.com',
      'role': 'Support',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Sub-Admins & Roles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: _showAddSubAdminDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AdminColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.black, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Add Sub-Admin',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage sub-admin accounts and assign specific access roles.',
          style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // List
        Expanded(
          child: ListView.builder(
            itemCount: _subAdmins.length,
            itemBuilder: (context, index) {
              final admin = _subAdmins[index];
              final isRevoked = !admin['isActive'];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isRevoked
                        ? AdminColors.borderColor
                        : AdminColors.primaryYellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.admin_panel_settings,
                              color: AdminColors.primaryYellow,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              admin['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isRevoked
                                ? Colors.redAccent.withValues(alpha: 0.1)
                                : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isRevoked
                                  ? Colors.redAccent
                                  : Colors.green,
                            ),
                          ),
                          child: Text(
                            isRevoked ? 'Revoked' : 'Active',
                            style: TextStyle(
                              color: isRevoked
                                  ? Colors.redAccent
                                  : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Details
                    Row(
                      children: [
                        const Icon(
                          Icons.email,
                          color: AdminColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          admin['email'],
                          style: const TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.badge,
                          color: AdminColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Role: ',
                          style: TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          admin['role'],
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Edit Role Dialog Open...'),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blueAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.blueAccent,
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Edit Role',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            setState(() {
                              admin['isActive'] = !admin['isActive'];
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isRevoked
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isRevoked
                                    ? Colors.green.withValues(alpha: 0.3)
                                    : Colors.redAccent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isRevoked ? Icons.check_circle : Icons.block,
                                  color: isRevoked
                                      ? Colors.green
                                      : Colors.redAccent,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isRevoked
                                      ? 'Restore Access'
                                      : 'Revoke Access',
                                  style: TextStyle(
                                    color: isRevoked
                                        ? Colors.green
                                        : Colors.redAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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
            },
          ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: content);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: content),
      ),
    );
  }

  void _showAddSubAdminDialog() {
    String selectedRole = 'Moderator';
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AdminColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AdminColors.borderColor),
              ),
              title: const Text(
                'Add Sub-Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      'Full Name (e.g. Rahul Verma)',
                      controller: nameController,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      'Email Address',
                      controller: emailController,
                    ),
                    const SizedBox(height: 12),
                    _buildPasswordField(
                      'Password',
                      controller: passwordController,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AdminColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminColors.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          dropdownColor: AdminColors.cardBg,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AdminColors.textMuted,
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setDialogState(() {
                                selectedRole = newValue;
                              });
                            }
                          },
                          items:
                              <String>[
                                'Moderator',
                                'Finance',
                                'Support',
                                'Super Admin',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AdminColors.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        emailController.text.isNotEmpty) {
                      setState(() {
                        _subAdmins.add({
                          'id': 'SA-${100 + _subAdmins.length}',
                          'name': nameController.text,
                          'email': emailController.text,
                          'role': selectedRole,
                          'isActive': true,
                        });
                      });
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sub-Admin invited successfully.'),
                        backgroundColor: AdminColors.primaryYellowDark,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryYellow,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Send Invite'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField(String hint, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AdminColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AdminColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.borderColor),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint, {TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AdminColors.textMuted, fontSize: 13),
        filled: true,
        fillColor: AdminColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AdminColors.borderColor),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Support Tickets / Help Desk Screen
// -----------------------------------------------------------------------------
class SupportTicketsScreen extends StatefulWidget {
  final bool isTabMode;
  const SupportTicketsScreen({super.key, this.isTabMode = false});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  // Mock data for tickets
  final List<Map<String, dynamic>> _tickets = [
    {
      'id': '#TCK-9901',
      'user': 'Vikram S.',
      'type': 'Payment Failed',
      'status': 'Open',
      'date': '2026-08-05 10:30 AM',
      'description':
          'I recharged my wallet with Rs. 500 but it is not reflecting in my balance. Money was deducted from my bank.',
      'reply': '',
    },
    {
      'id': '#TCK-9900',
      'user': 'Priya R.',
      'type': 'Call Dropped',
      'status': 'In Progress',
      'date': '2026-08-04 06:15 PM',
      'description':
          'I was talking to Astrologer Suresh and the call disconnected automatically after 2 minutes. Please refund.',
      'reply': 'We are looking into the call logs to verify the issue.',
    },
    {
      'id': '#TCK-9895',
      'user': 'Rahul K. (Expert)',
      'type': 'App Bug',
      'status': 'Resolved',
      'date': '2026-08-03 11:20 AM',
      'description':
          'I am not receiving notifications when a customer tries to call me.',
      'reply':
          'Please update the app to the latest version. This issue has been fixed.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Help Desk & Support',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AdminColors.primaryYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AdminColors.primaryYellow.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: AdminColors.primaryYellow,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Filter',
                    style: TextStyle(
                      color: AdminColors.primaryYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage and respond to customer and expert issues.',
          style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 24),

        // List
        Expanded(
          child: ListView.builder(
            itemCount: _tickets.length,
            itemBuilder: (context, index) {
              final ticket = _tickets[index];
              final status = ticket['status'];
              Color statusColor = Colors.orange;
              if (status == 'Resolved') statusColor = Colors.green;
              if (status == 'In Progress') statusColor = Colors.blueAccent;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: status == 'Open'
                        ? AdminColors.primaryYellow.withValues(alpha: 0.5)
                        : AdminColors.borderColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ticket['id'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Details
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          color: AdminColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ticket['user'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.category,
                          color: AdminColors.textMuted,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ticket['type'],
                          style: const TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AdminColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '"${ticket['description']}"',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    if (ticket['reply'] != '') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blueAccent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.reply,
                              color: Colors.blueAccent,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ticket['reply'],
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Action Buttons
                    if (status != 'Resolved')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ticket['date'],
                            style: const TextStyle(
                              color: AdminColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showReplyDialog(context, index),
                            icon: const Icon(Icons.reply, size: 16),
                            label: const Text('Reply & Resolve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminColors.primaryYellow,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          ticket['date'],
                          style: const TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: content);
    }

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: content),
      ),
    );
  }

  void _showReplyDialog(BuildContext context, int index) {
    final TextEditingController replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AdminColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AdminColors.borderColor),
          ),
          title: Text(
            'Reply to ${_tickets[index]['id']}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'User Issue:',
                  style: TextStyle(color: AdminColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _tickets[index]['description'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: replyController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Type your response here...',
                    hintStyle: const TextStyle(
                      color: AdminColors.textMuted,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AdminColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminColors.borderColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AdminColors.borderColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AdminColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tickets[index]['reply'] = replyController.text;
                  _tickets[index]['status'] = 'Resolved';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reply sent and ticket resolved.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryYellow,
                foregroundColor: Colors.black,
              ),
              child: const Text('Send & Resolve'),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Reviews & Ratings Moderation Screen
// -----------------------------------------------------------------------------
class ReviewsModerationScreen extends StatefulWidget {
  final bool isTabMode;
  const ReviewsModerationScreen({super.key, this.isTabMode = false});

  @override
  State<ReviewsModerationScreen> createState() =>
      _ReviewsModerationScreenState();
}

class _ReviewsModerationScreenState extends State<ReviewsModerationScreen> {
  // Mock data for reviews
  final List<Map<String, dynamic>> _reviews = [
    {
      'id': 'REV-101',
      'user': 'Priya R.',
      'expert': 'Suresh (Vedic)',
      'rating': 1,
      'comment': 'He was very rude and disconnected the call.',
      'isHidden': false,
      'date': '2026-08-04',
    },
    {
      'id': 'REV-102',
      'user': 'Rahul V.',
      'expert': 'Deepa (Tarot)',
      'rating': 5,
      'comment': 'Very accurate reading. Highly recommend.',
      'isHidden': false,
      'date': '2026-08-03',
    },
    {
      'id': 'REV-103',
      'user': 'Vikram S.',
      'expert': 'Suresh (Vedic)',
      'rating': 3,
      'comment': 'Okay experience. A bit too expensive.',
      'isHidden': true,
      'date': '2026-08-01',
    },
  ];

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews Moderation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Monitor and manage user reviews and ratings for experts.',
          style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _reviews.length,
            itemBuilder: (context, index) {
              final review = _reviews[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: review['isHidden']
                        ? AdminColors.borderColor
                        : AdminColors.primaryYellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              color: AdminColors.textMuted,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              review['user'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: AdminColors.textMuted,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              review['expert'],
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        if (review['isHidden'])
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: const Text(
                              'Hidden',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < review['rating']
                              ? Icons.star
                              : Icons.star_border,
                          color: AdminColors.primaryYellow,
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '"${review['comment']}"',
                      style: TextStyle(
                        color: review['isHidden']
                            ? AdminColors.textMuted
                            : Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review['date'],
                          style: const TextStyle(
                            color: AdminColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  review['isHidden'] = !review['isHidden'];
                                });
                              },
                              icon: Icon(
                                review['isHidden']
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 16,
                                color: AdminColors.textMuted,
                              ),
                              label: Text(
                                review['isHidden'] ? 'Unhide' : 'Hide',
                                style: const TextStyle(
                                  color: AdminColors.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _reviews.removeAt(index);
                                });
                              },
                              icon: const Icon(
                                Icons.delete,
                                size: 16,
                                color: Colors.redAccent,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: content);
    }
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: content),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Push Notifications Manager Screen
// -----------------------------------------------------------------------------
class NotificationsManagerScreen extends StatefulWidget {
  final bool isTabMode;
  const NotificationsManagerScreen({super.key, this.isTabMode = false});

  @override
  State<NotificationsManagerScreen> createState() =>
      _NotificationsManagerScreenState();
}

class _NotificationsManagerScreenState
    extends State<NotificationsManagerScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Diwali Special Offer! 🪔',
      'message': 'Get 50% off on your first consultation today.',
      'target': 'Customers',
      'date': '2025-10-24 10:00 AM',
    },
    {
      'title': 'System Maintenance 🛠️',
      'message':
          'The app will be down for maintenance tonight from 2 AM to 4 AM.',
      'target': 'Both',
      'date': '2026-08-01 04:00 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Push Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showCreateNotificationDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminColors.primaryYellow,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Send mass push notifications to customers and experts.',
          style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _notifications.length,
            itemBuilder: (context, index) {
              final notif = _notifications[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          notif['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.purple),
                          ),
                          child: Text(
                            notif['target'],
                            style: const TextStyle(
                              color: Colors.purple,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notif['message'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sent on: ${notif['date']}',
                      style: const TextStyle(
                        color: AdminColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );

    if (widget.isTabMode) {
      return Padding(padding: const EdgeInsets.all(20.0), child: content);
    }
    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(20.0), child: content),
      ),
    );
  }

  void _showCreateNotificationDialog() {
    String selectedTarget = 'Customers';
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AdminColors.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AdminColors.borderColor),
              ),
              title: const Text(
                'Send Notification',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Target Audience:',
                      style: TextStyle(
                        color: AdminColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AdminColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AdminColors.borderColor),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTarget,
                          dropdownColor: AdminColors.cardBg,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: AdminColors.textMuted,
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setDialogState(() {
                                selectedTarget = newValue;
                              });
                            }
                          },
                          items: <String>['Customers', 'Experts', 'Both']
                              .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Notification Title',
                        hintStyle: const TextStyle(
                          color: AdminColors.textMuted,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: AdminColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AdminColors.borderColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AdminColors.borderColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Message body...',
                        hintStyle: const TextStyle(
                          color: AdminColors.textMuted,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: AdminColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AdminColors.borderColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AdminColors.borderColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AdminColors.textMuted),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        messageController.text.isNotEmpty) {
                      setState(() {
                        _notifications.insert(0, {
                          'title': titleController.text,
                          'message': messageController.text,
                          'target': selectedTarget,
                          'date': 'Just now',
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notification Sent!'),
                          backgroundColor: AdminColors.primaryYellowDark,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminColors.primaryYellow,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Send Now'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Menu / Profile Screen
// -----------------------------------------------------------------------------
class MenuScreen extends StatelessWidget {
  final bool isTabMode;
  const MenuScreen({super.key, this.isTabMode = false});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: AdminColors.background,
          appBar: AppBar(
            backgroundColor: AdminColors.cardBg,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
            title: const Text('', style: TextStyle(color: Colors.white)),
          ),
          body: screen,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'icon': Icons.payments_rounded,
        'title': 'Payouts',
        'screen': const PayoutRequestsScreen(isTabMode: false),
      },
      {
        'icon': Icons.view_carousel_rounded,
        'title': 'Banners',
        'screen': const BannerManagementScreen(isTabMode: false),
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': 'Transactions',
        'screen': const TransactionsScreen(isTabMode: false),
      },
      {
        'icon': Icons.gavel_rounded,
        'title': 'Reports',
        'screen': const AbuseReportsScreen(isTabMode: false),
      },
      {
        'icon': Icons.verified_user,
        'title': 'KYC Verification',
        'screen': const KYCVerificationScreen(isTabMode: false),
      },
      {
        'icon': Icons.local_offer_rounded,
        'title': 'Promo Codes & Offers',
        'screen': const PromoCodesScreen(isTabMode: false),
      },
      {
        'icon': Icons.admin_panel_settings,
        'title': 'Sub-Admins',
        'screen': const SubAdminsScreen(isTabMode: false),
      },
      {
        'icon': Icons.support_agent,
        'title': 'Support Tickets',
        'screen': const SupportTicketsScreen(isTabMode: false),
      },
      {
        'icon': Icons.star_half,
        'title': 'Reviews Moderation',
        'screen': const ReviewsModerationScreen(isTabMode: false),
      },
      {
        'icon': Icons.campaign,
        'title': 'Push Notifications',
        'screen': const NotificationsManagerScreen(isTabMode: false),
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'screen': const SettingsScreen(isTabMode: false),
      },
    ];

    return Scaffold(
      backgroundColor: AdminColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Admin Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage all platform features and settings.',
              style: TextStyle(color: AdminColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ...menuItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AdminColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminColors.borderColor),
                ),
                child: ListTile(
                  leading: Icon(
                    item['icon'] as IconData,
                    color: AdminColors.primaryYellow,
                  ),
                  title: Text(
                    item['title'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AdminColors.textMuted,
                    size: 16,
                  ),
                  onTap: () => _navigateTo(context, item['screen'] as Widget),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
