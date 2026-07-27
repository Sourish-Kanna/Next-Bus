import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:nextbus/common.dart';

class ConnectivityProvider extends ChangeNotifier {
  late final InternetConnection _checker;
  StreamSubscription<InternetStatus>? _subscription;

  bool _isOnline = true;

  bool get isOnline => _isOnline;

  ConnectivityProvider({InternetConnection? checker})
    : _checker = checker ?? InternetConnection() {
    _subscription = _checker.onStatusChange.listen((status) {
      final wasOnline = _isOnline;
      _isOnline = (status == InternetStatus.connected);

      if (wasOnline != _isOnline) {
        AppLogger.onlyLocal(
          'Connectivity status changed: ${_isOnline ? "ONLINE" : "OFFLINE"}',
        );
        notifyListeners();
      }
    });
  }

  // Method to check connectivity once
  Future<bool> checkConnection() async {
    _isOnline = await _checker.hasInternetAccess;
    notifyListeners();
    return _isOnline;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
