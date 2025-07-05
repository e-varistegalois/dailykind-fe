#!/bin/bash

# Clean for Git Script
# This script removes sensitive files before pushing to git

echo "🧹 Cleaning sensitive files for git..."

# Remove sensitive configuration files
if [ -f "lib/firebase_options.dart" ]; then
    echo "🗑️  Removing lib/firebase_options.dart"
    rm lib/firebase_options.dart
fi

if [ -f "lib/constants/env_config.dart" ]; then
    echo "🗑️  Removing lib/constants/env_config.dart"
    rm lib/constants/env_config.dart
fi

# Remove Firebase configuration files
if [ -f "android/app/google-services.json" ]; then
    echo "🗑️  Removing android/app/google-services.json"
    rm android/app/google-services.json
fi

if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "🗑️  Removing ios/Runner/GoogleService-Info.plist"
    rm ios/Runner/GoogleService-Info.plist
fi

if [ -f "macos/Runner/GoogleService-Info.plist" ]; then
    echo "🗑️  Removing macos/Runner/GoogleService-Info.plist"
    rm macos/Runner/GoogleService-Info.plist
fi

# Remove environment files
if [ -f ".env" ]; then
    echo "🗑️  Removing .env"
    rm .env
fi

if [ -f ".env.local" ]; then
    echo "🗑️  Removing .env.local"
    rm .env.local
fi

if [ -f ".env.production" ]; then
    echo "🗑️  Removing .env.production"
    rm .env.production
fi

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "⚠️  Remember to:"
echo "1. Copy example files back after cloning"
echo "2. Fill in your actual configuration values"
echo "3. Download Firebase configuration files"
echo ""
echo "📚 See SETUP.md for instructions" 