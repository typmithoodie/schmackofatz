import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schmackofatz/screens/auth/login_screen.dart';
import 'package:schmackofatz/services/auth_service.dart';
import '../../main.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte akzeptiere die Nutzungsbedingungen'),
          backgroundColor: Color.fromARGB(255, 255, 0, 0),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService().signup(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => NavigatorPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Color.fromARGB(255, 255, 0, 0),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Konto erstellen',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6),
                Text(
                  'Registriere dich für schmackofatz',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28),
                // Benutzername
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Benutzername',
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Dein Benutzername',
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.person_outline, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 26, 169, 48),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib einen Benutzernamen ein';
                    }
                    if (value.length < 2) {
                      return 'Der Benutzername muss mindestens 2 Zeichen lang sein';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18),
                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'E-Mail',
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'deine@email.de',
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 26, 169, 48),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib deine E-Mail ein';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Bitte gib eine gültige E-Mail ein';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18),
                // Passwort
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Passwort',
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Mindestens 6 Zeichen',
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.black),
                    suffixIcon: IconButton(
                      color: Colors.black,
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 26, 169, 48),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte gib ein Passwort ein';
                    }
                    if (value.length < 6) {
                      return 'Passwort muss mindestens 6 Zeichen lang sein';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 18),
                // Passwort bestätigen
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Passwort bestätigen',
                    labelStyle: TextStyle(color: Colors.black),
                    hintText: 'Passwort wiederholen',
                    hintStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.black),
                    suffixIcon: IconButton(
                      color: Colors.black,
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 26, 169, 48),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte bestätige dein Passwort';
                    }
                    if (value != _passwordController.text) {
                      return 'Die Passwörter stimmen nicht überein';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Terms and Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      activeColor: Color.fromARGB(255, 26, 169, 48),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text.rich(
                          TextSpan(
                            text: 'Ich akzeptiere die ',
                            children: [
                              TextSpan(
                                text: 'Nutzungsbedingungen',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 26, 169, 48),
                                ),
                              ),
                              const TextSpan(text: ' und '),
                              TextSpan(
                                text: 'Datenschutzbestimmungen',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 26, 169, 48),
                                ),
                              ),
                            ],
                          ),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 26),

                // Signup Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 26, 169, 48),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Registrieren',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                SizedBox(height: 16),
                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bereits ein Konto? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Anmelden',
                        style: TextStyle(
                          color: Color.fromARGB(255, 26, 169, 48),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
