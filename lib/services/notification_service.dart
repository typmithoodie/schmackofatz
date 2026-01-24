import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'fridge_service.dart';
import '../models/fridge_item.dart';

/// Service für lokale Benachrichtigungen über ablaufende Kühlschrank-Artikel
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Timer? _checkTimer;

  // Storage keys
  static const String _lastNotificationDateKey =
      'last_expiry_notification_date';
  static const String _notificationEnabledKey = 'expiry_notifications_enabled';

  /// Initialisiert den Notification Service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Create notification channel for Android
    await _createNotificationChannel();

    _isInitialized = true;
  }

  /// Erstellt den Notification Channel für Android
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      'fridge_expiry_channel',
      'Kühlschrank Ablaufdatum',
      description: 'Benachrichtigungen über ablaufende Lebensmittel',
      importance: Importance.high,
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Prüft ob Notifications aktiviert sind
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ??
        true; // Standard: aktiviert
  }

  /// Aktiviert/deaktiviert Notifications
  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
  }

  /// Startet die automatische Prüfung auf ablaufende Artikel (läuft alle 6 Stunden)
  Future<void> startPeriodicCheck() async {
    await initialize();

    _checkTimer?.cancel();
    _checkTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => _checkExpiringItems(),
    );

    // Führe sofort eine Prüfung durch
    await _checkExpiringItems();
  }

  /// Stoppt die automatische Prüfung
  void stopPeriodicCheck() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  /// Prüft auf ablaufende Artikel und zeigt Benachrichtigungen an
  Future<void> _checkExpiringItems() async {
    if (!await isEnabled()) return;

    // Prüfe nur einmal pro Tag
    final prefs = await SharedPreferences.getInstance();
    final lastDate = prefs.getInt(_lastNotificationDateKey);
    final today = DateTime.now().day;

    if (lastDate == today) return; // Heute bereits Benachrichtigung gezeigt

    try {
      final expiringItems = await FridgeService().getExpiringItems();
      final expiredItems = await FridgeService().getExpiredItems();

      if (expiringItems.isEmpty && expiredItems.isEmpty) return;

      // Zeige Benachrichtigung
      await _showExpiryNotification(
        expiredCount: expiredItems.length,
        expiringCount: expiringItems.length,
        items: [...expiredItems, ...expiringItems].take(5).toList(),
      );

      // Speichere das Datum der letzten Benachrichtigung
      await prefs.setInt(_lastNotificationDateKey, today);
    } catch (e) {
      // Fehler beim Prüfen ignorieren
    }
  }

  /// Zeigt eine Benachrichtigung über ablaufende Artikel an
  Future<void> _showExpiryNotification({
    required int expiredCount,
    required int expiringCount,
    required List<FridgeItem> items,
  }) async {
    final details = await _getNotificationDetails();

    final String title;
    final String body;

    if (expiredCount > 0 && expiringCount > 0) {
      title = 'Achtung: Lebensmittel abgelaufen!';
      body =
          '$expiredCount Artikel bereits abgelaufen, $expiringCount laufen bald ab!\n\n${items.map((e) => '• ${e.name} (${_getExpiryText(e)})').join('\n')}';
    } else if (expiredCount > 0) {
      title = 'Achtung: Abgelaufene Lebensmittel!';
      body =
          '$expiredCount Artikel bereits abgelaufen!\n\n${items.map((e) => '• ${e.name}').join('\n')}';
    } else {
      title = 'Bald ablaufende Lebensmittel';
      body =
          '$expiringCount Artikel laufen bald ab:\n\n${items.map((e) => '• ${e.name} (${_getExpiryText(e)})').join('\n')}';
    }

    await _notifications.show(
      1001,
      title,
      body,
      details,
      payload: 'expiring_items',
    );
  }

  /// Zeigt eine sofortige Benachrichtigung an (z.B. nach dem Hinzufügen eines Artikels)
  Future<void> showImmediateNotification(FridgeItem item) async {
    if (!await isEnabled()) return;

    await initialize();
    final details = await _getNotificationDetails();

    final String title;
    final String body;

    if (item.daysUntilExpiration < 0) {
      title = 'Achtung: Abgelaufen!';
      body =
          '${item.name} ist bereits abgelaufen! Mindesthaltbarkeitsdatum: ${_formatDate(item.bestBeforeDate)}';
    } else if (item.daysUntilExpiration <= 1) {
      title = 'Läuft heute ab!';
      body =
          '${item.name} läuft heute ab! Mindesthaltbarkeitsdatum: ${_formatDate(item.bestBeforeDate)}';
    } else if (item.daysUntilExpiration <= 3) {
      title = 'Bald ablaufend';
      body =
          '${item.name} läuft in ${item.daysUntilExpiration} Tagen ab (${_formatDate(item.bestBeforeDate)})';
    } else {
      return; // Keine Benachrichtigung für frische Artikel
    }

    await _notifications.show(
      item.id.hashCode,
      title,
      body,
      details,
      payload: 'item_${item.id}',
    );
  }

  /// Zeigt eine Zusammenfassung aller ablaufenden Artikel an
  Future<void> showExpirySummary() async {
    if (!await isEnabled()) return;

    await initialize();

    final expiringItems = await FridgeService().getExpiringItems();
    final expiredItems = await FridgeService().getExpiredItems();

    if (expiredItems.isEmpty && expiringItems.isEmpty) {
      // Keine ablaufenden Artikel
      final details = await _getNotificationDetails();
      await _notifications.show(
        1002,
        'Kühlschrank OK',
        'Alle deine Lebensmittel sind noch frisch! 🍎',
        details,
      );
      return;
    }

    await _showExpiryNotification(
      expiredCount: expiredItems.length,
      expiringCount: expiringItems.length,
      items: [...expiredItems, ...expiringItems].take(5).toList(),
    );
  }

  /// Erstellt die Notification Details für die aktuelle Plattform
  Future<NotificationDetails> _getNotificationDetails() async {
    const androidDetails = AndroidNotificationDetails(
      'fridge_expiry_channel',
      'Kühlschrank Ablaufdatum',
      channelDescription: 'Benachrichtigungen über ablaufende Lebensmittel',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Formatiert ein Datum für die Anzeige
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  /// Gibt einen Text für das Ablaufdatum zurück
  String _getExpiryText(FridgeItem item) {
    if (item.daysUntilExpiration < 0) {
      return 'abgelaufen';
    } else if (item.daysUntilExpiration == 0) {
      return 'heute';
    } else if (item.daysUntilExpiration == 1) {
      return 'morgen';
    } else {
      return 'in ${item.daysUntilExpiration} Tagen';
    }
  }

  /// Fordert Berechtigungen für Notifications an (iOS)
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final settings = await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return settings ?? false;
    }
    return true;
  }
}
