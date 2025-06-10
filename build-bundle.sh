#!/bin/bash

set -e

echo "🚀 Building full React Native bundle for SeatclubApp..."

# Clean up any previous builds
rm -rf ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle
rm -rf node_modules/.cache

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
else
    echo "📦 Dependencies already installed"
fi

# Create output directory
mkdir -p ios/SeatclubApp/SeatclubApp/SeatclubApp

# Check if required files exist
if [ ! -f "index.js" ]; then
    echo "❌ Error: index.js not found"
    exit 1
fi

if [ ! -f "src/App.js" ]; then
    echo "❌ Error: App.js not found"
    exit 1
fi

# Build the bundle with all React Native features
echo "📱 Building complete React Native bundle..."
npx react-native bundle \
  --platform ios \
  --dev false \
  --entry-file index.js \
  --bundle-output ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle \
  --assets-dest ios/SeatclubApp/SeatclubApp/SeatclubApp/ \
  --config metro.config.js \
  --reset-cache \
  --verbose \
  --minify false

# Check if bundle was created
if [ -f "ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle" ]; then
    echo "✅ React Native bundle created successfully"
    echo "📊 Bundle size: $(ls -lh ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle | awk '{print $5}')"
    
    # Show first few lines of bundle to verify it's a React Native bundle
    echo "🔍 Bundle preview (first 300 characters):"
    head -c 300 ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle
    echo ""
    echo "..."
    
    # Check for essential React Native components
    echo "🔍 Checking bundle contents:"
    echo "  AppRegistry: $(grep -c "AppRegistry" ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle || echo "0") occurrences"
    echo "  React: $(grep -c "React" ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle || echo "0") occurrences"
    echo "  __fbBatchedBridge: $(grep -c "__fbBatchedBridge" ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle || echo "0") occurrences"
    echo "  registerComponent: $(grep -c "registerComponent" ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle || echo "0") occurrences"
    echo "  SeatclubApp: $(grep -c "SeatclubApp" ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle || echo "0") occurrences"
    
    # More detailed checks
    if grep -q "AppRegistry" ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle; then
        echo "✅ AppRegistry found in bundle"
    else
        echo "❌ Warning: AppRegistry not found in bundle"
    fi
    
    if grep -q "__fbBatchedBridge" ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle; then
        echo "✅ React Native bridge code found"
    else
        echo "⚠️ Warning: React Native bridge code not found"
    fi
    
    if grep -q "SeatclubApp" ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle; then
        echo "✅ SeatclubApp component found"
    else
        echo "❌ Warning: SeatclubApp component not found"
    fi
    
    # Check for Metro module system
    if grep -q "__r(" ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle; then
        echo "✅ Metro module system found"
    else
        echo "⚠️ Warning: Metro module system not found"
    fi
    
else
    echo "❌ Error: Bundle creation failed"
    exit 1
fi

echo "🎉 Full React Native bundle build completed!"