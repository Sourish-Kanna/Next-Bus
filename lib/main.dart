import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:nextbus/build_widgets.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/bus_timing_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nextbus/firebase_options.dart';
import 'package:nextbus/firebase_operations.dart';

var routes = {
  '/': (context) => const BusHomePage(),
  '/entries': (context) => const EntriesPage(),
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
  runApp(ChangeNotifierProvider(
    create: (context) => BusTimingList(),
    child: const BusTimingApp(),
  ),);
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

  void addroute() {
    var test = FirestoreService();
    List<String> timeList = [
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

    test.addRoute("56", ["tes1","test 2"], timeList);
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const NextTime(),
            const SizedBox(height: 5),

            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Past",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        ListHomePast(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        ListHomeNext(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () =>  Navigator.pushNamed(context, '/entries'),
              child: const Text(
                "View Entries",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addroute,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
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
        // title: const Text('Next Bus'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AddTime(),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Go Back",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                      ),
                    ],
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