import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class BusTimingProvider with ChangeNotifier {
  final List<DateTime> _busTimings = [
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 08:00 AM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 08:15 AM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 09:00 AM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 10:15 AM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 10:30 AM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 11:10 AM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 11:20 AM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 11:30 AM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 11:45 AM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 12:05 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 12:20 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 12:45 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 12:50 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 12:55 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 01:15 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 01:30 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 01:40 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 01:45 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 01:50 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 01:55 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 02:00 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 02:05 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 02:15 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 02:30 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 02:50 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 03:20 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 03:25 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 03:35 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 03:45 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 03:50 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 03:55 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 04:00 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 04:10 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 04:15 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 04:20 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 04:25 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 04:30 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 04:40 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 04:45 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 04:55 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 05:00 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 05:05 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 05:10 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 05:15 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 05:20 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 05:25 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 05:20 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 05:30 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 05:40 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 05:45 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 06:00 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 06:05 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 06:25 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 06:45 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 07:00 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 07:10 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 07:30 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 07:45 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 08:00 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 08:10 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 09:20 PM"), DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 09:40 PM"),
    DateFormat('yyyy-MM-dd hh:mm a').parse("2024-12-13 10:05 PM"),
  ];
  List<DateTime> get busTimings => _busTimings;

  void addBusTiming() {
    DateTime now = DateTime.now();
    _busTimings.add(now);
    _busTimings.sort();
    notifyListeners();
  }

  void deleteBusTiming(int index) {
    _busTimings.removeAt(index);
    _busTimings.sort();
    notifyListeners();
  }

  void editBusTiming(int index, DateTime newTime) {
    _busTimings[index] = newTime;
    _busTimings.sort();
    notifyListeners();
  }
}
