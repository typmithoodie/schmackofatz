import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Erweiterte ShoppingItem-Klasse für Integration mit anderen Services
class ShoppingListItem {
  String id;
  String name;
  String amount;
  final String category;
  double price;
  bool done;
  bool isFromFridge; // Markiert als vom Kühlschrank stammend
  bool isRestockNeeded; // Markiert als Nachschub-Bedarf
  bool isForRecipe; // Markiert als Rezept-Zutat
  String? originalItemId; // ID des ursprünglichen Kühlschrank-Artikels
  String? recipeId; // ID des Rezepts für das diese Zutat benötigt wird
  String? recipeName; // Name des Rezepts

  ShoppingListItem({
    required this.name,
    required this.amount,
    required this.category,
    required this.price,
    this.done = false,
    this.isFromFridge = false,
    this.isRestockNeeded = false,
    this.isForRecipe = false,
    this.originalItemId,
    this.recipeId,
    this.recipeName,
    String? id,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'category': category,
      'price': price,
      'done': done,
      'isFromFridge': isFromFridge,
      'isRestockNeeded': isRestockNeeded,
      'isForRecipe': isForRecipe,
      'originalItemId': originalItemId,
      'recipeId': recipeId,
      'recipeName': recipeName,
    };
  }

  factory ShoppingListItem.fromMap(Map<String, dynamic> map) {
    return ShoppingListItem(
      name: map['name'],
      amount: map['amount'],
      category: map['category'],
      price: map['price'],
      done: map['done'] ?? false,
      isFromFridge: map['isFromFridge'] ?? false,
      isRestockNeeded: map['isRestockNeeded'] ?? false,
      isForRecipe: map['isForRecipe'] ?? false,
      originalItemId: map['originalItemId'],
      recipeId: map['recipeId'],
      recipeName: map['recipeName'],
    )..id = map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
  }

  String toJson() => json.encode(toMap());
  factory ShoppingListItem.fromJson(String source) =>
      ShoppingListItem.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ShoppingListItem{name: $name, amount: $amount, category: $category, price: $price}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListItem &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// Service für erweiterte Einkaufslisten-Funktionalität
class ShoppingListService {
  static final ShoppingListService _instance = ShoppingListService._internal();
  factory ShoppingListService() => _instance;
  ShoppingListService._internal();

  static const String _storageKey = 'enhanced_shopping_list';

  /// Lädt alle Artikel aus dem Speicher
  Future<List<ShoppingListItem>> getAllItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedItems = prefs.getStringList(_storageKey);
    if (storedItems != null) {
      return storedItems.map((e) => ShoppingListItem.fromJson(e)).toList();
    }
    return [];
  }

  /// Fügt einen neuen Artikel hinzu
  Future<void> addItem(ShoppingListItem item) async {
    final items = await getAllItems();
    items.add(item);
    await _saveItems(items);
  }

  /// Aktualisiert einen bestehenden Artikel
  Future<void> updateItem(ShoppingListItem updatedItem) async {
    final items = await getAllItems();
    final index = items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      items[index] = updatedItem;
      await _saveItems(items);
    }
  }

  /// Entfernt einen Artikel
  Future<void> removeItem(String itemId) async {
    final items = await getAllItems();
    items.removeWhere((item) => item.id == itemId);
    await _saveItems(items);
  }

  /// Markiert einen Artikel als erledigt/nicht erledigt
  Future<void> toggleItemDone(String itemId) async {
    final items = await getAllItems();
    final item = items.firstWhere((item) => item.id == itemId);
    item.done = !item.done;
    await _saveItems(items);
  }

  /// Leert die gesamte Einkaufsliste
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Gibt nur die noch nicht erledigten Artikel zurück
  Future<List<ShoppingListItem>> getPendingItems() async {
    final items = await getAllItems();
    return items.where((item) => !item.done).toList();
  }

  /// Gibt nur die erledigten Artikel zurück
  Future<List<ShoppingListItem>> getCompletedItems() async {
    final items = await getAllItems();
    return items.where((item) => item.done).toList();
  }

  /// Gruppiert Artikel nach Kategorien
  Future<Map<String, List<ShoppingListItem>>> getGroupedItems() async {
    final items = await getAllItems();
    final Map<String, List<ShoppingListItem>> grouped = {};

    for (final item in items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return grouped;
  }

  /// Sucht Artikel nach Name
  Future<List<ShoppingListItem>> searchItems(String query) async {
    final items = await getAllItems();
    final lowercaseQuery = query.toLowerCase();
    return items
        .where(
          (item) =>
              item.name.toLowerCase().contains(lowercaseQuery) ||
              item.category.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  /// Fügt mehrere Artikel gleichzeitig hinzu
  Future<void> addMultipleItems(List<ShoppingListItem> itemsToAdd) async {
    final currentItems = await getAllItems();
    currentItems.addAll(itemsToAdd);
    await _saveItems(currentItems);
  }

  /// Berechnet die Gesamtsumme aller Artikel
  Future<double> getTotalPrice() async {
    final items = await getAllItems();
    double total = 0.0;
    for (final item in items) {
      total += item.price;
    }
    return total;
  }

  /// Berechnet die Summe der erledigten Artikel
  Future<double> getCompletedPrice() async {
    final items = await getCompletedItems();
    double total = 0.0;
    for (final item in items) {
      total += item.price;
    }
    return total;
  }

  /// Private Methode zum Speichern der Artikel
  Future<void> _saveItems(List<ShoppingListItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stringList = items.map((e) => e.toJson()).toList();
    await prefs.setStringList(_storageKey, stringList);
  }
}
