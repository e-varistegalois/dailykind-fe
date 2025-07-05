#!/bin/bash

# DailyKind FE Setup Script
echo "🚀 Setting up DailyKind FE project..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Create environment config if it doesn't exist
if [ ! -f "lib/constants/env_config.dart" ]; then
    echo "⚙️  Creating environment configuration..."
    cp lib/constants/env_config.example.dart lib/constants/env_config.dart
    echo "✅ Created lib/constants/env_config.dart"
    echo "⚠️  Please update lib/constants/env_config.dart with your actual values"
else
    echo "✅ Environment configuration already exists"
fi

# Create Firebase options if it doesn't exist
if [ ! -f "lib/firebase_options.dart" ]; then
    echo "🔥 Creating Firebase options..."
    cp lib/firebase_options.example.dart lib/firebase_options.dart
    echo "✅ Created lib/firebase_options.dart"
    echo "⚠️  Please update lib/firebase_options.dart with your actual Firebase configuration"
else
    echo "✅ Firebase options already exists"
fi

# Check if Google Services files exist
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️  Missing android/app/google-services.json"
    echo "   Download it from Firebase Console > Project Settings > Your Apps > Android"
fi

if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  Missing ios/Runner/GoogleService-Info.plist"
    echo "   Download it from Firebase Console > Project Settings > Your Apps > iOS"
fi

if [ ! -f "macos/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️  Missing macos/Runner/GoogleService-Info.plist"
    echo "   Download it from Firebase Console > Project Settings > Your Apps > macOS"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Update lib/constants/env_config.dart with your configuration"
echo "2. Update lib/firebase_options.dart with your Firebase settings"
echo "3. Update web/index.html with your Google Sign-In Client ID"
echo "4. Download Firebase configuration files from Firebase Console"
echo "5. Run 'flutter run' to test the app"
echo ""
echo "📚 See SETUP.md for detailed instructions" 