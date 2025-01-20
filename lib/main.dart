import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
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

final bool isAdmin = true;
String route = "56";
String user = "test";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      create: (context) => BusTimingList("56"),
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

        return MaterialApp(
          title: 'Next Bus',
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

  // Firebase operations for testing
  void addRoute() {
    var firestoreService = FirestoreService();
    List<String> timeList = [
      "08:00 AM", "08:15 AM", "09:00 AM", "10:15 AM", "10:30 AM", "11:10 AM",
      "09:20 PM", "09:40 PM", "10:05 PM"
    ];
    firestoreService.addRoute(
      "56",
      ["Route 1", "Route 2"],
      timeList,
      "Route description",
    );
  }

  void removeRoute() {
    var firestoreService = FirestoreService();
    firestoreService.removeRoute("56");
  }

  void addBusTiming() {
    var firestoreService = FirestoreService();
    firestoreService.addBusTiming("56", "07:43 PM", "Added via FAB");
  }

  Future<void> getBusTimings() async {
    var firestoreService = FirestoreService();
    print(await firestoreService.getBusTimings("56"));
  }

  void _showAdminOptionsDialog(BuildContext context) {
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
                  Navigator.pop(context); // Close the dialog
                  addRoute(); // Call your function to add a route
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Add Bus Timing"),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  addBusTiming(); // Call your function to add a bus timing
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Remove Route"),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  removeRoute(); // Call your function to remove a route
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("View Timings"),
                onTap: () {
                  Navigator.pop(context); // Close the dialog
                  getBusTimings(); // Call your function to get bus timings
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
          ],
        ),
      ),
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
