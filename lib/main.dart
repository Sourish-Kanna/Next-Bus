import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:nextbus/build_widgets.dart';
import 'package:nextbus/build_widgets.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/bus_timing_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nextbus/firebase_options.dart';
import 'package:nextbus/firebase_operations.dart';

// Define application routes
final Map<String, WidgetBuilder> routes = {
  '/': (context) => const BusHomePage(),
  '/entries': (context) => const EntriesPage(),
};

final bool isAdmin = false;
String route = "56";
String user = "test";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set app orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([

  // Set app orientation to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Start the app
  runApp(
    ChangeNotifierProvider(
      create: (context) => BusTimingList(route),
      child: const BusTimingApp(),
    ),
  );

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Start the app
  runApp(
    ChangeNotifierProvider(
      create: (context) => BusTimingList(route),
      child: const BusTimingApp(),
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
          initialRoute: '/',
          routes: routes,
          theme: ThemeData(colorScheme: lightScheme, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkScheme, useMaterial3: true),
          themeMode: ThemeMode.system,
          initialRoute: '/',
          routes: routes,
        );
      },
    );
  }
}

class BusHomePage extends StatelessWidget {
  const BusHomePage({super.key});

  void _showAdminOptionsDialog(BuildContext context) {

    void addRoute() {
      var firestoreService = FirestoreService();
      List<String> timeList = [ "07:45 AM",
        "08:00 AM", "08:15 AM", "09:00 AM", "10:15 AM", "10:30 AM", "11:10 AM",
        "11:20 AM", "11:30 AM", "11:45 AM", "12:05 PM", "12:20 PM", "12:45 PM",
        "12:50 PM", "12:55 PM", "01:15 PM", "01:30 PM", "01:40 PM", "01:45 PM",
        "01:50 PM", "01:55 PM", "02:00 PM", "02:05 PM", "02:15 PM", "02:30 PM",
        "02:50 PM", "03:20 PM", "03:25 PM", "03:35 PM", "03:45 PM", "03:50 PM",
        "03:55 PM", "04:00 PM", "04:10 PM", "04:15 PM", "04:20 PM", "04:25 PM",
        "04:30 PM", "04:40 PM", "04:45 PM", "04:55 PM", "05:00 PM", "05:05 PM",
        "05:10 PM", "05:15 PM", "05:20 PM", "05:25 PM", "05:20 PM", "05:30 PM",
        "05:40 PM", "05:45 PM", "06:00 PM", "06:05 PM", "06:25 PM", "06:45 PM",
        "07:00 PM", "07:10 PM", "07:30 PM", "07:45 PM", "08:00 PM", "08:10 PM",
        "09:20 PM", "09:40 PM", "10:05 PM"
      ];
      firestoreService.addRoute(
        route,
        ["Route 1", "Route 2"],
        timeList,
        "$user Route description",
      );
      // showAlertDialog(context);
      allSnackBar(context, "Route Added", onUndo: null);
      provideHapticFeedback();

    }

    void removeRoute() {
      var firestoreService = FirestoreService();
      firestoreService.removeRoute(route);
      allSnackBar(context, "Route Deleted", onUndo: null);
      provideHapticFeedback();
    }

    void addBusTiming() {
      var firestoreService = FirestoreService();
      String formattedTime = dateToString(DateTime.now());
      firestoreService.addBusTiming(route, formattedTime, "$user Added via FAB");
      allSnackBar(context, "Time Added",
        onUndo: () {
          String now = dateToString(DateTime.now());
          Provider.of<BusTimingList>(context, listen: false).undoAddBusTiming(route, now, user);
        },
      );
      provideHapticFeedback();
    }

    Future<void> getBusTimings() async {
      var firestoreService = FirestoreService();
      print(await firestoreService.getBusTimings(route));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Admin Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.directions_bus),
                title: const Text("Add Route"),
                onTap: () {
                  // Navigator.pop(context);
                  addRoute(); // Call your function to add a route
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Add Bus Timing"),
                onTap: () {
                  addBusTiming(); // Call your function to add a bus timing
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Remove Route"),
                onTap: () {
                  removeRoute(); // Call your function to remove a route
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("View Timings"),
                onTap: () {
                  getBusTimings(); // Call your function to get bus timings
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _showAdminOptionsDialog(BuildContext context) {

    void addRoute() {
      var firestoreService = FirestoreService();
      List<String> timeList = [ "07:45 AM",
        "08:00 AM", "08:15 AM", "09:00 AM", "10:15 AM", "10:30 AM", "11:10 AM",
        "11:20 AM", "11:30 AM", "11:45 AM", "12:05 PM", "12:20 PM", "12:45 PM",
        "12:50 PM", "12:55 PM", "01:15 PM", "01:30 PM", "01:40 PM", "01:45 PM",
        "01:50 PM", "01:55 PM", "02:00 PM", "02:05 PM", "02:15 PM", "02:30 PM",
        "02:50 PM", "03:20 PM", "03:25 PM", "03:35 PM", "03:45 PM", "03:50 PM",
        "03:55 PM", "04:00 PM", "04:10 PM", "04:15 PM", "04:20 PM", "04:25 PM",
        "04:30 PM", "04:40 PM", "04:45 PM", "04:55 PM", "05:00 PM", "05:05 PM",
        "05:10 PM", "05:15 PM", "05:20 PM", "05:25 PM", "05:20 PM", "05:30 PM",
        "05:40 PM", "05:45 PM", "06:00 PM", "06:05 PM", "06:25 PM", "06:45 PM",
        "07:00 PM", "07:10 PM", "07:30 PM", "07:45 PM", "08:00 PM", "08:10 PM",
        "09:20 PM", "09:40 PM", "10:05 PM"
      ];
      firestoreService.addRoute(
        route,
        ["Route 1", "Route 2"],
        timeList,
        "$user Route description",
      );
      // showAlertDialog(context);
      allSnackBar(context, "Route Added", onUndo: null);
      provideHapticFeedback();

    }

    void removeRoute() {
      var firestoreService = FirestoreService();
      firestoreService.removeRoute(route);
      allSnackBar(context, "Route Deleted", onUndo: null);
      provideHapticFeedback();
    }

    void addBusTiming() {
      var firestoreService = FirestoreService();
      String formattedTime = dateToString(DateTime.now());
      firestoreService.addBusTiming(route, formattedTime, "$user Added via FAB");
      allSnackBar(context, "Time Added",
        onUndo: () {
          String now = dateToString(DateTime.now());
          Provider.of<BusTimingList>(context, listen: false).undoAddBusTiming(route, now, user);
        },
      );
      provideHapticFeedback();
    }

    Future<void> getBusTimings() async {
      var firestoreService = FirestoreService();
      print(await firestoreService.getBusTimings(route));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Admin Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.directions_bus),
                title: const Text("Add Route"),
                onTap: () {
                  // Navigator.pop(context);
                  addRoute(); // Call your function to add a route
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Add Bus Timing"),
                onTap: () {
                  addBusTiming(); // Call your function to add a bus timing
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Remove Route"),
                onTap: () {
                  removeRoute(); // Call your function to remove a route
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("View Timings"),
                onTap: () {
                  getBusTimings(); // Call your function to get bus timings
                  Navigator.pop(context); // Close the dialog
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Next Bus'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const NextTime(),
            const SizedBox(height: 10),

            Expanded(
              child:
                Row(
                children: [
                  Expanded(
                    child: Column(
                        children: [
                          Text("Past",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,),
                          ),
                          ListHome(title: "Past", isPast: true,),
                        ]
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      children: [
                        Text("Next",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,),
                        ),
                        ListHome(title: "Next", isPast: false,),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.pushNamed(context, '/entries'),
              child: const Text(
                "View Entries",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),

            Expanded(
              child:
                Row(
                children: [
                  Expanded(
                    child: Column(
                        children: [
                          Text("Past",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,),
                          ),
                          ListHome(title: "Past", isPast: true,),
                        ]
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      children: [
                        Text("Next",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,),
                        ),
                        ListHome(title: "Next", isPast: false,),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.pushNamed(context, '/entries'),
              child: const Text(
                "View Entries",
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () => _showAdminOptionsDialog(context),
        tooltip: 'Admin Options',
        child: const Icon(Icons.add),
      ) : null,
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () => _showAdminOptionsDialog(context),
        tooltip: 'Admin Options',
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}

class EntriesPage extends StatelessWidget {
  const EntriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Entries'),
        title: const Text('Entries'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "All Entries",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const ListDisplay(),
            const SizedBox(height: 10),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AddTime(),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Go Back",
                    style: TextStyle(fontSize: 20),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AddTime(),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Go Back",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

