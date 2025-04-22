import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // Needed for kIsWeb

class AuthService with ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  User? get user => _auth.currentUser;

  AuthService._internal() {
    _initializeAuth();
  }


  /// Ensures Firebase Auth persistence & listens for auth changes
  Future<void> _initializeAuth() async {
    // await _auth.setPersistence(Persistence.LOCAL); // ✅ Keep user signed in
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  /// 🔹 Google Sign-In (Web & Mobile)
  Future<User?> signInWithGoogle() async {
    try {
      // debugPrint("Hello0");
      UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null; // User canceled sign-in
        // debugPrint("Hello1");

        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        // debugPrint("Hello2");

        userCredential = await _auth.signInWithCredential(credential);
      }

      _user = userCredential.user;
      notifyListeners();
      // debugPrint("Hello3");
      debugPrint("Google Sign-In Successful: ${_user?.email}");
      return _user;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  /// 🔹 Guest Login (Anonymous Sign-In)
  Future<User?> signInAsGuest() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      _user = userCredential.user;
      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint("Guest Login Error: $e");
      return null;
    }
  }

  /// 🔹 Logout & Delete Anonymous Users
  Future<void> signOut() async {
    try {
      if (_auth.currentUser != null) {
        if (_auth.currentUser!.isAnonymous) {
          await _auth.currentUser!.delete(); // ✅ Delete anonymous user
          debugPrint("Anonymous user deleted successfully.");
        }

        await _googleSignIn.signOut(); // ✅ Ensure Google sign-out
        await _auth.signOut(); // ✅ Sign out from Firebase Auth
        _user = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Sign-Out Error: $e");
    }
  }
}
