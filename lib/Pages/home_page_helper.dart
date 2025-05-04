
import 'package:flutter/material.dart';
import 'package:nextbus/Providers/bus_timing_provider.dart';
import 'package:provider/provider.dart';

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