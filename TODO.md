# Security Fix: Prevent sensitive profile changes when not logged in

## Task
Fix security vulnerability where email, password, username, and profile image can be changed when not logged in, and ensure different users have different profile data.

## Plan

### Step 1: Modify Profile Screen (`lib/screens/profile/profile_screen.dart`)
- Add `_checkLoginStatus()` helper method to verify user is logged in and not in guest mode
- Add `_canChangeSensitiveData()` helper method for consistent login checks
- Add `_showNotLoggedInDialog()` to show an alert dialog when users attempt sensitive operations without being logged in
- Add login status checks at the beginning of `_updateUsername()`, `_updateEmail()`, and `_changePassword()` methods
- Block the operation if user is not logged in or is in guest mode

### Step 2: Improve Auth Service (`lib/services/auth_service.dart`)
- Add explicit `isGuestMode` check in `changeEmail()` and `changePassword()` methods with clear error messages

### Step 3: Make Profile Service User-Specific (`lib/services/profile_service.dart`)
- Add `_getUserSpecificKey()` helper method to generate user-specific storage keys using Firebase UID
- Update all SharedPreferences calls to use benutzerspezifisch (user-specific) keys
- This ensures each user has their own username, email, and profile image stored separately

## Status

- [x] Step 1: Add login status check helper and update _updateEmail() and _changePassword() methods
- [x] Step 2: Add guest mode validation in auth_service.dart methods
- [x] Step 3: Add login check to _updateUsername() method
- [x] Step 4: Make profile data user-specific using Firebase UID in SharedPreferences keys
- [x] Step 5: Verify code compiles with flutter analyze (only pre-existing deprecation warnings found)

