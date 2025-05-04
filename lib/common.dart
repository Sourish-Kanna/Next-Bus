import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Haptic feedback for user actions
void provideHapticFeedback() {
  HapticFeedback.lightImpact();
}

// SnackBar widget with optional undo action
void allSnackBar(BuildContext context, String text, {VoidCallback? onUndo}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.inverseSurface.withOpacity(0.95),
      behavior: SnackBarBehavior.floating,
      content: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      action: onUndo != null
          ? SnackBarAction(
        label: "Undo",
        onPressed: onUndo,
      )
          : null,
      duration: const Duration(seconds: 3),
    ),
  );
  provideHapticFeedback();
}
