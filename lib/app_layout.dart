import 'package:flutter/material.dart';
import 'package:nextbus/common.dart';


class _NavItem {
  final String label;
  final IconData icon;
  final String? route;
  const _NavItem(this.label, this.icon, this.route,);
}

final List<_NavItem> _navItems = [
  _NavItem('Home', Icons.home, '/home'),
  _NavItem('Route', Icons.route, '/route'),
  _NavItem('Entries', Icons.bookmark, '/entries'),
  _NavItem('Admin', Icons.settings, '/admin')
];
final List<Widget> navDrawerDestinations = _navItems.map((item) =>
    NavigationDrawerDestination(icon: Icon(item.icon), label: Text(item.label),)
).toList();

class AppLayout extends StatefulWidget {
  final int selectedIndex;
  final Widget child;

  const AppLayout({super.key, required this.selectedIndex, required this.child});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}
class _AppLayoutState extends State<AppLayout> {

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;
    final isDrawer = width >= 1024;

    final navWidget = _buildNavigation(context, isWide, isDrawer, widget.selectedIndex);

    return Scaffold(
      body: Row(
        children: [
          if (isWide) navWidget,
          Expanded(child: SafeArea(child: widget.child),),
        ],
      ),
      bottomNavigationBar: !isWide ? navWidget : null,
    );
  }
}


void _onDestinationSelected(BuildContext context, int index) {
  final route = _navItems[index].route;
  if (route != null && ModalRoute.of(context)?.settings.name != route) {
    Navigator.pushNamed(context, route);
  }
}

Widget _buildNavigation(BuildContext context, bool isWide, bool isDrawer, int selectedIndex) {
  if (isDrawer) {
    return NavigationDrawer(
      selectedIndex: selectedIndex,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      children: [
        ...navDrawerDestinations,
        const Divider(),
        logoutButton(context, () => logoutUser(context)),
      ],
    );
  } else if (isWide) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      labelType: NavigationRailLabelType.all,
      destinations: _navItems
          .map((item) => NavigationRailDestination(
        icon: Icon(item.icon),
        label: Text(item.label),
      ))
          .toList(),
      trailing: logoutButton(context, () => logoutUser(context)),
    );
  } else {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      destinations: _navItems
          .map((item) => NavigationDestination(
        icon: Icon(item.icon),
        label: item.label,
      ))
          .toList(),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}
Widget logoutButton(BuildContext context, VoidCallback logoutUser) {
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: ElevatedButton.icon(
      onPressed: () {logoutUser();},
      icon: Icon(
        Icons.logout,
      ),
      label: Text("Logout"),
    ),
  );
}
