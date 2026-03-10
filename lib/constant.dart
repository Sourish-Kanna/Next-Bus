import 'package:flutter/material.dart';
import 'package:nextbus/pages/pages.dart';

final List<Color> seedColorList = [
  Colors.deepPurple,
  Colors.deepOrange,
  Colors.indigo,
  Colors.green,
  Colors.teal,
  Colors.pink,
];

final greenTime = Colors.green.shade700;
final orangeTime = Colors.orange.shade700;
final redTime = Colors.red.shade700;


final double mobileBreakpoint = 840; // used as tablet and mobile ui are same and web view is different
final fallbackColor = seedColorList[1];

final Map<String, String> urls = {
  'addRoute': '/route/add',
  'updateTime': '/timings/update',
  'busRoutes': '/route/routes',
  'busTimes': '/timings/{route}',
  "user": '/user/get-user-details'
};

enum NavigationDestinations {
  login,
  home,
  route,
  settings,
  admin,
}

final routesPage = {
  "home": HomePage(),
  "route": RouteSelect(),
  "settings": SettingPage(),
  "admin": AdminPage(),
  "login": AuthScreen(),
};