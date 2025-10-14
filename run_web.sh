#!/bin/bash

echo "Building Flutter web app..."
flutter build web --web-renderer html

echo "Starting web server on port 5000..."
cd build/web
python3 -m http.server 5000
