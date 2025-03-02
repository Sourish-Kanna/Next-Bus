#!/bin/bash

# Install dependencies
if [ -d "flutter" ]; then
    cd flutter
    git pull
else
    git clone https://github.com/flutter/flutter.git
    cd flutter
fi

# Checkout the required Flutter version
git checkout 3.27.2
git pull origin 3.27.2

# Add Flutter to PATH
export PATH="$PWD/bin:$PATH"

# Verify Flutter version
flutter --version

# Enable web support (only required once)
flutter config --enable-web

# Move back to the root directory
cd ..

# Install project dependencies
flutter pub get

# Build the Flutter web project
flutter build web
