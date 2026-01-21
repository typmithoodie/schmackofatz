# OpenFoodFacts API Integration Plan

## Overview
This plan outlines the integration of OpenFoodFacts API to enable barcode scanning and environmental impact analysis ("Umweltauswirkungen") in the schmackofatz Flutter app.

## Current State Analysis
- **Analysis Screen**: Currently shows 96% sustainability and 150€ saved
- **Fridge Screen**: Manages inventory with categories and expiration dates
- **Tech Stack**: Flutter with Firebase, Google Fonts, Lucide Icons

## Required Dependencies
1. **http** - For API calls to OpenFoodFacts
2. **barcode_scan2** - For barcode scanning functionality
3. **provider** or **riverpod** - For state management (optional but recommended)

## Implementation Steps

### Phase 1: Dependencies and Setup
- Add required packages to pubspec.yaml
- Configure internet permissions (Android/iOS)

### Phase 2: Data Models
- Create `OpenFoodFactsProduct` model
- Create `EnvironmentalImpact` model
- Extend `FridgeItem` model with barcode and environmental data

### Phase 3: API Integration
- Create `OpenFoodFactsService` for API calls
- Implement product lookup by barcode
- Parse environmental impact data from API response

### Phase 4: Barcode Scanning
- Create `BarcodeScannerWidget`
- Integrate with fridge item creation/editing
- Handle scan results and product lookup

### Phase 5: UI Updates
- Update Analysis Screen with environmental impact cards
- Add barcode scanning to fridge item forms
- Display environmental data in fridge items

### Phase 6: Environmental Impact Cards
- Design environmental impact cards for analysis screen
- Show CO2 footprint, water usage, environmental score
- Aggregate data from user's fridge items

## Expected Features
1. **Barcode Scanner**: Scan product barcodes in fridge screen
2. **Product Lookup**: Automatically fetch product information from OpenFoodFacts
3. **Environmental Cards**: Display environmental impact in analysis screen
4. **Enhanced Fridge Items**: Store environmental data with each item

## Technical Architecture
```
lib/
├── models/
│   ├── openfoodfacts_product.dart
│   ├── environmental_impact.dart
│   └── fridge_item.dart (updated)
├── services/
│   ├── openfoodfacts_service.dart
│   └── barcode_service.dart
├── widgets/
│   └── barcode_scanner_widget.dart
└── screens/
    ├── analysis_screen.dart (updated)
    └── fridge_screen.dart (updated)
```

## Environmental Impact Data to Display
- CO2 emissions per serving
- Water usage per serving  
- Environmental score (0-100)
- Packaging information
- Origin country/region
- Sustainability certifications
