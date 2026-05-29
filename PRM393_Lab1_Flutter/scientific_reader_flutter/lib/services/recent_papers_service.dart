import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/recent_paper.dart';

class RecentPapersService {
  static const String _storageKey = "recent_papers";

  Future<List<RecentPaper>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final data = jsonDecode(raw);

      if (data is! List) {
        return [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(RecentPaper.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<RecentPaper> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonData);
  }
}
