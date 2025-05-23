import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Brightness, DeviceOrientation, SystemChrome;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:dynamic_color/dynamic_color.dart' show ColorSchemeHarmonization, DynamicColorBuilder;
import 'package:provider/provider.dart' show ChangeNotifierProvider, MultiProvider;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;

import 'package:nextbus/Providers/providers.dart';
import 'package:nextbus/firebase_options.dart';
import 'package:nextbus/Pages/pages.dart';
import 'package:nextbus/app_layout.dart';


// Define application routes
final Map<String, WidgetBuilder> routes = {
  '/login': (context) => AuthScreen(),
  '/route': (context) => AppLayout(selectedIndex: 1, child: RouteSelect()),
  '/entries': (context) => AppLayout(selectedIndex: 2, child: EntriesPage()),
  '/home': (context) => AppLayout(selectedIndex: 0, child: BusHomePage()),
  '/admin': (context) => AppLayout(selectedIndex: 0, child: AdminPage()),
};

final List<MaterialColor> seedColorList = [
  Colors.deepPurple,
  Colors.deepOrange
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set app orientation to portrait mode only if platform is Android
  if (TargetPlatform.android == defaultTargetPlatform) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("error : $e");
    runApp(const ErrorScreen());
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => BusTimingList()),
        ChangeNotifierProvider(create: (context) => RouteProvider()),
      ],
      child: NextBusApp()
    ),
  );
}

class NextBusApp extends StatelessWidget {
  const NextBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = lightDynamic?.harmonized() ??
            ColorScheme.fromSeed(seedColor: seedColorList[1]);
        final darkScheme = darkDynamic?.harmonized() ??
            ColorScheme.fromSeed(
              seedColor: seedColorList[1],
              brightness: Brightness.dark,
            );

        return MaterialApp(
          title: 'Next Bus',
          theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: true,
          routes: routes,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AppLayout(selectedIndex: 0, child: CircularProgressIndicator()) ; // Or a loading screen
              }
              if (snapshot.hasData) {
                // User is logged in
                return AppLayout(selectedIndex: 0, child: Center(child: BusHomePage())) ;
              } else {
                // User is not logged in
                return const AuthScreen();
              }
            },
          ),
        );
      },
    );
  }
}
