#!/bin/bash

# Simple Flutter Web Launcher for EFE Documentation
# This launches only the Flutter documentation website

set -e

echo "=================================================="
echo "  📱 EFE Documentation Website"
echo "=================================================="
echo ""
echo "Launching Guide to Equidistributed Free Economy..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter."
    exit 1
fi

echo -e "${GREEN}✓ Flutter found${NC}"

# Navigate to Flutter app
cd "$(dirname "$0")/../Guide to Equidistributed Free Economy/efe"

# Get dependencies
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
flutter pub get

echo ""
echo -e "${GREEN}🚀 Launching web application...${NC}"
echo ""
echo "=================================================="
echo "  Opening in Chrome..."
echo "=================================================="
echo ""

# Run without WASM for compatibility
flutter run -d chrome --release

echo ""
echo "Application closed."
