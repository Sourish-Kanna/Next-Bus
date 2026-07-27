import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart'
    show ColorSchemeHarmonization, DynamicColorBuilder;
import 'package:nextbus/common.dart' show AppLogger;
import 'package:provider/provider.dart' show Consumer, Provider;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:firebase_analytics/firebase_analytics.dart'
    show FirebaseAnalyticsObserver;

import 'package:nextbus/providers/providers.dart'
    show ThemeProvider, ConnectivityProvider, TimetableProvider;
import 'package:nextbus/pages/pages.dart' show AuthScreen;
import 'package:nextbus/layout.dart' show AppLayout;
import 'package:nextbus/constant.dart' show fallbackColor;

class NextBusApp extends StatefulWidget {
  final FirebaseAnalyticsObserver observer;
  final User? initialUser;

  const NextBusApp({
    super.key,
    required this.observer,
    required this.initialUser,
  });

  @override
  State<NextBusApp> createState() => _NextBusAppState();
}

class _NextBusAppState extends State<NextBusApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final connProvider = Provider.of<ConnectivityProvider>(
        context,
        listen: false,
      );

      connProvider.addListener(() {
        if (connProvider.isOnline) {
          AppLogger.info("Back Online! Triggering sync...");
          Provider.of<TimetableProvider>(
            context,
            listen: false,
          ).syncPendingReports();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            final ColorScheme lightColorScheme;
            ColorScheme darkColorScheme;

            // Generate the initial color schemes
            if (themeProvider.isDynamicColor &&
                lightDynamic != null &&
                darkDynamic != null) {
              lightColorScheme = lightDynamic.harmonized();
              darkColorScheme = darkDynamic.harmonized();
            } else {
              final seed = themeProvider.selectedSeedColor ?? fallbackColor;
              lightColorScheme = ColorScheme.fromSeed(seedColor: seed);
              darkColorScheme = ColorScheme.fromSeed(
                seedColor: seed,
                brightness: Brightness.dark,
              );
            }

            // Build the MaterialApp
            return MaterialApp(
              title: 'Next Bus',
              theme: ThemeData(colorScheme: lightColorScheme),
              darkTheme: ThemeData(colorScheme: darkColorScheme),
              themeMode: themeProvider.themeMode,
              navigatorObservers: [widget.observer],
              home: StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                initialData: widget.initialUser,
                builder: (context, snapshot) {
                  final User? user = snapshot.data;
                  if (user != null) {
                    return AppLayout(); // User is logged in
                  } else {
                    return const AuthScreen(); // User is not logged in
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
