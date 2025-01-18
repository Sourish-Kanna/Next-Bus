import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextbus/firebase_operations.dart';

DateTime stringToDate(String time) {
  DateTime newTime = DateFormat('h:mm a').parse(time);
  return newTime;
}

String dateToString(DateTime time){
  return DateFormat('h:mm a').format(time);
}

class BusTimingList with ChangeNotifier {

  var FirebaseService = FirestoreService();

  final List<DateTime> _busTimings = [
    DateFormat('hh:mm a').parse("08:00 AM"), DateFormat('hh:mm a').parse("08:15 AM"),
    DateFormat('hh:mm a').parse("09:00 AM"), DateFormat('hh:mm a').parse("10:15 AM"),
    DateFormat('hh:mm a').parse("10:30 AM"), DateFormat('hh:mm a').parse("11:10 AM"),
    DateFormat('hh:mm a').parse("11:20 AM"), DateFormat('hh:mm a').parse("11:30 AM"),
    DateFormat('hh:mm a').parse("11:45 AM"), DateFormat('hh:mm a').parse("12:05 PM"),
    DateFormat('hh:mm a').parse("12:20 PM"), DateFormat('hh:mm a').parse("12:45 PM"),
    DateFormat('hh:mm a').parse("12:50 PM"), DateFormat('hh:mm a').parse("12:55 PM"),
    DateFormat('hh:mm a').parse("01:15 PM"), DateFormat('hh:mm a').parse("01:30 PM"),
    DateFormat('hh:mm a').parse("01:40 PM"), DateFormat('hh:mm a').parse("01:45 PM"),
    DateFormat('hh:mm a').parse("01:50 PM"), DateFormat('hh:mm a').parse("01:55 PM"),
    DateFormat('hh:mm a').parse("02:00 PM"), DateFormat('hh:mm a').parse("02:05 PM"),
    DateFormat('hh:mm a').parse("02:15 PM"), DateFormat('hh:mm a').parse("02:30 PM"),
    DateFormat('hh:mm a').parse("02:50 PM"), DateFormat('hh:mm a').parse("03:20 PM"),
    DateFormat('hh:mm a').parse("03:25 PM"), DateFormat('hh:mm a').parse("03:35 PM"),
    DateFormat('hh:mm a').parse("03:45 PM"), DateFormat('hh:mm a').parse("03:50 PM"),
    DateFormat('hh:mm a').parse("03:55 PM"), DateFormat('hh:mm a').parse("04:00 PM"),
    DateFormat('hh:mm a').parse("04:10 PM"), DateFormat('hh:mm a').parse("04:15 PM"),
    DateFormat('hh:mm a').parse("04:20 PM"), DateFormat('hh:mm a').parse("04:25 PM"),
    DateFormat('hh:mm a').parse("04:30 PM"), DateFormat('hh:mm a').parse("04:40 PM"),
    DateFormat('hh:mm a').parse("04:45 PM"), DateFormat('hh:mm a').parse("04:55 PM"),
    DateFormat('hh:mm a').parse("05:00 PM"), DateFormat('hh:mm a').parse("05:05 PM"),
    DateFormat('hh:mm a').parse("05:10 PM"), DateFormat('hh:mm a').parse("05:15 PM"),
    DateFormat('hh:mm a').parse("05:20 PM"), DateFormat('hh:mm a').parse("05:25 PM"),
    DateFormat('hh:mm a').parse("05:20 PM"), DateFormat('hh:mm a').parse("05:30 PM"),
    DateFormat('hh:mm a').parse("05:40 PM"), DateFormat('hh:mm a').parse("05:45 PM"),
    DateFormat('hh:mm a').parse("06:00 PM"), DateFormat('hh:mm a').parse("06:05 PM"),
    DateFormat('hh:mm a').parse("06:25 PM"), DateFormat('hh:mm a').parse("06:45 PM"),
    DateFormat('hh:mm a').parse("07:00 PM"), DateFormat('hh:mm a').parse("07:10 PM"),
    DateFormat('hh:mm a').parse("07:30 PM"), DateFormat('hh:mm a').parse("07:45 PM"),
    DateFormat('hh:mm a').parse("08:00 PM"), DateFormat('hh:mm a').parse("08:10 PM"),
    DateFormat('hh:mm a').parse("09:20 PM"), DateFormat('hh:mm a').parse("09:40 PM"),
    DateFormat('hh:mm a').parse("10:05 PM"),
  ];
  List<DateTime> get busTimings => _busTimings;

  void addBusTiming(String route, String user) {
    DateTime now = DateTime.now();
    String formattedTime = DateFormat('h:mm a').format(now);
    DateTime time = DateFormat('h:mm a').parse(formattedTime);
    _busTimings.add(time);
    _busTimings.sort();
    FirebaseService.addBusTiming(route, formattedTime, user);
    notifyListeners();
  }

  void undoAddBusTiming(DateTime now) {
    String formattedTime = DateFormat('h:mm a').format(now);
    DateTime time = DateFormat('h:mm a').parse(formattedTime);
    int index = _busTimings.indexOf(time);
    _busTimings.removeAt(index);
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
