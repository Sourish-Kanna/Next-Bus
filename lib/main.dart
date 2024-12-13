import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:next_bus/logics.dart';
import 'package:provider/provider.dart';
import 'bus_timing_provider.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(ChangeNotifierProvider(
    create: (context) => BusTimingProvider(),
    child: const BusTimingApp(),
  ),);
}

class BusTimingApp extends StatelessWidget {
  const BusTimingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Fallback to default Material 3 color schemes
          lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
          darkColorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark);
        }

        return MaterialApp(
          title: 'Next Bus',
          theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
          themeMode: ThemeMode.system, // Follows system theme
          home: const BusHomePage(),
        );
      },
    );
  }
}

class BusHomePage extends StatelessWidget {
  const BusHomePage({super.key});

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
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const NextTime(),
            const SizedBox(height: 20),
            // Bus Timing List Section
            Text(
              "All Timings:",
              style: TextStyle(
                fontSize: 24,
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
                          null;},
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
    );
  }
}
