# Fridge-Recipe-Shopping Integration Plan

## Current State Analysis
- ✅ Shopping screen fully implemented with categories, pricing, sharing
- ✅ Basic app structure with navigation
- ❌ Fridge screen is empty (just header and search)
- ❌ Recipes screen is empty
- ❌ No data models for fridge items or recipes
- ❌ No connection between fridge, recipes, and shopping

## Implementation Plan

### Phase 1: Data Models & Services (Foundation)
1. **Create FridgeItem data model:**
   - name, amount, category, bestBeforeDate, tags, addedDate, purchaseDate
   - JSON serialization for storage

2. **Create Recipe data model:**
   - name, ingredients (with amounts), instructions, tags, prepTime, servings
   - Ingredient model with name, amount, unit, category

3. **Create FridgeService:**
   - Add/remove/update fridge items
   - Get items by category or near expiration
   - Search functionality
   - Data persistence with SharedPreferences

4. **Create RecipeService:**
   - Add/remove/update recipes
   - Search recipes by ingredients
   - Get recipes that can be made with available fridge items

### Phase 2: Fridge Screen Enhancement
1. **Implement fridge screen with card design:**
   - Category-based organization
   - Expiration date indicators (red for urgent, yellow for soon)
   - Tag system for better organization
   - Add/Edit/Remove item functionality
   - Search and filter capabilities

2. **Item management features:**
   - Quick add from shopping list
   - Bulk operations
   - Quantity tracking
   - Photo attachment (optional)

### Phase 3: Home Screen Integration
1. **Add fridge card to home screen:**
   - Show 3-5 items with nearest expiration dates
   - Display item count by category
   - Quick actions (add item, view all)
   - Visual indicators for items needing attention

### Phase 4: Cross-Platform Integration
1. **Fridge ↔ Shopping integration:**
   - Add purchased items directly to fridge
   - Move consumed items to shopping list
   - Suggest items based on low stock
   - Automatic shopping list generation for expiring items

2. **Recipe ↔ Fridge integration:**
   - Show recipes that can be made with available ingredients
   - Check ingredient availability when viewing recipes
   - Suggest recipes based on expiring items
   - Add missing ingredients to shopping list

### Phase 5: Advanced Features
1. **Smart suggestions:**
   - "What to cook today" based on expiring items
   - Shopping suggestions based on consumption patterns
   - Recipe recommendations based on available ingredients

2. **Analytics & Insights:**
   - Food waste tracking
   - Consumption patterns
   - Best before date alerts

## Technical Implementation Details

### File Structure Updates:
```
lib/
├── models/
│   ├── fridge_item.dart
│   ├── recipe.dart
│   └── ingredient.dart
├── services/
│   ├── fridge_service.dart
│   ├── recipe_service.dart
│   └── integration_service.dart
├── screens/
│   ├── fridge_screen.dart (enhanced)
│   ├── recipes_screen.dart (enhanced)
│   └── home_screen.dart (enhanced with fridge card)
└── widgets/
    ├── fridge_item_card.dart
    ├── recipe_card.dart
    └── fridge_overview_card.dart
```

### Data Flow:
1. User adds item to shopping list → Purchase → Add to fridge
2. User views recipe → Check fridge availability → Add missing to shopping
3. Fridge items expire → Suggest recipes → Add to shopping list
4. Consumption tracking → Update shopping suggestions

### UI/UX Considerations:
- Consistent card design across all screens
- Intuitive color coding for expiration dates
- Quick actions for common tasks
- Smooth transitions between related screens
- Offline-first approach with local storage

## Implementation Priority:
1. **Week 1:** Data models and basic services
2. **Week 2:** Enhanced fridge screen with card design
3. **Week 3:** Home screen fridge card integration
4. **Week 4:** Shopping ↔ Fridge integration
5. **Week 5:** Recipe ↔ Fridge integration
6. **Week 6:** Advanced features and polish

This plan ensures a systematic approach while maintaining the existing app's stability and user experience.
