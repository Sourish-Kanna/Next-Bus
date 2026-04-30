import 'package:flutter/material.dart';
import 'package:nextbus/widgets/widgets.dart'
    show SettingsGroupCard, ThemeSettings;
import 'package:nextbus/providers/providers.dart'
    show AuthService, UserDetails, ConnectivityProvider, NavigationProvider;
import 'package:provider/provider.dart' show ReadContext, WatchContext;
import 'package:nextbus/pages/pages.dart' show AuthScreen;
import 'package:package_info_plus/package_info_plus.dart' show PackageInfo;
import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImageProvider;
import 'package:shared_preferences/shared_preferences.dart';

import '../common.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.auto_awesome_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text("The Story"),
          content: const SingleChildScrollView(
            child: Text(
              "This data is the result of 3.5 years of manually tracking my daily commute "
              "from Thane Station to Tikujiniwadi.\n\n"
              "It includes data for Route 56 and the parallel Route 156, "
              "which shares 95% of the same path.\n\n"
              "It started as a personal project to never miss a bus again. I hope it helps you too.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.4),
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

  void _showDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: Icon(
            Icons.gpp_maybe_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text("Data Authenticity"),
          content: const SingleChildScrollView(
            child: Text(
              "This application uses crowdsourced data collected from user reports. "
              "While we strive for accuracy, bus timings and availability may vary. "
              "Please use this data as a guide.",
              textAlign: TextAlign.center,
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout?"),
        content: const Text("You will need internet to sign back in."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton.tonal(
            onPressed: () {
              _logout(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    // 1. Clear local cache (Offline First logic)
    // We use context.read which is cleaner for functions
    await context.read<UserDetails>().clearUserData();
    if (!context.mounted) return;
    await context.read<NavigationProvider>().clearNavigationCache();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!context.mounted) return;
    // 2. Sign out from Firebase
    await context.read<AuthService>().signOut();
    if (!context.mounted) return;
    // 3. Navigate to AuthScreen and REMOVE ALL BACK HISTORY
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (Route<dynamic> route) =>
          false, // This predicate false = remove everything
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().user;
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    final String initials =
        user?.displayName?.trim().isNotEmpty ??
            false // checks if display name is there or not
        ? user!.displayName!
              .trim()
              .split(' ')
              .map((e) => e[0])
              .take(2)
              .join()
              .toUpperCase() // If yes
        : "GU"; // If no (GU => Guest User)
    final accessLevel = context.watch<UserDetails>().accessLevel;
    final String message =
        "${user?.email ?? "Signed in as Guest"}\n$accessLevel";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // --- APPEARANCE ---
          const SettingsGroupCard(
            title: 'Appearance',
            icon: Icons.dark_mode_rounded,
            children: [ThemeSettings()],
          ),
          const SizedBox(height: 16),

          // --- ACCOUNT (With Profile) ---
          SettingsGroupCard(
            title: 'Account',
            icon: Icons.manage_accounts_rounded,
            children: [
              // 2. Display User Info if logged in
              if (user != null) ...[
                // Tooltip(
                //   message: message,
                //   triggerMode: TooltipTriggerMode.longPress,
                //   child:
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    backgroundImage: user.photoURL != null
                        ? CachedNetworkImageProvider(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Text(
                            initials,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    user.displayName ?? "Guest User",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  isThreeLine: true,
                  subtitle: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // ),
                ),
                // const Divider(height: 24), // Separator
              ],

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isOnline
                      ? () => _confirmLogout(context)
                      : () => CustomSnackBar.showError(
                          context,
                          "You cannot logout while offline.",
                        ),
                  style: ElevatedButton.styleFrom(
                    // Grey out the button visually if offline
                    backgroundColor: isOnline
                        ? Theme.of(context).colorScheme.errorContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: isOnline
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: isOnline
                      ? const Icon(Icons.logout)
                      : const Icon(Icons.wifi_off),
                  label: Text(
                    isOnline ? "Logout" : "Offline (Logout Disabled)",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- ABOUT ---
          SettingsGroupCard(
            title: 'About',
            icon: Icons.auto_awesome_rounded,
            children: [
              ListTile(
                leading: const Icon(Icons.psychology),
                title: const Text("Why I Built This"),
                subtitle: const Text("The commuter's story"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showAboutDialog(context),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text("Data Authenticity"),
                subtitle: const Text("Disclaimer & Sources"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showDisclaimer(context),
              ),
              const Divider(height: 1, indent: 56),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  String versionText = "Loading...";
                  if (snapshot.hasData) {
                    versionText = snapshot.data!.version;
                    if (snapshot.data!.buildNumber.isNotEmpty) {
                      versionText += " (${snapshot.data!.buildNumber})";
                    }
                  }
                  return ListTile(
                    leading: const Icon(Icons.verified_outlined),
                    title: const Text("Version"),
                    subtitle: Text(versionText),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
