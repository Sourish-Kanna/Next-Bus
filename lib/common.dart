import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


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
