import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:nextbus/Providers/authentication.dart';


// SnackBar widget with optional undo action and Haptic feedback for user actions
void customSnackBar(BuildContext context, String text, {VoidCallback? onUndo}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface,
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      action: onUndo != null ?
      SnackBarAction(label: "Undo", onPressed: onUndo,) : null,
      duration: const Duration(seconds: 3),
    ),
  );
  HapticFeedback.lightImpact();
}

// Shared App Layout
class AppLayout extends StatelessWidget {
  final int selectedIndex;
  final Widget child;
  const AppLayout({super.key, required this.selectedIndex, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentItem = _NavDrawerItems[selectedIndex];
    return Scaffold(
      appBar: AppBar(title: Text(currentItem.label)),
      drawer: NavDrawer(selectedIndex: selectedIndex),
      body: child,
      bottomNavigationBar: AppBottomNavigationBar(selectedIndex: selectedIndex),
    );
  }
}

class NavDrawer extends StatelessWidget {
  final int selectedIndex;
  const NavDrawer({super.key, required this.selectedIndex});

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    if (ModalRoute.of(context)?.settings.name != route) {
      if (route == '/login') { Navigator.pushReplacementNamed(context, route);}
      else { Navigator.pushNamed(context, route);}
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          // padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text('App Navigation', style: TextStyle(fontSize: 20)),
            ),
            ..._NavDrawerItems.map((item) {
              if (item.submenus.isEmpty) {
                return ListTile(
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  selected: selectedIndex == _NavDrawerItems.indexOf(item),
                  onTap: () => _navigate(context, item.route!),
                );
              } else {
                return ExpansionTile(
                  leading: Icon(item.icon),
                  title: Text(item.label),
                  children: item.submenus.map((sub) {
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 72),
                      title: Text(sub.label),
                      onTap: () => _navigate(context, sub.route),
                    );
                  }).toList(),
                );
              }
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await authService.signOut();
                _navigate(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom Navigation Bar
class AppBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  const AppBottomNavigationBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      destinations: _NavBarItems
          .where((item) => item.route != null)
          .map((item) => NavigationDestination(
        icon: Icon(item.icon),
        label: item.label,
      ))
          .toList(),
      onDestinationSelected: (index) {
        final route = _NavBarItems.where((item) => item.route != null).toList()[index].route;
        if (route != null && ModalRoute.of(context)?.settings.name != route) {
          Navigator.pushNamed(context, route);
        }
      },
    );
  }
}

// Nav Items and Submenus
class _NavItem {
  final String label;
  final IconData icon;
  final String? route;
  final List<_SubNavItem> submenus;
  const _NavItem(this.label, this.icon, this.route, [this.submenus = const []]);
}

class _SubNavItem {
  final String label;
  final String route;
  const _SubNavItem(this.label, this.route);
}

const List<_NavItem> _NavDrawerItems = [
  _NavItem('Home', Icons.home, '/home'),
  _NavItem('Route', Icons.route, '/route'),
  _NavItem('Entries', Icons.bookmark, '/entries'),
  // _NavItem('Logout', Icons.logout_rounded, '/login')
  // _NavItem('Quote', Icons.format_quote, '/route'),
];

const List<_NavItem> _NavBarItems = [
  _NavItem('Home', Icons.home, '/home'),
  _NavItem('Route', Icons.route, '/route'),
  _NavItem('Entries', Icons.bookmark, '/entries'),
  // _NavItem('Logout', Icons.logout_rounded, '/login')
  _NavItem('Route', Icons.format_quote, '/route'),
];
