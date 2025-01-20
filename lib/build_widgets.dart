import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nextbus/bus_timing_provider.dart';
import 'package:provider/provider.dart';

var route = "56";
var user = "test";

// SnackBar widget
SnackBar addSnackBar(BuildContext context, String text, {VoidCallback? onUndo}) {
  return SnackBar(
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
  );
}

// NextTime widget
class NextTime extends StatelessWidget {
  const NextTime({super.key});

  String getNextBus(BusTimingList provider) {
    DateTime now = dateToFormat(DateTime.now());
    for (String time in provider.busTimings) {
      if (now.isBefore(stringToDate(time))) {
        return time;
      }
    }
    return "No buses";
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

// ListDisplay widget
class ListDisplay extends StatelessWidget {
  const ListDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BusTimingList>(
      builder: (context, provider, child) {
        return Expanded(
          child: ListView.builder(
            itemCount: provider.busTimings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Slidable(
                  key: ValueKey(provider.busTimings[index]),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => provider.deleteBusTiming(route,index, user),
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
                        onPressed: (context) => _editBusTiming(context, index, provider),
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
                          provider.busTimings[index],
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
  }

  void _editBusTiming(BuildContext context, int index, BusTimingList provider) {
    TextEditingController timeController = TextEditingController(
      text: provider.busTimings[index],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Bus Timing"),
        content: TextField(
          controller: timeController,
          decoration: const InputDecoration(labelText: "Enter Time (HH:MM AM/PM)"),
          keyboardType: TextInputType.datetime,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                var newTime = timeController.text;
                provider.editBusTiming(route, index, newTime, user);
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  addSnackBar(context, "Invalid time format"),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

// AddTime widget
class AddTime extends StatelessWidget {
  const AddTime({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      onPressed: () {
        Provider.of<BusTimingList>(context, listen: false).addBusTiming(route, "${user}Add Button");
        ScaffoldMessenger.of(context).showSnackBar(
          addSnackBar(
            context,
            "Time Added",
            onUndo: () {
              String now = dateToString(DateTime.now());
              Provider.of<BusTimingList>(context, listen: false).undoAddBusTiming(route, now, user);
            },
          ),
        );
      },
      child: const Text(
        "Add time",
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}

// ListHomeNext & ListHomePast widgets
class ListHome extends StatelessWidget {
  final String title;
  final bool isPast;

  const ListHome({super.key, required this.title, required this.isPast});

  @override
  Widget build(BuildContext context) {
    DateTime nowtime = dateToFormat(DateTime.now());
    return Consumer<BusTimingList>(
      builder: (context, provider, child) {
        List<String> timings = isPast
            ? provider.busTimings.where((time) => stringToDate(time).isBefore(nowtime)).toList()
            : provider.busTimings.where((time) => stringToDate(time).isAfter(nowtime)).toList();

        timings = isPast ? timings.reversed.toList() : timings;

        return Expanded(
          child: ListView.builder(
            itemCount: timings.length,
            itemBuilder: (context, index) {
              return Padding(
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
              );
            },
          ),
        );
      },
    );
  }
}
