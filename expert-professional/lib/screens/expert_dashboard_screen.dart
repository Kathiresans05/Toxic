import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_professional/providers/auth_provider.dart';
import 'package:expert_professional/services/api_service.dart';
import 'package:expert_professional/services/socket_service.dart';
import 'package:expert_professional/screens/expert_onboarding_screens.dart';
import 'package:expert_professional/screens/voice_bio_screen.dart';
import 'package:expert_professional/screens/bank_payout_screen.dart';
import 'package:expert_professional/services/notification_service.dart';
import 'package:expert_professional/services/foreground_service.dart';

// Reuse visual constants matching the golden/dark luxury theme
class ExpertColors {
  static const Color background = Color(0xFF08080A);
  static const Color cardBg = Color(0xFF141418);
  static const Color cardSelectedBg = Color(0xFF1C1A14);
  static const Color primaryYellow = Color(0xFFFFC107);
  static const Color primaryYellowDark = Color(0xFFFFB800);
  static const Color textMuted = Color(0xFF8A8A93);
  static const Color borderColor = Color(0xFF24242A);
}

class ExpertDashboardScreen extends StatefulWidget {
  const ExpertDashboardScreen({super.key});

  @override
  State<ExpertDashboardScreen> createState() => _ExpertDashboardScreenState();
}

