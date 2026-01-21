import 'dart:convert';

/// Datenmodell für einzelne Zutaten in Rezepten
class Ingredient {
  final String name;
  final double amount;
  final String unit;
  final String? category;
  final bool isOptional;

  Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.category,
    this.isOptional = false,
  });

  /// Konvertiert die Zutat in eine Map für JSON-Serialisierung
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'unit': unit,
      'category': category,
      'isOptional': isOptional,
    };
  }

  /// Erstellt eine Zutat aus einer Map
  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      name: map['name'],
      amount: map['amount'],
      unit: map['unit'],
      category: map['category'],
      isOptional: map['isOptional'] ?? false,
    );
  }

  /// Konvertiert die Zutat in JSON-String
  String toJson() => json.encode(toMap());

  /// Erstellt eine Zutat aus einem JSON-String
  factory Ingredient.fromJson(String source) =>
      Ingredient.fromMap(json.decode(source));

  @override
  /// String-Repräsentation der Zutat
  String toString() {
    return '${amount.toStringAsFixed(1)} ${unit} ${name}';
  }

  @override
  /// Gleichheitsvergleich basierend auf dem Namen
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ingredient &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  /// Hash-Code basierend auf dem Namen
  int get hashCode => name.hashCode;
}
