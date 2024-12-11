import 'package:flutter/material.dart';

class BusTimingProvider with ChangeNotifier {
  List<String> _busTimings = ["08:00", "09:00", "10:30", "12:30", "16:50", "23:50"];

  List<String> get busTimings => _busTimings;

  void addBusTiming(String newTime) {
    _busTimings.add(newTime);
    _busTimings.sort();
    notifyListeners();
  }

  void deleteBusTiming(int index) {
    _busTimings.removeAt(index);
    notifyListeners();
  }

  void editBusTiming(int index, String newTime) {
    _busTimings[index] = newTime;
    notifyListeners();
  }
}
