import 'package:flutter/material.dart';
import 'package:nextbus/providers/providers.dart' show ConnectivityProvider;
import 'package:provider/provider.dart' show Consumer;
import 'package:nextbus/common.dart' show CustomSnackBar;

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivity, child) {
        // Wrap in AnimatedSize for smooth slide-in/slide-out effect
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: connectivity.isOnline
              ? const SizedBox.shrink() // Height becomes 0 nicely
              : Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: InkWell(
                    onTap: () async {
                      // Visual Feedback (Clearer)
                      CustomSnackBar.show(
                        context,
                        'Checking connection...',
                        // backgroundColor: Colors.green,
                        // foregroundColor: Colors.white,
                      );

                      // Perform Check
                      bool isNowOnline = await connectivity.checkConnection();

                      // Feedback
                      if (context.mounted) {
                        if (isNowOnline) {
                          CustomSnackBar.showSuccess(
                            context,
                            'Back online!',
                            // backgroundColor: Colors.green,
                            // foregroundColor: Colors.white,
                          );
                        } else {
                          CustomSnackBar.showInfo(
                            context,
                            'Still offline. Please check settings.',
                            // backgroundColor: Theme.of(context).colorScheme.error,
                            // foregroundColor: Theme.of(context).colorScheme.onError,
                          );
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      // Increased padding for better touch target
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              'No connection. Tap to retry.',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
