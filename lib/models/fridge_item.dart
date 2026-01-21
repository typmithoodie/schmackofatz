import 'dart:convert';

/// Datenmodell für Kühlschrank-Artikel
class FridgeItem {
  final String id;
  final String name;
  final String category;
  final double amount;
  final String unit;
  final DateTime bestBeforeDate;
  final DateTime addedDate;
  final DateTime purchaseDate;
  final List<String> tags;
  final String? notes;
  final String? imagePath;
  final bool isLowStock;
  final double originalAmount;

  FridgeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.unit,
    required this.bestBeforeDate,
    required this.addedDate,
    required this.purchaseDate,
    this.tags = const [],
    this.notes,
    this.imagePath,
    this.isLowStock = false,
    required this.originalAmount,
  });

  /// Berechnet Tage bis zum Ablauf (negativ wenn bereits abgelaufen)
  int get daysUntilExpiration {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(
      bestBeforeDate.year,
      bestBeforeDate.month,
      bestBeforeDate.day,
    );
    return expiry.difference(today).inDays;
  }

  /// Gibt den Ablaufstatus für die Farbkodierung zurück
  ExpirationStatus get expirationStatus {
    final days = daysUntilExpiration;
    if (days < 0) return ExpirationStatus.expired;
    if (days <= 1) return ExpirationStatus.urgent;
    if (days <= 3) return ExpirationStatus.soon;
    return ExpirationStatus.fresh;
  }

  /// Prüft ob Artikel bald abläuft (3 Tage oder weniger)
  bool get isNearExpiration => daysUntilExpiration <= 3;

  /// Berechnet verbleibenden Prozentsatz der ursprünglichen Menge
  double get remainingPercentage => (amount / originalAmount) * 100;

  /// Prüft ob Artikel nachbestellt werden sollte
  bool get shouldReorder => remainingPercentage <= 20 || isLowStock;

  /// Erstellt eine Kopie mit aktualisierten Eigenschaften
  FridgeItem copyWith({
    String? id,
    String? name,
    String? category,
    double? amount,
    String? unit,
    DateTime? bestBeforeDate,
    DateTime? addedDate,
    DateTime? purchaseDate,
    List<String>? tags,
    String? notes,
    String? imagePath,
    bool? isLowStock,
    double? originalAmount,
  }) {
    return FridgeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      bestBeforeDate: bestBeforeDate ?? this.bestBeforeDate,
      addedDate: addedDate ?? this.addedDate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      isLowStock: isLowStock ?? this.isLowStock,
      originalAmount: originalAmount ?? this.originalAmount,
    );
  }

  /// Konvertiert den Artikel in eine Map für JSON-Serialisierung
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'unit': unit,
      'bestBeforeDate': bestBeforeDate.millisecondsSinceEpoch,
      'addedDate': addedDate.millisecondsSinceEpoch,
      'purchaseDate': purchaseDate.millisecondsSinceEpoch,
      'tags': tags,
      'notes': notes,
      'imagePath': imagePath,
      'isLowStock': isLowStock,
      'originalAmount': originalAmount,
    };
  }

  /// Erstellt einen Artikel aus einer Map
  factory FridgeItem.fromMap(Map<String, dynamic> map) {
    return FridgeItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      amount: map['amount'],
      unit: map['unit'],
      bestBeforeDate: DateTime.fromMillisecondsSinceEpoch(
        map['bestBeforeDate'],
      ),
      addedDate: DateTime.fromMillisecondsSinceEpoch(map['addedDate']),
      purchaseDate: DateTime.fromMillisecondsSinceEpoch(map['purchaseDate']),
      tags: List<String>.from(map['tags'] ?? []),
      notes: map['notes'],
      imagePath: map['imagePath'],
      isLowStock: map['isLowStock'] ?? false,
      originalAmount: map['originalAmount'],
    );
  }

  /// Konvertiert den Artikel in JSON-String
  String toJson() => json.encode(toMap());

  /// Erstellt einen Artikel aus einem JSON-String
  factory FridgeItem.fromJson(String source) =>
      FridgeItem.fromMap(json.decode(source));

  @override
  /// String-Repräsentation des Artikels
  String toString() {
    return 'FridgeItem{name: $name, category: $category, amount: $amount $unit}';
  }

  @override
  /// Gleichheitsvergleich basierend auf der ID
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FridgeItem && runtimeType == other.runtimeType && id == other.id;

  @override
  /// Hash-Code basierend auf der ID
  int get hashCode => id.hashCode;
}

/// Aufzählung für Ablaufstatus
enum ExpirationStatus {
  expired, // Rot
  urgent, // Orange
  soon, // Gelb
  fresh, // Grün
}
