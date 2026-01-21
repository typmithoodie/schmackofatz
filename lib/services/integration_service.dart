import '../models/fridge_item.dart';
import '../models/recipe.dart';
import 'fridge_service.dart';
import 'shopping_list_service.dart';
import 'recipe_service.dart';

/// Service für die Integration zwischen Kühlschrank, Einkaufsliste und Rezepten
class IntegrationService {
  static final IntegrationService _instance = IntegrationService._internal();
  factory IntegrationService() => _instance;
  IntegrationService._internal();

  final FridgeService _fridgeService = FridgeService();
  final ShoppingListService _shoppingService = ShoppingListService();
  final RecipeService _recipeService = RecipeService();

  /// Fügt ablaufende Artikel automatisch zur Einkaufsliste hinzu
  Future<void> syncExpiringItemsToShopping() async {
    try {
      final fridgeItems = await _fridgeService.getAllItems();
      final expiringItems = fridgeItems.where((item) {
        final daysUntilExpiry = item.bestBeforeDate
            .difference(DateTime.now())
            .inDays;
        return daysUntilExpiry <= 2 && daysUntilExpiry >= 0;
      }).toList();

      for (final item in expiringItems) {
        // Prüfen, ob Artikel bereits in der Einkaufsliste ist
        final existingItems = await _shoppingService.getAllItems();
        final alreadyInList = existingItems.any(
          (shoppingItem) =>
              shoppingItem.name.toLowerCase() == item.name.toLowerCase(),
        );

        if (!alreadyInList) {
          await _shoppingService.addItem(
            ShoppingListItem(
              name: item.name,
              amount: item.unit,
              category: item.category,
              price: 0.0, // Preis wird vom Benutzer festgelegt
              isFromFridge: true, // Markiert als vom Kühlschrank stammend
              originalItemId: item.id,
            ),
          );
        }
      }
    } catch (e) {
      print('Fehler beim Synchronisieren ablaufender Artikel: $e');
    }
  }

  /// Fügt verbrauchte Artikel zur Einkaufsliste für Nachschub hinzu
  Future<void> addConsumedItemToShopping(
    String itemName,
    String category,
  ) async {
    try {
      final existingItems = await _shoppingService.getAllItems();
      final alreadyInList = existingItems.any(
        (shoppingItem) =>
            shoppingItem.name.toLowerCase() == itemName.toLowerCase() &&
            !shoppingItem.done,
      );

      if (!alreadyInList) {
        await _shoppingService.addItem(
          ShoppingListItem(
            name: itemName,
            amount: '1',
            category: category,
            price: 0.0,
            isRestockNeeded: true, // Markiert als Nachschub-Bedarf
          ),
        );
      }
    } catch (e) {
      print('Fehler beim Hinzufügen verbrauchter Artikel: $e');
    }
  }

