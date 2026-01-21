# Plan: Change First-Time User Flow to Show Onboarding Before Welcome Screen

## Current State Analysis
- StartDecider currently shows WelcomeScreen first for unauthenticated users
- Onboarding is only shown after authentication (guest or login)
- Users see WelcomeScreen → then Onboarding → then MainApp

## Required Changes

### 1. Modify StartDecider Logic
**Current Logic:**
```dart
if (isSignedIn || isGuestMode) {
  // Check onboarding status
  return onboardingSnapshot.data! ? NavigatorPage() : OnboardingScreen();
}
return WelcomeScreen(); // Unauthenticated users go straight to Welcome
```

**New Logic:**
```dart
// Check if user is new (never done onboarding)
if (!onboardingDone) {
  return OnboardingScreen(); // Show onboarding first for all new users
}

// If onboarding is done, check authentication
if (isSignedIn || isGuestMode) {
  return NavigatorPage(); // Go to main app
}
return WelcomeScreen(); // Show Welcome for authenticated but onboarding-complete users
```

### 2. Modify OnboardingScreen Completion Flow
**Current:** OnboardingScreen → NavigatorPage (main app)
**New:** OnboardingScreen → WelcomeScreen

### 3. Update SharedPreferences Logic
- Need to track first-time users vs returning users
- Onboarding completion should lead to WelcomeScreen instead of main app

## New Flow Implementation

### For Brand New Users:
1. **First app open** → OnboardingScreen (4 questions)
2. **After onboarding** → WelcomeScreen
3. **From WelcomeScreen** → Choose guest mode, login, or signup
4. **After authentication** → MainApp (NavigatorPage)

### For Returning Users:
1. **If authenticated and onboarding done** → MainApp directly
2. **If unauthenticated but onboarding done** → WelcomeScreen
3. **If authenticated but onboarding not done** → OnboardingScreen

## Files to Modify

### 1. lib/start_decider.dart
- Change the main logic flow
- Reorder the conditions to check onboarding status first
- Modify authentication check order

### 2. lib/onboarding/onboarding_screen.dart
- Change `finishOnboarding()` method to navigate to WelcomeScreen instead of NavigatorPage
- Update navigation logic

## Implementation Steps

1. **Update StartDecider**: Modify logic to show onboarding first for new users
2. **Update OnboardingScreen**: Change final navigation to WelcomeScreen
3. **Test Flow**: Ensure both new and returning users have correct experience
4. **Verify Guest Mode**: Ensure guest mode still works after onboarding

## Expected Result
- New users will see onboarding questions first
- After completing onboarding, they see the welcome screen
- Returning users who have completed onboarding go directly to main app (if authenticated) or welcome screen (if not authenticated)
- This creates a more engaging first-time experience by collecting user preferences before showing authentication options
