import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextbus/firebase_operations.dart';

String dateToString(DateTime time) {
  return DateFormat('h:mm a').format(time);
}

DateTime stringToDate(String time) {
  return DateFormat('h:mm a').parse(time);
}

class BusTimingList with ChangeNotifier {
  final FirestoreService _firebaseService = FirestoreService();
  final List<String> _busTimings = []; // Keeping strings as requested

  List<String> get busTimings => _busTimings;

  Future<void> fetchBusTimings(String route) async {
    try {
      final List<String> timings = await _firebaseService.getBusTimings(route);
      _busTimings.clear();
      _busTimings.addAll(timings);
      _busTimings.sort((a, b) => stringToDate(a).compareTo(stringToDate(b))); // Sort the timings
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching bus timings: $e');
    }
  }

  void addBusTiming(String route, String user) async {
    DateTime now = DateTime.now();
    String formattedTime = dateToString(now);
    _busTimings.add(formattedTime);
    _busTimings.sort((a, b) => stringToDate(a).compareTo(stringToDate(b)));

    // Add to Firestore
    try {
      await _firebaseService.addBusTiming(route, formattedTime, user);
    } catch (e) {
      debugPrint('Error adding bus timing: $e');
    }

    notifyListeners();
  }

  void undoAddBusTiming(String route, String time, String user) async {
    _busTimings.remove(time);
    _busTimings.sort((a, b) => stringToDate(a).compareTo(stringToDate(b)));

    // Remove from Firestore
    try {
      await _firebaseService.deleteBusTiming(route, time, user);
    } catch (e) {
      debugPrint('Error undoing add bus timing: $e');
    }

    notifyListeners();
  }

  void deleteBusTiming(String route, int index, String user) async {
    String timeToDelete = _busTimings[index];
    _busTimings.removeAt(index);
    _busTimings.sort((a, b) => stringToDate(a).compareTo(stringToDate(b)));

    // Remove from Firestore
    try {
      await _firebaseService.deleteBusTiming(route, timeToDelete, user);
    } catch (e) {
      debugPrint('Error deleting bus timing: $e');
    }

    notifyListeners();
  }

  void editBusTiming(String route, int index, String newTime, String user) async {
    String oldTime = _busTimings[index];
    _busTimings[index] = newTime;
    _busTimings.sort((a, b) => stringToDate(a).compareTo(stringToDate(b)));

    // Update Firestore
    try {
      await _firebaseService.updateBusTiming(route, oldTime, newTime, user);
    } catch (e) {
      debugPrint('Error editing bus timing: $e');
    }

    notifyListeners();
  }
}