  /// Verschiebt gekaufte Artikel vom Einkauf zum Kühlschrank
  Future<void> movePurchasedItemsToFridge() async {
    try {
      final shoppingItems = await _shoppingService.getAllItems();
      final purchasedItems = shoppingItems.where((item) => item.done).toList();

      for (final purchasedItem in purchasedItems) {
        // Prüfen, ob Artikel bereits im Kühlschrank ist
        final fridgeItems = await _fridgeService.getAllItems();
        final existingInFridge = fridgeItems.any(
          (fridgeItem) =>
              fridgeItem.name.toLowerCase() == purchasedItem.name.toLowerCase(),
        );

        if (!existingInFridge) {
          // Neuen Artikel zum Kühlschrank hinzufügen
          final newFridgeItem = FridgeItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: purchasedItem.name,
            category: purchasedItem.category,
            amount: 1.0,
            unit: purchasedItem.amount,
            bestBeforeDate: DateTime.now().add(
              Duration(days: 7),
            ), // Standard: 7 Tage
            addedDate: DateTime.now(),
            purchaseDate: DateTime.now(),
            tags: ['Gekauft'],
            notes: 'Automatisch von Einkaufsliste hinzugefügt',
            originalAmount: 1.0,
          );

          await _fridgeService.addItem(newFridgeItem);
        } else {
          // Bestehenden Artikel im Kühlschrank aktualisieren
          final existingItem = fridgeItems.firstWhere(
            (item) =>
                item.name.toLowerCase() == purchasedItem.name.toLowerCase(),
          );

          final updatedItem = FridgeItem(
            id: existingItem.id,
            name: existingItem.name,
            category: existingItem.category,
            amount: existingItem.amount + 1.0, // Menge erhöhen
            unit: existingItem.unit,
            bestBeforeDate: DateTime.now().add(Duration(days: 7)),
            addedDate: existingItem.addedDate,
            purchaseDate: DateTime.now(),
            tags: existingItem.tags,
            notes: existingItem.notes,
            originalAmount: existingItem.originalAmount + 1.0,
          );

          await _fridgeService.updateItem(updatedItem);
        }

        // Gekauften Artikel aus der Einkaufsliste entfernen
        await _shoppingService.removeItem(purchasedItem.id);
      }
    } catch (e) {
      print('Fehler beim Verschieben gekaufter Artikel: $e');
    }
  }

  /// Findet kochbare Rezepte basierend auf verfügbaren Kühlschrank-Inhalten
  Future<List<Recipe>> getCookableRecipes() async {
    try {
      final allRecipes = await _recipeService.getAllRecipes();
      final fridgeItems = await _fridgeService.getAllItems();
      final availableIngredients = fridgeItems
          .map((item) => item.name.toLowerCase())
          .toList();

      final cookableRecipes = allRecipes.where((recipe) {
        final recipeIngredients = recipe.ingredients
            .map((ing) => ing.name.toLowerCase())
            .toList();
        final availableCount = recipeIngredients
            .where((ing) => availableIngredients.contains(ing))
            .length;
        final coveragePercentage = availableCount / recipeIngredients.length;

        // Rezept ist kochbar wenn mindestens 70% der Zutaten verfügbar sind
        return coveragePercentage >= 0.7;
      }).toList();

      return cookableRecipes;
    } catch (e) {
      print('Fehler beim Finden kochbarer Rezepte: $e');
      return [];
    }
  }

  /// Fügt fehlende Zutaten eines Rezepts zur Einkaufsliste hinzu
  Future<void> addMissingIngredientsToShopping(Recipe recipe) async {
    try {
      final fridgeItems = await _fridgeService.getAllItems();
      final availableIngredients = fridgeItems
          .map((item) => item.name.toLowerCase())
          .toList();

      final missingIngredients = recipe.ingredients.where((ingredient) {
        return !availableIngredients.contains(ingredient.name.toLowerCase());
      }).toList();

      for (final ingredient in missingIngredients) {
        await _shoppingService.addItem(
          ShoppingListItem(
            name: ingredient.name,
            amount: '${ingredient.amount} ${ingredient.unit}',
            category: ingredient.category ?? 'Sonstiges',
            price: 0.0,
            isForRecipe: true, // Markiert als Rezept-Zutat
            recipeId: recipe.id,
            recipeName: recipe.name,
          ),
        );
      }
    } catch (e) {
      print('Fehler beim Hinzufügen fehlender Zutaten: $e');
    }
  }

  /// Gibt smarte Einkaufsvorschläge basierend auf Kühlschrank-Inhalten zurück
  Future<List<String>> getSmartShoppingSuggestions() async {
    try {
      final suggestions = <String>[];
      final fridgeItems = await _fridgeService.getAllItems();
      final cookableRecipes = await getCookableRecipes();

      // 1. Artikel die bald ablaufen
      final expiringItems = fridgeItems
          .where((item) {
            final daysUntilExpiry = item.bestBeforeDate
                .difference(DateTime.now())
                .inDays;
            return daysUntilExpiry <= 2 && daysUntilExpiry >= 0;
          })
          .map((item) => '${item.name} (Ersatz)')
          .toList();
      suggestions.addAll(expiringItems);

      // 2. Fehlende Zutaten für kochbare Rezepte
      for (final recipe in cookableRecipes.take(3)) {
        // Nur die ersten 3 Rezepte
        final fridgeIngredients = fridgeItems
            .map((item) => item.name.toLowerCase())
            .toList();
        final missingIngredients = recipe.ingredients
            .where((ing) => !fridgeIngredients.contains(ing.name.toLowerCase()))
            .map((ing) => ing.name)
            .toList();

        if (missingIngredients.isNotEmpty) {
          suggestions.addAll(missingIngredients);
        }
      }

      // 3. Basis-Lebensmittel die immer gut sind
      final basicItems = [
        'Salz',
        'Pfeffer',
        'Olivenöl',
        'Knoblauch',
        'Zwiebeln',
      ];
      suggestions.addAll(basicItems);

      return suggestions.toSet().toList(); // Duplikate entfernen
    } catch (e) {
      print('Fehler beim Erstellen smarter Einkaufsvorschläge: $e');
      return [];
    }
  }

  /// Synchronisiert alle Systeme miteinander
  Future<void> syncAllSystems() async {
    try {
      await syncExpiringItemsToShopping();
      await movePurchasedItemsToFridge();
    } catch (e) {
      print('Fehler bei der System-Synchronisation: $e');
    }
  }

  /// Erstellt einen Bericht über den aktuellen System-Status
  Future<Map<String, dynamic>> getSystemStatus() async {
    try {
      final fridgeItems = await _fridgeService.getAllItems();
      final shoppingItems = await _shoppingService.getAllItems();
      final cookableRecipes = await getCookableRecipes();

      final expiringItems = fridgeItems.where((item) {
        final daysUntilExpiry = item.bestBeforeDate
            .difference(DateTime.now())
            .inDays;
        return daysUntilExpiry <= 2 && daysUntilExpiry >= 0;
      }).length;

      final expiredItems = fridgeItems.where((item) {
        return item.bestBeforeDate.isBefore(DateTime.now());
      }).length;

      return {
        'fridgeItems': fridgeItems.length,
        'shoppingItems': shoppingItems.length,
        'cookableRecipes': cookableRecipes.length,
        'expiringItems': expiringItems,
        'expiredItems': expiredItems,
        'lastSync': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Fehler beim Erstellen des System-Status: $e');
      return {};
    }
  }
}
