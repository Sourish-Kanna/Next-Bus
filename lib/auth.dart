import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';


// Singleton AuthService
class AuthService with ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthService._internal() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;
      notifyListeners();
      return _user;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

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

  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    _user = null;
    notifyListeners();
  }
}


class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(title: const Text("Next Bus Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.account_circle),
              label: const Text("Sign in with Google"),
              onPressed: () async {
                User? user = await authService.signInWithGoogle();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_outline),
              label: const Text("Continue as Guest"),
              onPressed: () async {
                User? user = await authService.signInAsGuest();
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Next Bus"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome, ${user.displayName ?? 'Guest'}",
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 10),
            user.photoURL != null
                ? CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL!),
              radius: 40,
            )
                : const Icon(Icons.account_circle, size: 80),
            const SizedBox(height: 20),
            Text("User ID: ${user.uid}", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
