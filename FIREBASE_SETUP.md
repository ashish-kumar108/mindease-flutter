# Firebase Google Sign-In Integration Setup

## Overview
This document outlines the Firebase and Google Sign-In integration for the MindEase meditation app.

## Files Modified

### 1. `lib/screens/auth_service.dart`
- Enhanced `AuthService` class with proper Google Sign-In initialization
- Added scopes for email and profile access
- Improved error handling with comprehensive logging using `dart:developer`
- Added `signOut()` method for logout functionality

### 2. `lib/screens/login_screen.dart`
- Integrated Google Sign-In button with actual authentication logic
- Added email/password login with Firebase Authentication
- Proper error handling with user feedback via SnackBar
- Uses `dart:developer` for logging instead of `print()`

### 3. `lib/main.dart`
- Added proper Firebase initialization in main function
- Added error handling for Firebase initialization
- Includes logging for debugging

## Setup Instructions

### Prerequisites
- Flutter SDK 3.6.0 or higher
- Firebase project created at [Firebase Console](https://console.firebase.google.com)
- Android/iOS platforms configured in Firebase

### 1. Android Configuration

#### Add google-services.json
1. Download `google-services.json` from your Firebase project
2. Place it in `android/app/` directory (already present in workspace)

#### Update build.gradle files
The Android configuration should already be set up via FlutterFire CLI.

### 2. iOS Configuration

#### Add GoogleService-Info.plist
1. Download `GoogleService-Info.plist` from your Firebase project
2. Add it to Xcode:
   - Open `ios/Runner.xcworkspace`
   - Drag & drop the plist file into Xcode
   - Select "Copy items if needed"

#### Update iOS Build Settings
```
# In ios/Podfile, ensure:
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
      ]
    end
  end
end
```

### 3. Dependencies Already Configured

The following dependencies are in `pubspec.yaml`:
```yaml
firebase_core: ^4.0.0
firebase_auth: ^6.0.1
google_sign_in: ^6.2.1
```

Run to ensure all dependencies are downloaded:
```bash
flutter pub get
```

### 4. Google Sign-In OAuth Credentials

#### For Android:
1. Go to Firebase Console → Project Settings → Service Accounts
2. Download the private key JSON
3. The `google-services.json` already contains the necessary credentials

#### For iOS:
1. In Firebase Console, go to Authentication → Sign-in method
2. Enable Google Sign-In
3. Ensure your iOS app is registered with its Bundle ID (`com.example.meditationAndMindfulness`)

### 5. Testing

#### Test Google Sign-In Flow:
```bash
flutter run
# Tap "Continue with Google" button on login screen
# You should see log messages in the console
```

#### Check Logs:
Google Sign-In and Firebase authentication logs are output using `dart:developer.log()`:
```
flutter logs
# Look for messages like:
# - "Starting Google Sign-In..."
# - "Google user signed in: user@example.com"
# - "Firebase sign-in successful"
```

## Authentication Flow

1. **User taps "Continue with Google"**
   - `_loginWithGoogle()` is called
   - AuthService initiates Google Sign-In

2. **Google Authentication**
   - User selects Google account
   - Google OAuth tokens are obtained

3. **Firebase Sign-In**
   - OAuth tokens are exchanged for Firebase credentials
   - User is signed into Firebase

4. **Navigation**
   - On successful auth, user is navigated to `/home`
   - User object is stored in state

## Error Handling

The implementation includes:
- Try-catch blocks for Google Sign-In errors
- Try-catch for Firebase authentication errors
- User feedback via SnackBar widgets
- Console logging via `dart:developer.log()`

## Production Checklist

- [ ] Update Firebase OAuth redirect URIs for production domain
- [ ] Enable reCAPTCHA in Firebase Console for enhanced security
- [ ] Test on actual Android/iOS devices (not emulator for OAuth)
- [ ] Verify Firebase security rules in Firestore/Realtime Database
- [ ] Add user creation logic after successful authentication
- [ ] Implement session persistence (optional)
- [ ] Test logout functionality

## Troubleshooting

### "Google Sign-In failed" error
- Check that `google-services.json` is in correct location
- Verify Firebase project has Google Sign-In enabled
- Ensure Android signing certificate matches Firebase configuration

### "Target of URI doesn't exist" in analyzer
- Run `flutter pub get` again
- Close and reopen VS Code if issue persists
- Check `.dart_tool` is not corrupted

### Email login not working
- Ensure user account exists in Firebase Authentication
- Check Firebase security rules allow user creation

## Next Steps

1. Implement user profile creation after first Google Sign-In
2. Add Firestore user data storage
3. Implement user preferences and settings persistence
4. Add account linking (multiple auth methods per user)
5. Implement refresh token handling

---

**Last Updated:** December 25, 2025
**Firebase Setup Status:** ✅ Configured and Ready
