import 'package:firebase_auth/firebase_auth.dart';
import 'package:nextbus/Pages/view_entries_helper.dart';
import 'package:flutter/material.dart';
import 'package:nextbus/Providers/authentication.dart';
import 'package:nextbus/Providers/route.dart';
import 'package:provider/provider.dart';

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
