# DailyKind FE - Setup Guide

## Prerequisites
- Flutter SDK (^3.5.4)
- Dart SDK
- Firebase project
- Google Cloud Console access

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dailykind_fe
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication with Google Sign-In
   - Enable People API in Google Cloud Console
   - Download configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
     - Web configuration for web platform

4. **Configure Environment Variables**
   - Copy `lib/constants/env_config.dart.example` to `lib/constants/env_config.dart`
   - Fill in your Firebase configuration values
   - Add your Google Sign-In Client ID

5. **Configure Firebase Options**
   - Copy `lib/firebase_options.example.dart` to `lib/firebase_options.dart`
   - Fill in your actual Firebase configuration values
   - Or run `flutterfire configure` to generate the file automatically

6. **Configure Google Sign-In**
   - Update `web/index.html` with your Google Sign-In Client ID
   - For mobile platforms, ensure OAuth client IDs are configured

## Project Structure

```
lib/
├── constants/
│   ├── app_constants.dart      # App-wide constants
│   └── env_config.dart         # Environment variables (gitignored)
├── screens/
│   ├── sign_in_screen.dart     # Sign-in screen
│   └── home_screen.dart        # Home screen
├── services/
│   └── google_sign_in_service.dart  # Google Sign-In service
├── models/                     # Data models
├── utils/                      # Utility functions
├── widgets/                    # Reusable widgets
├── firebase_options.dart       # Firebase configuration
└── main.dart                   # App entry point
```

## Environment Variables

Create `lib/constants/env_config.dart` with the following structure:

```dart
class EnvConfig {
  static const String firebaseApiKey = 'YOUR_API_KEY';
  static const String firebaseProjectId = 'YOUR_PROJECT_ID';
  static const String googleSignInClientId = 'YOUR_CLIENT_ID';
  // ... other configuration
}
```

## Running the App

```bash
# For web
flutter run -d chrome

# For mobile
flutter run
```

## Troubleshooting

1. **Google Sign-In always asks for verification**
   - This is normal for development apps
   - Enable People API in Google Cloud Console
   - Configure OAuth consent screen

2. **Firebase initialization error**
   - Ensure Firebase is properly configured
   - Check `firebase_options.dart` file
   - Verify API keys and project settings

3. **Missing assets error**
   - Add required assets to `pubspec.yaml`
   - Or use default icons instead of custom assets

## Security Notes

- Never commit `env_config.dart` with real values
- Keep Firebase configuration files secure
- Use environment variables for production
- Regularly rotate API keys and secrets 