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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
          // home: const BusHomePage(),
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
    test.addRoute("56",["Thane Station","Tiku-Jini-Wadi"],["08:50","12:50"]);
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

            Text(
              "Past Timings:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListHomePast(),
            const SizedBox(height: 5),

            Text(
              "Next Timings:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListHomeNext(),
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
              ],
            )
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