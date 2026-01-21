import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding/onboarding_screen.dart';
import 'main.dart'; // für NavigatorPage
import 'services/auth_service.dart';
import 'screens/auth/welcome_screen.dart';

/// Entscheidet über den Start der App basierend auf Authentifizierungsstatus und Onboarding
class StartDecider extends StatelessWidget {
  const StartDecider({super.key});

  /// Prüft, ob das Onboarding bereits abgeschlossen wurde
  Future<bool> _isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_done') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, authSnapshot) {
        // Lädt während der Überprüfung des Authentifizierungsstatus
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final authService = AuthService();
        final isSignedIn = authService.isSignedIn;
        final isGuestMode = authService.isGuestMode;

        // Zuerst Onboarding-Status prüfen für alle neuen Benutzer
        return FutureBuilder<bool>(
          future: _isOnboardingDone(),
          builder: (context, onboardingSnapshot) {
            if (!onboardingSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final onboardingDone = onboardingSnapshot.data!;

            // Wenn Onboarding noch nicht gemacht → OnboardingScreen (für alle neuen Benutzer)
            if (!onboardingDone) {
              return OnboardingScreen();
            }

            // Wenn Onboarding abgeschlossen ist
            if (isSignedIn || isGuestMode) {
              // Angemeldet oder Gast-Modus → Zur Haupt-App
              return NavigatorPage();
            }

            // Nicht authentifiziert, aber Onboarding abgeschlossen → Willkommensbildschirm
            return WelcomeScreen();
          },
        );
      },
    );
  }
}
