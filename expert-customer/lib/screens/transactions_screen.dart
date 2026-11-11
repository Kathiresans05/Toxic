import 'package:flutter/material.dart';
import 'package:expert_customer/theme/app_theme.dart';
import 'package:expert_customer/services/api_service.dart';
import 'package:expert_customer/screens/call_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  List<dynamic> _callLogs = [];
  List<dynamic> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchHistoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final txResponse = await _apiService.client.get('/users/transactions');
      if (txResponse.statusCode == 200 || txResponse.statusCode == 201) {
        _transactions = txResponse.data;
      }
    } catch (e) {
      print('Fetch Transactions Error: $e');
    }

    try {
      final callResponse = await _apiService.client.get('/calls/history');
      if (callResponse.statusCode == 200 || callResponse.statusCode == 201) {
        final List<dynamic> logs = callResponse.data;
        _callLogs = logs.map((log) {
          final expert = log['expert'] ?? {};
          final expertUser = expert['user'] ?? {};
          final createdAtStr = log['createdAt'] != null
              ? DateTime.parse(log['createdAt']).toLocal().toString().substring(0, 16)
              : 'Recent';
          final durationSecs = log['durationSeconds'] ?? 0;
          final durationMins = (durationSecs / 60).ceil();

          return {
            'id': log['id']?.toString() ?? '',
            'companionName': expertUser['name']?.toString() ?? 'Expert',
            'companionId': expert['id']?.toString() ?? '',
            'callType': log['channelName']?.toString().contains('video') == true ? 'video' : 'audio',
            'durationMinutes': durationMins,
            'amountCharged': double.tryParse(log['amountCharged']?.toString() ?? '0') ?? 0.0,
            'pricePerMinute': double.tryParse(expert['pricePerMinute']?.toString() ?? '10.0') ?? 10.0,
            'date': createdAtStr,
            'status': log['status']?.toString() ?? 'Completed',
          };
        }).toList();
      } else {
        _callLogs = [];
      }
    } catch (e) {
      print('Fetch Call Logs Error: $e');
      _callLogs = [];
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('History & Statements', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: isLight ? Colors.grey.shade600 : Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: '📞 Call Logs'),
            Tab(text: '💳 Wallet Txns'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCallLogsTab(),
                _buildTransactionsTab(),
              ],
            ),
    );
  }

  Widget _buildCallLogsTab() {
    if (_callLogs.isEmpty) {
      return const Center(
        child: Text('No call logs recorded yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistoryData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _callLogs.length,
        itemBuilder: (context, index) {
          final log = _callLogs[index];
          final String companionName = log['companionName'] ?? 'Companion';
          final String companionId = log['companionId'] ?? '';
          final String callType = log['callType'] ?? 'audio';
          final int duration = log['durationMinutes'] ?? 0;
          final double amountCharged = double.tryParse(log['amountCharged']?.toString() ?? '0') ?? 0.0;
          final double pricePerMinute = double.tryParse(log['pricePerMinute']?.toString() ?? '10') ?? 10.0;
          final String date = log['date'] ?? '';
          final isVideo = callType == 'video';
          final isLight = Theme.of(context).brightness == Brightness.light;
          final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white.withValues(alpha: 0.05)),
              boxShadow: isLight ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ] : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isVideo ? const Color(0xFFE91E63).withValues(alpha: 0.2) : AppTheme.primary.withValues(alpha: 0.2),
                      child: Icon(
                        isVideo ? Icons.videocam : Icons.call,
                        color: isVideo ? const Color(0xFFE91E63) : AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companionName,
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${isVideo ? "Video" : "Audio"} Call • $duration mins • $date',
                            style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '- ₹${amountCharged.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Divider(color: isLight ? Colors.grey.shade200 : Colors.white10, height: 1),
                const SizedBox(height: 10),

                // Action Bar: Instant Call Back
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CallScreen(
                              expertName: companionName,
                              expertId: companionId,
                              pricePerMinute: pricePerMinute,
                              callType: callType,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.call, size: 16, color: Colors.black),
                      label: const Text('Call Back 📞', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  String _selectedTxFilter = 'All Txns';

  Widget _buildTransactionsTab() {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF0F172A) : Colors.white;

    List<dynamic> filteredTxns = _transactions.where((tx) {
      final amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
      if (_selectedTxFilter == 'Recharges (+)' && amount <= 0) return false;
      if (_selectedTxFilter == 'Debits (-)' && amount >= 0) return false;
      return true;
    }).toList();

    return Column(
      children: [
        // Txn Statement Filter Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['All Txns', 'Recharges (+)', 'Debits (-)'].map((filter) {
              final isSelected = filter == _selectedTxFilter;
              return ChoiceChip(
                label: Text(filter, style: const TextStyle(fontSize: 12)),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    _selectedTxFilter = filter;
                  });
                },
                backgroundColor: Theme.of(context).cardColor,
                selectedColor: isSelected
                    ? (filter.contains('+') ? Colors.green : (filter.contains('-') ? Colors.redAccent : AppTheme.primary))
                    : Theme.of(context).cardColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isLight ? Colors.grey.shade700 : Colors.grey),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ),

        Expanded(
          child: filteredTxns.isEmpty
              ? const Center(
                  child: Text('No matching transactions found.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              : RefreshIndicator(
                  onRefresh: _fetchHistoryData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTxns.length,
                    itemBuilder: (context, index) {
                      final tx = filteredTxns[index];
                      final type = tx['type'] ?? 'transaction';
                      final amountStr = tx['amount']?.toString() ?? '0';
                      final amount = double.tryParse(amountStr) ?? 0.0;
                      final isPositive = amount > 0;
                      final desc = tx['description'] ?? (isPositive ? 'Wallet Top-up' : 'Call / Gift Debit');
                      final dateStr = tx['createdAt'] != null
                          ? DateTime.parse(tx['createdAt']).toLocal().toString().substring(0, 16)
                          : '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: isLight ? AppTheme.lightCardBorder : Colors.white.withValues(alpha: 0.05)),
                          boxShadow: isLight ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ] : null,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: isPositive ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                              child: Icon(
                                isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline,
                                color: isPositive ? Colors.green : Colors.red,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    desc,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${type.toString().toUpperCase()} • $dateStr',
                                    style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isPositive ? "+" : ""}₹${amount.abs().toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isPositive ? Colors.green : Colors.red,
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
  }
}
