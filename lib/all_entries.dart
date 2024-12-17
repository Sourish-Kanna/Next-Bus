import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:next_bus/logics.dart';
import 'package:provider/provider.dart';
import 'package:next_bus/bus_timing_provider.dart';

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Next Bus'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "All Entries",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListDisplay(),
          ],
        ),
      ),
    );
  }
}
