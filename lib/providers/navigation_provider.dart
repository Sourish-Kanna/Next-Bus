import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextbus/constant.dart';

class NavigationProvider extends ChangeNotifier {
  static const _prefsKey = 'last_navigation_destination';

  NavigationDestinations _current = NavigationDestinations.home;

  NavigationDestinations get current => _current;

  NavigationProvider() {
    _restoreLastTab();
  }

  Future<void> _restoreLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);

    if (stored != null) {
      final match = NavigationDestinations.values
          .where((e) => e.name == stored)
          .toList();

      if (match.isNotEmpty) {
        _current = match.first;
        notifyListeners();
      }
    }
  }

  Future<void> navigateTo(NavigationDestinations destination) async {
    if (_current == destination) return;

    _current = destination;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, destination.name);
  }

  void resetIfInvalid(Set<NavigationDestinations> valid) {
    if (!valid.contains(_current)) {
      navigateTo(NavigationDestinations.home);
    }
  }

  Future<void> clearNavigationCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _current = NavigationDestinations.home;
    notifyListeners();
  }
}
