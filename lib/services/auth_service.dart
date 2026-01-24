import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service für die Verwaltung der Benutzerauthentifizierung
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream für Authentifizierungsstatus-Änderungen
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Aktueller Benutzer
  User? get currentUser => _auth.currentUser;

  // Prüft, ob Benutzer angemeldet ist
  bool get isSignedIn => currentUser != null;

  // Gast-Modus Status
  bool get isGuestMode => _isGuestMode;
  static bool _isGuestMode = false;

  /// Anmeldung mit E-Mail und Passwort
  Future<UserCredential?> login(String email, String password) async {
    try {
      _isGuestMode = false;
      await _saveGuestMode(false);
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Registrierung mit E-Mail und Passwort
  Future<UserCredential?> signup(
    String email,
    String password,
    String username,
  ) async {
    try {
      _isGuestMode = false;
      await _saveGuestMode(false);
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Anzeigenamen aktualisieren
      await result.user?.updateDisplayName(username);
      await result.user?.reload();

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Abmeldung
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _saveGuestMode(false);
      _isGuestMode = false;
    } catch (e) {
      throw Exception('Fehler beim Abmelden');
    }
  }

  /// Als Gast fortfahren
  Future<void> continueAsGuest() async {
    _isGuestMode = true;
    await _saveGuestMode(true);
  }

  /// Prüft, ob Benutzer im Gast-Modus war
  Future<bool> wasGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('guest_mode') ?? false;
  }

  /// Passwort zurücksetzen
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Passwort ändern
  Future<void> changePassword(String newPassword) async {
    try {
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'Benutzer ist nicht angemeldet.',
        );
      }
      if (_isGuestMode) {
        throw FirebaseAuthException(
          code: 'guest-mode',
          message: 'Gäste können das Passwort nicht ändern.',
        );
      }
      await currentUser!.updatePassword(newPassword);
      await currentUser!.reload();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// E-Mail-Adresse ändern (benötigt kürzliche Anmeldung)
  Future<void> changeEmail(String newEmail) async {
    try {
      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-user',
          message: 'Benutzer ist nicht angemeldet.',
        );
      }
      if (_isGuestMode) {
        throw FirebaseAuthException(
          code: 'guest-mode',
          message: 'Gäste können die E-Mail-Adresse nicht ändern.',
        );
      }
      await currentUser!.verifyBeforeUpdateEmail(newEmail.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Gast-Modus Status speichern
  Future<void> _saveGuestMode(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('guest_mode', isGuest);
  }

  /// Firebase Auth-Ausnahmen behandeln
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Kein Benutzer mit dieser E-Mail-Adresse gefunden.';
      case 'wrong-password':
        return 'Falsches Passwort. Bitte überprüfe deine Eingabe oder klicke auf "Passwort vergessen", um dein Passwort zurückzusetzen.';
      case 'email-already-in-use':
        return 'Diese E-Mail-Adresse wird bereits verwendet.';
      case 'weak-password':
        return 'Das Passwort ist zu schwach. Es muss mindestens 6 Zeichen lang sein.';
      case 'invalid-email':
        return 'Ungültige E-Mail-Adresse. Bitte überprüfe die Formatierung.';
      case 'operation-not-allowed':
        return 'E-Mail/Passwort-Anmeldung ist nicht aktiviert.';
      case 'user-disabled':
        return 'Dieses Benutzerkonto wurde deaktiviert.';
      case 'too-many-requests':
        return 'Zu viele Anfragen. Bitte warte einen Moment und versuche es erneut.';
      case 'requires-recent-login':
        return 'Aus Sicherheitsgründen musst du dich erneut anmelden, um diese Aktion auszuführen.';
      case 'no-user':
        return 'Du musst angemeldet sein, um diese Aktion auszuführen.';
      case 'guest-mode':
        return 'Diese Aktion ist im Gast-Modus nicht verfügbar. Bitte melde dich mit deinem Konto an.';
      default:
        return 'Ein Fehler ist aufgetreten: ${e.message}';
    }
  }
}
