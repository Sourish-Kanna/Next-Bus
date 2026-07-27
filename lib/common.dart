import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// A utility class for creating a custom SnackBar.
class CustomSnackBar {
  /// Base method for showing a SnackBar
  static void show(
    BuildContext context,
    String text, {
    VoidCallback? onUndo,
    Color? backgroundColor,
    Color? foregroundColor,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    final colorScheme = Theme.of(context).colorScheme;
    final bg = backgroundColor ?? colorScheme.inverseSurface;
    final fg = foregroundColor ?? colorScheme.onInverseSurface;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: fg, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        action: onUndo != null
            ? SnackBarAction(
                label: "UNDO",
                textColor: colorScheme.inversePrimary,
                onPressed: onUndo,
              )
            : null,
      ),
    );
    HapticFeedback.lightImpact();
  }

  /// Shortcut for Error/Warning messages
  static void showError(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    show(
      context,
      text,
      backgroundColor: colorScheme.error,
      foregroundColor: colorScheme.onError,
      icon: Icons.error_outline_rounded,
    );
    HapticFeedback.heavyImpact(); // Stronger feedback for errors
  }

  /// Shortcut for Success messages
  static void showSuccess(BuildContext context, String text) {
    show(
      context,
      text,
      // Using a custom green if your theme doesn't have a success color
      backgroundColor: Colors.green[700],
      foregroundColor: Colors.white,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  /// Shortcut for Info/General messages (uses default M3 Inverse Surface)
  static void showInfo(BuildContext context, String text, {IconData? icon}) {
    show(context, text, icon: icon ?? Icons.info_outline_rounded);
  }
}

/// A utility class for logging and crash reporting.
class AppLogger {
  static FirebaseCrashlytics? _crashlytics;

  /// Initialize the logger with the Crashlytics instance.
  static void initialize(FirebaseCrashlytics instance) {
    _crashlytics = instance;
  }

  static void onlyLocal(String message) {
    if (kDebugMode) {
      debugPrint("💻 [LOCAL] $message");
    }
  }

  /// For simple informational messages.
  static void info(String message) {
    if (kDebugMode) {
      debugPrint("ℹ️ [INFO] $message");
    }
    // Log to Crashlytics as a breadcrumb
    if (!kIsWeb) {
      _crashlytics?.log("[INFO] $message");
    }
  }

  /// For warnings that don't stop the app.
  static void warn(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint("⚠️ [WARN] $message");
      if (error != null) {
        debugPrint(error.toString());
      }
      if (stack != null) {
        debugPrint(stack.toString());
      }
    }
    // Log to Crashlytics as a breadcrumb
    if (!kIsWeb) {
      _crashlytics?.log("[WARN] $message");
    }
  }

  /// For errors that should be reported as non-fatal issues.
  static void error(String reason, Object error, [StackTrace? stack]) {
    if (kDebugMode) {
      debugPrint("🔥 [ERROR] $reason");
      debugPrint(error.toString());
      if (stack != null) {
        debugPrint(stack.toString());
      }
    }

    // Log the error to Crashlytics. This will show up as a
    // "non-fatal" issue in your Firebase dashboard.
    if (!kIsWeb) {
      _crashlytics?.recordError(
        error,
        stack,
        reason: reason,
        fatal: false, // false because the app isn't crashing
      );
    }
  }
}
