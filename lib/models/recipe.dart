import 'dart:convert';
import 'ingredient.dart';

/// Datenmodell für Rezepte
class Recipe {
  final String id;
  final String name;
  final String description;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final int prepTime; // in Minuten
  final int cookTime; // in Minuten
  final int servings;
  final String? imagePath;
  final int difficulty; // 1-5 Skala
  final String category;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? lastCooked;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.tags,
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    this.imagePath,
    required this.difficulty,
    required this.category,
    this.isFavorite = false,
    required this.createdAt,
    this.lastCooked,
  });

  /// Berechnet die gesamte Kochzeit
  int get totalTime => prepTime + cookTime;

  /// Gibt den Schwierigkeitsgrad als Text zurück
  String get difficultyText {
    switch (difficulty) {
      case 1:
        return 'Einfach';
      case 2:
        return 'Leicht';
      case 3:
        return 'Mittel';
      case 4:
        return 'Schwer';
      case 5:
        return 'Profi';
      default:
        return 'Unbekannt';
    }
  }

  /// Gibt den Anzeigenamen der Kategorie zurück
  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'breakfast':
        return 'Frühstück';
      case 'lunch':
        return 'Mittagessen';
      case 'dinner':
        return 'Abendessen';
      case 'dessert':
        return 'Dessert';
      case 'snack':
        return 'Snack';
      case 'drink':
        return 'Getränk';
      default:
        return category;
    }
  }

  /// Gibt nur die Zutatennamen zurück
  List<String> get ingredientNames => ingredients.map((e) => e.name).toList();

  /// Prüft ob das Rezept mit verfügbaren Zutaten gekocht werden kann
  bool canBeMadeWith(List<String> availableIngredients) {
    final availableSet = availableIngredients
        .map((e) => e.toLowerCase())
        .toSet();
    final requiredIngredients = ingredients.where((ing) => !ing.isOptional);
    return requiredIngredients.every(
      (ing) => availableSet.contains(ing.name.toLowerCase()),
    );
  }

  /// Gibt fehlende Zutaten für ein Rezept zurück
  List<Ingredient> getMissingIngredients(List<String> availableIngredients) {
    final availableSet = availableIngredients
        .map((e) => e.toLowerCase())
        .toSet();
    return ingredients
        .where(
          (ing) =>
              !availableSet.contains(ing.name.toLowerCase()) && !ing.isOptional,
        )
        .toList();
  }

  /// Berechnet die Anzahl verfügbarer Zutaten
  int getAvailableIngredientsCount(List<String> availableIngredients) {
    final availableSet = availableIngredients
        .map((e) => e.toLowerCase())
        .toSet();
    return ingredients
        .where((ing) => availableSet.contains(ing.name.toLowerCase()))
        .length;
  }

  /// Berechnet den Fertigstellungsprozentsatz
  double getCompletionPercentage(List<String> availableIngredients) {
    if (ingredients.isEmpty) return 0;
    final availableCount = getAvailableIngredientsCount(availableIngredients);
    return (availableCount / ingredients.length) * 100;
  }

  /// Erstellt eine Kopie mit aktualisierten Eigenschaften
  Recipe copyWith({
    String? id,
    String? name,
    String? description,
    List<Ingredient>? ingredients,
    List<String>? instructions,
    List<String>? tags,
    int? prepTime,
    int? cookTime,
    int? servings,
    String? imagePath,
    int? difficulty,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? lastCooked,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      tags: tags ?? this.tags,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      imagePath: imagePath ?? this.imagePath,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      lastCooked: lastCooked ?? this.lastCooked,
    );
  }

  /// Konvertiert das Rezept in eine Map für JSON-Serialisierung
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'instructions': instructions,
      'tags': tags,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'imagePath': imagePath,
      'difficulty': difficulty,
      'category': category,
      'isFavorite': isFavorite,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastCooked': lastCooked?.millisecondsSinceEpoch,
    };
  }

  /// Erstellt ein Rezept aus einer Map
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      ingredients:
          (map['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromMap(e))
              .toList() ??
          [],
      instructions: List<String>.from(map['instructions'] ?? []),
      tags: List<String>.from(map['tags'] ?? []),
      prepTime: map['prepTime'],
      cookTime: map['cookTime'],
      servings: map['servings'],
      imagePath: map['imagePath'],
      difficulty: map['difficulty'],
      category: map['category'],
      isFavorite: map['isFavorite'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      lastCooked: map['lastCooked'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastCooked'])
          : null,
    );
  }

  /// Konvertiert das Rezept in JSON-String
  String toJson() => json.encode(toMap());

  /// Erstellt ein Rezept aus einem JSON-String
  factory Recipe.fromJson(String source) => Recipe.fromMap(json.decode(source));

  @override
  /// String-Repräsentation des Rezepts
  String toString() {
    return 'Recipe{name: $name, ingredients: ${ingredients.length}, category: $category}';
  }

  @override
  /// Gleichheitsvergleich basierend auf der ID
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe && runtimeType == other.runtimeType && id == other.id;

  @override
  /// Hash-Code basierend auf der ID
  int get hashCode => id.hashCode;
}
