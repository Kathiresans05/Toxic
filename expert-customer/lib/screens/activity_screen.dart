import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expert_customer/services/api_service.dart';
import 'package:expert_customer/screens/call_screen.dart';
import 'package:expert_customer/screens/dashboard_screens.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => ActivityScreenState();
}

class ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
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

  Future<void> reload() async {
    await _loadAllData();
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

  LinearGradient _getAvatarGradient(String name) {
    final lower = name.trim().toLowerCase();
    int hash = 0;
    for (int i = 0; i < lower.length; i++) {
      hash = (hash * 31 + lower.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    final index = hash % 6;
    switch (index) {
      case 0:
        return const LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFFB7185)]); // Rose / Coral
      case 1:
        return const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA855F7)]); // Purple / Violet
      case 2:
        return const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF38BDF8)]); // Ocean / Cyan
      case 3:
        return const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)]); // Warm Amber / Gold
      case 4:
        return const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF818CF8)]); // Royal Indigo / Blue
      default:
        return const LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF2DD4BF)]); // Teal / Turquoise
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0B3543);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? Colors.white12 : const Color(0xFFF5DFC9);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFFEE8D1),
      appBar: AppBar(
        title: const Text(
          'Calls & Favorites',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white, letterSpacing: 0.2),
        ),
        centerTitle: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0C4F3E), Color(0xFF073328)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: const Color(0xFF0C4F3E),
              unselectedLabelColor: Colors.white.withValues(alpha: 0.85),
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
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
                      Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFE11D48)),
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
      body: Stack(
        children: [
          // Warm Apricot Peach Background matching Login & Dashboard
          Positioned.fill(
            child: Container(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFEE8D1),
            ),
          ),
          RefreshIndicator(
            color: const Color(0xFF0C4F3E),
            onRefresh: _loadAllData,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCallHistoryTab(isDark, textColor, cardBg, borderColor),
                _buildFavoritesTab(isDark, textColor, cardBg, borderColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallHistoryTab(bool isDark, Color textColor, Color cardBg, Color borderColor) {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0C4F3E)));
    }

    if (_liveCallHistory.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFF5DFC9)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6E431E).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C4F3E).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_missed_rounded, size: 48, color: Color(0xFF0C4F3E)),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No Call History Yet',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0B3543),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your completed consultation calls with experts will be recorded here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey : const Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchExpertsScreen()),
                      );
                    },
                    icon: const Icon(Icons.call_rounded, size: 16, color: Colors.white),
                    label: const Text(
                      'Browse Online Experts',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C4F3E),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final list = _liveCallHistory;

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
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF0C4F3E).withValues(alpha: 0.12),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'E',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0C4F3E), fontSize: 17),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0B3543),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role,
                      style: TextStyle(color: isDark ? Colors.grey : const Color(0xFF64748B), fontSize: 12),
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
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFFC89153)),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchExpertsScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C4F3E),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0C4F3E).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.call_rounded, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Call Again', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0C4F3E)));
    }

    if (_favoriteIds.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFF5DFC9)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6E431E).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_border_rounded, size: 48, color: Color(0xFFE11D48)),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No Saved Favorites Yet',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0B3543),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any expert\'s profile to add them to your saved favorites list.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey : const Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchExpertsScreen()),
                      );
                    },
                    icon: const Icon(Icons.search_rounded, size: 16, color: Colors.white),
                    label: const Text(
                      'Explore Experts',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C4F3E),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final favorites = _onlineExperts.where((e) {
      final id = (e['id'] ?? e['user']?['id'] ?? '').toString();
      return _favoriteIds.contains(id);
    }).toList();

    if (favorites.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFF5DFC9)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6E431E).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite_rounded, size: 48, color: Color(0xFFE11D48)),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Favorites Currently Offline',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0B3543),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your saved expert consultants will appear here as soon as they come online.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey : const Color(0xFF64748B),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SearchExpertsScreen()),
                      );
                    },
                    icon: const Icon(Icons.call_rounded, size: 16, color: Colors.white),
                    label: const Text(
                      'Browse Online Experts',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C4F3E),
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
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
        final isFav = _favoriteIds.contains(expId);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFF5DFC9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6E431E).withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF0C4F3E).withValues(alpha: 0.12),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'E',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0C4F3E), fontSize: 17),
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
                        border: Border.all(color: isDark ? const Color(0xFF131823) : Colors.white, width: 2),
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
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF0B3543),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
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
                            color: const Color(0xFFE11D48),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      headline,
                      style: TextStyle(color: isDark ? Colors.grey : const Color(0xFF64748B), fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFE5A93B)),
                        const SizedBox(width: 3),
                        Text(
                          rating,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF0B3543),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹$rate/min',
                          style: const TextStyle(color: Color(0xFFC89153), fontSize: 11, fontWeight: FontWeight.bold),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C4F3E),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C4F3E).withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.call_rounded, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
