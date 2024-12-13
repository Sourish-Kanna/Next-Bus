import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class BusTimingProvider with ChangeNotifier {
  final List<String> _busTimings = ["6:30 AM", "8:00 AM", "9:00 AM", "10:30 AM", "12:30 PM", "4:50 PM", "11:50 PM"];

  List<String> get busTimings => _busTimings;

  void addBusTiming() {
    DateTime now = DateTime.now();
    String newTime = DateFormat('h:mm a').format(now);
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
