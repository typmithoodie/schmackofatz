# Environmental Impact Implementation Plan

## Current State Analysis
- ✅ EnvironmentalImpact model exists with ColorType enum
- ✅ FridgeItem model supports OpenFoodFacts integration 
- ✅ Basic analysis screen with static data (96% Nachhaltigkeit, 150€ gespart)
- ❌ No barcode scanning functionality
- ❌ No OpenFoodFacts API integration
- ❌ Analysis screen shows only static values
- ❌ No environmental score cards for products

## Implementation Plan

### Phase 1: Barcode Scanning Integration
1. **Add barcode scanning to FridgeScreen**
   - Import barcode_scan2 package
   - Add scan button to add item interface
   - Implement barcode scanning functionality
   - Store barcode in FridgeItem

### Phase 2: OpenFoodFacts API Integration
2. **Create OpenFoodFacts Service**
   - Implement API service to fetch product data
   - Parse environmental impact from API response
   - Map product data to FridgeItem model

### Phase 3: Environmental Score Display
3. **Update FridgeItem cards**
   - Add environmental score indicator to product cards
   - Show color-coded environmental grades (A-E)
   - Display environmental metrics (carbon footprint, etc.)

### Phase 4: Dynamic Analysis Screen
4. **Replace static analysis data**
   - Calculate real sustainability metrics from scanned products
   - Show environmental score distribution
   - Display average environmental impact
   - Add environmental score cards for individual products

## Files to Modify
1. `lib/screens/fridge_screen.dart` - Add scanning functionality
2. `lib/screens/analysis_screen.dart` - Replace static with dynamic data
3. Create `lib/services/openfoodfacts_service.dart` - API integration
4. `lib/widgets/environmental_score_card.dart` - Environmental score display

## Expected Result
- Users can scan products and see environmental scores
- Analysis screen shows real environmental impact data
- Product cards display color-coded environmental grades
- Dynamic sustainability metrics based on actual product data
