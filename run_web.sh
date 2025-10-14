#!/bin/bash

echo "Building Flutter web app..."
flutter build web --web-renderer html --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

echo "Starting web server on port 5000..."
cd build/web
python3 -m http.server 5000
