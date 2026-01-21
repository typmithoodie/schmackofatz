import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Aktueller Benutzer
  User? get currentUser => _auth.currentUser;

  /// Profilbild hochladen (vereinfachte Version ohne Firebase Storage)
  Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      if (currentUser == null) {
        throw Exception('Benutzer ist nicht angemeldet');
      }

      // Für jetzt speichern wir die Bild-URL als Base64 oder lokal
      // In einer echten App würden wir Firebase Storage verwenden
      final bytes = await imageFile.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // Profilbild URL in SharedPreferences speichern
      await _saveProfileImageUrl(base64Image);

      return base64Image;
    } catch (e) {
      throw Exception('Fehler beim Speichern des Profilbilds!');
    }
  }

  // Get profile image URL
  Future<String?> getProfileImageUrl() async {
    try {
      // First check if user is signed in
      if (currentUser == null) return null;

      // Try to get from Firebase Storage if photoURL exists
      if (currentUser!.photoURL != null && currentUser!.photoURL!.isNotEmpty) {
        return currentUser!.photoURL;
      }

      // Fallback to stored preferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('profile_image_url');
    } catch (e) {
      return null;
    }
  }

  // Update username
  Future<void> updateUsername(String username) async {
    try {
      if (currentUser == null) throw Exception('User not signed in');

      // Update display name in Firebase Auth
      await currentUser!.updateDisplayName(username);
      await currentUser!.reload();

      // Save to preferences
      await _saveUsername(username);
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren des Benutzernamens!');
    }
  }

  // Get stored username
  Future<String?> getUsername() async {
    try {
      if (currentUser?.displayName != null &&
          currentUser!.displayName!.isNotEmpty) {
        return currentUser!.displayName;
      }

      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('username');
    } catch (e) {
      return null;
    }
  }

  // Get stored email
  Future<String?> getEmail() async {
    try {
      if (currentUser?.email != null) {
        return currentUser!.email;
      }

      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('email');
    } catch (e) {
      return null;
    }
  }

  // Save username to preferences
  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  // Save profile image URL to preferences
  Future<void> _saveProfileImageUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_url', url);
  }

  // Save email to preferences
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  /// Profilbild löschen
  Future<void> deleteProfileImage() async {
    try {
      if (currentUser == null) return;

      // Lösche nur aus SharedPreferences (kein Firebase Storage)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_url');
    } catch (e) {
      // Ignoriere Fehler (Bild könnte nicht existieren)
    }
  }

  // Clear all profile data
  Future<void> clearProfileData() async {
    try {
      await deleteProfileImage();

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      await prefs.remove('email');
      await prefs.remove('profile_image_url');
    } catch (e) {
      // Ignore errors
    }
  }

  // Check if profile is complete
  Future<bool> isProfileComplete() async {
    final username = await getUsername();
    final email = await getEmail();
    await getProfileImageUrl();

    return username != null &&
        username.isNotEmpty &&
        email != null &&
        email.isNotEmpty;
  }
}
