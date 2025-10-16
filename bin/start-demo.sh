#!/bin/bash

# aequchain Demo Startup Script
# Starts# Start Julia API server in background
echo -e "${YELLOW}🔧 Starting aequchain testnet API server...${NC}"
julia --project=. start-api.jl &
API_PID=$!ver and Flutter web application

set -e  # Exit on error

echo "=================================================="
echo "  🚀 aequchain DEMO MODE STARTUP"
echo "=================================================="
echo ""
echo "⚠️  WARNING: DEMO MODE ONLY - NO REAL VALUE ⚠️"
echo ""
echo "This demo is for testing and evaluation purposes."
echo "All data is ephemeral and will be lost on exit."
echo "No real financial transactions occur."
echo ""
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Julia is installed
if ! command -v julia &> /dev/null; then
    echo -e "${RED}❌ Julia is not installed${NC}"
    echo "Please install Julia 1.8+ from https://julialang.org"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    echo "Please install Flutter from https://flutter.dev"
    exit 1
fi

echo -e "${GREEN}✓ Julia found: $(julia --version)${NC}"
echo -e "${GREEN}✓ Flutter found: $(flutter --version | head -1)${NC}"
echo ""

# Navigate to aequchain directory
cd "$(dirname "$0")/.."

# Initialize Julia project if needed
if [ ! -d ".julia" ]; then
    echo -e "${YELLOW}🔧 Initializing Julia project...${NC}"
    julia --project=. -e 'using Pkg; Pkg.instantiate()'
fi

# Start Julia API server in background
echo -e "${YELLOW}📡 Starting Julia Testnet API server...${NC}"
julia --project=. -e '
    using Pkg
    Pkg.instantiate()
    
    # Load required packages
    using HTTP
    using JSON3
    using SHA
    using Base64
    
    # Start testnet API server
    include("files/src/network/APIServer.jl")
    using .APIServer
    
    APIServer.start_server(host="127.0.0.1", port=3000)
' &
API_PID=$!

# Give API server time to start (Fibonacci: 5 seconds)
sleep 5

# Check if API server started successfully
if ! kill -0 $API_PID 2>/dev/null; then
    echo -e "${RED}❌ Failed to start API server${NC}"
    exit 1
fi

echo -e "${GREEN}✓ API server running (PID: $API_PID)${NC}"
echo ""

# Navigate to aequchain testnet Flutter app
cd "aequchain_testnet_dapp"

# Get Flutter dependencies
echo -e "${YELLOW}🌐 Starting aequchain Testnet DApp...${NC}"
echo -e "${YELLOW}📦 Getting Flutter dependencies...${NC}"
flutter pub get

# Build and run Flutter web
echo -e "${YELLOW}🔨 Building Flutter web app...${NC}"
flutter run -d chrome --release &
FLUTTER_PID=$!

# Give Flutter time to start (Fibonacci: 8 seconds)
sleep 8

echo ""
echo "=================================================="
echo -e "${GREEN}  ✅ DEMO ENVIRONMENT RUNNING${NC}"
echo "=================================================="
echo ""
echo "📱 Flutter Web App: http://localhost:8080"
echo "📡 API Server: http://localhost:3000"
echo "🔌 WebSocket Server: ws://localhost:3001"
echo ""
echo "=================================================="
echo ""
echo "⚠️  REMEMBER: This is DEMO MODE with NO REAL VALUE"
echo ""
echo "To stop the demo:"
echo "  Press Ctrl+C or run: kill $API_PID $FLUTTER_PID"
echo ""
echo "=================================================="

# Function to cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Shutting down demo environment...${NC}"
    kill $API_PID 2>/dev/null || true
    kill $FLUTTER_PID 2>/dev/null || true
    echo -e "${GREEN}✓ Demo environment stopped${NC}"
    exit 0
}

# Trap Ctrl+C and cleanup
trap cleanup INT TERM

# Wait for processes
wait
