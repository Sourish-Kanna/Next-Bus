import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Route Provider with String-based Route Persistence
class RouteProvider with ChangeNotifier {
  String _route = "56"; // Default route as String

  String get route => _route;

  RouteProvider() {
    _loadRoute();
  }

  void _loadRoute() async {
    final prefs = await SharedPreferences.getInstance();
    _route = prefs.getString('selectedRoute') ?? "56";
    notifyListeners();
  }

  void setRoute(String newRoute) async {
    if (_route == newRoute) return;
    _route = newRoute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRoute', newRoute);
    notifyListeners();
  }
}