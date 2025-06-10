#!/bin/bash

echo "🔍 Debugging React Native Bundle..."

BUNDLE_PATH="ios/SeatclubApp/SeatclubApp/SeatclubApp/seatclub-app.jsbundle"

if [ -f "$BUNDLE_PATH" ]; then
    echo "✅ Bundle found at: $BUNDLE_PATH"
    echo "📊 Bundle size: $(ls -lh "$BUNDLE_PATH" | awk '{print $5}')"
    
    echo ""
    echo "🔍 Checking for React Native components in bundle:"
    echo "AppRegistry:" $(grep -c "AppRegistry" "$BUNDLE_PATH" || echo "0")
    echo "React:" $(grep -c '"react"' "$BUNDLE_PATH" || echo "0")
    echo "__fbBatchedBridge:" $(grep -c "__fbBatchedBridge" "$BUNDLE_PATH" || echo "0")
    echo "TurboModuleRegistry:" $(grep -c "TurboModuleRegistry" "$BUNDLE_PATH" || echo "0")
    echo "registerComponent:" $(grep -c "registerComponent" "$BUNDLE_PATH" || echo "0")
    echo "SeatclubApp:" $(grep -c "SeatclubApp" "$BUNDLE_PATH" || echo "0")
    
    echo ""
    echo "🔍 First 500 characters of bundle:"
    head -c 500 "$BUNDLE_PATH"
    echo ""
    echo "..."
    
    echo ""
    echo "🔍 Last 500 characters of bundle:"
    tail -c 500 "$BUNDLE_PATH"
    
    echo ""
    echo "🔍 Looking for AppRegistry.registerComponent calls:"
    grep -n "registerComponent" "$BUNDLE_PATH" | head -5
    
else
    echo "❌ Bundle not found at: $BUNDLE_PATH"
fi