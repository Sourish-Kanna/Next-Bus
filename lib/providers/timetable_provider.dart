import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nextbus/providers/api_caller.dart';
import 'package:nextbus/common.dart';
import 'package:nextbus/constant.dart';

class TimetableProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  static const String _pendingReportsKey = 'pending_reports_queue';

  final Map<String, List<dynamic>> _timetables = {};
  Map<String, List<dynamic>> get timetables => _timetables;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchTimetable(String route) async {
    if (route.isEmpty) return; // Removed 'containsKey' check to allow refreshing

    // 1. Only set loading to true if we don't have data in memory yet.
    // This prevents the UI from flashing a spinner if we are just refreshing existing data.
    if (!_timetables.containsKey(route)) {
      _isLoading = true;
      notifyListeners();
    }

    final prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'timetable_$route';

    // 2. CACHE LAYER: Try to load from disk first
    String? cachedData = prefs.getString(cacheKey);
    if (cachedData != null && !_timetables.containsKey(route)) {
      try {
        List<dynamic> decoded = json.decode(cachedData);
        _timetables[route] = decoded;

        // Show cached data immediately, turn off loading
        _isLoading = false;
        notifyListeners();
        AppLogger.info("Loaded route $route from cache.");
      } catch (e) {
        AppLogger.warn("Failed to parse cached timetable for $route");
      }
      return ;
    }

    // 3. NETWORK LAYER: Fetch fresh data in the background
    try {
      final response = await _apiService.get(urls['busTimes']!.replaceAll('{route}', route));

      if (response.statusCode == 200) {
        List<dynamic> newData = response.data['data'];

        // Update memory
        _timetables[route] = newData;

        // Update disk cache
        await prefs.setString(cacheKey, json.encode(newData));

        AppLogger.info("Fetched fresh timetable for route $route from API.");
      }
    } catch (e, stack) {
      AppLogger.error(
        "Failed to fetch timetable for route: $route",
        e,
        stack,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addRoute(String routeName, List<String> stops, String timing, String start, String end) async {
    Map<String, dynamic> data = {
      "route_name": routeName,
      "stops": stops,
      "start": start,
      "end": end,
      "timing": timing,
    };

    try {
      var response = await _apiService.post(urls['addRoute']!, data: data);

      if (response.statusCode == 200 && response.data != null && response.data is Map<String, dynamic>) {
        return {'success': true, 'data': response.data['data']};
      } else {
        return {'success': false, 'message': response.data['detail'] ?? 'Failed to add route'};
      }
    } catch (e) {
      AppLogger.info("Error adding route: $e");
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // [Modified] updateTime with Offline Fallback
  Future<Map<String, dynamic>> updateTime(String routeName, String stopName, String timing) async {
    Map<String, dynamic> data = {
      "route_name": routeName,
      "timing": timing,
      "stop": stopName
    };

    try {
      // 1. Try to send to API directly
      var response = await _apiService.put(urls['updateTime']!, data: data);

      if (response.statusCode == 200) {
        _handleSuccessfulUpdate(routeName);
        return {'success': true, 'data': response.data['data']};
      }

      // Handle Rate Limiting (429)
      if (response.statusCode == 429) {
        return {
          'success': false,
          'message': 'Rate limit exceeded (429). Please wait.'
        };
      }

      return {
        'success': false,
        'message': response.data['detail'] ?? 'Failed to update time'
      };

    } catch (e) {
      // If the error is a Dio/Network error, handle offline mode
      // If it's a 429 inside the catch block (depending on your ApiService setup):
      if (e.toString().contains('429')) {
        return {'success': false, 'message': 'Too many reports. Please wait (429).'};
      }

      AppLogger.warn("Network failed. Saving report offline.");
      await _queueOfflineReport(data);

      return {
        'success': true,
        'message': 'Saved offline.',
        'isOffline': true
      };
    }
  }

  // [New] Helper to clear cache after an update
  Future<void> _handleSuccessfulUpdate(String routeName) async {
    _timetables.remove(routeName);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('timetable_$routeName');
    fetchTimetable(routeName);
  }

  // [New] Saves the report to SharedPreferences list
  Future<void> _queueOfflineReport(Map<String, dynamic> reportData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> pending = prefs.getStringList(_pendingReportsKey) ?? [];

      // Add timestamp to track when it was created (optional but good for debugging)
      reportData['created_at'] = DateTime.now().toIso8601String();

      pending.add(json.encode(reportData));
      await prefs.setStringList(_pendingReportsKey, pending);

      AppLogger.info("Report queued offline. Total pending: ${pending.length}");
    } catch (e) {
      AppLogger.error("Failed to save offline report", e);
    }
  }

  // [New] The Sync Logic - Call this when Internet comes back!
  Future<void> syncPendingReports() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> pending = prefs.getStringList(_pendingReportsKey) ?? [];

    if (pending.isEmpty) return;

    AppLogger.info("Syncing ${pending.length} offline reports...");

    List<String> remaining = []; // Keep track of what fails to send

    for (String jsonStr in pending) {
      try {
        Map<String, dynamic> data = json.decode(jsonStr);

        // Remove the extra 'created_at' before sending to API if your backend is strict
        // data.remove('created_at');

        var response = await _apiService.put(urls['updateTime']!, data: data);

        if (response.statusCode == 200) {
          AppLogger.info("Synced offline report for ${data['route_name']}");
          // If successful, invalidate cache for that route
          _handleSuccessfulUpdate(data['route_name']);
        } else {
          // If API rejects it (e.g. 400 Bad Request), don't retry. Log it and move on.
          AppLogger.error("Server rejected offline report: ${response.data}", response);
        }
      } catch (e) {
        // If network fails AGAIN, keep it in the list to try next time
        remaining.add(jsonStr);
        AppLogger.warn("Sync failed for one item, keeping in queue.");
      }
    }

    // Update the disk with whatever is left
    await prefs.setStringList(_pendingReportsKey, remaining);

    if (pending.length != remaining.length) {
      AppLogger.info("Sync complete. Items left: ${remaining.length}");
    }
  }
}