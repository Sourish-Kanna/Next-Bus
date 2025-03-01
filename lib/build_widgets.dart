import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nextbus/bus_timing_provider.dart';
import 'package:provider/provider.dart';

String user = "test"; // Hardcoded user (Replace with actual auth logic)

// Haptic feedback for user actions
void provideHapticFeedback() {
  HapticFeedback.lightImpact();
}

// SnackBar widget with optional undo action
void allSnackBar(BuildContext context, String text, {VoidCallback? onUndo}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.95),
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      action: onUndo != null
          ? SnackBarAction(
        label: "Undo",
        onPressed: onUndo,
      )
          : null,
      duration: const Duration(seconds: 3),
    ),
  );
  provideHapticFeedback();
}

// NextTime widget - Displays the next available bus
class NextTime extends StatelessWidget {
  final String route;
  const NextTime({super.key, required this.route});

  String getNextBus(BusTimingList provider) {
    DateTime now = dateToFormat(DateTime.now());
    return provider.getBusTimings(route).firstWhere(
          (time) => now.isBefore(stringToDate(time)),
      orElse: () => "No buses",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BusTimingList>(
      builder: (context, provider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Next Bus at:",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text(
              getNextBus(provider),
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ListDisplay widget - Displays all bus timings with edit & delete actions
class ListDisplay extends StatelessWidget {
  final String route;
  const ListDisplay({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<BusTimingList>(context, listen: false).fetchBusTimings(route),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error loading data: ${snapshot.error}"));
        }
        return Consumer<BusTimingList>(
          builder: (context, provider, child) {
            List<String> timings = provider.getBusTimings(route);
            if (timings.isEmpty) {
              return const Center(
                child: Text(
                  "No Bus Timings Available",
                  style: TextStyle(fontSize: 18),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timings.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Slidable(
                    key: ValueKey(timings[index]),
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => provider.deleteBusTiming(route, index, user),
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
                          onPressed: (_) => _editBusTiming(context, index, provider),
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          label: 'Edit',
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            timings[index],
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Time picker for editing bus timings
  void _editBusTiming(BuildContext context, int index, BusTimingList provider) async {
    DateTime initialTime = stringToDate(provider.getBusTimings(route)[index]);

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );

    if (pickedTime != null) {
      String formattedTime = dateToString(
        DateTime(0, 0, 0, pickedTime.hour, pickedTime.minute),
      );
      provider.editBusTiming(route, index, formattedTime, user);
    }
  }
}

// AddTime widget - Adds a new bus timing
class AddTime extends StatelessWidget {
  final String route;
  final String userId;
  const AddTime({super.key, required this.route, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      onPressed: () async {
        String newTime = dateToString(DateTime.now()); // Generate a new time entry
        await Provider.of<BusTimingList>(context, listen: false).addBusTiming(route, newTime, userId);

        allSnackBar(
          context,
          "Time Added for Route $route",
          onUndo: () {
            Provider.of<BusTimingList>(context, listen: false).undoAddBusTiming(route, newTime, userId);
          },
        );
      },
      child: const Text(
        "Add Time",
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

// ListHome widget - Displays a list of bus timings for a given route
class ListHome extends StatelessWidget {
  final String title;
  final bool isPast;
  final String route; // Added route parameter

  const ListHome({super.key, required this.title, required this.isPast, required this.route});

  @override
  Widget build(BuildContext context) {
    DateTime nowtime = dateToFormat(DateTime.now());

    return Consumer<BusTimingList>(
      builder: (context, provider, child) {
        List<String> timings = provider.getBusTimings(route)
            .where((time) => isPast ? stringToDate(time).isBefore(nowtime) : stringToDate(time).isAfter(nowtime))
            .toList();

        if (isPast) timings = List.from(timings.reversed);

        return Expanded(
          child: ListView.builder(
            itemCount: timings.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Center(
                    child: Text(
                      timings[index],
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
