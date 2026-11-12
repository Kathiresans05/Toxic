import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/providers/auth_provider.dart';
import 'package:expert_customer/services/api_service.dart';
import 'package:expert_customer/screens/call_screen.dart';
import 'package:expert_customer/screens/wallet_screens.dart';

// Explore Experts
class SearchExpertsScreen extends StatefulWidget {
  const SearchExpertsScreen({super.key});

  @override
  State<SearchExpertsScreen> createState() => _SearchExpertsScreenState();
}

class _SearchExpertsScreenState extends State<SearchExpertsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _filters = [
    'All',
    'Breakup & Heartbreak',
    'Vent Out & Confessions',
    'Friendly Listener',
    'Loneliness & Stress',
    'Love & Relationship',
    'Late Night Talks',
    'Career & Student Stress',
    'Life Motivation',
    'Price \u2193',
    'Rating'
  ];
  String _selectedFilter = 'All';

  final List<String> _languageFilters = ['All Languages', 'Tamil', 'English', 'Hindi', 'Telugu', 'Malayalam'];
  String _selectedLanguage = 'All Languages';
  final String _selectedStatus = 'All Status';

  List<dynamic> _experts = [];
  bool _isLoading = true;
  StreamSubscription? _expertsSub;

  @override
  void initState() {
    super.initState();
    _fetchExperts();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _expertsSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchExperts() async {
    _expertsSub?.cancel();
    try {
      final apiList = await _apiService.getOnlineExperts();
      if (mounted) {
        setState(() {
          _experts = apiList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('API fetch experts error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openFilterModal(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Experts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isLight ? const Color(0xFF0F172A) : Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Language', style: TextStyle(fontWeight: FontWeight.bold, color: isLight ? Colors.grey.shade700 : Colors.grey.shade400)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _languageFilters.map((lang) {
                              final isSel = lang == _selectedLanguage;
                              return ChoiceChip(
                                label: Text(lang),
                                selected: isSel,
                                onSelected: (val) {
                                  setModalState(() => _selectedLanguage = lang);
                                  setState(() {});
                                },
                                selectedColor: AppTheme.primary,
                                backgroundColor: isLight ? Colors.grey.shade100 : Colors.white12,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.black : (isLight ? Colors.black87 : Colors.white),
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 15),
                          Text('Category & Sort', style: TextStyle(fontWeight: FontWeight.bold, color: isLight ? Colors.grey.shade700 : Colors.grey.shade400)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _filters.map((cat) {
                              final isSel = cat == _selectedFilter;
                              return ChoiceChip(
                                label: Text(cat),
                                selected: isSel,
                                onSelected: (val) {
                                  setModalState(() => _selectedFilter = cat);
                                  setState(() {});
                                },
                                selectedColor: AppTheme.primary,
                                backgroundColor: isLight ? Colors.grey.shade100 : Colors.white12,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.black : (isLight ? Colors.black87 : Colors.white),
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isLight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : (isLight ? Colors.white : AppTheme.darkCardColor),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isLight ? AppTheme.lightCardBorder : Colors.white12),
            width: 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            else if (isLight)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.black),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.black
                    : (isLight ? const Color(0xFF475569) : Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filtered = _experts.where((e) {
      final user = e['user'] is Map ? e['user'] : {};
      final name = (user['fullName'] ?? user['name'] ?? e['name'] ?? '').toString().toLowerCase();
      final bio = (e['headline'] ?? e['bio'])?.toString().toLowerCase() ?? '';
      final cats = (e['categories'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? [];
      final langs = (e['languages'] as List<dynamic>?)?.map((l) => l.toString()).toList() ?? ['Tamil', 'English'];
      final isOnline = e['available'] == true || e['isOnline'] == true;
      final isBusy = e['isBusy'] == true;

      final query = _searchController.text.toLowerCase();
      final matchesSearch = name.contains(query) || bio.contains(query);

      if (!matchesSearch) return false;

      // Language Filter
      if (_selectedLanguage != 'All Languages') {
        final hasLang = langs.any((l) => l.toLowerCase() == _selectedLanguage.toLowerCase());
        if (!hasLang) return false;
      }

      // Status Filter
      if (_selectedStatus == 'Online 🟢' && (!isOnline || isBusy)) return false;
      if (_selectedStatus == 'Busy 🔴' && !isBusy) return false;
      if (_selectedStatus == 'Offline ⚪' && isOnline) return false;

      // Category Filter
      if (_selectedFilter != 'All' && _selectedFilter != 'Price \u2193' && _selectedFilter != 'Rating') {
        return cats.any((c) => c.toLowerCase().contains(_selectedFilter.toLowerCase()));
      }

      return true;
    }).toList();

    final authProvider = Provider.of<AuthProvider>(context);
    final userLangs = authProvider.preferredLanguages.map((l) => l.toLowerCase()).toList();

    if (_selectedFilter == 'Price \u2193') {
      filtered.sort((a, b) {
        final pa = double.tryParse((a['audioRatePerMin'] ?? a['pricePerMinute'])?.toString() ?? '0') ?? 0.0;
        final pb = double.tryParse((b['audioRatePerMin'] ?? b['pricePerMinute'])?.toString() ?? '0') ?? 0.0;
        return pb.compareTo(pa);
      });
    } else if (_selectedFilter == 'Rating') {
      filtered.sort((a, b) {
        final ra = double.tryParse((a['ratingAverage'] ?? a['rating'])?.toString() ?? '0') ?? 0.0;
        final rb = double.tryParse((b['ratingAverage'] ?? b['rating'])?.toString() ?? '0') ?? 0.0;
        return rb.compareTo(ra);
      });
    } else {
      filtered.sort((a, b) {
        final langsA = (a['languages'] as List<dynamic>?)?.map((l) => l.toString().toLowerCase()).toList() ?? [];
        final langsB = (b['languages'] as List<dynamic>?)?.map((l) => l.toString().toLowerCase()).toList() ?? [];

        final hasLangMatchA = langsA.any((l) => userLangs.contains(l));
        final hasLangMatchB = langsB.any((l) => userLangs.contains(l));

        if (hasLangMatchA != hasLangMatchB) {
          return hasLangMatchA ? -1 : 1;
        }

        final isOnlineA = (a['available'] == true || a['isOnline'] == true) && a['isBusy'] != true;
        final isOnlineB = (b['available'] == true || b['isOnline'] == true) && b['isBusy'] != true;
        if (isOnlineA != isOnlineB) {
          return isOnlineA ? -1 : 1;
        }

        final ra = double.tryParse((a['ratingAverage'] ?? a['rating'])?.toString() ?? '0') ?? 0.0;
        final rb = double.tryParse((b['ratingAverage'] ?? b['rating'])?.toString() ?? '0') ?? 0.0;
        return rb.compareTo(ra);
      });
    }

    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;
    final cardBg = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Explore Experts', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
                      boxShadow: isLight ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ] : [],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        hintText: 'Search experts...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _openFilterModal(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.white : cardBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
                      boxShadow: isLight ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ] : [],
                    ),
                    child: Icon(Icons.tune_rounded, color: AppTheme.primary, size: 22),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                : filtered.isEmpty
                    ? const Center(child: Text('No experts found', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final expert = filtered[index];
                          final user = expert['user'] is Map ? expert['user'] : {};
                          final name = user['fullName'] ?? user['name'] ?? expert['name'] ?? 'Expert';
                          final avatar = user['avatarUrl'] ?? user['profilePhotoUrl'] ?? expert['avatar'] ?? '';
                          final rating = double.tryParse((expert['ratingAverage'] ?? expert['rating'])?.toString() ?? '5.0') ?? 5.0;
                          final rate = double.tryParse((expert['audioRatePerMin'] ?? expert['pricePerMinute'])?.toString() ?? '5.0') ?? 5.0;
                          final expertLangs = (expert['languages'] as List<dynamic>?)?.map((l) => l.toString()).toList() ?? ['Tamil', 'English'];
                          final languages = expertLangs.join(', ');
                          final matchingLangs = expertLangs.where((l) => userLangs.contains(l.toLowerCase())).toList();
                          final hasLanguageMatch = matchingLangs.isNotEmpty;
                          final isOnline = expert['available'] == true || expert['isOnline'] == true;
                          final isBusy = expert['isBusy'] == true;
                          final statusColor = !isOnline ? Colors.grey : (isBusy ? Colors.red : Colors.green);
                          final statusText = !isOnline ? 'Offline' : (isBusy ? 'Busy' : 'Online');

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExpertProfileScreen(name: name, rate: rate, expert: expert),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white10),
                                boxShadow: isLight ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ] : null,
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: isLight ? Colors.grey.shade300 : Colors.grey.shade800,
                                        backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                        child: avatar.isEmpty
                                            ? Text(name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'E', style: TextStyle(color: textColor, fontWeight: FontWeight.bold))
                                            : null,
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: statusColor,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Wrap(
                                          spacing: 5,
                                          runSpacing: 4,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            const Icon(Icons.verified, color: AppTheme.primary, size: 13),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: statusColor.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: statusColor, width: 0.8),
                                              ),
                                              child: Text(
                                                statusText,
                                                style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.star, color: Colors.amber, size: 12),
                                                const SizedBox(width: 2),
                                                Text(rating.toStringAsFixed(1), style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                            if (hasLanguageMatch)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                                                ),
                                                child: Text(
                                                  '${matchingLangs.first} Match 🌟',
                                                  style: const TextStyle(color: Color(0xFFD97706), fontSize: 9, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Relationship • $languages',
                                          style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey, fontSize: 11),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 3),
                                        Text('₹${rate.toStringAsFixed(0)}/min', style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Audio Call Button (Secondary Emerald)
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CallScreen(
                                                expertName: name,
                                                expertId: (expert['id'] != null && expert['id'].toString().isNotEmpty) ? expert['id'] : (expert['user']?['id'] ?? ''),
                                                pricePerMinute: rate,
                                                callType: 'audio',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.secondary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.call_rounded, color: Colors.white, size: 19),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Video Call Button
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CallScreen(
                                                expertName: name,
                                                expertId: (expert['id'] != null && expert['id'].toString().isNotEmpty) ? expert['id'] : (expert['user']?['id'] ?? ''),
                                                pricePerMinute: rate * 1.5,
                                                callType: 'video',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: isLight ? Colors.grey.shade200 : Colors.white.withValues(alpha: 0.08),
                                            border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.white.withValues(alpha: 0.14), width: 1.0),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.videocam_rounded, color: textColor, size: 20),
                                        ),
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
        ],
      ),
    );
  }
}

// Expert Categories
class ExpertCategoriesScreen extends StatelessWidget {
  const ExpertCategoriesScreen({super.key});

  final List<Map<String, dynamic>> _categories = const [
    {'name': 'Breakup & Heartbreak', 'icon': Icons.heart_broken_rounded, 'color': Colors.pink},
    {'name': 'Vent Out & Confessions', 'icon': Icons.question_answer_rounded, 'color': Colors.orange},
    {'name': 'Friendly Listener', 'icon': Icons.headset_mic_rounded, 'color': Colors.amber},
    {'name': 'Loneliness & Stress', 'icon': Icons.spa_rounded, 'color': Colors.teal},
    {'name': 'Love & Relationship', 'icon': Icons.favorite_rounded, 'color': Colors.redAccent},
    {'name': 'Late Night Talks', 'icon': Icons.nights_stay_rounded, 'color': Colors.purple},
    {'name': 'Career & Student Stress', 'icon': Icons.work_rounded, 'color': Colors.blue},
    {'name': 'Life Motivation', 'icon': Icons.lightbulb_rounded, 'color': Colors.yellow},
  ];

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Categories')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpertListScreen(categoryName: cat['name'])),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: cat['color'].withOpacity(0.1),
                      child: Icon(cat['icon'], color: cat['color'], size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cat['name'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Expert List
class ExpertListScreen extends StatelessWidget {
  final String categoryName;
  const ExpertListScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text('$categoryName Experts')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) {
          final names = ['Sarah Jenkins', 'Rajesh Kumar', 'Monica Geller'];
          final rates = [5.0, 10.0, 8.0];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpertProfileScreen(name: names[index], rate: rates[index]),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 35),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(names[index], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Text('English • Tamil', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            const Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            Text('• ₹${rates[index].toStringAsFixed(0)}/min', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Expert Profile (Topmate & Superpeer Creator Style)
class ExpertProfileScreen extends StatefulWidget {
  final String name;
  final double rate;
  final Map<String, dynamic>? expert;

  const ExpertProfileScreen({
    super.key,
    this.name = 'Expert',
    this.rate = 5.0,
    this.expert,
  });

  @override
  State<ExpertProfileScreen> createState() => _ExpertProfileScreenState();
}

class _ExpertProfileScreenState extends State<ExpertProfileScreen> {
  bool _isFavorite = false;

  void _showCallChoiceSheet(BuildContext context, String expertName, String expertId, double audioRate, double videoRate) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? AppTheme.lightCardColor : AppTheme.darkCardColor;
    final primaryText = isLight ? AppTheme.lightTextPrimary : Colors.white;
    final secondaryText = isLight ? AppTheme.lightTextSecondary : Colors.grey;
    final tileBg = isLight ? AppTheme.lightBackground : AppTheme.darkBackground;
    final tileBorder = isLight ? AppTheme.lightCardBorder : Colors.white10;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isLight ? Colors.black12 : Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Connect with $expertName',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryText),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose your preferred consultation mode',
                style: TextStyle(color: secondaryText, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ListTile(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallScreen(
                        expertName: expertName,
                        expertId: expertId,
                        pricePerMinute: audioRate,
                        callType: 'audio',
                      ),
                    ),
                  );
                },
                tileColor: tileBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: tileBorder),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.call_rounded, color: Colors.green, size: 22),
                ),
                title: Text('Instant Voice Call', style: TextStyle(color: primaryText, fontWeight: FontWeight.bold)),
                subtitle: Text('Private & confidential • ₹${audioRate.toStringAsFixed(0)}/min', style: TextStyle(color: secondaryText, fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios_rounded, color: secondaryText, size: 16),
              ),
              const SizedBox(height: 12),
              ListTile(
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallScreen(
                        expertName: expertName,
                        expertId: expertId,
                        pricePerMinute: videoRate,
                        callType: 'video',
                      ),
                    ),
                  );
                },
                tileColor: tileBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: tileBorder),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: const Icon(Icons.videocam_rounded, color: AppTheme.primary, size: 22),
                ),
                title: Text('Face-to-Face Video Call', style: TextStyle(color: primaryText, fontWeight: FontWeight.bold)),
                subtitle: Text('HD Video Clarity • ₹${videoRate.toStringAsFixed(0)}/min', style: TextStyle(color: secondaryText, fontSize: 12)),
                trailing: Icon(Icons.arrow_forward_ios_rounded, color: secondaryText, size: 16),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expert = widget.expert;
    final user = expert?['user'] is Map ? expert!['user'] : {};
    final String expertName = user['fullName'] ?? user['name'] ?? expert?['name'] ?? widget.name;
    final String expertId = (expert?['id'] != null && expert!['id'].toString().isNotEmpty) ? expert['id'].toString() : (user['id']?.toString() ?? '');
    final double audioRate = double.tryParse((expert?['audioRatePerMin'] ?? expert?['audioCallRate'] ?? expert?['pricePerMinute'])?.toString() ?? '') ?? widget.rate;
    final double videoRate = double.tryParse((expert?['videoRatePerMin'] ?? expert?['videoCallRate'])?.toString() ?? '') ?? (audioRate * 1.5);
    final String avatar = user['profilePhotoUrl'] ?? user['avatarUrl'] ?? expert?['avatar'] ?? '';
    final String initialLetter = expertName.isNotEmpty ? expertName.substring(0, 1).toUpperCase() : 'E';
    final double rating = double.tryParse((expert?['ratingAverage'] ?? expert?['rating'])?.toString() ?? '') ?? 4.9;
    final int reviewsCount = int.tryParse(expert?['totalReviews']?.toString() ?? '') ?? 120;
    final String experience = '${expert?['experienceYears'] ?? 5}+ Years';
    final String headline = expert?['headline'] ?? 'Certified Relationship & Mindset Consultant';
    final List<dynamic> languagesList = expert?['languages'] as List<dynamic>? ?? ['Tamil', 'English'];
    final bool isOnline = expert?['available'] == true || expert?['isOnline'] == true;

    final isLight = Theme.of(context).brightness == Brightness.light;
    final Color bgColor = isLight ? AppTheme.lightBackground : AppTheme.darkBackground;
    final Color cardBg = isLight ? AppTheme.lightCardColor : AppTheme.darkCardColor;
    final Color cardBorder = isLight ? AppTheme.lightCardBorder : Colors.white.withValues(alpha: 0.08);
    final Color primaryText = isLight ? AppTheme.lightTextPrimary : Colors.white;
    final Color secondaryText = isLight ? AppTheme.lightTextSecondary : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Sleek Cover Banner + Overlapping Glowing Avatar Header
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cover Banner with Stack (clipBehavior: Clip.none so avatar overlaps seamlessly)
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Cover Banner Gradient
                        Container(
                          height: 170,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isLight
                                  ? const [
                                      Color(0xFFFFEDD5),
                                      Color(0xFFFED7AA),
                                      Color(0xFFF59E0B),
                                    ]
                                  : const [
                                      Color(0xFF1E293B),
                                      Color(0xFF0F172A),
                                      Color(0xFFD97706),
                                    ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                top: -20,
                                child: CircleAvatar(
                                  radius: 90,
                                  backgroundColor: AppTheme.primary.withValues(alpha: isLight ? 0.25 : 0.12),
                                ),
                              ),
                              // Top Verified Consultant Badge positioned at bottom right
                              Positioned(
                                right: 16,
                                bottom: 14,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isLight ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.primary.withValues(alpha: isLight ? 0.6 : 0.3)),
                                    boxShadow: isLight
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.auto_awesome, color: AppTheme.primary, size: 14),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Top Verified Consultant',
                                        style: TextStyle(
                                          color: isLight ? const Color(0xFFB45309) : AppTheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Back Button (Floating Glass)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: isLight ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.5),
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_rounded, color: primaryText, size: 20),
                              padding: EdgeInsets.zero,
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),

                        // Favorite Button (Floating Glass)
                        Positioned(
                          top: 16,
                          right: 16,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: isLight ? Colors.white.withValues(alpha: 0.85) : Colors.black.withValues(alpha: 0.5),
                            child: IconButton(
                              icon: Icon(
                                _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: _isFavorite ? Colors.redAccent : primaryText,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () => setState(() => _isFavorite = !_isFavorite),
                            ),
                          ),
                        ),

                        // Avatar overlapping the bottom edge without being cut off
                        Positioned(
                          left: 20,
                          bottom: -46,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.primary, width: 3.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withValues(alpha: isLight ? 0.45 : 0.4),
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundColor: isLight ? const Color(0xFFFDE8D7) : const Color(0xFF1E293B),
                                  backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                  child: avatar.isEmpty
                                      ? Text(
                                          initialLetter,
                                          style: const TextStyle(
                                            fontSize: 38,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primary,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                right: 4,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: isOnline ? Colors.green : Colors.grey,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: bgColor, width: 3.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Content below overlapping avatar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Badge Row aligned right to give avatar breathing room
                          SizedBox(
                            height: 52,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isOnline ? Colors.green.withValues(alpha: isLight ? 0.12 : 0.15) : (isLight ? Colors.grey.shade200 : Colors.white10),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isOnline ? Colors.green : (isLight ? Colors.grey.shade300 : Colors.white24), width: 1),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle, color: isOnline ? Colors.green : Colors.grey, size: 8),
                                      const SizedBox(width: 6),
                                      Text(
                                        isOnline ? 'Available Now' : 'Offline',
                                        style: TextStyle(
                                          color: isOnline ? (isLight ? const Color(0xFF047857) : Colors.green) : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Name & Verified Badge
                          Row(
                            children: [
                              Text(
                                expertName,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: primaryText,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.verified, color: AppTheme.primary, size: 22),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            headline,
                            style: TextStyle(color: secondaryText, fontSize: 14, height: 1.3),
                          ),
                          const SizedBox(height: 14),

                            // Micro info row: Rating, response time, languages
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ExpertReviewsScreen(expertName: expertName)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                      const SizedBox(width: 3),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        ' ($reviewsCount Reviews)',
                                        style: TextStyle(color: secondaryText, fontSize: 12, decoration: TextDecoration.underline),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.bolt_rounded, color: AppTheme.primary, size: 16),
                                    const SizedBox(width: 2),
                                    Text('~2 min response', style: TextStyle(color: secondaryText, fontSize: 12)),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.translate_rounded, color: secondaryText, size: 14),
                                    const SizedBox(width: 4),
                                    Text(languagesList.join(', '), style: TextStyle(color: secondaryText, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            // Glassmorphic Stats Row
                            Row(
                              children: [
                                Expanded(child: _buildModernStat(icon: Icons.workspace_premium_rounded, label: 'Experience', value: experience)),
                                const SizedBox(width: 10),
                                Expanded(child: _buildModernStat(icon: Icons.favorite_rounded, label: 'Clients', value: '120+ Happy')),
                                const SizedBox(width: 10),
                                Expanded(child: _buildModernStat(icon: Icons.phone_in_talk_rounded, label: 'Consultations', value: '250+ Calls')),
                              ],
                            ),
                            const SizedBox(height: 26),

                            // 5. Consultation Options Cards (Topmate Services)
                            Text(
                              'Consultation Services ⚡',
                              style: TextStyle(color: primaryText, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),

                            // Service 1: Audio Call Card
                            _buildServiceCard(
                              icon: Icons.call_rounded,
                              iconBg: Colors.green.withValues(alpha: 0.15),
                              iconColor: Colors.green,
                              title: 'Instant 1-on-1 Voice Call',
                              subtitle: 'Instant private connection. Billed per minute.',
                              priceText: '₹${audioRate.toStringAsFixed(0)} / min',
                              buttonText: 'Call Now',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CallScreen(
                                    expertName: expertName,
                                    expertId: expertId,
                                    pricePerMinute: audioRate,
                                    callType: 'audio',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Service 2: Video Call Card
                            _buildServiceCard(
                              icon: Icons.videocam_rounded,
                              iconBg: AppTheme.primary.withValues(alpha: 0.15),
                              iconColor: AppTheme.primary,
                              title: 'Face-to-Face Video Consultation',
                              subtitle: 'HD clarity for deep discussions & body language.',
                              priceText: '₹${videoRate.toStringAsFixed(0)} / min',
                              buttonText: 'Video Call',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CallScreen(
                                    expertName: expertName,
                                    expertId: expertId,
                                    pricePerMinute: videoRate,
                                    callType: 'video',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Service 3: Dedicated Slot Booking
                            _buildServiceCard(
                              icon: Icons.calendar_month_rounded,
                              iconBg: Colors.amber.withValues(alpha: 0.15),
                              iconColor: Colors.amber,
                              title: 'Pre-book Dedicated Slot (Escrow)',
                              subtitle: 'Reserve guaranteed time slot (15, 30, or 60 Mins).',
                              priceText: 'From ₹${(audioRate * 15).toStringAsFixed(0)}',
                              buttonText: 'View Slots',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExpertAvailabilityScreen(
                                    expertName: expertName,
                                    audioRate: audioRate,
                                    videoRate: videoRate,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Specializations & Topics
                            Text(
                              'Specializations & Topics 🎯',
                              style: TextStyle(color: primaryText, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                '#RelationshipGuidance',
                                '#BreakupHealing',
                                '#StressRelief',
                                '#CareerClarity',
                                '#FriendlyListener',
                                '#LifeMotivation',
                              ].map((topic) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isLight ? const Color(0xFFFDE8D7) : AppTheme.primary.withValues(alpha: 0.4)),
                                    boxShadow: isLight
                                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))]
                                        : null,
                                  ),
                                  child: Text(
                                    topic,
                                    style: TextStyle(
                                      color: isLight ? const Color(0xFFB45309) : AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 120), // Bottom padding for sticky action bar
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          // 9. Sticky Floating Glass Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: cardBg.withValues(alpha: 0.96),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: cardBorder, width: 1.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isLight ? 0.08 : 0.5),
                    blurRadius: isLight ? 16 : 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Price tag
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rate per min', style: TextStyle(color: secondaryText, fontSize: 11)),
                        Text(
                          '₹${audioRate.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isLight ? const Color(0xFFD97706) : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 18),

                    // Book Slot Button
                    Expanded(
                      flex: 4,
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ExpertAvailabilityScreen(
                                  expertName: expertName,
                                  audioRate: audioRate,
                                  videoRate: videoRate,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 18),
                          label: const Text('Book Slot', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primary, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Instant Call Button
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () => _showCallChoiceSheet(context, expertName, expertId, audioRate, videoRate),
                          icon: const Icon(Icons.bolt_rounded, color: Colors.black, size: 20),
                          label: const Text('Call Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                          ),
                        ),
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
  }

  Widget _buildModernStat({required IconData icon, required String label, required String value}) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? AppTheme.lightCardColor : AppTheme.darkCardColor;
    final cardBorder = isLight ? AppTheme.lightCardBorder : Colors.white.withValues(alpha: 0.08);
    final primaryText = isLight ? AppTheme.lightTextPrimary : Colors.white;
    final secondaryText = isLight ? AppTheme.lightTextSecondary : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: isLight
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]
            : null,
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: secondaryText, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String priceText,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cardBg = isLight ? AppTheme.lightCardColor : AppTheme.darkCardColor;
    final cardBorder = isLight ? AppTheme.lightCardBorder : Colors.white.withValues(alpha: 0.08);
    final primaryText = isLight ? AppTheme.lightTextPrimary : Colors.white;
    final secondaryText = isLight ? AppTheme.lightTextSecondary : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorder),
        boxShadow: isLight
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: primaryText, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: secondaryText, fontSize: 12)),
                const SizedBox(height: 4),
                Text(priceText, style: TextStyle(color: isLight ? const Color(0xFFD97706) : AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// Expert Reviews
class ExpertReviewsScreen extends StatelessWidget {
  final String expertName;
  const ExpertReviewsScreen({super.key, required this.expertName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: Text('$expertName Reviews')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) {
          final clients = ['Rahul', 'Anitha', 'Dinesh'];
          final feedbacks = [
            'Very helpful advice, cleared all my doubts instantly!',
            'Patient listener and gave clean directives.',
            'Decent call, rate is fully justified.'
          ];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardColor, borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(clients[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        Icon(Icons.star, color: Colors.orange, size: 16),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(feedbacks[index], style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Expert Availability & Slot Booking (Option 1: Full Amount Wallet Deduction)
class ExpertAvailabilityScreen extends StatefulWidget {
  final String expertName;
  final double audioRate;
  final double videoRate;

  const ExpertAvailabilityScreen({
    super.key,
    required this.expertName,
    this.audioRate = 15.0,
    this.videoRate = 30.0,
  });

  @override
  State<ExpertAvailabilityScreen> createState() => _ExpertAvailabilityScreenState();
}

class _ExpertAvailabilityScreenState extends State<ExpertAvailabilityScreen> {
  String _selectedDay = 'Mon';
  int _selectedDuration = 30; // default 30 mins
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<int> _durations = [15, 30, 45, 60];
  final Set<String> _bookedSlots = {'04:00 PM - 05:00 PM'};

  final List<String> _slotTimes = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:30 AM - 12:30 PM',
    '02:00 PM - 03:00 PM',
    '04:00 PM - 05:00 PM',
    '06:00 PM - 07:00 PM',
  ];

  double _calculatePrice(int minutes) {
    return widget.audioRate * minutes;
  }

  void _showBookingSheet(String time) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    int currentDuration = _selectedDuration;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final user = authProvider.user ?? {};
            final double walletBalance = double.tryParse(user['walletBalance']?.toString() ?? '0') ?? 0.0;
            final double price = _calculatePrice(currentDuration);
            final bool hasSufficientBalance = walletBalance >= price;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Confirm Slot Booking',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primary, width: 0.8),
                        ),
                        child: Text(
                          '$_selectedDay Slot',
                          style: const TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Duration selector inside sheet
                  const Text('Select Duration', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: _durations.map((d) {
                      final isSel = currentDuration == d;
                      final fee = _calculatePrice(d);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setModalState(() => currentDuration = d);
                            setState(() => _selectedDuration = d);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel ? AppTheme.primary : AppTheme.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSel ? AppTheme.primary : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$d Min',
                                  style: TextStyle(
                                    color: isSel ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₹${fee.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: isSel ? Colors.black87 : AppTheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Summary Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Expert Name', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text(widget.expertName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        const Divider(height: 20, color: Colors.white10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Scheduled Time', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                        const Divider(height: 20, color: Colors.white10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Rate per Minute', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text('₹${widget.audioRate.toStringAsFixed(0)}/min', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                        const Divider(height: 20, color: Colors.white10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Calculated Fee ($currentDuration mins)', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            Text('₹${price.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wallet status
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: hasSufficientBalance
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.orange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasSufficientBalance ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasSufficientBalance ? Icons.account_balance_wallet : Icons.warning_amber_rounded,
                          color: hasSufficientBalance ? Colors.green : Colors.orange,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wallet Balance: ₹${walletBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: hasSufficientBalance ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                hasSufficientBalance
                                    ? 'Exact amount will be held in Escrow until session'
                                    : 'Insufficient balance. Need ₹${(price - walletBalance).toStringAsFixed(0)} more.',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (hasSufficientBalance)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await authProvider.rechargeWallet(-price);
                          setState(() {
                            _bookedSlots.add(time);
                          });
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                backgroundColor: AppTheme.cardColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                                    SizedBox(width: 10),
                                    Text('Slot Booked!', style: TextStyle(color: Colors.white, fontSize: 18)),
                                  ],
                                ),
                                content: Text(
                                  'Appointment confirmed with ${widget.expertName} on $_selectedDay at $time.\n\n'
                                  'Duration: $currentDuration Mins\n'
                                  'Advance amount ₹${price.toStringAsFixed(0)} safely held in Escrow.',
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx),
                                    child: const Text('OK', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          'Confirm & Pay ₹${price.toStringAsFixed(0)} ➔',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddMoneyScreen()),
                          );
                        },
                        icon: const Icon(Icons.add, color: Colors.black),
                        label: const Text(
                          'Recharge Wallet ➔',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Schedule & Slots', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expert Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      widget.expertName.isNotEmpty ? widget.expertName[0].toUpperCase() : 'E',
                      style: const TextStyle(color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.expertName,
                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: AppTheme.primary, size: 16),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Audio: ₹${widget.audioRate.toStringAsFixed(0)}/min • Video: ₹${widget.videoRate.toStringAsFixed(0)}/min',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Weekly Days Selection
            const Text(
              '1. Select Consultation Day',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _days.map((day) {
                  final isSelected = _selectedDay == day;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Duration Selector on Main Screen
            const Text(
              '2. Select Consultation Duration',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: _durations.map((duration) {
                final isSelected = _selectedDuration == duration;
                final fee = _calculatePrice(duration);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDuration = duration),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$duration Mins',
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${fee.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: isSelected ? Colors.black87 : AppTheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Available Slots Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '3. Available Slots ($_selectedDay)',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Escrow Protected 🔒',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Slots List
            Expanded(
              child: ListView.builder(
                itemCount: _slotTimes.length,
                itemBuilder: (context, index) {
                  final time = _slotTimes[index];
                  final isBooked = _bookedSlots.contains(time);
                  final double price = _calculatePrice(_selectedDuration);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isBooked ? Colors.white10 : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: isBooked ? Colors.grey : AppTheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: isBooked ? Colors.grey : Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '$_selectedDuration Mins • Fee: ₹${price.toStringAsFixed(0)} (₹${widget.audioRate.toStringAsFixed(0)}/min)',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isBooked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Booked 🔒',
                              style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: () => _showBookingSheet(time),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Book', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Random Match Radar
class RandomMatchScreen extends StatefulWidget {
  const RandomMatchScreen({super.key});

  @override
  State<RandomMatchScreen> createState() => _RandomMatchScreenState();
}

class _RandomMatchScreenState extends State<RandomMatchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matched with Expert Sarah! Connecting call...')),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Random Match')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: RadarPainter(_controller.value),
                  child: Container(
                    width: 250,
                    height: 250,
                    alignment: Alignment.center,
                    child: const CircleAvatar(
                      radius: 35,
                      backgroundColor: AppTheme.primary,
                      child: Icon(Icons.flash_on, size: 40, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text('Searching for Online Experts...', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Finding the best available consultant in your language', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double progress;
  RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 1 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    canvas.drawCircle(center, maxRadius * progress, paint);
    canvas.drawCircle(center, maxRadius * ((progress + 0.5) % 1.0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
