import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Brightness, DeviceOrientation, SystemChrome;
import 'package:dynamic_color/dynamic_color.dart' show ColorSchemeHarmonization, DynamicColorBuilder;
import 'package:provider/provider.dart' show ChangeNotifierProvider, MultiProvider;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;

import 'package:nextbus/Providers/providers.dart';
import 'package:nextbus/firebase_options.dart';
import 'package:nextbus/Pages/pages.dart';


// Define application routes
final Map<String, WidgetBuilder> routes = {
  '/login': (context) => const AuthScreen(),
  '/route': (context) => const RouteSelect(),
  '/entries': (context) => const EntriesPage(),
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set app orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
      child: BusTimingApp()
    ),
  );
}

class BusTimingApp extends StatelessWidget {
  const BusTimingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightScheme = lightDynamic?.harmonized() ??
            ColorScheme.fromSeed(seedColor: Colors.deepPurple);
        final darkScheme = darkDynamic?.harmonized() ??
            ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
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
                return const CircularProgressIndicator(); // Or a loading screen
              }
              if (snapshot.hasData) {
                // User is logged in
                return const BusHomePage();
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

