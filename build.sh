#!/bin/bash
set -e

echo "Installing Flutter..."

# Clone Flutter SDK if not already present
if [ ! -d "flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify and configure Flutter
echo "Flutter version:"
flutter --version
flutter config --enable-web

# Install dependencies
echo "Getting dependencies..."
flutter pub get

# Build for web
echo "Building Flutter web app..."
flutter build web --release

echo "Build complete!"
