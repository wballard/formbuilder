#!/bin/bash
set -e

echo "🚀 Building Flutter Web Storybook for GitHub Pages..."

# Navigate to example directory
cd example

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web with proper base href
echo "🔨 Building web app..."
flutter build web --base-href /formbuilder/

# Create .nojekyll file to bypass Jekyll processing
echo "📄 Creating .nojekyll file..."
touch build/web/.nojekyll

echo "✅ Build complete!"
echo ""
echo "📋 To deploy to GitHub Pages:"
echo "1. Make sure GitHub Pages is enabled in your repository settings"
echo "2. Set the source to 'GitHub Actions' in Pages settings"
echo "3. Push your changes to trigger the deployment workflow"
echo ""
echo "🌐 Your storybook will be available at:"
echo "   https://[your-username].github.io/formbuilder/"
echo ""
echo "💡 Alternatively, you can manually deploy with:"
echo "   git subtree push --prefix example/build/web origin gh-pages"