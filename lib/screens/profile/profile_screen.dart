import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:schmackofatz/screens/auth/welcome_screen.dart';
import 'package:schmackofatz/services/auth_service.dart';
import 'package:schmackofatz/services/profile_service.dart';
import '../../widgets/profile_image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  String? _username;
  String? _email;
  String? _profileImageUrl;
  bool _isLoading = true;
  bool _isUpdating = false;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadProfileData();
  }

  Future<void> _checkLoginStatus() async {
    final isSignedIn = _authService.isSignedIn;
    final isGuestMode = _authService.isGuestMode;
    setState(() {
      _isLoggedIn = isSignedIn && !isGuestMode;
    });
  }

  bool _canChangeSensitiveData() {
    if (!_isLoggedIn) return false;
    return _authService.isSignedIn && !_authService.isGuestMode;
  }

  Future<void> _showNotLoggedInDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Nicht angemeldet!',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Du musst angemeldet sein, um diese Aktion auszuführen. Bitte melde dich mit deinem Konto an.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 26, 169, 48),
            ),
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProfileData() async {
    try {
      final username = await _profileService.getUsername();
      final email = await _profileService.getEmail();
      final imageUrl = await _profileService.getProfileImageUrl();

      setState(() {
        _username = username;
        _email = email;
        _profileImageUrl = imageUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden der Profildaten!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateProfileImage(XFile imageFile) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final imageUrl = await _profileService.uploadProfileImage(imageFile);
      setState(() {
        _profileImageUrl = imageUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profilbild erfolgreich aktualisiert'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Aktualisieren des Profilbildes!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _updateUsername() async {
    // Security check: Verify user is logged in (not in guest mode)
    if (!_canChangeSensitiveData()) {
      await _showNotLoggedInDialog();
      return;
    }

    final usernameController = TextEditingController(text: _username ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Benutzername ändern',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: 'Neuer Benutzername',
            labelStyle: TextStyle(color: Colors.black),
            hintText: 'Gib deinen neuen Benutzernamen ein',
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 26, 169, 48),
                width: 2,
              ),
            ),
          ),
          maxLength: 30,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Abbrechen',
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final username = usernameController.text.trim();
              if (username.isNotEmpty) {
                Navigator.of(context).pop({'username': username});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 26, 169, 48),
            ),
            child: Text(
              'Speichern',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _isUpdating = true;
      });

      try {
        await _profileService.updateUsername(result['username']!);
        setState(() {
          _username = result['username'];
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Benutzername erfolgreich aktualisiert'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Fehler beim Aktualisieren des Benutzernamens! \nDerzeit ist niemand angemeldet.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _updateEmail() async {
    // Security check: Verify user is logged in (not in guest mode)
    if (!_canChangeSensitiveData()) {
      await _showNotLoggedInDialog();
      return;
    }

    final emailController = TextEditingController(text: _email ?? '');

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'E-Mail-Adresse ändern',
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gib deine neue E-Mail-Adresse ein:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Neue E-Mail-Adresse',
                labelStyle: TextStyle(color: Colors.black),
                hintText: 'deine@neueemail.de',
                hintStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 26, 169, 48),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Abbrechen',
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty &&
                  RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                Navigator.of(context).pop({'email': email});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 26, 169, 48),
            ),
            child: Text(
              'Senden',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _isUpdating = true;
      });

      try {
        await _authService.changeEmail(result['email']!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'E-Mail-Änderung eingeleitet. Bitte überprüfe deine neue E-Mail-Adresse.',
              ),
              backgroundColor: Color.fromARGB(255, 26, 169, 48),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Ändern der E-Mail-Adresse!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    // Security check: Verify user is logged in (not in guest mode)
    if (!_canChangeSensitiveData()) {
      await _showNotLoggedInDialog();
      return;
    }

    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscurePassword = true;
    bool obscureConfirmPassword = true;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Passwort ändern',
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Neues Passwort',
                  labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Mindestens 6 Zeichen',
                  hintStyle: TextStyle(color: Colors.black, fontSize: 14),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 26, 169, 48),
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    color: Colors.black,
                    icon: Icon(
                      obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Passwort bestätigen',
                  labelStyle: TextStyle(color: Colors.black),
                  hintText: 'Passwort wiederholen',
                  hintStyle: TextStyle(color: Colors.black, fontSize: 14),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 26, 169, 48),
                      width: 2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    color: Colors.black,
                    icon: Icon(
                      obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Abbrechen',
                style: GoogleFonts.poppins(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final password = passwordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (password.isNotEmpty &&
                    password.length >= 6 &&
                    password == confirmPassword) {
                  Navigator.of(context).pop({'password': password});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 26, 169, 48),
              ),
              child: Text(
                'Ändern',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _isUpdating = true;
      });

      try {
        await _authService.changePassword(result['password']!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Passwort erfolgreich geändert'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Ändern des Passworts!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Abmelden',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Möchtest du dich wirklich abmelden?',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Abbrechen',
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 26, 169, 48),
            ),
            child: Text(
              'Abmelden',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _authService.logout();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Abmelden!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isUpdating
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        ProfileImagePicker(
                          imageUrl: _profileImageUrl,
                          onImageSelected: _updateProfileImage,
                          size: 100,
                          userIdentifier:
                              _username ??
                              _email, // Für eindeutige Standard-Avatare
                        ),
                        SizedBox(height: 16),
                        Text(
                          _username ?? 'Benutzername',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _email ?? 'E-Mail-Adresse',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Profile Options
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: 'Benutzername ändern',
                    subtitle: _username ?? 'Nicht gesetzt',
                    onTap: _updateUsername,
                  ),
                  _buildProfileOption(
                    icon: Icons.email_outlined,
                    title: 'E-Mail-Adresse ändern',
                    subtitle: _email ?? 'Nicht gesetzt',
                    onTap: _updateEmail,
                  ),
                  _buildProfileOption(
                    icon: Icons.lock_outline,
                    title: 'Passwort ändern',
                    subtitle: '••••••••',
                    onTap: _changePassword,
                  ),
                  SizedBox(height: 16),

                  // Logout Button
                  Container(
                    margin: EdgeInsets.all(16),
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        'Abmelden',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 26, 169, 48).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color.fromARGB(255, 26, 169, 48)),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
