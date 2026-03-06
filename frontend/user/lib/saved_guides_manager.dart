import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/community_model.dart';

class SavedGuidesManager extends ChangeNotifier {
  static final SavedGuidesManager instance = SavedGuidesManager._internal();

  SavedGuidesManager._internal();

  static const String _prefsKey = 'saved_guides';

  final List<CommunityPost> _savedGuides = [];
  bool _isLoaded = false;

  List<CommunityPost> get savedGuides => List.unmodifiable(_savedGuides);

  Future<void> _ensureLoaded() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.trim().isEmpty) {
      _isLoaded = true;
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _savedGuides
          ..clear()
          ..addAll(
            decoded
                .whereType<Map>()
                .map((m) => Map<String, dynamic>.from(m))
                .map(CommunityPost.fromJson),
          );
      }
    } catch (_) {
      _savedGuides.clear();
    }

    _isLoaded = true;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_savedGuides.map((g) => g.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  bool isSavedSync(String guideId) {
    return _savedGuides.any((g) => g.id == guideId);
  }

  Future<bool> isSaved(String guideId) async {
    await _ensureLoaded();
    return isSavedSync(guideId);
  }

  Future<void> toggle(CommunityPost guide) async {
    await _ensureLoaded();
    if (isSavedSync(guide.id)) {
      _savedGuides.removeWhere((g) => g.id == guide.id);
    } else {
      _savedGuides.add(guide);
    }
    await _persist();
    notifyListeners();
  }

  Future<List<CommunityPost>> getSavedItems() async {
    await _ensureLoaded();
    return List.unmodifiable(_savedGuides);
  }
}