import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextbus/providers/api_caller.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';

class RouteProvider with ChangeNotifier {
  String _route = "56";
  List<String> _availableRoutes = ["56"];

  String get route => _route;
  List<String> get availableRoutes => _availableRoutes;

  RouteProvider() {
    _loadAvailableRoutes();
    _loadRoute();
  }

  // 1. NEW: Public method for Pull-to-Refresh
  // This forces an API call, ignoring the cache initially
  Future<void> fetchRoutes() async {
    ApiService apiService = ApiService();
    try {
      var response = await apiService.get(urls['busRoutes']!);

      if (response.statusCode == 200) {
        // Update local list
        _availableRoutes = List<String>.from(response.data['data']);

        // Save to cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('availableRoutes', _availableRoutes);

        // Validation: If the currently selected route no longer exists in the new list, reset it.
        if (_availableRoutes.isNotEmpty && !_availableRoutes.contains(_route)) {
          _route = _availableRoutes.first;
          await prefs.setString('selectedRoute', _route);
        }

        notifyListeners();
      } else {
        AppLogger.warn("Error refreshing routes: ${response.statusCode}");
      }
    } catch (e) {
      AppLogger.error("Error refreshing routes from API", e);
      // Optional: rethrow if you want the UI to show a SnackBar on failure
      rethrow;
    }
  }

  void _loadAvailableRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? savedRoutes = prefs.getStringList('availableRoutes');

    if (savedRoutes != null && savedRoutes.isNotEmpty) {
      _availableRoutes = savedRoutes;
      notifyListeners(); // Notify immediately if we have cached data
    } else {
      // If no cache, use the fetch method we just created
      await fetchRoutes();
    }
  }

  void _loadRoute() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedRoute = prefs.getString('selectedRoute');

    // Logic updated to ensure we don't select a route that isn't in availableRoutes
    if (savedRoute != null && _availableRoutes.contains(savedRoute)) {
      _route = savedRoute;
    } else if (_availableRoutes.isNotEmpty) {
      _route = _availableRoutes.first;
    }
    notifyListeners();
  }

  void setRoute(String newRoute) async {
    if (_route == newRoute || !_availableRoutes.contains(newRoute)) return;
    _route = newRoute;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRoute', newRoute);

    notifyListeners();
  }
}
