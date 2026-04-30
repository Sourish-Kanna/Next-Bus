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

final double mobileBreakpoint = 840; // used as tablet and mobile ui are same and web view is different
final fallbackColor = seedColorList[1];

final Map<String, String> urls = {
  'addRoute': '/v1/route/add',
  'updateTime': '/v1/timings/update',
  'busRoutes': '/v1/route/routes',
  'busTimes': '/v1/timings/{route}',
  "user": '/v1/user/get-user-details',
};

enum NavigationDestinations { login, home, route, settings, admin }

final routesPage = {
  "home": HomePage(),
  "route": RouteSelect(),
  "settings": SettingPage(),
  "admin": AdminPage(),
  "login": AuthScreen(),
};
