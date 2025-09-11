#!/bin/bash

# Install Flutter if not present
if ! command -v flutter &> /dev/null; then
    echo "Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
    export PATH="$PATH:$HOME/flutter/bin"
fi

# Enable Flutter web
flutter config --enable-web

# Get dependencies
flutter pub get

# Build for web
flutter build web --release --web-renderer html

echo "Build completed successfully!"
