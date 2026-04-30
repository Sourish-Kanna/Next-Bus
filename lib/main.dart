import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
import 'package:firebase_analytics/firebase_analytics.dart'
    show FirebaseAnalytics, FirebaseAnalyticsObserver;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:firebase_crashlytics/firebase_crashlytics.dart'
    show FirebaseCrashlytics;
import 'package:flutter/foundation.dart'
    show kIsWeb, PlatformDispatcher, TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    show InternetCheckOption, InternetConnection;

import 'package:nextbus/pages/error_screen.dart' show ErrorScreen;
import 'package:nextbus/providers/providers.dart';
import 'package:nextbus/common.dart' show AppLogger;
import 'package:nextbus/config.dart' show Config;
import 'package:nextbus/entry.dart' show NextBusApp;
import 'package:provider/provider.dart'
    show ChangeNotifierProvider, MultiProvider;

void main() async {
  // Ensure bindings are initialized before doing anything else
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app with the initializer widget
  runApp(const AppInitializer());
}

enum AppStatus { loading, success, error }

// This widget will handle the async initialization and show the correct UI based on the state (loading, error, or success).
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  AppStatus _status = AppStatus.loading;
  String _errorTitle = "";
  String _errorMessage = "";

  // Define analytics and observer here as 'late final'
  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver _observer;
  late final User? _initialUser;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // Sends a non-blocking request to wake up the server.
  Future<void> _wakeUpServer() async {
    try {
      // Use your custom instance here, with a short timeout.
      final connection = InternetConnection.createInstance(
        checkInterval: const Duration(seconds: 120), // Give it 120s to wake up
        customCheckOptions: [
          InternetCheckOption(uri: Uri.parse(Config.apiUrl)),
        ],
      );

      await connection.hasInternetAccess;
      AppLogger.onlyLocal("Server wake-up ping sent to ${Config.apiUrl}");
    } catch (e) {
      AppLogger.onlyLocal("Server wake-up ping failed or timed out: $e");
    }
  }

  // Runs all initialization logic and updates the state.
  Future<void> _initializeApp() async {
    // Set state to loading when retrying
    if (mounted) {
      setState(() {
        _status = AppStatus.loading;
      });
    }

    // if (mounted) {
    //   setState(() {
    //     _status = AppStatus.error;
    //     _errorTitle = "Test Error Screen";
    //     _errorMessage = "This is a forced error to verify the new Material 3 design.";
    //   });
    //   return; // Stop the rest of the app from loading
    // }

    // OFFLINE CHECK (Non-blocking for cached data access)
    final connectivityResult = await Connectivity().checkConnectivity();
    bool isOffline = connectivityResult.contains(ConnectivityResult.none);

    if (isOffline) {
      AppLogger.onlyLocal(
        "No Internet Connection (Instant Check) - Starting in Offline Mode",
      );
    } else {
      final bool hasInternet = await InternetConnection().hasInternetAccess;
      if (!hasInternet) {
        AppLogger.onlyLocal(
          "Connected to Router but No Internet Access - Starting in Offline Mode",
        );
        isOffline = true;
      }
    }

    // Wake up server (Only if we think we are online)
    if (!isOffline) {
      _wakeUpServer();
    }

    // Set app orientation
    if (TargetPlatform.android == defaultTargetPlatform) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    // Set Up Firebase (Works offline due to local persistence)
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: Config.firebaseOptions);
        AppLogger.onlyLocal("Firebase initialized successfully.");
      } else {
        AppLogger.onlyLocal(
          "Firebase was already initialized. Using existing instance.",
        );
      }

      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);

      // Initialize Crashlytics right after Firebase
      final crashlytics = FirebaseCrashlytics.instance;

      if (!kIsWeb) {
        // Crashlytics Error Handlers for non-web platforms
        FlutterError.onError = (errorDetails) {
          crashlytics.recordFlutterFatalError(errorDetails);
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          crashlytics.recordError(error, stack, fatal: true);
          return true;
        };
      }
      AppLogger.initialize(crashlytics);
    } catch (e) {
      AppLogger.onlyLocal("Firebase Init Error: $e");
      if (mounted) {
        setState(() {
          _status = AppStatus.error;
          _errorTitle = "Failed to Initialize Firebase";
          _errorMessage = "An error occurred while connecting to our services.";
        });
      }
      return;
    }

    // Get Initial Auth State
    try {
      _initialUser = await FirebaseAuth.instance.authStateChanges().first;
    } catch (e) {
      AppLogger.onlyLocal("Auth Check Failed (likely offline): $e");
      _initialUser = null;
    }

    // If all successful
    if (mounted) {
      setState(() {
        _status = AppStatus.success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case AppStatus.loading:
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepOrange,
          ),
          home: const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(strokeCap: StrokeCap.round),
                  SizedBox(height: 16),
                  Text("Loading..."),
                ],
              ),
            ),
          ),
        );

      case AppStatus.error:
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepOrange,
          ),
          home: ErrorScreen(
            title: _errorTitle,
            message: _errorMessage,
            onRetry: _initializeApp,
          ),
        );

      case AppStatus.success:
        // Show the main app
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => AuthService()),
            ChangeNotifierProvider(create: (context) => RouteProvider()),
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => UserDetails()),
            ChangeNotifierProvider(create: (context) => TimetableProvider()),
            ChangeNotifierProvider(create: (context) => ConnectivityProvider()),
            ChangeNotifierProvider(create: (context) => NavigationProvider()),
          ],
          child: NextBusApp(observer: _observer, initialUser: _initialUser),
        );
    }
  }
}
