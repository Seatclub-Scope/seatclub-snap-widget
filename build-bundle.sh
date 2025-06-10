#!/bin/bash

set -e

echo "🚀 Building SeatclubApp bundle..."

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
fi

# Create assets directory if it doesn't exist
mkdir -p ios/SeatclubApp/SeatclubApp/SeatclubApp

# Check if required files exist
if [ ! -f "index.js" ]; then
    echo "❌ Error: index.js not found"
    exit 1
fi

# Build the bundle
echo "📱 Building React Native bundle..."
npx react-native bundle \
  --platform ios \
  --dev false \
  --entry-file index.js \
  --bundle-output ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle \
  --assets-dest ios/SeatclubApp/SeatclubApp/SeatclubApp/ \
  --config metro.config.js \
  --reset-cache

# Check if bundle was created
if [ -f "ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle" ]; then
    echo "✅ Bundle created successfully at ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle"
    echo "📊 Bundle size: $(ls -lh ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle | awk '{print $5}')"
else
    echo "❌ Error: Bundle creation failed"
    exit 1
fi
