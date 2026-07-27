import 'package:flutter/material.dart';
import 'package:nextbus/constant.dart';
import 'package:nextbus/providers/providers.dart'
    show UserDetails, NavigationProvider;
import 'package:nextbus/widgets/widgets.dart' show ConnectivityBanner;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

// Navigation Item Model
class NavigationItem {
  final NavigationDestinations destination;
  final IconData icon;
  final String label;

  const NavigationItem({
    required this.destination,
    required this.icon,
    required this.label,
  });
}

// App Layout
class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool _isInit = true; // Flag to ensure fetch only runs once
  static bool _isDialogShowing = false;

  // Fetch user data once
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      context.read<UserDetails>().fetchUserDetails(isInit: _isInit);
      _isInit = false;
    }
  }

  // Disclaimer dialog (shown once)
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDisclaimerDialog();
    });
  }

  Future<void> _showDisclaimerDialog() async {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('hasShownDisclaimer') ?? false;

    if (shown || !mounted) {
      _isDialogShowing = false;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.info_outline,
          color: Theme.of(ctx).colorScheme.primary,
        ),
        title: const Text('Data Notice'),
        content: const Text(
          'This application uses crowdsourced data which may not be fully verified. '
          'Please use with discretion.',
          textAlign: TextAlign.center,
        ),
        actions: [
          FilledButton(
            onPressed: () async {
              await prefs.setBool('hasShownDisclaimer', true);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }

  // Destinations Builder
  List<NavigationItem> _buildDestinations(bool isAdmin) {
    final items = <NavigationItem>[
      const NavigationItem(
        destination: NavigationDestinations.home,
        icon: Icons.home,
        label: 'Home',
      ),
      const NavigationItem(
        destination: NavigationDestinations.route,
        icon: Icons.route,
        label: 'Route',
      ),
      const NavigationItem(
        destination: NavigationDestinations.settings,
        icon: Icons.settings,
        label: 'Settings',
      ),
    ];

    if (isAdmin) {
      items.add(
        const NavigationItem(
          destination: NavigationDestinations.admin,
          icon: Icons.admin_panel_settings,
          label: 'Admin',
        ),
      );
    }

    return items;
  }

  // Page Resolver
  Widget _currentPage(NavigationDestinations destination) {
    switch (destination) {
      case NavigationDestinations.home:
        return routesPage['home']!;
      case NavigationDestinations.route:
        return routesPage['route']!;
      case NavigationDestinations.settings:
        return routesPage['settings']!;
      case NavigationDestinations.admin:
        return routesPage['admin']!;
      default:
        return const Center(child: Text("Page not found"));
    }
  }

  // Material 3 NavigationBar (Mobile)
  Widget? _navigationBar(
    bool isMobile,
    List<NavigationItem> destinations,
    NavigationProvider nav,
  ) {
    if (!isMobile) return null;

    final index = destinations.indexWhere(
      (item) => item.destination == nav.current,
    );

    return NavigationBar(
      selectedIndex: index < 0 ? 0 : index,
      onDestinationSelected: (i) {
        nav.navigateTo(destinations[i].destination);
      },
      destinations: destinations
          .map(
            (item) =>
                NavigationDestination(icon: Icon(item.icon), label: item.label),
          )
          .toList(),
    );
  }

  // NavigationRail (Desktop)
  Widget _navigationRail(
    BuildContext context,
    List<NavigationItem> destinations,
    NavigationProvider nav,
  ) {
    final index = destinations.indexWhere(
      (item) => item.destination == nav.current,
    );

    return NavigationRail(
      selectedIndex: index < 0 ? 0 : index,
      onDestinationSelected: (i) {
        nav.navigateTo(destinations[i].destination);
      },
      labelType: NavigationRailLabelType.all,
      destinations: destinations
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              label: Text(item.label),
            ),
          )
          .toList(),
    );
  }

  // Animated Page
  Widget _buildPage(NavigationDestinations current) {
    return Column(
      children: [
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey(current),
              child: _currentPage(current),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: const ConnectivityBanner(key: ValueKey('connectivity')),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = context.watch<UserDetails>();
    final nav = context.watch<NavigationProvider>();

    final destinations = _buildDestinations(userDetails.isAdmin);

    nav.resetIfInvalid(destinations.map((e) => e.destination).toSet());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < mobileBreakpoint;

        // AppLogger.info(
        //   'Destinations Count: ${destinations.length}',
        // );

        return Scaffold(
          body: isMobile
              ? _buildPage(nav.current)
              : Row(
                  children: [
                    _navigationRail(context, destinations, nav),
                    const VerticalDivider(width: 1),
                    Expanded(child: _buildPage(nav.current)),
                  ],
                ),
          bottomNavigationBar: _navigationBar(isMobile, destinations, nav),
        );
      },
    );
  }
}
