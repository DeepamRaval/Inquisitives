#!/bin/bash

# Install Flutter
echo "Downloading Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# Run Flutter Doctor (optional but good for logs)
flutter doctor -v

# Enable Web
flutter config --enable-web

# Build
echo "Building Flutter Web App..."
flutter build web --release
