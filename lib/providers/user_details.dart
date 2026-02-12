import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';
import 'package:nextbus/providers/api_caller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetails with ChangeNotifier {
  // Initialize with safe defaults (Guest)
  bool _isAdmin = false;
  bool _isLoggedIn = false;
  bool _isGuest = true;

  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  String get accessLevel => _isGuest ? "Guest" : isAdmin ? "Admin" : "User";

  /// Main function to get user data.
  /// Strategy: Load Cache (Instant) -> Fetch API (Background) -> Update Cache
  Future<void> fetchUserDetails() async {
    // 1. LOAD FROM CACHE FIRST
    // This gives immediate UI feedback (e.g. shows Admin Dashboard) even before the API returns.
    if (await _loadFromCache() == true){
      notifyListeners();
      return;
    }

    ApiService api = ApiService();
    try {
      // 2. FETCH FROM API
      // We use your existing ApiService and URL constants
      var result = await api.get(urls["user"]!);

      if (result.data != null && result.data["data"] != null) {
        Map<String, dynamic> data = result.data["data"];
        // AppLogger.info("User Details fetched from API: $data");

        // Update local state with fresh data from server
        _isAdmin = data["isAdmin"] ?? false;
        _isLoggedIn = data["isLoggedIn"] ?? false;
        _isGuest = data["isGuest"] ?? true;

        // 3. UPDATE CACHE
        // Save these new values so they work offline next time
        await _saveToCache();
      } else {
        AppLogger.error("API response invalid. Keeping cached data.", result.data);
        // Note: We do NOT reset to guest here. We trust the cache if the API sends junk.
      }
    } catch (e) {
      AppLogger.error("Network error fetching user details. Using cached data.", e);
      // Note: We swallow the error so the UI stays in "Offline Mode" using the last known good state.
    }

    // Update UI with final state (either fresh API data or preserved cache)
    notifyListeners();
  }

  /// Loads the last known user state from device storage (SharedPreferences)
  Future<bool> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Only load if keys exist, otherwise stick to default Guest
      if (prefs.containsKey('user_isGuest')) {
        _isAdmin = prefs.getBool('user_isAdmin') ?? false;
        _isLoggedIn = prefs.getBool('user_isLoggedIn') ?? false;
        _isGuest = prefs.getBool('user_isGuest') ?? true;
        AppLogger.info("Loaded User from Cache: Admin=$_isAdmin, Guest=$_isGuest");
      }
      return true;
    } catch (e) {
      AppLogger.warn("Failed to load user cache: $e");
      return false;
    }
  }

  /// Saves the current user state to device storage
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('user_isAdmin', _isAdmin);
      await prefs.setBool('user_isLoggedIn', _isLoggedIn);
      await prefs.setBool('user_isGuest', _isGuest);
    } catch (e) {
      AppLogger.warn("Failed to save user cache: $e");
    }
  }

  /// Clears local user data and cache. Call this on Logout.
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_isAdmin');
      await prefs.remove('user_isLoggedIn');
      await prefs.remove('user_isGuest');
    } catch (e) {
      AppLogger.warn("Failed to clear user cache: $e");
    }

    _setDefaultGuest();
    notifyListeners();
  }

  /// Helper to reset state to default Guest
  void _setDefaultGuest() {
    _isAdmin = false;
    _isLoggedIn = false;
    _isGuest = true;
  }
}