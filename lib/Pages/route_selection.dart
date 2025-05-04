import 'package:flutter/material.dart';

class RouteSelect extends StatefulWidget {
  const RouteSelect({super.key});

  @override
  State<RouteSelect> createState() => _RouteSelectState();
}

class _RouteSelectState extends State<RouteSelect> {
  String? selectedRoute;
  List<String> routes = ["56", "102", "110", "205", "301", "402", "505", "606", "707", "808", "909", "1010"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Route"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose a route:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedRoute,
              items: routes.map((route) => DropdownMenuItem(
                value: route,
                child: Text("Route $route"),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRoute = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Or select from the list:"),
            Expanded(
              child: ListView.builder(
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Route ${routes[index]}"),
                    leading: Icon(Icons.directions_bus, color: selectedRoute == routes[index] ? Colors.blue : Colors.grey),
                    onTap: () {
                      setState(() {
                        selectedRoute = routes[index];
                      });
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: selectedRoute != null ? () {
                  Navigator.pop(context, selectedRoute);
                } : null,
                child: const Text("Confirm Route"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}