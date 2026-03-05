import 'accommodation.dart';

/// Singleton to manage saved (bookmarked) accommodations — per logged-in user.
/// Saved listings are keyed by userId so different users on the same device
/// maintain completely independent bookmark lists.
class SavedManager {
  SavedManager._internal();
  static final SavedManager instance = SavedManager._internal();

  // Map of userId → list of saved accommodations
  final Map<String, List<Accommodation>> _userSaved = {};

  /// Must be called after login/register with the real userId.
  void switchUser(String userId) {
    // Ensure the bucket exists; existing data is preserved
    _userSaved.putIfAbsent(userId, () => []);
    _currentUserId = userId;
  }

  String _currentUserId = 'guest';

  List<Accommodation> get savedAccommodations =>
      _userSaved[_currentUserId] ?? [];

  bool isSaved(String id) =>
      savedAccommodations.any((a) => a.id == id);

  /// Toggles save state. Returns true if now saved, false if removed.
  bool toggle(Accommodation acc) {
    final bucket = _userSaved.putIfAbsent(_currentUserId, () => []);
    final idx = bucket.indexWhere((a) => a.id == acc.id);
    if (idx >= 0) {
      bucket.removeAt(idx);
      acc.isSaved = false;
      return false;
    } else {
      acc.isSaved = true;
      bucket.add(acc);
      return true;
    }
  }

  /// Clear saved list for current user (on logout)
  void clearCurrentUser() {
    _userSaved.remove(_currentUserId);
    _currentUserId = 'guest';
  }
}
