#!/bin/bash

# VisReminder Build Script
# This script helps build and test the VisReminder app

set -e

echo "🏗️  Building VisReminder..."

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Xcode is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "VisReminder.xcodeproj/project.pbxproj" ]; then
    echo "❌ Please run this script from the VisReminder directory"
    exit 1
fi

# Clean build directory
echo "🧹 Cleaning build directory..."
xcodebuild clean -project VisReminder.xcodeproj -scheme VisReminder

# Build for iOS Simulator
echo "📱 Building for iOS Simulator..."
xcodebuild build -project VisReminder.xcodeproj -scheme VisReminder -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'

# Build for macOS
echo "🖥️  Building for macOS..."
xcodebuild build -project VisReminder.xcodeproj -scheme VisReminder -destination 'platform=macOS'

echo "✅ Build completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Open VisReminder.xcodeproj in Xcode"
echo "2. Select your development team in project settings"
echo "3. Choose a target device or simulator"
echo "4. Press Cmd+R to run the app"
echo ""
echo "🔧 Required permissions:"
echo "- Camera access for photo capture"
echo "- Photo library access for selecting photos"
echo "- Reminders access for Apple Reminders integration" 