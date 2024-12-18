import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:nextbus/bus_timing_provider.dart';
import 'package:provider/provider.dart';

SnackBar addSnackBar(BuildContext context, String text, ) {
  DateTime now = DateTime.now();
  return SnackBar(
    backgroundColor: Theme.of(context).colorScheme.
    inverseSurface.withOpacity(0.95),
    behavior: SnackBarBehavior.floating,
    content: Text(text,
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    action: text=="Time Added" ? SnackBarAction(
      label: "Undo",
      onPressed: () {
        Provider.of<BusTimingList>(context, listen: false).undoAddBusTiming(now);
      },
    ) : null ,
    duration: Duration(seconds: 3),
  );
}


class NextTime extends StatelessWidget {
  const NextTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BusTimingList>(
        builder: (context, provider, child) {

          String getNextBus() {
            DateTime now = DateTime.now();
            String formattedTime = DateFormat('h:mm a').format(now);
            DateTime timeNew = DateFormat('h:mm a').parse(formattedTime);
            for (DateTime time in provider.busTimings) {
              if (timeNew.isBefore(time)) {
                return dateToString(time);
              }
            }
            return "No more buses today";
          }

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
                getNextBus(),
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
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                child: Slidable(
                  key: ValueKey(provider.busTimings[index]),
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          provider.deleteBusTiming(index);
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
                          // Handle editing
                          _editBusTiming(context, index, provider);
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
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dateToString(provider.busTimings[index]),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
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
    TextEditingController timeController = TextEditingController(text: dateToString(provider.busTimings[index]));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Bus Timing"),
        content: TextField(
          controller: timeController,
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
              if (timeController.text.isNotEmpty) {
                provider.editBusTiming(index, stringToDate(timeController.text));
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}


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
        Provider.of<BusTimingList>(context, listen: false).addBusTiming();
        ScaffoldMessenger.of(context).showSnackBar(
          addSnackBar(context, "Time Added"),
        );
      },
      child: const Text(
        "Add time",
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal
        ),
      ),
    );
  }
}


class ListHome extends StatelessWidget {
  const ListHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BusTimingList>(
      builder: (context, provider, child) {
        return Expanded(
          child: ListView.builder(
            itemCount: provider.busTimings.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dateToString(provider.busTimings[index]),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
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