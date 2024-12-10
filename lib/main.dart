import 'package:flutter/material.dart';

void main() {
  runApp(const BusTimingApp());
}

class BusTimingApp extends StatelessWidget {
  const BusTimingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Timing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const BusTimingPage(),
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
        title: const Text('Bus Timing App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Text(
              "Next Bus:",
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
                  return Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        busTimings[index],
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
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
