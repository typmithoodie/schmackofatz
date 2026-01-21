import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schmackofatz/main.dart';
import 'package:schmackofatz/screens/auth/login_screen.dart';
import 'package:schmackofatz/screens/auth/signup_screen.dart';
import 'package:schmackofatz/services/auth_service.dart';

/// Willkommensbildschirm für neue und bestehende Benutzer
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo und App-Name
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('lib/images/schmackofatz_logo.png', height: 80),
                    SizedBox(height: 24),
                    Text(
                      'schmackofatz',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 26, 169, 48),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Dein smarter Küchenassistent',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Aktionsschaltflächen
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Als Gast fortfahren-Schaltfläche
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await AuthService().continueAsGuest();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NavigatorPage(),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Fehler: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[700],
                        padding: EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Als Gast fortfahren',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Anmelde-Schaltfläche
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 26, 169, 48),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 36,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Anmelden',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Registrieren-Schaltfläche
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Color.fromARGB(255, 26, 169, 48),
                          width: 2,
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 36,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Registrieren',
                        style: TextStyle(
                          color: Color.fromARGB(255, 26, 169, 48),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
