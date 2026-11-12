import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/services/api_service.dart';
import 'package:expert_customer/screens/call_screen.dart';
import 'package:expert_customer/screens/dashboard_screens.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  List<dynamic> _liveCallHistory = [];
  bool _isLoadingHistory = true;

  List<dynamic> _onlineExperts = [];
  bool _isLoadingExperts = true;
  Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadCallHistory(),
      _loadFavoritesAndExperts(),
    ]);
  }

  Future<void> _loadCallHistory() async {
    try {
      final history = await _apiService.getCallHistory();
      if (mounted) {
        setState(() {
          _liveCallHistory = history;
          _isLoadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  Future<void> _loadFavoritesAndExperts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFavs = prefs.getStringList('saved_favorite_expert_ids') ?? [];

      final experts = await _apiService.getOnlineExperts();
      if (mounted) {
        setState(() {
          _favoriteIds = savedFavs.toSet();
          _onlineExperts = experts;
          _isLoadingExperts = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingExperts = false);
      }
    }
  }

  Future<void> _toggleFavorite(String expertId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteIds.contains(expertId)) {
        _favoriteIds.remove(expertId);
      } else {
        _favoriteIds.add(expertId);
      }
    });
    await prefs.setStringList('saved_favorite_expert_ids', _favoriteIds.toList());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
      final timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      if (isToday) return 'Today, $timeStr';
      return '${dt.day}/${dt.month}/${dt.year}, $timeStr';
    } catch (_) {
      return raw;
    }
  }

  String _formatDuration(int? seconds) {
    final s = seconds ?? 0;
    if (s <= 0) return '0 min';
    final m = s ~/ 60;
    final remainingS = s % 60;
    if (m == 0) return '${remainingS}s';
    return '$m min ${remainingS}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardBg = Theme.of(context).cardColor;
    final borderColor = isDark ? Colors.white12 : AppTheme.lightCardBorder;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Calls & Favorites', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: AppTheme.primary,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.black,
              unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Call History'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_rounded, size: 16, color: Colors.redAccent),
                      SizedBox(width: 6),
                      Text('Saved Favorites'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCallHistoryTab(isDark, textColor, cardBg, borderColor),
            _buildFavoritesTab(isDark, textColor, cardBg, borderColor),
          ],
        ),
      ),
    );
  }

  Widget _buildCallHistoryTab(bool isDark, Color textColor, Color cardBg, Color borderColor) {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    // If database has live calls, display them
    final list = _liveCallHistory.isNotEmpty
        ? _liveCallHistory
        : [
            // Sample placeholder if no calls made yet
            {
              'expertName': 'Priya Sharma',
              'headline': 'Relationship Advisor',
              'callType': 'AUDIO',
              'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
              'durationSeconds': 720,
              'totalAmount': 120.0,
              'status': 'COMPLETED',
            },
            {
              'expertName': 'Dr. Karthik R',
              'headline': 'Life & Career Coach',
              'callType': 'VIDEO',
              'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
              'durationSeconds': 1080,
              'totalAmount': 270.0,
              'status': 'COMPLETED',
            },
            {
              'expertName': 'Ananya Verma',
              'headline': 'Friendly Listener',
              'callType': 'AUDIO',
              'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
              'durationSeconds': 1500,
              'totalAmount': 200.0,
              'status': 'COMPLETED',
            },
          ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final name = (item['expertName'] ?? item['name'] ?? 'Expert').toString();
        final role = (item['headline'] ?? item['role'] ?? 'Consultant').toString();
        final callType = (item['callType'] ?? 'AUDIO').toString().toUpperCase();
        final isVideo = callType == 'VIDEO';
        final duration = _formatDuration(int.tryParse(item['durationSeconds']?.toString() ?? '0'));
        final dateStr = _formatDateTime(item['createdAt']?.toString() ?? item['date']?.toString());
        final amount = '₹${item['totalAmount'] ?? item['amount'] ?? '0'}';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.25),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'E',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: TextStyle(color: isDark ? Colors.grey : AppTheme.lightTextSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                          size: 13,
                          color: const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$duration • $dateStr',
                          style: TextStyle(color: isDark ? Colors.white60 : Colors.black45, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFD97706)),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchExpertsScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.call_rounded, size: 12, color: Colors.black),
                          SizedBox(width: 4),
                          Text('Call Again', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab(bool isDark, Color textColor, Color cardBg, Color borderColor) {
    if (_isLoadingExperts) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    // Filter live experts that user marked as favorite, or show available experts with toggle
    List<dynamic> favorites = [];
    if (_onlineExperts.isNotEmpty) {
      if (_favoriteIds.isNotEmpty) {
        favorites = _onlineExperts.where((e) {
          final id = (e['id'] ?? e['user']?['id'] ?? '').toString();
          return _favoriteIds.contains(id);
        }).toList();
      }
      // If none marked yet, show all online experts as suggestion
      if (favorites.isEmpty) {
        favorites = _onlineExperts;
      }
    } else {
      // Default initial favorites list
      favorites = [
        {
          'id': 'exp_1',
          'name': 'Priya Sharma',
          'headline': 'Breakup & Emotional Healing Expert',
          'ratingAverage': 4.9,
          'audioRatePerMin': 10,
          'available': true,
        },
        {
          'id': 'exp_2',
          'name': 'Dr. Karthik R',
          'headline': 'Career Clarity & Stress Relief Coach',
          'ratingAverage': 4.8,
          'audioRatePerMin': 15,
          'available': true,
        },
        {
          'id': 'exp_3',
          'name': 'Ananya Verma',
          'headline': 'Late Night Friendly Listener',
          'ratingAverage': 5.0,
          'audioRatePerMin': 8,
          'available': false,
        },
      ];
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final expert = favorites[index];
        final expId = (expert['id'] ?? expert['user']?['id'] ?? 'exp_$index').toString();
        final name = expert['user']?['fullName'] ?? expert['name'] ?? 'Expert';
        final headline = expert['headline'] ?? 'Consultant';
        final rating = expert['ratingAverage']?.toString() ?? '5.0';
        final rate = expert['audioRatePerMin']?.toString() ?? '10';
        final isAvailable = expert['available'] == true;
        final isFav = _favoriteIds.contains(expId) || _favoriteIds.isEmpty;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.25),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'E',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 17),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: isAvailable ? const Color(0xFF10B981) : Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: cardBg, width: 2),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _toggleFavorite(expId),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 17,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      headline,
                      style: TextStyle(color: isDark ? Colors.grey : AppTheme.lightTextSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFB800)),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹$rate/min',
                          style: const TextStyle(color: Color(0xFFD97706), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  final expertUserId = expert['user']?['id']?.toString() ?? expert['userId']?.toString() ?? expId;
                  final price = double.tryParse(rate) ?? 10.0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallScreen(
                        expertId: expertUserId,
                        expertName: name,
                        callType: 'audio',
                        pricePerMinute: price,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.call_rounded, size: 14, color: Colors.black),
                      SizedBox(width: 4),
                      Text('Call', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
