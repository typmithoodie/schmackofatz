import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import '../models/ingredient.dart';

/// Service für die Verwaltung von Rezepten
class RecipeService {
  static final RecipeService _instance = RecipeService._internal();
  factory RecipeService() => _instance;
  RecipeService._internal();

  static const String _storageKey = 'recipes';

  /// Ruft alle Rezepte ab
  Future<List<Recipe>> getAllRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedRecipes = prefs.getStringList(_storageKey);

    if (storedRecipes == null) return [];

    return storedRecipes.map((json) => Recipe.fromJson(json)).toList();
  }

  /// Fügt ein neues Rezept hinzu
  Future<void> addRecipe(Recipe recipe) async {
    final recipes = await getAllRecipes();
    recipes.add(recipe);
    await _saveRecipes(recipes);
  }

  /// Aktualisiert ein bestehendes Rezept
  Future<void> updateRecipe(Recipe updatedRecipe) async {
    final recipes = await getAllRecipes();
    final index = recipes.indexWhere((recipe) => recipe.id == updatedRecipe.id);

    if (index != -1) {
      recipes[index] = updatedRecipe;
      await _saveRecipes(recipes);
    }
  }

  /// Entfernt ein Rezept
  Future<void> removeRecipe(String recipeId) async {
    final recipes = await getAllRecipes();
    recipes.removeWhere((recipe) => recipe.id == recipeId);
    await _saveRecipes(recipes);
  }

  /// Ruft ein Rezept nach ID ab
  Future<Recipe?> getRecipeById(String id) async {
    final recipes = await getAllRecipes();
    try {
      return recipes.firstWhere((recipe) => recipe.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Sucht Rezepte nach Name, Beschreibung oder Tags
  Future<List<Recipe>> searchRecipes(String query) async {
    if (query.isEmpty) return getAllRecipes();

    final recipes = await getAllRecipes();
    final queryLower = query.toLowerCase();

    return recipes
        .where(
          (recipe) =>
              recipe.name.toLowerCase().contains(queryLower) ||
              recipe.description.toLowerCase().contains(queryLower) ||
              recipe.tags.any(
                (tag) => tag.toLowerCase().contains(queryLower),
              ) ||
              recipe.category.toLowerCase().contains(queryLower),
        )
        .toList();
  }

  /// Ruft Rezepte nach Kategorie ab
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final recipes = await getAllRecipes();
    return recipes
        .where(
          (recipe) => recipe.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  /// Ruft Lieblingsrezepte ab
  Future<List<Recipe>> getFavoriteRecipes() async {
    final recipes = await getAllRecipes();
    return recipes.where((recipe) => recipe.isFavorite).toList();
  }

  /// Schaltet den Lieblingsstatus eines Rezepts um
  Future<void> toggleFavorite(String recipeId) async {
    final recipes = await getAllRecipes();
    final index = recipes.indexWhere((recipe) => recipe.id == recipeId);

    if (index != -1) {
      recipes[index] = recipes[index].copyWith(
        isFavorite: !recipes[index].isFavorite,
      );
      await _saveRecipes(recipes);
    }
  }

  /// Ruft Rezepte ab, die mit verfügbaren Zutaten gekocht werden können
  Future<List<Recipe>> getCookableRecipes(
    List<String> availableIngredients,
  ) async {
    final recipes = await getAllRecipes();
    return recipes
        .where((recipe) => recipe.canBeMadeWith(availableIngredients))
        .toList();
  }

  /// Ruft Rezepte mit fehlenden Zutaten ab
  Future<List<Recipe>> getRecipesWithMissingIngredients(
    List<String> availableIngredients,
  ) async {
    final recipes = await getAllRecipes();
    return recipes
        .where(
          (recipe) =>
              !recipe.canBeMadeWith(availableIngredients) &&
              recipe.getMissingIngredients(availableIngredients).isNotEmpty,
        )
        .toList();
  }

  /// Ruft Rezepte sortiert nach Zutatenverfügbarkeit in Prozent ab
  Future<List<Recipe>> getRecipesByAvailability(
    List<String> availableIngredients,
  ) async {
    final recipes = await getAllRecipes();
    recipes.sort(
      (a, b) => b
          .getCompletionPercentage(availableIngredients)
          .compareTo(a.getCompletionPercentage(availableIngredients)),
    );
    return recipes;
  }

  /// Ruft kürzlich gekochte Rezepte ab
  Future<List<Recipe>> getRecentlyCookedRecipes() async {
    final recipes = await getAllRecipes();
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));

    return recipes
        .where(
          (recipe) =>
              recipe.lastCooked != null &&
              recipe.lastCooked!.isAfter(thirtyDaysAgo),
        )
        .toList()
      ..sort((a, b) => b.lastCooked!.compareTo(a.lastCooked!));
  }

  /// Markiert ein Rezept als gekocht
  Future<void> markAsCooked(String recipeId) async {
    final recipes = await getAllRecipes();
    final index = recipes.indexWhere((recipe) => recipe.id == recipeId);

    if (index != -1) {
      recipes[index] = recipes[index].copyWith(lastCooked: DateTime.now());
      await _saveRecipes(recipes);
    }
  }

  /// Ruft alle eindeutigen Kategorien ab
  Future<List<String>> getCategories() async {
    final recipes = await getAllRecipes();
    final categories = recipes
        .map((recipe) => recipe.category)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  /// Ruft alle eindeutigen Tags ab
  Future<List<String>> getAllTags() async {
    final recipes = await getAllRecipes();
    final tags = <String>{};

    for (final recipe in recipes) {
      tags.addAll(recipe.tags);
    }

    return tags.toList()..sort();
  }

  /// Ruft Rezepte nach Schwierigkeitsgrad ab
  Future<List<Recipe>> getRecipesByDifficulty(int difficulty) async {
    final recipes = await getAllRecipes();
    return recipes.where((recipe) => recipe.difficulty == difficulty).toList();
  }

  /// Ruft Rezepte nach maximaler Kochzeit ab
  Future<List<Recipe>> getRecipesByMaxTime(int maxMinutes) async {
    final recipes = await getAllRecipes();
    return recipes.where((recipe) => recipe.totalTime <= maxMinutes).toList();
  }

  /// Ruft zufällige Rezeptvorschläge ab
  Future<List<Recipe>> getRandomSuggestions(
    int count,
    List<String> availableIngredients,
  ) async {
    final cookableRecipes = await getCookableRecipes(availableIngredients);
    cookableRecipes.shuffle();
    return cookableRecipes.take(count).toList();
  }

  /// Ruft Rezeptempfehlungen basierend auf verfügbaren Zutaten ab
  Future<List<Recipe>> getRecommendations(
    List<String> availableIngredients,
  ) async {
    final allRecipes = await getAllRecipes();

    // Bewertet Rezepte nach Zutatenverfügbarkeit und Aktualität
    final scoredRecipes = allRecipes.map((recipe) {
      final availability = recipe.getCompletionPercentage(availableIngredients);
      final hasAllIngredients = recipe.canBeMadeWith(availableIngredients);

      // Erhöht Bewertung für Rezepte mit allen Zutaten
      double score = availability;
      if (hasAllIngredients) score += 50;

      // Erhöht Bewertung für Lieblingsrezepte
      if (recipe.isFavorite) score += 20;

      // Erhöht Bewertung für kürzlich gekochte Rezepte
      if (recipe.lastCooked != null) {
        final daysSinceCooked = DateTime.now()
            .difference(recipe.lastCooked!)
            .inDays;
        if (daysSinceCooked > 7)
          score += 10; // Erhöht Bewertung für ältere Rezepte
      }

      return MapEntry(recipe, score);
    }).toList();

    // Sortiert nach Bewertung und gibt Top-Empfehlungen zurück
    scoredRecipes.sort((a, b) => b.value.compareTo(a.value));
    return scoredRecipes.map((entry) => entry.key).take(10).toList();
  }

  /// Bereinigt doppelte Rezepte basierend auf Namen
  Future<void> removeDuplicateRecipes() async {
    final recipes = await getAllRecipes();
    final uniqueRecipes = <String, Recipe>{};

    // Behalte nur das erste Rezept pro Namen (case-insensitive)
    for (final recipe in recipes) {
      final nameKey = recipe.name.toLowerCase();
      if (!uniqueRecipes.containsKey(nameKey)) {
        uniqueRecipes[nameKey] = recipe;
      }
    }

    final cleanedRecipes = uniqueRecipes.values.toList();
    if (cleanedRecipes.length != recipes.length) {
      await _saveRecipes(cleanedRecipes);
      print(
        'Doppelte Rezepte bereinigt: ${recipes.length} -> ${cleanedRecipes.length} Rezepte',
      );
    }
  }

  /// Löscht alle Rezepte (für Tests/Reset)
  Future<void> clearAllRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// Private Methode zum Speichern von Rezepten im Speicher
  Future<void> _saveRecipes(List<Recipe> recipes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = recipes
        .map((recipe) => recipe.toJson())
        .toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  /// Fügt Beispielrezepte für Demonstration hinzu (nur wenn noch nicht vorhanden)
  Future<void> addSampleRecipes() async {
    // Bereinige zuerst doppelte Rezepte
    await removeDuplicateRecipes();

    final existingRecipes = await getAllRecipes();

    // Prüfe ob bereits Beispielrezepte existieren (basierend auf Namen)
    final existingRecipeNames = existingRecipes
        .map((r) => r.name.toLowerCase())
        .toSet();
    final sampleRecipeNames = ['spaghetti carbonara', 'caesar salad'];

    // Wenn bereits Beispielrezepte existieren, überspringe
    if (sampleRecipeNames.any((name) => existingRecipeNames.contains(name))) {
      print('Beispielrezepte bereits vorhanden, überspringe...');
      return;
    }

    final sampleRecipes = [
      Recipe(
        id: 'sample_recipe_1',
        name: 'Spaghetti Carbonara',
        description:
            'Ein klassisches italienisches Gericht mit Eiern, Speck und Parmesan.',
        ingredients: [
          Ingredient(name: 'Spaghetti', amount: 400, unit: 'g'),
          Ingredient(name: 'Speck', amount: 200, unit: 'g'),
          Ingredient(name: 'Eier', amount: 3, unit: 'Stück'),
          Ingredient(name: 'Parmesan', amount: 100, unit: 'g'),
          Ingredient(name: 'Schwarzer Pfeffer', amount: 1, unit: 'Prise'),
        ],
        instructions: [
          'Spaghetti in gesalzenem Wasser al dente kochen.',
          'Speck in einer Pfanne knusprig braten.',
          'Eier mit geriebenem Parmesan verquirlen.',
          'Heiße Spaghetti mit Ei-Käse-Mischung vermengen.',
          'Mit Speck und Pfeffer garnieren.',
        ],
        tags: ['italienisch', 'pasta', 'schnell'],
        prepTime: 10,
        cookTime: 15,
        servings: 4,
        difficulty: 2,
        category: 'dinner',
        createdAt: DateTime.now(),
      ),
      Recipe(
        id: 'sample_recipe_2',
        name: 'Caesar Salad',
        description:
            'Frischer Salat mit Hähnchen, Croutons und Caesar-Dressing.',
        ingredients: [
          Ingredient(name: 'Römersalat', amount: 1, unit: 'Kopf'),
          Ingredient(name: 'Hähnchenbrust', amount: 300, unit: 'g'),
          Ingredient(name: 'Parmesan', amount: 50, unit: 'g'),
          Ingredient(name: 'Croutons', amount: 100, unit: 'g'),
          Ingredient(name: 'Zitrone', amount: 1, unit: 'Stück'),
        ],
        instructions: [
          'Hähnchenbrust anbraten und in Streifen schneiden.',
          'Salat waschen und in Stücke teilen.',
          'Parmesan reiben.',
          'Alles mit Caesar-Dressing vermengen.',
          'Mit Croutons garnieren.',
        ],
        tags: ['salat', 'gesund', 'schnell'],
        prepTime: 15,
        cookTime: 10,
        servings: 2,
        difficulty: 1,
        category: 'lunch',
        createdAt: DateTime.now(),
      ),
    ];

    for (final recipe in sampleRecipes) {
      await addRecipe(recipe);
    }

    print('Beispielrezepte hinzugefügt: ${sampleRecipes.length} Rezepte');
  }
}

/// Erweiterung für zusätzliche Utility-Methoden
extension RecipeUtils on List<Recipe> {
  /// Sortiert Rezepte nach Name
  List<Recipe> sortByName() {
    sort((a, b) => a.name.compareTo(b.name));
    return this;
  }

  /// Sortiert Rezepte nach gesamter Kochzeit
  List<Recipe> sortByTime() {
    sort((a, b) => a.totalTime.compareTo(b.totalTime));
    return this;
  }

  /// Sortiert Rezepte nach Schwierigkeitsgrad
  List<Recipe> sortByDifficulty() {
    sort((a, b) => a.difficulty.compareTo(b.difficulty));
    return this;
  }

  /// Gruppiert Rezepte nach Kategorie
  Map<String, List<Recipe>> groupByCategory() {
    return fold<Map<String, List<Recipe>>>({}, (map, recipe) {
      map.putIfAbsent(recipe.category, () => []).add(recipe);
      return map;
    });
  }

  /// Filtert Rezepte nach Mindestbewertung (Schwierigkeitsgrad als Proxy)
  List<Recipe> filterByDifficulty(int minDifficulty) {
    return where((recipe) => recipe.difficulty >= minDifficulty).toList();
  }

  /// Filtert Rezepte nach maximaler Kochzeit
  List<Recipe> filterByMaxTime(int maxMinutes) {
    return where((recipe) => recipe.totalTime <= maxMinutes).toList();
  }
}
