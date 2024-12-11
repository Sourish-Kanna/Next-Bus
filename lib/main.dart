import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const BusTimingApp());
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
          lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.green);
          darkColorScheme = ColorScheme.fromSeed(seedColor: Colors.green, brightness: Brightness.dark);
        }

        return MaterialApp(
          title: 'Next Bus',
          theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
          darkTheme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
          themeMode: ThemeMode.system, // Follows system theme
          home: const BusTimingPage(),
        );
      },
    );
  }
}

class BusTimingPage extends StatefulWidget {
  const BusTimingPage({super.key});

  @override
  State<BusTimingPage> createState() => _BusTimingPageState();
}

class _BusTimingPageState extends State<BusTimingPage> {
  List<String> busTimings = ["08:00", "09:00", "10:30"];
  Set<int> swipedIndices = {};
  final TextEditingController _timeController = TextEditingController();

  String getNextBus() {
    DateTime now = DateTime.now();
    for (String time in busTimings) {
      DateTime busTime = DateTime.parse("${now.year}-${now.month}-${now.day} $time:00");
      if (now.isBefore(busTime)) {
        return time;
      }
    }
    return "No more buses today";
  }

  void _deleteBusTiming(int index) {
    setState(() {
      busTimings.removeAt(index);
      swipedIndices.remove(index);
    });
  }

  void _editBusTiming(int index) {
    _timeController.text = busTimings[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Bus Timing"),
        content: TextField(
          controller: _timeController,
          decoration: const InputDecoration(labelText: "Enter Time (HH:MM)"),
          keyboardType: TextInputType.datetime,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (_timeController.text.isNotEmpty) {
                setState(() {
                  busTimings[index] = _timeController.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _addNewBusTiming(String newTime) {
    setState(() {
      busTimings.add(newTime);
      busTimings.sort();
    });
    _timeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Next Bus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Text(
              "Next Bus at:",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              getNextBus(),
              style: TextStyle(
                fontSize: 36,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 20),

            // Bus Timing List Section
            Text(
              "All Timings:",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: ListView.builder(
              itemCount: busTimings.length,
              itemBuilder: (context, index) {
                bool isSwiped = swipedIndices.contains(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                  child: Slidable(
                    key: ValueKey(busTimings[index]),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context)  {
                            setState(() {
                              swipedIndices.add(index);
                            });
                            _deleteBusTiming(index);
                          },
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Delete',
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            setState(() {
                              swipedIndices.add(index);
                            });
                            _editBusTiming(index);
                          },
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          label: 'Edit',
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: isSwiped
                            ? BorderRadius.zero // Not rounded when swiped
                            : BorderRadius.circular(12), // Rounded when not swiped
                      ),
                      child: ListTile(
                        title: Text(
                          busTimings[index],
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

      ),

            // Input Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _timeController,
                    decoration: InputDecoration(
                      labelText: "Enter Time (HH:MM)",
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary, // Text color
                  ),
                  onPressed: () {
                    if (_timeController.text.isNotEmpty) {
                      _addNewBusTiming(_timeController.text);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
