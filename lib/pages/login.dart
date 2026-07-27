import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nextbus/providers/providers.dart' show AuthService;
import 'package:nextbus/layout.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LOGO (Squircle)
              Center(
                child: Material(
                  elevation: 3,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/logo_new.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                      semanticLabel: 'Next Bus app logo',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // TITLE
              Text(
                "Next Bus",
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Never miss your ride again",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 48),

              // GOOGLE SIGN IN (Primary)
              FilledButton.icon(
                onPressed: () async {
                  final user = await authService.signInWithGoogle(context);
                  if (user != null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AppLayout()),
                    );
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  textStyle: theme.textTheme.labelLarge,
                ),
                icon: const Icon(Icons.login, size: 24),
                label: const Text("Sign in with Google"),
              ),

              const SizedBox(height: 16),

              // GUEST MODE (Secondary)
              OutlinedButton.icon(
                onPressed: () async {
                  final user = await authService.signInAsGuest(context);
                  if (user != null && context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AppLayout()),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  textStyle: theme.textTheme.labelLarge,
                ),
                icon: const Icon(Icons.person_outline, size: 24),
                label: const Text("Continue as Guest"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
