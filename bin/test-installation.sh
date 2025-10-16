#!/bin/bash
# Test script to verify aequchain testnet demo installation
# Run this after cloning and installing dependencies

set -e  # Exit on error

echo "========================================"
echo "  aequchain Testnet Demo - Test Suite"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

test_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo "1. Checking system requirements..."
echo "-----------------------------------"

# Check Julia
if command -v julia &> /dev/null; then
    JULIA_VERSION=$(julia --version | grep -oP '\d+\.\d+' | head -1)
    if (( $(echo "$JULIA_VERSION >= 1.8" | bc -l) )); then
        test_pass "Julia $JULIA_VERSION found"
    else
        test_fail "Julia version $JULIA_VERSION is < 1.8"
    fi
else
    test_fail "Julia not found"
fi

# Check Flutter
if command -v flutter &> /dev/null; then
    FLUTTER_VERSION=$(flutter --version 2>&1 | grep "Flutter" | grep -oP '\d+\.\d+\.\d+' | head -1)
    test_pass "Flutter $FLUTTER_VERSION found"
else
    test_fail "Flutter not found"
fi

# Check curl
if command -v curl &> /dev/null; then
    test_pass "curl found"
else
    test_warn "curl not found (optional for testing)"
fi

# Check jq
if command -v jq &> /dev/null; then
    test_pass "jq found"
else
    test_warn "jq not found (optional for pretty JSON)"
fi

echo ""
echo "2. Checking port availability..."
echo "-----------------------------------"

# Check port 3000
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    test_warn "Port 3000 is in use (may need to kill process)"
else
    test_pass "Port 3000 is available"
fi

# Check port 43255
if lsof -Pi :43255 -sTCP:LISTEN -t >/dev/null 2>&1; then
    test_warn "Port 43255 is in use (may need to kill process)"
else
    test_pass "Port 43255 is available"
fi

echo ""
echo "3. Checking directory structure..."
echo "-----------------------------------"

# Check for required files
if [ -f "start-api.jl" ]; then
    test_pass "start-api.jl found"
else
    test_fail "start-api.jl not found"
fi

if [ -f "Project.toml" ]; then
    test_pass "Project.toml found"
else
    test_fail "Project.toml not found"
fi

if [ -d "aequchain_testnet_dapp" ]; then
    test_pass "aequchain_testnet_dapp/ directory found"
else
    test_fail "aequchain_testnet_dapp/ directory not found"
fi

if [ -f "aequchain_testnet_dapp/pubspec.yaml" ]; then
    test_pass "Flutter pubspec.yaml found"
else
    test_fail "Flutter pubspec.yaml not found"
fi

if [ -f "bin/start-demo.sh" ]; then
    test_pass "bin/start-demo.sh found"
    if [ -x "bin/start-demo.sh" ]; then
        test_pass "bin/start-demo.sh is executable"
    else
        test_warn "bin/start-demo.sh not executable (run: chmod +x bin/start-demo.sh)"
    fi
else
    test_fail "bin/start-demo.sh not found"
fi

echo ""
echo "4. Checking Julia dependencies..."
echo "-----------------------------------"

if [ -f "Manifest.toml" ]; then
    test_pass "Manifest.toml exists (packages installed)"
else
    test_warn "Manifest.toml not found (run: julia --project=. -e 'using Pkg; Pkg.instantiate()')"
fi

# Try to load the main module
if julia --project=. -e 'using AequChain' 2>&1 | grep -q "ERROR"; then
    test_fail "Cannot load AequChain module"
    echo "    Run: julia --project=. -e 'using Pkg; Pkg.instantiate()'"
else
    test_pass "AequChain module loads successfully"
fi

echo ""
echo "5. Checking Flutter dependencies..."
echo "-----------------------------------"

if [ -f "aequchain_testnet_dapp/pubspec.lock" ]; then
    test_pass "pubspec.lock exists (Flutter packages installed)"
else
    test_warn "pubspec.lock not found (run: cd aequchain_testnet_dapp && flutter pub get)"
fi

echo ""
echo "6. Starting API server test..."
echo "-----------------------------------"

# Kill any existing API server
pkill -f "julia.*start-api" 2>/dev/null || true
sleep 2

# Start API server in background
echo "Starting API server..."
julia --project=. start-api.jl > /tmp/test-api.log 2>&1 &
API_PID=$!
sleep 6

# Test if server is running
if ps -p $API_PID > /dev/null 2>&1; then
    test_pass "API server started (PID: $API_PID)"
else
    test_fail "API server failed to start"
    echo "Check logs: tail /tmp/test-api.log"
fi

# Test root endpoint
if curl -s http://localhost:3000/ | grep -q "aequchain"; then
    test_pass "API root endpoint responds"
else
    test_fail "API root endpoint not responding"
fi

# Test account creation
if curl -s -X POST http://localhost:3000/api/testnet/account/create \
    -H "Content-Type: application/json" \
    -d '{"account_id":"test_alice"}' | grep -q "success"; then
    test_pass "Account creation works"
else
    test_fail "Account creation failed"
fi

# Test accounts listing
if curl -s http://localhost:3000/api/testnet/accounts | grep -q "test_alice"; then
    test_pass "Accounts listing works"
else
    test_fail "Accounts listing failed"
fi

# Test transaction
curl -s -X POST http://localhost:3000/api/testnet/account/create \
    -H "Content-Type: application/json" \
    -d '{"account_id":"test_bob"}' > /dev/null

if curl -s -X POST http://localhost:3000/api/testnet/transaction/send \
    -H "Content-Type: application/json" \
    -d '{"from":"test_alice","to":"test_bob","amount":100}' | grep -q "success"; then
    test_pass "Transaction sending works"
else
    test_fail "Transaction sending failed"
fi

# Test stats
if curl -s http://localhost:3000/api/testnet/stats | grep -q "total_accounts"; then
    test_pass "Statistics endpoint works"
else
    test_fail "Statistics endpoint failed"
fi

echo ""
echo "7. Cleaning up..."
echo "-----------------------------------"

# Stop API server
kill $API_PID 2>/dev/null || true
sleep 1
test_pass "API server stopped"

echo ""
echo "========================================"
echo "           Test Results"
echo "========================================"
echo -e "${GREEN}Passed:${NC} $TESTS_PASSED"
echo -e "${RED}Failed:${NC} $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "You're ready to run the demo:"
    echo "  ./bin/start-demo.sh"
    echo ""
    echo "Or start components separately:"
    echo "  API:     julia --project=. start-api.jl"
    echo "  Flutter: cd aequchain_testnet_dapp && flutter run -d web-server --web-port 43255"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    echo "Please fix the issues above and try again."
    echo "See REQUIREMENTS.md for detailed setup instructions."
    exit 1
fi
