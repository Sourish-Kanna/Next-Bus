import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

List<String> busTimings = ["08:00", "09:00", "10:30", "16:50", "23:50"];

class NextTime extends StatefulWidget {
  const NextTime({super.key});

  @override
  State<NextTime> createState() => _NextTimeState();
}

class _NextTimeState extends State<NextTime> {
  Set<int> swipedIndices = {};


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

  @override
  Widget build(BuildContext context) {
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
  }
}


class ListDisplay extends StatefulWidget {
  const ListDisplay({super.key});

  @override
  State<ListDisplay> createState() => _ListDisplayState();
}

class _ListDisplayState extends State<ListDisplay> {

  Set<int> swipedIndices = {};
  final TextEditingController _timeController = TextEditingController();

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


  @override
  Widget build(BuildContext context) {
    return Expanded(
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

    );
  }
}


class AddTime extends StatefulWidget {
  const AddTime({super.key});

  @override
  State<AddTime> createState() => _AddTimeState();
}

class _AddTimeState extends State<AddTime> {

  List<String> busTimings = ["08:00", "09:00", "10:30"];
  final TextEditingController _timeController = TextEditingController();


  void _addNewBusTiming(String newTime) {
    setState(() {
      busTimings.add(newTime);
      busTimings.sort();
    });
    _timeController.clear();
  }

  @override
  Widget build(BuildContext context) {
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
    );
  }
}