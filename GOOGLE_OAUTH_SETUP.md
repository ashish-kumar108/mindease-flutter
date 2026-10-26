# Google OAuth Sign-In Setup Guide

## Problem: "Google Sign-In Cancelled" Error

If you see "Google Sign-In cancelled" when clicking the Google Sign-In button, it means Google OAuth isn't properly configured.

## Step 1: Get Your Web Client ID

### From Firebase Console:

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **meditation-86047**
3. Go to **Settings** → **Project Settings**
4. Scroll down to **Web API Key** section
5. Click on **Google Cloud Console** link

### From Google Cloud Console:

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select project: **meditation-86047**
3. Left sidebar → **APIs & Services** → **Credentials**
4. Look for **OAuth 2.0 Client ID** with type **Web application**
5. Click it to view the **Client ID** (looks like: `xxx-xxx.apps.googleusercontent.com`)

## Step 2: Update auth_service.dart

Replace the placeholder Client ID in `lib/screens/auth_service.dart`:

**Current (Line 16):**
```dart
clientId: kIsWeb ? '707355438584-your-web-client-id.apps.googleusercontent.com' : null,
```

**Change to:**
```dart
clientId: kIsWeb ? 'YOUR_ACTUAL_CLIENT_ID.apps.googleusercontent.com' : null,
```

Example:
```dart
clientId: kIsWeb ? '123456789-abc1def2ghi3jkl4mno5pqr6stu7.apps.googleusercontent.com' : null,
```

## Step 3: Configure OAuth Consent Screen

### In Google Cloud Console:

1. **APIs & Services** → **OAuth consent screen**
2. Choose **External** user type
3. Click **Create**
4. Fill in:
   - **App name:** MindEase
   - **User support email:** your-email@example.com
   - **Developer contact:** your-email@example.com
5. Click **Save and Continue**
6. **Add or Remove Scopes:**
   - Add: `email`
   - Add: `profile`
   - Add: `openid`
7. Click **Save and Continue**
8. Click **Back to Dashboard**

## Step 4: Configure Authorized Redirect URIs

### In Google Cloud Console:

1. **APIs & Services** → **Credentials**
2. Click your **OAuth 2.0 Client ID** (Web application)
3. Under **Authorized redirect URIs**, add:

**For Web (localhost development):**
```
http://localhost:5000
http://localhost:5000/
```

**For Chrome debugging:**
```
http://localhost:5000/blank
```

**For production (replace with your domain):**
```
https://yourdomain.com/
https://yourdomain.com/blank
```

4. Click **Save**

## Step 5: For Android Configuration

### Get Your SHA-1 Fingerprint:

```bash
keytool -list -v -keystore C:\Users\YOUR_USER\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the **SHA1** value.

### In Google Cloud Console:

1. **APIs & Services** → **Credentials**
2. Click your **OAuth 2.0 Client ID** (Android)
3. Add your app's **package name** and **SHA-1** fingerprint
4. Click **Save**

**Package Name:** `com.example.meditationAndMindfulness`

## Step 6: For iOS Configuration

### In Google Cloud Console:

1. **APIs & Services** → **Credentials**
2. Click your **OAuth 2.0 Client ID** (iOS)
3. Add your app's **Bundle ID**
4. Click **Save**

**Bundle ID:** `com.example.meditationAndMindfulness`

## Step 7: Test the Integration

### On Web (Chrome):

```bash
flutter run -d chrome
```

1. Navigate to login screen
2. Click **Continue with Google**
3. You should see Google's login dialog
4. Sign in with your Google account

### On Android:

```bash
flutter run -d <device>
```

Same process as above.

## Troubleshooting

### Error: "Google Sign-In Cancelled"
- **Cause:** OAuth not configured or user clicked cancel
- **Solution:** Complete steps 1-6 above

### Error: "Invalid Client ID"
- **Cause:** Wrong Client ID in code
- **Solution:** Double-check Client ID matches your web app in Google Cloud Console

### Error: "Redirect URI mismatch"
- **Cause:** Your app's URL isn't in the authorized list
- **Solution:** Add your localhost URL (step 4) to the authorized redirect URIs

### Error: "OAuth consent screen not configured"
- **Cause:** You haven't set up the consent screen
- **Solution:** Complete step 3 above

### Still seeing "cancelled" message
- **Check:**
  1. Is Firebase initialized successfully? (Check logs)
  2. Is Client ID correct in code?
  3. Is the consent screen published (for external users)?
  4. Are scopes authorized in consent screen?

## How to View Logs

While the app is running:

```bash
flutter logs
```

Look for messages like:
```
Starting Google Sign-In...
Google user signed in: user@gmail.com
Firebase sign-in successful
```

## Firebase Security Rules

After successful sign-in, users will be authenticated in Firebase. Make sure your Firestore/Realtime Database rules allow authenticated users:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Production Checklist

- [ ] Update Client ID in code with production web Client ID
- [ ] Add production domain to authorized redirect URIs
- [ ] Set up OAuth consent screen as "Production" (not External)
- [ ] Test on actual Android device with signed APK
- [ ] Test on actual iOS device
- [ ] Update Firebase security rules for production
- [ ] Enable HTTPS for web domain
- [ ] Add domain to OAuth authorized list

## Next Steps

Once Google Sign-In is working:
1. Implement user profile creation
2. Store user data in Firestore
3. Set up user preferences
4. Implement logout functionality

---

**Last Updated:** December 25, 2025
**Status:** Configuration Guide
