import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/Pages/home_page_helper.dart';
import 'package:nextbus/Providers/authentication.dart';
import 'package:nextbus/Providers/route.dart';
import 'package:nextbus/Pages/login.dart';
import 'package:nextbus/Pages/admin_page.dart';

class BusHomePage extends StatelessWidget {
  const BusHomePage({super.key});

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

    return Container(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Consumer<RouteProvider>(
      //     builder: (context, routeProvider, child) {
      //       return Text('Route ${routeProvider.route}');
      //     },),
      //   actions: [
      //     if (user != null)
      //       IconButton(
      //         icon: const Icon(Icons.logout),
      //         onPressed: () async {
      //           await authService.signOut();
      //           Navigator.pushReplacement(
      //             context,
      //             MaterialPageRoute(builder: (context) => const AuthScreen()),
      //           );
      //         },
      //       ),
      //   ],
      // ),
      child: Padding(
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
      // floatingActionButton: isAdmin ? adminFAB(context, user) : null,
    );
  }
}