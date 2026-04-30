import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignIn;
import 'package:flutter/material.dart' show BuildContext, ChangeNotifier;
import 'package:flutter/foundation.dart' show ChangeNotifier, kIsWeb;
import 'package:nextbus/constant.dart' show urls;
import 'package:provider/provider.dart' show Provider;

import 'package:nextbus/common.dart' show AppLogger, CustomSnackBar;
import 'package:nextbus/providers/user_details.dart' show UserDetails;
import 'package:nextbus/providers/api_caller.dart' show ApiService;

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  User? get user => _auth.currentUser;

  AuthService() {
    _initializeAuth();
  }

  /// 🔹 Listen to Firebase auth state changes
  void _initializeAuth() {
    _auth.authStateChanges().listen((User? user) {
      AppLogger.info(
        "Auth state changed → ${user?.uid}, anonymous: ${user?.isAnonymous}",
      );
      notifyListeners();
    });
  }

  /// 🔹 Google Sign-In (Web + Mobile)
  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      UserCredential? userCredential;

      if (kIsWeb) {
        AppLogger.info("Starting Google Sign-In (Web)...");
        userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        AppLogger.info("Starting Google Sign-In (Mobile)...");
        final googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          AppLogger.info("Google Sign-In canceled by user.");
          return null;
        }

        AppLogger.info("Google user chosen: ${googleUser.email}");

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final user = userCredential.user;

      if (user != null) {
        await syncUserWithBackend();

        AppLogger.info(
          "Google Sign-In success → UID: ${user.uid}, Email: ${user.email}",
        );

        if (context.mounted) {
          final userDetails = Provider.of<UserDetails>(context, listen: false);
          await userDetails.fetchUserDetails();
          AppLogger.info(
            "UserDetails → Admin: ${userDetails.isAdmin}, Guest: ${userDetails.isGuest}, Logged: ${userDetails.isLoggedIn}",
          );
        }

        return user;
      }

      return null;
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          "Sign-in failed. Please check your internet or configuration.",
        );
      }
      AppLogger.error("Google Sign-In Error", e);
      return null;
    }
  }

  /// 🔹 Guest (anonymous) login
  Future<User?> signInAsGuest(BuildContext context) async {
    try {
      AppLogger.info("Starting Guest Login...");
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;

      if (user != null) {
        AppLogger.info("Guest Login Successful → UID: ${user.uid}");

        if (context.mounted) {
          final userDetails = Provider.of<UserDetails>(context, listen: false);
          await userDetails.fetchUserDetails();
          AppLogger.info(
            "UserDetails → Admin: ${userDetails.isAdmin}, Guest: ${userDetails.isGuest}, Logged: ${userDetails.isLoggedIn}",
          );
        }
      }

      return user;
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.showError(
          context,
          "Sign-in failed. Please check your internet or configuration.",
        );
      }
      AppLogger.error("Guest Login Error", e);
      return null;
    }
  }

  /// 🔹 Logout (and delete anonymous users)
  Future<void> signOut() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser != null) {
        AppLogger.info(
          "Signing out user → UID: ${currentUser.uid}, anonymous: ${currentUser.isAnonymous}",
        );

        if (currentUser.isAnonymous) {
          await currentUser.delete();
          AppLogger.info("Deleted anonymous user account.");
        }

        if (!kIsWeb) {
          await _googleSignIn.signOut();
          AppLogger.info("GoogleSignIn.signOut() completed (mobile only).");
        }

        await _auth.signOut();
        AppLogger.info("FirebaseAuth.signOut() completed.");

        notifyListeners();
      }
    } catch (e) {
      AppLogger.error("Sign-Out Error", e);
    }
  }
}

Future<void> syncUserWithBackend() async {
  try {
    AppLogger.info("Attempting to sync user with backend...");

    final apiService = ApiService();

    // No data body is needed because the backend extracts everything from the JWT token.
    final response = await apiService.post(urls['SyncUser']!);

    if (response.statusCode == 200) {
      AppLogger.info("User successfully synced with backend: ${response.data}");
    } else {
      AppLogger.info(
        "Backend sync returned unexpected status: ${response.statusCode}",
      );
    }
  } catch (e) {
    // We log the error but do not throw it.
    // If the backend has a brief hiccup, we still want the user to enter the app!
    AppLogger.error("Failed to sync user with backend", e);
  }
}