class _ExpertDashboardScreenState extends State<ExpertDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  bool _isOnline = false;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _setupIncomingCallListener();
    _setupChatListener();
  }

  void _setupChatListener() {
    SocketService().onReceiveMessage = (data) {
      if (mounted) {
        final senderName = data['senderName'] ?? 'Customer';
        final text = data['text'] ?? '';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: ExpertColors.cardBg,
            duration: const Duration(seconds: 5),
            content: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  color: ExpertColors.primaryYellow,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message from $senderName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: ExpertColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    };
  }

  void _setupIncomingCallListener() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expertId = authProvider.user?['id']?.toString();

    if (expertId != null && expertId.isNotEmpty) {
      SocketService().connect(expertId);
      SocketService().onIncomingCall = (data) {
        if (!mounted) return;
        final callId = data['callId']?.toString() ?? '';
        final callerName = data['callerName']?.toString() ?? 'Customer';
        final channelName = data['channelName']?.toString() ?? 'room_$callId';
        final pricePerMinute =
            double.tryParse(data['pricePerMinute']?.toString() ?? '') ?? 3.0;
        final callType = data['callType']?.toString().toLowerCase() ?? 'video';

        // Trigger Android native wake-lock, full-screen intent & heads-up notification
        ForegroundService().triggerIncomingCall(
          callerName: callerName,
          callId: callId,
          channelName: channelName,
          price: pricePerMinute,
          callType: callType,
        );

        // Show in-app banner with incoming call controls
        CallNotificationService().showIncomingCallBanner(
          context: context,
          callId: callId,
          callerName: callerName,
          channelName: channelName,
          pricePerMinute: pricePerMinute,
          callType: callType,
        );
      };
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshProfile();
    final stats = await ApiService().getExpertStats();
    if (mounted) {
      final online = authProvider.user?['isOnline'] == true;
      setState(() {
        _stats = stats;
        _isOnline = online;
      });

      if (online) {
        ForegroundService().startOnlineService();
        final expertId = authProvider.user?['id']?.toString();
        if (expertId != null && expertId.isNotEmpty) {
          SocketService().connect(expertId);
        }
      }
    }
  }

  Future<void> _toggleOnline(bool value) async {
    setState(() {
      _isOnline = value;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final expertId = authProvider.user?['id']?.toString();

    if (value) {
      await ForegroundService().startOnlineService();
      if (expertId != null && expertId.isNotEmpty) {
        SocketService().connect(expertId);
      }
    } else {
      await ForegroundService().stopOnlineService();
    }

    try {
      await ApiService().toggleExpertStatus(value);
    } catch (_) {}
    if (mounted) {
      authProvider.refreshProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildSideDrawer(context),
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildDashboardTab(),
            const CallHistoryView(),
            _buildEarningsTab(),
            const ProfileTabView(),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: ExpertColors.background),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: ExpertColors.background,
          selectedItemColor: ExpertColors.primaryYellow,
          unselectedItemColor: ExpertColors.textMuted,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_in_talk),
              label: 'Calls',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Main Dashboard Tab (Image 1 of first batch)
  // ---------------------------------------------------------------------------
  Widget _buildDashboardTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user ?? {};
    String name = 'Expert';
    if (user['name'] != null && user['name'].toString().trim().isNotEmpty) {
      name = user['name'].toString().trim();
    } else if (user['fullName'] != null &&
        user['fullName'].toString().trim().isNotEmpty) {
      name = user['fullName'].toString().trim();
    } else if (user['user'] is Map &&
        user['user']['fullName'] != null &&
        user['user']['fullName'].toString().trim().isNotEmpty) {
      name = user['user']['fullName'].toString().trim();
    } else if (user['email'] != null &&
        user['email'].toString().trim().isNotEmpty) {
      name = user['email'].toString().split('@')[0];
    } else if (user['phone'] != null &&
        user['phone'].toString().trim().isNotEmpty) {
      name = user['phone'].toString().trim();
    } else if (user['mobileNumber'] != null &&
        user['mobileNumber'].toString().trim().isNotEmpty) {
      name = user['mobileNumber'].toString().trim();
    }

    String role = 'Friendly Listener & Companion';
    if (user['bio'] != null && user['bio'].toString().trim().isNotEmpty) {
      role = user['bio'].toString().trim();
    } else if (user['categories'] != null &&
        (user['categories'] as List).isNotEmpty) {
      role = (user['categories'] as List).join(', ');
    }
    final String photoUrl = user['profilePhotoUrl'] ?? '';
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'E';

    final String todayEarnings =
        user['todayEarnings']?.toString() ??
        _stats?['todayEarnings'] ??
        '₹ 0.00';
    final String totalCalls =
        user['totalCalls']?.toString() ??
        _stats?['totalCalls']?.toString() ??
        '0';
    final String duration =
        user['duration']?.toString() ??
        _stats?['duration']?.toString() ??
        '00:00:00';
    final String rating =
        user['rating']?.toString() ?? _stats?['rating']?.toString() ?? '5.0';
    final String missedCalls =
        user['missedCalls']?.toString() ??
        _stats?['missedCalls']?.toString() ??
        '0';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: ExpertColors.primaryYellow,
                  size: 28,
                ),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const Text(
                'Expert Dashboard',
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
                    color: ExpertColors.primaryYellow,
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

          // User Profile Row
          Row(
            children: [
              // Avatar with glow ring
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ExpertColors.primaryYellow,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ExpertColors.primaryYellow.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.transparent,
                  child: ClipOval(
                    child: photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildFallbackAvatar(firstLetter),
                          )
                        : _buildFallbackAvatar(firstLetter),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name & verified badge
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
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: ExpertColors.primaryYellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role,
                      style: const TextStyle(
                        color: ExpertColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Online status switcher
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isOnline
                          ? Colors.amber.shade900.withValues(alpha: 0.2)
                          : Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isOnline
                            ? ExpertColors.primaryYellow.withValues(alpha: 0.4)
                            : Colors.white24,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _isOnline
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: _isOnline
                                ? ExpertColors.primaryYellow
                                : Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Switch(
                    value: _isOnline,
                    activeTrackColor: ExpertColors.primaryYellow,
                    activeThumbColor: Colors.white,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.white24,
                    onChanged: (val) => _toggleOnline(val),
                  ),
                  if (user['isApproved'] != true) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber, width: 0.8),
                      ),
                      child: const Text(
                        'Pending Approval ⏳',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Today's Earnings Yellow Card
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
                  color: ExpertColors.primaryYellow.withValues(alpha: 0.2),
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
                      'Today\'s Earnings',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
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
                        'Live',
                        style: TextStyle(
                          color: ExpertColors.primaryYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  todayEarnings,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                // Sparkline graph
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: CustomPaint(painter: SparklinePainter()),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '00:00',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '12:00',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '24:00',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats Grid (4 cards)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.45,
            children: [
              _buildStatCard(
                'Total Calls',
                totalCalls,
                'Live',
                Colors.greenAccent,
                Icons.phone_in_talk_rounded,
              ),
              _buildStatCard(
                'Duration',
                duration,
                'Total',
                Colors.greenAccent,
                Icons.av_timer_rounded,
              ),
              _buildStatCard(
                'Rating  ★',
                rating,
                'Average',
                ExpertColors.primaryYellow,
                Icons.star_rounded,
              ),
              _buildStatCard(
                'Missed Calls',
                missedCalls,
                'Live',
                Colors.redAccent,
                Icons.phone_missed_rounded,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Upcoming Slots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Slots',
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
                    color: ExpertColors.primaryYellow,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSlotRow('10:00 AM - 11:00 AM', 'Booked', true),
          const SizedBox(height: 12),
          _buildSlotRow('11:30 AM - 12:30 PM', 'Available', false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(String letter) {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFC107), Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
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
        color: ExpertColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ExpertColors.borderColor),
        gradient: const LinearGradient(
          colors: [ExpertColors.cardBg, Color(0xFF1B1B22)],
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
                  color: ExpertColors.textMuted,
                  fontSize: 13,
                ),
              ),
              Icon(
                icon,
                color: ExpertColors.primaryYellow.withValues(alpha: 0.8),
                size: 20,
              ),
            ],
          ),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
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

  Widget _buildSlotRow(String time, String status, bool isBooked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ExpertColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: isBooked
                    ? ExpertColors.primaryYellow
                    : ExpertColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                time,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            status,
            style: TextStyle(
              color: isBooked
                  ? ExpertColors.primaryYellow
                  : ExpertColors.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: Earnings Tab
  // ---------------------------------------------------------------------------
  Widget _buildEarningsTab() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ExpertColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Earnings',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: ExpertColors.primaryYellow,
            labelColor: ExpertColors.primaryYellow,
            unselectedLabelColor: ExpertColors.textMuted,
            tabs: [
              Tab(text: 'Logs History'),
              Tab(text: 'Overview Balance'),
            ],
          ),
        ),
        body: TabBarView(
          children: [EarningsLogsView(), EarningsOverviewView()],
        ),
      ),
    );
  }

  Widget _buildSideDrawer(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user ?? {};
    String name = 'Expert';
    if (user['name'] != null && user['name'].toString().trim().isNotEmpty) {
      name = user['name'].toString().trim();
    } else if (user['email'] != null &&
        user['email'].toString().trim().isNotEmpty) {
      name = user['email'].toString().split('@')[0];
    } else if (user['phone'] != null &&
        user['phone'].toString().trim().isNotEmpty) {
      name = user['phone'].toString().trim();
    } else if (user['mobileNumber'] != null &&
        user['mobileNumber'].toString().trim().isNotEmpty) {
      name = user['mobileNumber'].toString().trim();
    }

    String role = 'Friendly Listener & Companion';
    if (user['bio'] != null && user['bio'].toString().trim().isNotEmpty) {
      role = user['bio'].toString().trim();
    } else if (user['categories'] != null &&
        (user['categories'] as List).isNotEmpty) {
      role = (user['categories'] as List).join(', ');
    }
    final String mobile =
        user['mobileNumber'] ?? user['phone'] ?? (user['email'] ?? 'N/A');
    final String photoUrl = user['profilePhotoUrl'] ?? '';
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'E';

    return Drawer(
      backgroundColor: const Color(0xFF0F0F12),
      child: Column(
        children: [
          // Header Profile Area
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1F1F24), Color(0xFF141418)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border(bottom: BorderSide(color: Colors.white10)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ExpertColors.primaryYellow,
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white10,
                    child: photoUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              photoUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            firstLetter,
                            style: const TextStyle(
                              color: ExpertColors.primaryYellow,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
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
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: ExpertColors.primaryYellow,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        role,
                        style: const TextStyle(
                          color: ExpertColors.textMuted,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mobile,
                        style: const TextStyle(
                          color: ExpertColors.primaryYellow,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Menu List Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 0);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.phone_in_talk_rounded,
                  title: 'Call Logs & History',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 1);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'Earnings & Payouts',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BankPayoutScreen(),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_rounded,
                  title: 'My Profile & Bio',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _currentIndex = 3);
                  },
                ),
                const Divider(
                  color: Colors.white10,
                  height: 24,
                  indent: 20,
                  endIndent: 20,
                ),
                _buildDrawerItem(
                  icon: Icons.mic_rounded,
                  title: 'Voice Bio (30s Intro)',
                  badgeText: 'New',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VoiceBioScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.verified_user_rounded,
                  title: 'KYC & Certificates',
                  badgeText: 'Approved',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Your Expert Credentials are 100% Verified.',
                        ),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications_active_rounded,
                  title: 'Notification Settings',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // Logout Footer Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white10)),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExpertLoginScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: ExpertColors.primaryYellow, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badgeText != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ExpertColors.primaryYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ExpertColors.primaryYellow.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: ExpertColors.primaryYellow,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(
              Icons.chevron_right,
              color: ExpertColors.textMuted,
              size: 18,
            ),
      onTap: onTap,
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 2: Call History Screen (Image 2)
// -----------------------------------------------------------------------------
class CallHistoryView extends StatefulWidget {
  const CallHistoryView({super.key});

  @override
  State<CallHistoryView> createState() => _CallHistoryViewState();
}

class _CallHistoryViewState extends State<CallHistoryView> {
  String _selectedCallFilter = 'All';
  List<dynamic> _callLogs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCallHistory();
  }

  Future<void> _fetchCallHistory() async {
    final history = await ApiService().getCallHistory();
    if (mounted) {
      setState(() {
        _callLogs = history ?? [];
        _isLoading = false;
      });
    }
  }

  List<dynamic> _filteredLogs() {
    if (_selectedCallFilter == 'All') return _callLogs;
    return _callLogs.where((log) {
      final status = (log['status'] ?? '').toString().toLowerCase();
      return status == _selectedCallFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Center(
            child: Text(
              'Call History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Filters row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildCallFilterPill('All'),
                const SizedBox(width: 8),
                _buildCallFilterPill('Completed'),
                const SizedBox(width: 8),
                _buildCallFilterPill('Missed'),
                const SizedBox(width: 8),
                _buildCallFilterPill('Cancelled'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // List log
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: ExpertColors.primaryYellow,
                    ),
                  )
                : _filteredLogs().isEmpty
                ? const Center(
                    child: Text(
                      'No call history yet',
                      style: TextStyle(
                        color: ExpertColors.textMuted,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredLogs().length,
                    itemBuilder: (context, index) {
                      final log = _filteredLogs()[index];
                      final customer = log['customer'] ?? {};
                      final String name =
                          customer['name'] ??
                          customer['mobileNumber'] ??
                          'Customer';
                      final String avatar = customer['profilePhotoUrl'] ?? '';
                      final String firstLetter = name.isNotEmpty
                          ? name[0].toUpperCase()
                          : 'C';
                      final double earning =
                          double.tryParse(
                            log['expertEarning']?.toString() ?? '0',
                          ) ??
                          0.0;
                      final int durationSecs = log['durationSeconds'] ?? 0;
                      final String durationStr =
                          '${(durationSecs ~/ 60).toString().padLeft(2, '0')}:${(durationSecs % 60).toString().padLeft(2, '0')} min';
                      final String status =
                          log['status']?.toString().toUpperCase() ??
                          'COMPLETED';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ExpertColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ExpertColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: ExpertColors.primaryYellow,
                              backgroundImage: avatar.isNotEmpty
                                  ? NetworkImage(avatar)
                                  : null,
                              child: avatar.isEmpty
                                  ? Text(
                                      firstLetter,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$durationStr • $status',
                                    style: const TextStyle(
                                      color: ExpertColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${earning.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: ExpertColors.primaryYellow,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: ExpertColors.borderColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.phone_in_talk,
                                    color: ExpertColors.primaryYellow,
                                    size: 16,
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
      ),
    );
  }

  Widget _buildCallFilterPill(String filterName) {
    final isSelected = _selectedCallFilter == filterName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCallFilter = filterName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ExpertColors.primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ExpertColors.primaryYellow : Colors.white24,
          ),
        ),
        child: Text(
          filterName,
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
// TAB 4: Profile Tab Screen (Image 4)
// -----------------------------------------------------------------------------
class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user ?? {};
    String name = 'Expert';
    if (user['name'] != null && user['name'].toString().trim().isNotEmpty) {
      name = user['name'].toString().trim();
    } else if (user['email'] != null &&
        user['email'].toString().trim().isNotEmpty) {
      name = user['email'].toString().split('@')[0];
    } else if (user['phone'] != null &&
        user['phone'].toString().trim().isNotEmpty) {
      name = user['phone'].toString().trim();
    } else if (user['mobileNumber'] != null &&
        user['mobileNumber'].toString().trim().isNotEmpty) {
      name = user['mobileNumber'].toString().trim();
    }

    String role = 'Friendly Listener & Companion';
    if (user['bio'] != null && user['bio'].toString().trim().isNotEmpty) {
      role = user['bio'].toString().trim();
    } else if (user['categories'] != null &&
        (user['categories'] as List).isNotEmpty) {
      role = (user['categories'] as List).join(', ');
    }
    final String photoUrl = user['profilePhotoUrl'] ?? '';
    final String firstLetter = name.isNotEmpty ? name[0].toUpperCase() : 'E';
    final String experienceYears = user['experienceYears']?.toString() ?? '1+';
    final String languages =
        user['languages'] != null && (user['languages'] as List).isNotEmpty
        ? (user['languages'] as List).join(', ')
        : 'Tamil, English';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top title
          const Center(
            child: Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Avatar display with pencil clicker
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ExpertColors.primaryYellow,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ExpertColors.primaryYellow.withValues(
                          alpha: 0.2,
                        ),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 64,
                  backgroundColor: ExpertColors.primaryYellow,
                  backgroundImage: photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl.isEmpty
                      ? Text(
                          firstLetter,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 44,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  top: 50,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ExpertColors.cardBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: ExpertColors.borderColor),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: ExpertColors.primaryYellow,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Name and verified
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: ExpertColors.primaryYellow,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  role,
                  style: const TextStyle(
                    color: ExpertColors.textMuted,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Key metrics row (Years Exp, Happy Clients, Response Rate)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: ExpertColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ExpertColors.borderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricCol('$experienceYears Yrs', 'Experience'),
                ),
                Container(height: 30, width: 1, color: Colors.white12),
                Expanded(child: _buildMetricCol('5.0 ★', 'Rating')),
                Container(height: 30, width: 1, color: Colors.white12),
                Expanded(child: _buildMetricCol('100%', 'Response Rate')),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // About Me
          const Text(
            'About Me',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            role.isNotEmpty ? role : 'Verified Expert Consultant.',
            style: const TextStyle(
              color: ExpertColors.textMuted,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Info lists (Languages, Expertise, Consultation Style)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ExpertColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ExpertColors.borderColor),
            ),
            child: Column(
              children: [
                _buildInfoRow(Icons.translate, 'Languages', languages),
                const Divider(color: Colors.white10, height: 24),
                _buildInfoRow(
                  Icons.psychology,
                  'Expertise',
                  'Relationship, Breakup, Marriage',
                ),
                const Divider(color: Colors.white10, height: 24),
                _buildInfoRow(
                  Icons.record_voice_over,
                  'Consultation Style',
                  'Voice, Friendly, Practical',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu link options
          _buildMenuLink(
            context,
            Icons.star_outline_rounded,
            'My Client Reviews',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyReviewsScreen()),
            ),
          ),
          _buildMenuLink(
            context,
            Icons.mic_rounded,
            'Voice Bio (30s Intro)',
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VoiceBioScreen()),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuLink(
            context,
            Icons.event_available_rounded,
            'Availability Settings',
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AvailabilitySettingsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMetricCol(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: ExpertColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String val) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ExpertColors.primaryYellow, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: ExpertColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                val,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuLink(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: ExpertColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ExpertColors.borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: ExpertColors.primaryYellow, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: ExpertColors.textMuted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// My Reviews Screen (Image 3)
// -----------------------------------------------------------------------------
class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  bool _isLoading = true;
  List<dynamic> _reviews = [];
  int _selectedFilter = 0; // 0: All, 5: 5 Star, 4: 4 Star, 3: 3 Star

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    final data = await ApiService().getExpertReviews();
    if (mounted) {
      setState(() {
        _reviews = data ?? [];
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredReviews {
    if (_selectedFilter == 0) return _reviews;
    return _reviews.where((r) => r['rating'] == _selectedFilter).toList();
  }

  void _showReplyDialog(String clientName) {
    final TextEditingController replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: ExpertColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Reply to $clientName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: replyController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Write a professional thank you reply...',
              hintStyle: TextStyle(color: ExpertColors.textMuted),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: ExpertColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Reply sent to $clientName!'),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ExpertColors.primaryYellow,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'Send Reply',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: ExpertColors.primaryYellow,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Customer Reviews',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),

              // Overall rating card summary
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '4.9',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: ExpertColors.primaryYellow,
                            size: 16,
                          ),
                          Icon(
                            Icons.star,
                            color: ExpertColors.primaryYellow,
                            size: 16,
                          ),
                          Icon(
                            Icons.star,
                            color: ExpertColors.primaryYellow,
                            size: 16,
                          ),
                          Icon(
                            Icons.star,
                            color: ExpertColors.primaryYellow,
                            size: 16,
                          ),
                          Icon(
                            Icons.star,
                            color: ExpertColors.primaryYellow,
                            size: 16,
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '100% Satisfaction',
                        style: TextStyle(
                          color: ExpertColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  // Progress bars breakdown
                  Expanded(
                    child: Column(
                      children: [
                        _buildStarsProgress('5 Star', 0.94, '94%'),
                        _buildStarsProgress('4 Star', 0.05, '5%'),
                        _buildStarsProgress('3 Star', 0.01, '1%'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Star Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterPill('All Reviews', 0),
                    const SizedBox(width: 8),
                    _buildFilterPill('5 Stars ★', 5),
                    const SizedBox(width: 8),
                    _buildFilterPill('4 Stars ★', 4),
                    const SizedBox(width: 8),
                    _buildFilterPill('3 Stars ★', 3),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reviews list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: ExpertColors.primaryYellow,
                        ),
                      )
                    : _filteredReviews.isEmpty
                    ? const Center(
                        child: Text(
                          'No reviews found for this rating.',
                          style: TextStyle(color: ExpertColors.textMuted),
                        ),
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _filteredReviews.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final item = _filteredReviews[index];
                          final String clientName =
                              item['customerName'] ??
                              item['customer']?['name'] ??
                              'Client';
                          final String dateStr =
                              item['createdAt'] ?? 'Recently';
                          final int rating = item['rating'] ?? 5;
                          final String comment =
                              item['comment'] ??
                              item['reviewText'] ??
                              'Great experience talking with the expert!';
                          final String firstLetter = clientName.isNotEmpty
                              ? clientName[0].toUpperCase()
                              : 'C';

                          return _buildReviewCard(
                            clientName,
                            firstLetter,
                            dateStr,
                            rating,
                            comment,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, int value) {
    final bool isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ExpertColors.primaryYellow : ExpertColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? ExpertColors.primaryYellow
                : ExpertColors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStarsProgress(String label, double val, String percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          SizedBox(
            width: 45,
            child: Text(
              label,
              style: const TextStyle(
                color: ExpertColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: val,
                color: ExpertColors.primaryYellow,
                backgroundColor: Colors.white12,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              percent,
              style: const TextStyle(
                color: ExpertColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    String clientName,
    String firstLetter,
    String dateStr,
    int rating,
    String feedback,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ExpertColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: ExpertColors.primaryYellow.withValues(
                  alpha: 0.2,
                ),
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: ExpertColors.primaryYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(
                        5,
                        (idx) => Icon(
                          Icons.star_rounded,
                          color: idx < rating
                              ? ExpertColors.primaryYellow
                              : Colors.white24,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(
                  color: ExpertColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            feedback,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () => _showReplyDialog(clientName),
                child: const Row(
                  children: [
                    Icon(
                      Icons.reply_rounded,
                      color: ExpertColors.primaryYellow,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Reply',
                      style: TextStyle(
                        color: ExpertColors.primaryYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Availability Settings Screen (Image 5)
// -----------------------------------------------------------------------------
class AvailabilitySettingsScreen extends StatefulWidget {
  const AvailabilitySettingsScreen({super.key});

  @override
  State<AvailabilitySettingsScreen> createState() =>
      _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState
    extends State<AvailabilitySettingsScreen> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _isOnline = authProvider.user?['isOnline'] == true;
  }

  bool _autoAccept = true;
  bool _dnd = false;
  int _selectedDayIndex = 0;

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<Map<String, dynamic>> _slots = [
    {'time': '09:00 AM - 10:00 AM', 'available': true},
    {'time': '10:00 AM - 11:00 AM', 'available': true},
    {'time': '11:30 AM - 12:30 PM', 'available': true},
    {'time': '02:00 PM - 03:00 PM', 'available': true},
    {'time': '04:00 PM - 05:00 PM', 'available': false},
    {'time': '06:00 PM - 07:00 PM', 'available': true},
  ];

  void _addCustomSlot() {
    final TextEditingController timeController = TextEditingController(
      text: '08:00 PM - 09:00 PM',
    );
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: ExpertColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add Time Slot',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: timeController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'e.g. 08:00 PM - 09:00 PM',
              hintStyle: TextStyle(color: ExpertColors.textMuted),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(color: ExpertColors.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (timeController.text.isNotEmpty) {
                  setState(() {
                    _slots.add({
                      'time': timeController.text,
                      'available': true,
                    });
                  });
                }
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ExpertColors.primaryYellow,
                foregroundColor: Colors.black,
              ),
              child: const Text(
                'Add Slot',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAvailability() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await ApiService().toggleExpertStatus(_isOnline);
    } catch (_) {}
    if (mounted) {
      authProvider.refreshProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✅ Schedule & Availability Slots updated successfully!',
          ),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: ExpertColors.primaryYellow,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Schedule & Slots',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 20),

              // Option 1: You are Online Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isOnline
                      ? ExpertColors.primaryYellow
                      : ExpertColors.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isOnline
                        ? ExpertColors.primaryYellow
                        : ExpertColors.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You are Online',
                            style: TextStyle(
                              color: _isOnline ? Colors.black : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Clients can call & book slots now',
                            style: TextStyle(
                              color: _isOnline
                                  ? Colors.black87
                                  : ExpertColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isOnline,
                      activeTrackColor: Colors.black38,
                      activeThumbColor: Colors.black,
                      inactiveTrackColor: Colors.white12,
                      inactiveThumbColor: Colors.grey,
                      onChanged: (val) {
                        setState(() {
                          _isOnline = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Quick Controls Row
              Row(
                children: [
                  Expanded(
                    child: _buildSettingCard(
                      'Auto-Accept',
                      'Instant call connect',
                      _autoAccept,
                      (val) => setState(() => _autoAccept = val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSettingCard(
                      'Do Not Disturb',
                      'Pause calls',
                      _dnd,
                      (val) => setState(() => _dnd = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weekly Working Days Header
              const Text(
                'Weekly Schedule Days',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_days.length, (index) {
                  final bool isSelected = _selectedDayIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ExpertColors.primaryYellow
                            : ExpertColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? ExpertColors.primaryYellow
                              : ExpertColors.borderColor,
                        ),
                      ),
                      child: Text(
                        _days[index],
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Available Time Slots Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Slots (${_days[_selectedDayIndex]})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: ExpertColors.primaryYellow,
                      size: 24,
                    ),
                    onPressed: _addCustomSlot,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Slots List
              Column(
                children: _slots.map((slot) {
                  final bool isAvail = slot['available'] == true;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: ExpertColors.cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isAvail
                            ? ExpertColors.borderColor
                            : Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled_rounded,
                              color: isAvail
                                  ? ExpertColors.primaryYellow
                                  : ExpertColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              slot['time'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              slot['available'] = !isAvail;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAvail
                                  ? ExpertColors.primaryYellow.withValues(
                                      alpha: 0.15,
                                    )
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isAvail
                                    ? ExpertColors.primaryYellow
                                    : Colors.white24,
                              ),
                            ),
                            child: Text(
                              isAvail ? 'Available' : 'Disabled',
                              style: TextStyle(
                                color: isAvail
                                    ? ExpertColors.primaryYellow
                                    : ExpertColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAvailability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ExpertColors.primaryYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Schedule & Slots',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    String title,
    String subtitle,
    bool isSelected,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ExpertColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Switch(
                value: isSelected,
                activeTrackColor: ExpertColors.primaryYellow.withValues(
                  alpha: 0.4,
                ),
                activeThumbColor: ExpertColors.primaryYellow,
                inactiveTrackColor: Colors.white12,
                inactiveThumbColor: Colors.grey,
                onChanged: onChanged,
              ),
            ],
          ),
          Text(
            subtitle,
            style: const TextStyle(color: ExpertColors.textMuted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// Sparkline Painter for Dashboard Card Chart
// -----------------------------------------------------------------------------
class SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Curve line paint
    final linePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.75);
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.70,
      size.width * 0.25,
      size.height * 0.60,
    );
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.50,
      size.width * 0.45,
      size.height * 0.70,
    );
    path.quadraticBezierTo(
      size.width * 0.55,
      size.height * 0.90,
      size.width * 0.60,
      size.height * 0.70,
    );
    path.quadraticBezierTo(
      size.width * 0.70,
      size.height * 0.35,
      size.width * 0.80,
      size.height * 0.55,
    );
    path.quadraticBezierTo(
      size.width * 0.90,
      size.height * 0.70,
      size.width,
      size.height * 0.15,
    );

    // 2. Create a closed path to fill under the curve
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // 3. Draw gradient fill under the curve
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

    // 4. Draw the curve line
    canvas.drawPath(path, linePaint);

    // 5. Draw glowing peak data points
    final dotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    final dotStrokePaint = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Peaks coordinates
    final peaks = [
      Offset(size.width * 0.25, size.height * 0.60),
      Offset(size.width * 0.80, size.height * 0.55),
      Offset(size.width, size.height * 0.15),
    ];

    for (final peak in peaks) {
      canvas.drawCircle(peak, 4, dotPaint);
      canvas.drawCircle(peak, 4, dotStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Sub-view: Earnings Logs History (Image 4)
// -----------------------------------------------------------------------------
class EarningsLogsView extends StatefulWidget {
  const EarningsLogsView({super.key});

  @override
  State<EarningsLogsView> createState() => _EarningsLogsViewState();
}

class _EarningsLogsViewState extends State<EarningsLogsView> {
  String _selectedFilter = 'Today';
  Map<String, dynamic>? _earningsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEarnings();
  }

  Future<void> _fetchEarnings() async {
    setState(() {
      _isLoading = true;
    });
    final data = await ApiService().getExpertEarnings(_selectedFilter);
    if (mounted) {
      setState(() {
        _earningsData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalEarnings =
        _earningsData?['totalEarnings']?.toString() ?? '₹ 0.00';
    final breakdownRaw = _earningsData?['breakdown'];
    final breakdown = breakdownRaw is Map ? breakdownRaw : {};
    final callEarnings = breakdown['callEarnings']?.toString() ?? '₹ 0.00';
    final bonus = breakdown['bonus']?.toString() ?? '₹ 0.00';
    final tips = breakdown['tips']?.toString() ?? '₹ 0.00';
    final List<dynamic> hourlyList = (_earningsData?['hourlyBreakdown'] is List)
        ? (_earningsData!['hourlyBreakdown'] as List)
        : List.filled(12, 0);

    double maxVal = 1.0;
    for (var v in hourlyList) {
      final num d = num.tryParse(v.toString()) ?? 0;
      if (d > maxVal) maxVal = d.toDouble();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildFilterPill('Today'),
              const SizedBox(width: 10),
              _buildFilterPill('This Week'),
              const SizedBox(width: 10),
              _buildFilterPill('This Month'),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ExpertColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ExpertColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Earnings',
                  style: TextStyle(color: ExpertColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      totalEarnings,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Live Data',
                        style: TextStyle(
                          color: ExpertColors.primaryYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Hourly breakdown',
                  style: TextStyle(color: ExpertColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ExpertColors.primaryYellow,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: hourlyList.map((val) {
                            final num d = num.tryParse(val.toString()) ?? 0;
                            final double h = (d / maxVal * 110).clamp(
                              4.0,
                              110.0,
                            );
                            return _buildBar(h);
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '00',
                      style: TextStyle(
                        color: ExpertColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '06',
                      style: TextStyle(
                        color: ExpertColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '12',
                      style: TextStyle(
                        color: ExpertColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '18',
                      style: TextStyle(
                        color: ExpertColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '24',
                      style: TextStyle(
                        color: ExpertColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildBreakdownItem(
            Icons.phone_in_talk,
            'Call Earnings',
            callEarnings,
            Colors.yellow,
          ),
          _buildBreakdownItem(Icons.verified, 'Bonus', bonus, Colors.redAccent),
          _buildBreakdownItem(
            Icons.monetization_on,
            'Tips',
            tips,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String filter) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        if (_selectedFilter != filter) {
          setState(() {
            _selectedFilter = filter;
          });
          _fetchEarnings();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ExpertColors.primaryYellow : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ExpertColors.primaryYellow : Colors.white24,
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

  Widget _buildBar(double height) {
    return Container(
      width: 14,
      height: height,
      decoration: BoxDecoration(
        color: ExpertColors.primaryYellow,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBreakdownItem(
    IconData icon,
    String title,
    String val,
    Color iconCol,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ExpertColors.borderColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconCol.withValues(alpha: 0.15),
            child: Icon(icon, color: iconCol),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sub-view: Earnings Overview & Radial Progress Ring
// -----------------------------------------------------------------------------
class EarningsOverviewView extends StatelessWidget {
  const EarningsOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user ?? {};
    final double walletBalance =
        double.tryParse(user['walletBalance']?.toString() ?? '0') ?? 0.0;
    final String formattedBalance = '₹ ${walletBalance.toStringAsFixed(2)}';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 200,
              height: 200,
              margin: const EdgeInsets.symmetric(vertical: 24),
              child: CustomPaint(
                painter: BalanceRingPainter(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                          color: ExpertColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formattedBalance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Available to withdraw',
                        style: TextStyle(
                          color: ExpertColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatusDetailCard(
                  'Available',
                  formattedBalance,
                  ExpertColors.primaryYellow,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatusDetailCard(
                  'Pending',
                  '₹ 0.00',
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatusDetailCard(
                  'Withdrawn',
                  '₹ 0.00',
                  Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WithdrawScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ExpertColors.primaryYellow,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Withdraw Balance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDetailCard(String title, String val, Color dotCol) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: ExpertColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ExpertColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotCol,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: ExpertColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Balance Ring Painter
class BalanceRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final trackPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawCircle(center, radius, trackPaint);

    final activePaint = Paint()
      ..color = ExpertColors.primaryYellow
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5, // start angle
      4.8, // sweep angle
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// Withdraw Screen (Wallet Withdrawal - Image 1 of last batch)
// -----------------------------------------------------------------------------
class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  String _selectedMethod = 'Bank'; // 'Bank' or 'UPI'
  final TextEditingController _amountController = TextEditingController(
    text: '2500',
  );

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user ?? {};
    final double walletBalance =
        double.tryParse(user['walletBalance']?.toString() ?? '0') ?? 0.0;
    final String formattedBalance = '₹ ${walletBalance.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: ExpertColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Withdraw',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48), // Balancing spacer
                ],
              ),
              const SizedBox(height: 24),

              // Available Balance Card (Yellow Card)
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
                      color: ExpertColors.primaryYellow.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Balance',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            formattedBalance,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Minimum withdrawal ₹500',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Wallet Outline Container
                    Container(
                      width: 80,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          Positioned(
                            right: 8,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: ExpertColors.primaryYellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Small card outline visual inside
                          Positioned(
                            left: 8,
                            top: 8,
                            child: Container(
                              width: 32,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Select Withdraw Method Header
              const Text(
                'Select Withdraw Method',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Method 1: Bank Transfer
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMethod = 'Bank';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ExpertColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedMethod == 'Bank'
                          ? ExpertColors.primaryYellow
                          : ExpertColors.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedMethod == 'Bank'
                              ? ExpertColors.primaryYellow.withValues(
                                  alpha: 0.15,
                                )
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.account_balance_outlined,
                          color: _selectedMethod == 'Bank'
                              ? ExpertColors.primaryYellow
                              : Colors.white60,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bank Transfer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'HDFC Bank •••• 3456',
                              style: TextStyle(
                                color: ExpertColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedMethod == 'Bank'
                                ? ExpertColors.primaryYellow
                                : Colors.white30,
                            width: 2,
                          ),
                        ),
                        child: _selectedMethod == 'Bank'
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: ExpertColors.primaryYellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Method 2: UPI
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMethod = 'UPI';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ExpertColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedMethod == 'UPI'
                          ? ExpertColors.primaryYellow
                          : ExpertColors.borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedMethod == 'UPI'
                              ? ExpertColors.primaryYellow.withValues(
                                  alpha: 0.15,
                                )
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.qr_code_2_outlined,
                          color: _selectedMethod == 'UPI'
                              ? ExpertColors.primaryYellow
                              : Colors.white60,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'UPI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'ancy@yblupi',
                              style: TextStyle(
                                color: ExpertColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedMethod == 'UPI'
                                ? ExpertColors.primaryYellow
                                : Colors.white30,
                            width: 2,
                          ),
                        ),
                        child: _selectedMethod == 'UPI'
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: ExpertColors.primaryYellow,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Enter Amount section
              const Text(
                'Enter Amount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: ExpertColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ExpertColors.primaryYellow),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    const Text(
                      '₹ ',
                      style: TextStyle(
                        color: ExpertColors.primaryYellow,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Withdraw Now Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final double amt =
                        double.tryParse(_amountController.text) ?? 0.0;
                    if (amt < 500) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Minimum withdrawal amount is ₹500'),
                        ),
                      );
                      return;
                    }
                    await ApiService().requestPayoutWithdrawal(amt, {
                      'method': _selectedMethod,
                    });
                    if (mounted) {
                      Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).refreshProfile();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '🎉 Withdrawal request of ₹${amt.toStringAsFixed(2)} submitted successfully!',
                          ),
                        ),
                      );
                      Navigator.pop(context);
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
                    'Withdraw Now',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Withdrawal History Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Withdrawal History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: ExpertColors.primaryYellow,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mock history item
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ExpertColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ExpertColors.borderColor),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Withdrawn to HDFC Bank',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '18 July, 11:20 AM • Success',
                          style: TextStyle(
                            color: ExpertColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹ 5,000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
