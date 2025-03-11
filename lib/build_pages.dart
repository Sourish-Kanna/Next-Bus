import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextbus/build_widgets.dart';
import 'package:nextbus/firebase_operations.dart';
import 'package:flutter/material.dart';
import 'package:nextbus/auth.dart';
import 'package:nextbus/route_provider.dart';
import 'package:provider/provider.dart';
import 'bus_timing_provider.dart';


class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text("Failed to initialize Firebase", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              const Text("Try again later, by turning on internet", style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

class BusHomePage extends StatelessWidget {
  const BusHomePage({super.key});

  void _showAdminOptionsDialog(BuildContext context, User? user) {
    final routeProvider = Provider.of<RouteProvider>(context, listen: false);
    final busTimingProvider = Provider.of<BusTimingList>(context, listen: false);
    var firestoreService = FirestoreService();

    // Function to change the route
    void changeRoute(BuildContext context, RouteProvider routeProvider) {
      String selectedRoute = routeProvider.route;
      List<String> routes = [
        "56", "102", "110", "205", "301", "402", "505", "606", "707", "808", "909", "1010"
      ]; // Example routes

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Change Route"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Select a new route:"),
                      DropdownButtonFormField<String>(
                        value: selectedRoute,
                        items: routes.map((route) {
                          return DropdownMenuItem(
                            value: route,
                            child: Text("Route $route"),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedRoute = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text("Confirm"),
                    onPressed: () {
                      Navigator.pop(context);
                      routeProvider.setRoute(selectedRoute);
                      allSnackBar(context, "Route changed to $selectedRoute");
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    }

    // Function to add a new route
    void addRoute(BuildContext context) {
      TextEditingController routeController = TextEditingController();
      TextEditingController stopController = TextEditingController();
      TextEditingController timeController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Add Route"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: routeController,
                    decoration: const InputDecoration(labelText: "Route Number"),
                  ),
                  TextField(
                    controller: stopController,
                    decoration: const InputDecoration(labelText: "Stop Name"),
                  ),
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: "Timing (e.g., 10:00 AM)"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Add"),
                onPressed: () {
                  firestoreService.addRoute(
                    routeController.text,
                    [stopController.text],
                    [timeController.text],
                    user!.uid,
                  );
                  allSnackBar(context, "Added Route ${routeController.text}");
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    // Function to remove a route
    void removeRoute(BuildContext context) {
      TextEditingController routeController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Remove Route"),
            content: TextField(
              controller: routeController,
              decoration: const InputDecoration(labelText: "Enter Route Number"),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Remove"),
                onPressed: () {
                  firestoreService.removeRoute(routeController.text, user!.uid);
                  allSnackBar(context, "Removed Route ${routeController.text}");
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    // Function to add bus timing
    void addBusTiming(BuildContext context) {
      TextEditingController routeController = TextEditingController();
      TextEditingController stopController = TextEditingController();
      TextEditingController timeController = TextEditingController();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Add Bus Timing"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: routeController,
                    decoration: const InputDecoration(labelText: "Route Number"),
                  ),
                  TextField(
                    controller: stopController,
                    decoration: const InputDecoration(labelText: "Stop Name"),
                  ),
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: "Timing (e.g., 10:00 AM)"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Add"),
                onPressed: () {
                  busTimingProvider.addBusTiming(
                    routeController.text,
                    stopController.text,
                    timeController.text,
                  );
                  allSnackBar(context, "Added Timing for Route ${routeController.text}");
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }

    // Show Admin Options Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Admin Options"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ExpansionTile(
                  title: const Text("Route Options"),
                  leading: const Icon(Icons.directions),
                  childrenPadding: const EdgeInsets.only(left: 20.0),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.swap_horiz),
                      title: const Text("Change Route"),
                      onTap: () => changeRoute(context, routeProvider),
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text("Add Route"),
                      onTap: () => addRoute(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text("Remove Route"),
                      onTap: () => removeRoute(context),
                    ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text("View Timings"),
                  onTap: () {
                    busTimingProvider.getBusTimings(routeProvider.route);
                    allSnackBar(context, "Fetching timings for Route ${routeProvider.route}");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text("Add Bus Timing"),
                  onTap: () => addBusTiming(context),
                ),
                ListTile(
                  leading: const Icon(Icons.print),
                  title: const Text("Print All Variables"),
                  onTap: () {
                    debugPrint("Route: ${routeProvider.route}");
                    debugPrint("User ID: ${user?.uid}");
                    debugPrint("Auth Status: ${user?.isAnonymous}");
                  },
                ),
                ListTile(
                  title: const Text("Route Selector"),
                  leading: const Icon(Icons.select_all),
                  onTap: () {
                    Navigator.pushNamed(context, '/route');
                  },
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final User? user = authService.user;

    final routeProvider = Provider.of<RouteProvider>(context);
    String route = routeProvider.route;
    bool isAdmin = false;
    if (user != null) {
      isAdmin = !user.isAnonymous;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Consumer<RouteProvider>(
          builder: (context, routeProvider, child) {
            return Text('Route ${routeProvider.route}');
          },),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authService.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NextTime(route: route),
            const SizedBox(height: 10),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text("Past", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ListHome(title: "Past", isPast: true, route: route),
                      ],
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      children: [
                        Text("Next", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ListHome(title: "Next", isPast: false, route: route),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () => Navigator.pushNamed(context, '/entries'),
              child: const Text("View All Timings", style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
        onPressed: () => _showAdminOptionsDialog(context, user),
        tooltip: 'Admin Options',
        child: const Icon(Icons.settings_suggest),
      )
          : null,
    );
  }
}

class EntriesPage extends StatelessWidget {
  const EntriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routeProvider = Provider.of<RouteProvider>(context);
    final authService = Provider.of<AuthService>(context); // Get AuthService instance
    final User? user = authService.user; // Retrieve the currently logged-in user
    bool isAdmin = false; // Default to false if user is null
    if (user != null) {
      isAdmin = !user.isAnonymous;
    }

    String route = routeProvider.route;
    String userId = user?.uid ?? "guest"; // Use "guest" if the user is not logged in

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Entries'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "All Entries",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            ListDisplay(route: route),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isAdmin)
                  AddTime(userId: userId,route: route),

                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Go Back",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Next Bus Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.account_circle),
              label: const Text("Sign in with Google"),
              onPressed: () async {
                User? user = await authService.signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BusHomePage()),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_outline),
              label: const Text("Continue as Guest"),
              onPressed: () async {
                User? user = await authService.signInAsGuest();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BusHomePage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

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