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

    void changeRoute(String newRoute) {
      routeProvider.setRoute(newRoute);
      Navigator.pop(context);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Admin Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text("Change Route"),
                onTap: () {
                  changeRoute("102");
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_bus),
                title: const Text("Add Route"),
                onTap: () {
                  firestoreService.addRoute("102", ["Stop1", "Stop2"], ["10:00 AM", "10:30 AM"], user!.uid);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text("Add Bus Timing"),
                onTap: () {
                  busTimingProvider.addBusTiming("102", "Stop1", "11:00 AM");
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Remove Route"),
                onTap: () {
                  firestoreService.removeRoute("102",user!.uid);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("View Timings"),
                onTap: () {
                  busTimingProvider.getBusTimings("102");
                },
              ),
              ListTile(
                leading: const Icon(Icons.telegram),
                title: const Text("display all var"),
                onTap: () {
                  debugPrint("route : ${routeProvider.route}");
                  debugPrint("user id : ${user?.uid}");
                  debugPrint("auth: ${user?.isAnonymous}");

                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
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

    // Redirect to login if user is not authenticated
    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final routeProvider = Provider.of<RouteProvider>(context);
    String route = routeProvider.route;
    bool isAdmin = !user.isAnonymous;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Welcome, ${user.displayName ?? "User"}'),
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
            Text("Current Route: $route"),
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
        child: const Icon(Icons.add),
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
