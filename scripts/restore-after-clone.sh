#!/bin/bash

# Restore After Clone Script
# This script restores configuration files after cloning the repository

echo "🔄 Restoring configuration files after clone..."

# Restore environment config if it doesn't exist
if [ ! -f "lib/constants/env_config.dart" ]; then
    if [ -f "lib/constants/env_config.example.dart" ]; then
        echo "📝 Creating lib/constants/env_config.dart from example..."
        cp lib/constants/env_config.example.dart lib/constants/env_config.dart
        echo "✅ Created lib/constants/env_config.dart"
        echo "⚠️  Please update with your actual configuration values"
    else
        echo "❌ lib/constants/env_config.example.dart not found"
    fi
else
    echo "✅ lib/constants/env_config.dart already exists"
fi

# Restore Firebase options if it doesn't exist
if [ ! -f "lib/firebase_options.dart" ]; then
    if [ -f "lib/firebase_options.example.dart" ]; then
        echo "🔥 Creating lib/firebase_options.dart from example..."
        cp lib/firebase_options.example.dart lib/firebase_options.dart
        echo "✅ Created lib/firebase_options.dart"
        echo "⚠️  Please update with your actual Firebase configuration"
    else
        echo "❌ lib/firebase_options.example.dart not found"
    fi
else
    echo "✅ lib/firebase_options.dart already exists"
fi

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

echo ""
echo "🎉 Restore complete!"
echo ""
echo "Next steps:"
echo "1. Update lib/constants/env_config.dart with your configuration"
echo "2. Update lib/firebase_options.dart with your Firebase settings"
echo "3. Update web/index.html with your Google Sign-In Client ID"
echo "4. Download Firebase configuration files from Firebase Console"
echo "5. Run 'flutter run' to test the app"
echo ""
echo "📚 See SETUP.md for detailed instructions" 