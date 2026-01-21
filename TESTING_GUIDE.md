# RevenueCat Integration Testing Guide

## Prerequisites
1. **RevenueCat Dashboard Setup**
   - Create a RevenueCat account at https://www.revenuecat.com
   - Create a new project for "schmackofatz"
   - Add your test API keys (the ones you used in `initialize_revenuecat.dart`)
   - Create a product with ID "schmackofatz Pro"
   - Configure entitlements in RevenueCat dashboard

2. **Test Devices/Simulators**
   - iOS Simulator or Android Emulator
   - Or physical test devices

## Testing Steps

### 1. Basic App Launch
```bash
cd c:/Development/Flutter-Projekte/schmackofatz
flutter run
```

**Expected Results:**
- App launches successfully
- No errors in console related to RevenueCat initialization
- Home screen loads with "KI-Rezeptvorschläge" button

### 2. Test Non-Premium User Flow

**Scenario 1: First-time user (no subscription)**
1. Open app → Should see "KI-Rezeptvorschläge" button
2. Tap the button → Should trigger paywall dialog
3. Verify upgrade dialog shows:
   - Title: "Upgrade zu Pro"
   - Premium features list
   - "Später" and "Jetzt upgraden" buttons

**Scenario 2: Package Selection**
1. Tap "Jetzt upgraden" → Should load package selection dialog
2. Verify packages are loaded from RevenueCat
3. Test package selection (don't complete purchase)

**Scenario 3: Dismiss Paywall**
1. Tap "Später" → Should dismiss dialog
2. User returns to home screen
3. Button should still be accessible (for testing)

### 3. Test Premium User Flow

**To simulate a Pro user:**
1. Complete a test purchase in RevenueCat dashboard
2. Or use RevenueCat's debug features to grant entitlements

**Expected Results:**
1. App loads → Entitlement check completes
2. Tap "KI-Rezeptvorschläge" → Should show "KI-Rezeptvorschläge werden geladen..." snackbar
3. No paywall dialog should appear

### 4. Test Loading States

**Expected Behavior:**
- App loads → Button shows "Lädt..." with spinner
- After entitlement check → Button shows "KI-Rezeptvorschläge"
- Button is disabled during loading

### 5. Test Error Scenarios

**Network Error Simulation:**
1. Disable network connection
2. Launch app → Should handle error gracefully
3. Re-enable network → Should retry entitlement check

## RevenueCat Dashboard Testing

### Test Mode Setup
1. Go to RevenueCat Dashboard → Project Settings
2. Enable "Test Mode" for sandbox testing
3. Configure test users and entitlements

### Debugging Features
```dart
// Add this to see detailed logs
 Purchases.setLogLevel(LogLevel.debug);
```

## Console Output to Expect

### Successful Initialization:
```
[Purchases] - DEBUG: 💰 Initializing RevenueCat SDK
[Purchases] - INFO: RevenueCat initialized
```

### Entitlement Check:
```
[Purchases] - DEBUG: Fetching customer info
[Purchases] - INFO: Customer info updated
```

### Paywall Trigger:
```
[Purchases] - DEBUG: Showing upgrade dialog
[Purchases] - INFO: User attempted to access premium feature
```

## Common Issues & Solutions

### Issue 1: "No entitlements found"
**Solution:** Check RevenueCat dashboard setup and API keys

### Issue 2: Paywall not showing packages
**Solution:** Verify products are properly configured in RevenueCat

### Issue 3: Network errors
**Solution:** Check internet connection and RevenueCat service status

### Issue 4: Button remains disabled
**Solution:** Check entitlement service logs for errors

## Testing Checklist

- [ ] App launches without RevenueCat errors
- [ ] Entitlement check completes successfully
- [ ] Non-premium users see paywall when tapping premium button
- [ ] Paywall shows correct premium features
- [ ] Package selection loads available subscriptions
- [ ] Premium users can access features without paywall
- [ ] Loading states work correctly
- [ ] Error handling works for network issues
- [ ] Purchase flow completes (in test mode)

## Test Accounts

**RevenueCat Test Users:**
- Create test users in RevenueCat dashboard
- Grant/different entitlements for testing
- Use sandbox test cards for purchases

## Next Steps After Testing

1. **Production Setup:**
   - Replace test API keys with production keys
   - Configure real products in app stores
   - Disable test mode

2. **Analytics:**
   - Monitor conversion rates
   - Track premium feature usage
   - A/B test paywall triggers

3. **Polish:**
   - Customize paywall design
   - Add more premium features
   - Implement subscription management
