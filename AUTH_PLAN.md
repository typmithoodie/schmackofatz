# Authentication & Profile Management Implementation Plan

## Current Project Analysis
- Flutter food management app "schmackofatz"
- Firebase already configured (auth, core)
- Uses green accent color: Color.fromARGB(255, 26, 169, 48)
- Existing bottom navigation with 5 screens
- SharedPreferences for onboarding state

## Implementation Steps

### 1. Dependencies Update (pubspec.yaml)
- Add `firebase_storage: ^6.1.3` for profile image storage
- Add `image_picker: ^1.1.2` for selecting images
- Add `cached_network_image: ^3.4.1` for optimized image display

### 2. Authentication Services
**File: `lib/services/auth_service.dart`**
- Firebase Authentication wrapper
- Login, signup, logout, password reset methods
- User state management
- Guest mode handling

**File: `lib/services/profile_service.dart`**
- Profile image upload to Firebase Storage
- User data management (username, email)
- Profile data persistence

### 3. Authentication Screens
**File: `lib/screens/auth/welcome_screen.dart`**
- Welcome screen with Continue as Guest button
- Login and Signup navigation options

**File: `lib/screens/auth/login_screen.dart`**
- Email/password login form
- Password reset link
- Signup navigation

**File: `lib/screens/auth/signup_screen.dart`**
- Username, email, password registration form
- Terms acceptance
- Login navigation

**File: `lib/screens/auth/password_reset_screen.dart`**
- Email input for password reset
- Reset confirmation

### 4. Profile Management
**File: `lib/screens/profile/profile_screen.dart`**
- Profile image display with upload option
- Username update functionality
- Email change option
- Password change option
- Logout functionality

### 5. Navigation Updates
**File: `lib/start_decider.dart`**
- Check authentication state
- Route to appropriate screen (auth/main app)

**File: `lib/main.dart`**
- Add profile tab to bottom navigation
- Update NavigatorPage to include profile screen

### 6. UI Components
**File: `lib/widgets/profile_image_picker.dart`**
- Reusable image picker widget
- Circular avatar with edit overlay

### 7. Theme Integration
- Use existing green color scheme
- Follow current app styling patterns
- Responsive design for all screen sizes

## Key Features
- ✅ Guest mode continuation
- ✅ Firebase Storage integration
- ✅ Green color scheme consistency
- ✅ Profile image upload/change
- ✅ Username update
- ✅ Email change
- ✅ Password reset/change
- ✅ Secure authentication flow
- ✅ Optimized image handling

## File Structure to Create
```
lib/
├── services/
│   ├── auth_service.dart
│   └── profile_service.dart
├── screens/
│   ├── auth/
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── password_reset_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── widgets/
    └── profile_image_picker.dart
```

## Integration Points
- Update start_decider.dart to check auth state
- Add profile tab to existing bottom navigation
- Maintain existing onboarding flow
- Preserve guest mode functionality
