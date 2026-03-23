import 'package:flutter/material.dart';
import 'package:nextbus/providers/providers.dart' show RouteProvider, NavigationProvider;
import 'package:nextbus/common.dart' show AppLogger;
import 'package:nextbus/constant.dart' show NavigationDestinations;
import 'package:provider/provider.dart' show ReadContext, WatchContext;

class RouteSelect extends StatefulWidget {
  const RouteSelect({super.key});

  @override
  State<RouteSelect> createState() => _RouteSelectState();
}

class _RouteSelectState extends State<RouteSelect> {
  String? selectedRoute;
  bool _isLoading = true;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      final routeProvider = context.read<RouteProvider>();
      _resolveSelectedRoute(routeProvider);
      _isInit = false;
    }
  }

  void _resolveSelectedRoute(RouteProvider routeProvider) {
    if (routeProvider.availableRoutes.isNotEmpty) {
      if (selectedRoute == null) {
        if (routeProvider.route.isNotEmpty &&
            routeProvider.availableRoutes.contains(routeProvider.route)) {
          selectedRoute = routeProvider.route;
        } else {
          selectedRoute = routeProvider.availableRoutes.first;
        }
        AppLogger.info('Selected route resolved to: $selectedRoute');
      }
      _isLoading = false;
    } else {
      AppLogger.warn('RouteSelect: availableRoutes is empty.');
      _isLoading = false;
    }
  }

  /// ------------------------------
  /// Refresh Routes
  /// ------------------------------
  Future<void> _refreshRoutes() async {
    final routeProvider = context.read<RouteProvider>();

    await routeProvider.fetchRoutes();

    if (!mounted) return;

    setState(() {
      _resolveSelectedRoute(routeProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeProvider = context.watch<RouteProvider>();
    final navProvider = context.read<NavigationProvider>();

    AppLogger.info('RouteSelect build — selectedRoute: $selectedRoute');

    return Scaffold(
      appBar: AppBar(
          title: const Text(
            'Select a TMT Bus Route',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select a route from the list below:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshRoutes,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: routeProvider.availableRoutes.length,
                        itemBuilder: (context, index) {
                          final routeItem =
                              routeProvider.availableRoutes[index];
                          final isSelected = selectedRoute == routeItem;

                          return ListTile(
                            title: Text(routeItem),
                            leading: Icon(
                              Icons.directions_bus,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            tileColor: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                      .withValues(alpha: 0.3)
                                : null,
                            onTap: () {
                              AppLogger.info(
                                'Route selected and confirmed: $routeItem',
                              );

                              routeProvider.setRoute(routeItem);

                              // ✅ Navigate using enum-based navigation
                              navProvider.navigateTo(
                                NavigationDestinations.home,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
