import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallHistoryService {
  static final CallHistoryService _instance = CallHistoryService._internal();
  factory CallHistoryService() => _instance;
  CallHistoryService._internal();

  static const String _kLocalCallHistoryKey = 'local_call_history';

  /// Save or update a call record in local storage
  Future<void> saveCall(Map<String, dynamic> callRecord) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_kLocalCallHistoryKey) ?? [];
      final List<Map<String, dynamic>> records = [];

      for (final raw in rawList) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            records.add(decoded);
          }
        } catch (_) {}
      }

      final callId = callRecord['callId']?.toString() ?? '';
      
      // Update existing if exists, else insert at top
      final existingIndex = records.indexWhere((r) =>
          (r['callId'] != null && r['callId'].toString() == callId && callId.isNotEmpty));

      if (existingIndex >= 0) {
        records[existingIndex] = {
          ...records[existingIndex],
          ...callRecord,
        };
      } else {
        records.insert(0, callRecord);
      }

      // Cap to 50 records
      final capped = records.take(50).toList();
      final encoded = capped.map((r) => jsonEncode(r)).toList();
      await prefs.setStringList(_kLocalCallHistoryKey, encoded);
    } catch (e) {
      debugPrint('Error saving local call history: $e');
    }
  }

  /// Get locally cached calls
  Future<List<Map<String, dynamic>>> getLocalCalls() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_kLocalCallHistoryKey) ?? [];
      final List<Map<String, dynamic>> records = [];

      for (final raw in rawList) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            records.add(decoded);
          }
        } catch (_) {}
      }
      return records;
    } catch (e) {
      debugPrint('Error reading local call history: $e');
      return [];
    }
  }

  /// Merge remote call history with local records, removing duplicates and sorting newest first
  List<dynamic> mergeHistory(List<dynamic> remoteCalls, List<Map<String, dynamic>> localCalls) {
    final Map<String, dynamic> mergedMap = {};

    // First add local calls
    for (final loc in localCalls) {
      final key = loc['callId']?.toString().isNotEmpty == true
          ? loc['callId'].toString()
          : '${loc['expertName']}_${loc['createdAt']}';
      mergedMap[key] = loc;
    }

    // Then layer remote calls on top (remote is authoritative if present)
    for (final rem in remoteCalls) {
      if (rem is Map) {
        final key = (rem['callId'] ?? rem['id'])?.toString().isNotEmpty == true
            ? (rem['callId'] ?? rem['id']).toString()
            : '${rem['expertName']}_${rem['createdAt']}';

        final existing = mergedMap[key];
        if (existing is Map<String, dynamic>) {
          // Merge remote fields into existing local
          mergedMap[key] = {
            ...existing,
            ...Map<String, dynamic>.from(rem),
          };
        } else {
          mergedMap[key] = Map<String, dynamic>.from(rem);
        }
      }
    }

    final List<dynamic> list = mergedMap.values.toList();
    // Sort descending by createdAt
    list.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return list;
  }
}
