import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/providers/providers.dart'
    show
        AuthService,
        RouteProvider,
        TimetableProvider,
        UserDetails,
        ConnectivityProvider;
import 'package:nextbus/common.dart';
import 'package:nextbus/widgets/widgets.dart'; // Reusable widgets

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  // --- 1. CHANGE ACTIVE ROUTE (Dropdown Dialog) ---
  void _changeRoute(BuildContext context, RouteProvider routeProvider) {
    String selectedRoute = routeProvider.route;
    List<String> routes = routeProvider.availableRoutes;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              icon: Icon(
                Icons.swap_horiz,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text("Switch Active Route"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Select the route you want to manage:"),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    initialValue: selectedRoute,
                    items: routes.map((route) {
                      return DropdownMenuItem(
                        value: route,
                        child: Text("Route $route"),
                      );
                    }).toList(),
                    onChanged: (newValue) =>
                        setState(() => selectedRoute = newValue!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
                FilledButton(
                  child: const Text("Confirm"),
                  onPressed: () {
                    Navigator.pop(context);
                    routeProvider.setRoute(selectedRoute);
                    CustomSnackBar.showInfo(
                      context,
                      "Switched to Route $selectedRoute",
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- 2. ADD NEW ROUTE (Input Form) ---
  void _showAddRouteDialog(BuildContext context) {
    final routeNameController = TextEditingController();
    final startController = TextEditingController();
    final endController = TextEditingController();
    final stopsController = TextEditingController();
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Add New Route"),
            scrollable: true,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: routeNameController,
                  decoration: const InputDecoration(
                    labelText: "Route Name (e.g. 56A)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: startController,
                  decoration: const InputDecoration(
                    labelText: "Start Point",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: endController,
                  decoration: const InputDecoration(
                    labelText: "End Point",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stopsController,
                  decoration: const InputDecoration(
                    labelText: "Stops (comma separated)",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text("Initial Timing"),
                  trailing: Text(
                    selectedTime.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) setState(() => selectedTime = picked);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              FilledButton(
                onPressed: () async {
                  if (routeNameController.text.isEmpty) return;

                  final provider = Provider.of<TimetableProvider>(
                    context,
                    listen: false,
                  );
                  List<String> stops = stopsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  final String timeStr = selectedTime.format(context);

                  await provider.addRoute(
                    routeNameController.text,
                    stops,
                    timeStr,
                    startController.text,
                    endController.text,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    CustomSnackBar.showSuccess(
                      context,
                      "Route ${routeNameController.text} Added!",
                    );
                  }
                },
                child: const Text("Create"),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 3. UPDATE TIMING (Input Form) ---
  void _showUpdateTimingDialog(
    BuildContext context,
    RouteProvider routeProvider,
  ) {
    String selectedRoute = routeProvider.route;
    final stopNameController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Update Bus Timing"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedRoute,
                  decoration: const InputDecoration(
                    labelText: "Route",
                    border: OutlineInputBorder(),
                  ),
                  items: routeProvider.availableRoutes
                      .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedRoute = val!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: stopNameController,
                  decoration: const InputDecoration(
                    labelText: "Stop Name (e.g. Station)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  title: const Text("New Timing"),
                  trailing: Text(
                    selectedTime.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) setState(() => selectedTime = picked);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              FilledButton(
                onPressed: () async {
                  if (stopNameController.text.isEmpty) return;

                  final provider = Provider.of<TimetableProvider>(
                    context,
                    listen: false,
                  );
                  final String timeStr = selectedTime.format(context);

                  await provider.updateTime(
                    selectedRoute,
                    stopNameController.text,
                    timeStr,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    CustomSnackBar.showSuccess(
                      context,
                      "Updated $selectedRoute at $timeStr",
                    );
                  }
                },
                child: const Text("Update"),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- 4. ENHANCED DEBUG INFO ---
  Future<void> _showDebugDialog(BuildContext context) async {
    // 1. Fetch all providers
    final authService = context.read<AuthService>();
    final routeProvider = context.read<RouteProvider>();
    final userDetails = context.read<UserDetails>();
    final timetableProvider = context.read<TimetableProvider>();
    final connectivity = context.read<ConnectivityProvider>();

    // 2. Fetch App Version (Async)
    final packageInfo = await PackageInfo.fromPlatform();

    // 3. Construct the Mega-Log
    final String debugInfo =
        """
[SYSTEM DIAGNOSTICS]
====================
APP INFO
- Version: ${packageInfo.version}
- Build Number: ${packageInfo.buildNumber}
- Package: ${packageInfo.packageName}
====================
NETWORK
- Status: ${connectivity.isOnline ? "ONLINE 🟢" : "OFFLINE 🔴"}
====================
USER SESSION
- UID: ${authService.user?.uid ?? "NULL"}
- Email: ${authService.user?.email ?? "N/A"}
- Is Admin: ${userDetails.isAdmin}
- Is Guest: ${userDetails.isGuest}
- Is Anonymous (Auth): ${authService.user?.isAnonymous}
====================
ROUTE STATE
- Active Route: ${routeProvider.route}
- Total Available: ${routeProvider.availableRoutes.length}
- Route List: ${routeProvider.availableRoutes}
====================
TIMETABLE CACHE
- Routes in Memory: ${timetableProvider.timetables.length}
- Cached Keys: ${timetableProvider.timetables.keys.toList()}
- Is Loading: ${timetableProvider.isLoading}
====================
TIMESTAMP
${DateTime.now().toIso8601String()}
    """;

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Icon(
            Icons.bug_report,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          title: const Text("System State Dump"),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: SelectableText(
                  // Allows text selection on mobile
                  debugInfo,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: debugInfo));
                CustomSnackBar.show(context, "Full logs copied to clipboard");
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text("Copy Log"),
            ),
            FilledButton(
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
    final busTimingProvider = Provider.of<TimetableProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // 1. ADMIN PROFILE
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: const Icon(Icons.admin_panel_settings),
              ),
              title: Text(
                user?.displayName ?? "Admin User",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user?.email ?? "No Email"),
            ),
          ),
          const SizedBox(height: 20),

          // 2. ROUTE MANAGEMENT
          SettingsGroupCard(
            title: 'Route Management',
            icon: Icons.map_outlined,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Active Route",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          "Route ${routeProvider.route}",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _changeRoute(context, routeProvider),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text("Switch"),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_road),
                title: const Text("Create New Route"),
                subtitle: const Text("Define name, stops & timing"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAddRouteDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. DATA & TIMINGS
          SettingsGroupCard(
            title: 'Data & Timings',
            icon: Icons.dataset_outlined,
            children: [
              ListTile(
                leading: const Icon(Icons.update),
                title: const Text("Update Timings"),
                subtitle: const Text("Add arrival time for a stop"),
                onTap: () => _showUpdateTimingDialog(context, routeProvider),
              ),
              const Divider(indent: 56),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("Inspect Route Data"),
                onTap: () async {
                  await busTimingProvider.fetchTimetable(routeProvider.route);
                  if (context.mounted) {
                    CustomSnackBar.show(
                      context,
                      "Data fetched. Check debug logs.",
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. DEBUGGING
          SettingsGroupCard(
            title: 'System Debug',
            icon: Icons.bug_report_outlined,
            children: [
              ListTile(
                title: const Text("Dump Application State"),
                subtitle: const Text("View logs, cache & connectivity"),
                leading: const Icon(Icons.terminal),
                onTap: () => _showDebugDialog(context), // Updated call
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
