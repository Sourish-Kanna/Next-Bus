import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nextbus/Providers/bus_timing.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/Providers/authentication.dart';
import 'package:nextbus/common.dart';


// ListDisplay widget - Displays all bus timings with edit & delete actions
class ListDisplay extends StatelessWidget {
  final String route;
  const ListDisplay({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final User? user = authService.user;
    bool isAdmin = false; // Default to false if user is null
    if (user != null) {
      isAdmin = !user.isAnonymous;
    }

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
            return Expanded(
              child: ListView.builder(
                itemCount: timings.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Slidable(
                      key: ValueKey(timings[index]),
                      startActionPane: isAdmin
                        ? ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => provider.deleteBusTiming(route, index, user!.uid),
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                          ),
                        ],
                      ) : null,
                      endActionPane: isAdmin
                        ? ActionPane(
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
                      ) : null,
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
              ),
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
      final authService = Provider.of<AuthService>(context, listen: false);
      final User? user = authService.user;
      provider.editBusTiming(route, index, formattedTime, user!.uid);
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

