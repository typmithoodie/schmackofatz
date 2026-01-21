import 'package:shared_preferences/shared_preferences.dart';
import '../models/fridge_item.dart';

/// Service für die Verwaltung von Kühlschrank-Artikeln
class FridgeService {
  static final FridgeService _instance = FridgeService._internal();
  factory FridgeService() => _instance;
  FridgeService._internal();

  static const String _storageKey = 'fridge_items';

  /// Ruft alle Kühlschrank-Artikel ab
  Future<List<FridgeItem>> getAllItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedItems = prefs.getStringList(_storageKey);

    if (storedItems == null) return [];

    return storedItems.map((json) => FridgeItem.fromJson(json)).toList();
  }

  /// Fügt einen neuen Artikel zum Kühlschrank hinzu
  Future<void> addItem(FridgeItem item) async {
    final items = await getAllItems();
    items.add(item);
    await _saveItems(items);
  }

  /// Aktualisiert einen bestehenden Artikel
  Future<void> updateItem(FridgeItem updatedItem) async {
    final items = await getAllItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);

    if (index != -1) {
      items[index] = updatedItem;
      await _saveItems(items);
    }
  }

  /// Entfernt einen Artikel aus dem Kühlschrank
  Future<void> removeItem(String itemId) async {
    final items = await getAllItems();
    items.removeWhere((item) => item.id == itemId);
    await _saveItems(items);
  }

  /// Ruft Artikel nach Kategorie ab
  Future<List<FridgeItem>> getItemsByCategory(String category) async {
    final items = await getAllItems();
    return items
        .where((item) => item.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Ruft Artikel ab, die bald ablaufen (3 Tage oder weniger)
  Future<List<FridgeItem>> getExpiringItems() async {
    final items = await getAllItems();
    return items.where((item) => item.isNearExpiration).toList();
  }

  /// Ruft abgelaufene Artikel ab
  Future<List<FridgeItem>> getExpiredItems() async {
    final items = await getAllItems();
    return items.where((item) => item.daysUntilExpiration < 0).toList();
  }

  /// Sucht Artikel nach Name oder Tags
  Future<List<FridgeItem>> searchItems(String query) async {
    if (query.isEmpty) return getAllItems();

    final items = await getAllItems();
    final queryLower = query.toLowerCase();

    return items
        .where(
          (item) =>
              item.name.toLowerCase().contains(queryLower) ||
              item.tags.any((tag) => tag.toLowerCase().contains(queryLower)) ||
              item.category.toLowerCase().contains(queryLower),
        )
        .toList();
  }

  /// Ruft alle eindeutigen Kategorien ab
  Future<List<String>> getCategories() async {
    final items = await getAllItems();
    final categories = items.map((item) => item.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Ruft Artikel ab, die nachbestellt werden müssen
  Future<List<FridgeItem>> getLowStockItems() async {
    final items = await getAllItems();
    return items.where((item) => item.shouldReorder).toList();
  }

  /// Aktualisiert die Artikelmenge (für Verbrauch)
  Future<void> consumeItem(String itemId, double amount) async {
    final items = await getAllItems();
    final index = items.indexWhere((item) => item.id == itemId);

    if (index != -1) {
      final item = items[index];
      final newAmount = (item.amount - amount).clamp(0.0, double.infinity);

      if (newAmount <= 0) {
        items.removeAt(index);
      } else {
        items[index] = item.copyWith(amount: newAmount);
      }

      await _saveItems(items);
    }
  }

  /// Konvertiert Kühlschrank-Artikel zu Zutaten für Rezept-Prüfung
  Future<List<String>> getAvailableIngredientNames() async {
    final items = await getAllItems();
    return items.map((item) => item.name).toList();
  }

  /// Fügt Artikel aus dem Einkauf hinzu
  Future<void> addItemsFromShopping({
    required String name,
    required String category,
    required double amount,
    required String unit,
    required DateTime bestBeforeDate,
    List<String> tags = const [],
    String? notes,
  }) async {
    final item = FridgeItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      amount: amount,
      unit: unit,
      bestBeforeDate: bestBeforeDate,
      addedDate: DateTime.now(),
      purchaseDate: DateTime.now(),
      tags: tags,
      notes: notes,
      originalAmount: amount,
    );

    await addItem(item);
  }

  /// Ruft Artikelstatistiken ab
  Future<Map<String, dynamic>> getStatistics() async {
    final items = await getAllItems();

    final totalItems = items.length;
    final expiringItems = items.where((item) => item.isNearExpiration).length;
    final expiredItems = items
        .where((item) => item.daysUntilExpiration < 0)
        .length;
    final lowStockItems = items.where((item) => item.shouldReorder).length;

    final categoryCount = <String, int>{};
    for (final item in items) {
      categoryCount[item.category] = (categoryCount[item.category] ?? 0) + 1;
    }

    return {
      'totalItems': totalItems,
      'expiringItems': expiringItems,
      'expiredItems': expiredItems,
      'lowStockItems': lowStockItems,
      'categoryCount': categoryCount,
    };
  }

  /// Löscht alle Artikel (für Tests/Reset)
  Future<void> clearAllItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Private Methode zum Speichern von Artikeln im Speicher
  Future<void> _saveItems(List<FridgeItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }
}

/// Erweiterung für zusätzliche Utility-Methoden
extension FridgeItemUtils on List<FridgeItem> {
  /// Sortiert Artikel nach Ablaufdatum
  List<FridgeItem> sortByExpiration() {
    sort((a, b) => a.daysUntilExpiration.compareTo(b.daysUntilExpiration));
    return this;
  }

  /// Sortiert Artikel nach Kategorie
  List<FridgeItem> sortByCategory() {
    sort((a, b) => a.category.compareTo(b.category));
    return this;
  }

  /// Gruppiert Artikel nach Kategorie
  Map<String, List<FridgeItem>> groupByCategory() {
    return fold<Map<String, List<FridgeItem>>>({}, (map, item) {
      map.putIfAbsent(item.category, () => []).add(item);
      return map;
    });
  }
}
