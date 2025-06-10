#!/bin/bash

set -e

echo "🚀 Building SeatclubApp Framework..."

# Ensure we're in the project root
cd "$(dirname "$0")"

# Step 1: Build the JavaScript bundle
echo "📱 Building JavaScript bundle..."
./build-bundle.sh

# Step 2: Navigate to iOS project
cd ios/SeatclubApp

# Step 3: Build for iOS Device (arm64)
echo "🔨 Building for iOS Device..."
xcodebuild clean archive \
  -workspace SeatclubApp.xcworkspace \
  -scheme SeatclubApp \
  -destination "generic/platform=iOS" \
  -archivePath "../../build/SeatclubApp-iOS" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  IPHONEOS_DEPLOYMENT_TARGET=17.0

# Step 4: Build for iOS Simulator
echo "🔨 Building for iOS Simulator..."
xcodebuild clean archive \
  -workspace SeatclubApp.xcworkspace \
  -scheme SeatclubApp \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "../../build/SeatclubApp-Simulator" \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  IPHONEOS_DEPLOYMENT_TARGET=17.0

# Step 5: Navigate back to project root
cd ../..

# Step 6: Create XCFramework
echo "📦 Creating XCFramework..."
xcodebuild -create-xcframework \
  -framework "build/SeatclubApp-iOS.xcarchive/Products/Library/Frameworks/SeatclubApp.framework" \
  -framework "build/SeatclubApp-Simulator.xcarchive/Products/Library/Frameworks/SeatclubApp.framework" \
  -output "build/SeatclubApp.xcframework"

echo "✅ XCFramework created successfully: build/SeatclubApp.xcframework"

# Step 7: Create distribution zip
echo "📦 Creating distribution zip..."
cd build
zip -r SeatclubApp.xcframework.zip SeatclubApp.xcframework
cd ..

# Calculate file sizes
FRAMEWORK_SIZE=$(du -sh build/SeatclubApp.xcframework 2>/dev/null | cut -f1 || echo "Unknown")
ZIP_SIZE=$(du -sh build/SeatclubApp.xcframework.zip 2>/dev/null | cut -f1 || echo "Unknown")

echo ""
echo "🎉 Build completed successfully!"
echo "📊 Framework size: $FRAMEWORK_SIZE"
echo "📦 Zip size: $ZIP_SIZE"
echo "📁 Distribution zip: build/SeatclubApp.xcframework.zip"
echo ""
echo "📝 Next steps:"
echo "1. Upload the .xcframework.zip to your GitHub releases"
echo "2. Update the checksum in Package.swift"
echo "3. Update the URL in Package.swift to point to your release"
