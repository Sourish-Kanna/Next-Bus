import 'package:flutter/material.dart';
import 'package:nextbus/providers/providers.dart'
    show RouteProvider, TimetableProvider;
import 'package:provider/provider.dart' show ReadContext;
import 'package:intl/intl.dart' show DateFormat;
import 'package:nextbus/common.dart' show AppLogger, CustomSnackBar;

class ReportBusSheet extends StatefulWidget {
  const ReportBusSheet({super.key});

  @override
  State<ReportBusSheet> createState() => _ReportBusSheetState();
}

class _ReportBusSheetState extends State<ReportBusSheet> {
  // Loading State Variable
  bool _isLoading = false;

  Future<void> _submitReport(BuildContext context, String timeStr) async {
    setState(() => _isLoading = true);

    try {
      final routeProvider = context.read<RouteProvider>();
      final timeProvider = context.read<TimetableProvider>();

      final result = await timeProvider.updateTime(
        routeProvider.route,
        "Thane Station",
        timeStr,
      );

      AppLogger.info('Reported: Route ${routeProvider.route} at $timeStr');
      if (!context.mounted) return;

      if (result['success'] == true) {
        // CASE: Saved Offline
        if (result['isOffline'] == true) {
          CustomSnackBar.showInfo(
            context,
            'Offline: Report saved and will sync later.',
          );
        } else {
          // CASE: Successful API call
          CustomSnackBar.showSuccess(
            context,
            'Reported: Route ${routeProvider.route} at $timeStr',
          );
        }
        Navigator.pop(context);
      } else {
        // CASE: Server Error (including 429)
        String errorMsg = result['message'] ?? 'Unknown error';

        if (errorMsg.contains('429')) {
          CustomSnackBar.showError(
            context,
            'Too many requests. Please wait a moment.',
          );
        } else {
          CustomSnackBar.showError(context, errorMsg);
        }
      }
    } catch (e) {
      // Handle errors gracefully (optional)
      if (context.mounted) {
        CustomSnackBar.showError(context, 'An unexpected error occurred.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper widget for the M3 Spinner
  Widget _buildSpinner(BuildContext context, {bool onPrimary = true}) {
    return CircularProgressIndicator(
      strokeCap: StrokeCap.round,
      color: onPrimary
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).colorScheme.onSecondaryContainer,
    );
  }

  ButtonStyle _xlButtonStyle(BuildContext context, {bool isError = false}) {
    final theme = Theme.of(context);
    return FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isError ? theme.colorScheme.errorContainer : null,
      foregroundColor: isError ? theme.colorScheme.onErrorContainer : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Report Bus",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 25),

          // --- BUTTON 1: Arrived Now ---
          FilledButton.icon(
            onPressed: _isLoading
                ? null
                : () {
                    String formattedTime = DateFormat(
                      'h:mm a',
                    ).format(DateTime.now());
                    _submitReport(context, formattedTime);
                  },
            style: _xlButtonStyle(context),
            icon: _isLoading ? null : const Icon(Icons.directions_bus),
            label: Text(
              _isLoading ? "Sending..." : "Arrived Now",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ), // Larger Font
          ),
          const SizedBox(height: 16), // Increased spacing
          // --- BUTTON 2: Report Time ---
          FilledButton.tonalIcon(
            style: _xlButtonStyle(context),
            onPressed: _isLoading
                ? null
                : () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      final DateTime now = DateTime.now();
                      final DateTime dateTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      final String formattedTime = DateFormat(
                        'h:mm a',
                      ).format(dateTime);
                      if (!context.mounted) return;
                      _submitReport(context, formattedTime);
                    }
                  },
            icon: _isLoading ? null : const Icon(Icons.schedule),
            label: _isLoading
                ? _buildSpinner(context, onPrimary: true)
                : Text(
                    "Report Time",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
          ),
          const SizedBox(height: 16), // Increased spacing
        ],
      ),
    );
  }
}
