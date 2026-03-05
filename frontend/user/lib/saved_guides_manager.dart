import 'package:flutter/material.dart';

class SavedGuidesManager extends ChangeNotifier {
  static final SavedGuidesManager instance = SavedGuidesManager._internal();

  SavedGuidesManager._internal();

  final List<dynamic> savedGuides = [];

  bool isSaved(dynamic guide) {
    return savedGuides.any((g) => g["_id"] == guide["_id"]);
  }

  void toggle(dynamic guide) {
    if (isSaved(guide)) {
      savedGuides.removeWhere((g) => g["_id"] == guide["_id"]);
    } else {
      savedGuides.add(guide);
    }
    notifyListeners();
  }
}