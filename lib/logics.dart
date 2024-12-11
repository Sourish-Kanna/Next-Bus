import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:next_bus/bus_timing_provider.dart';
import 'package:provider/provider.dart';

class NextTime extends StatelessWidget {
  const NextTime({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BusTimingProvider>(
        builder: (context, provider, child) {
          String getNextBus() {
            DateTime now = DateTime.now();
            for (String time in provider.busTimings) {
              DateTime busTime = DateTime.parse("${now.year}-${now.month}-${now.day} $time:00");
              if (now.isBefore(busTime)) {
                return time;
              }
            }
            return "No more buses today";
          }
          return Column(
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
    return Consumer<BusTimingProvider>(
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
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        provider.busTimings[index],
                        style: Theme.of(context).textTheme.bodyMedium,
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

  void _editBusTiming(BuildContext context, int index, BusTimingProvider provider) {
    TextEditingController _timeController = TextEditingController(text: provider.busTimings[index]);
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
                provider.editBusTiming(index, _timeController.text);
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
    TextEditingController _timeController = TextEditingController();

    return Row(
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
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            if (_timeController.text.isNotEmpty) {
              Provider.of<BusTimingProvider>(context, listen: false).addBusTiming(_timeController.text);
              _timeController.clear();
            }
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
