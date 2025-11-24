#!/bin/bash

set -e  # Exit on error

echo "=========================================="
echo "Compiling Knuth C Example"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${YELLOW}>>> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/local-test"
KTH_DIR="$TEST_DIR/kth-local/direct_deploy/kth"

# Check if Knuth is deployed
if [ ! -d "$KTH_DIR" ]; then
    print_error "Knuth not found at: $KTH_DIR"
    echo "Please run ./test-local.sh first"
    exit 1
fi

print_success "Found Knuth at: $KTH_DIR"

# Paths
INCLUDE_DIR="$KTH_DIR/include"
LIB_DIR="$KTH_DIR/lib"
EXAMPLE_C="$SCRIPT_DIR/examples/example.c"
OUTPUT_BIN="$TEST_DIR/example"

# Verify paths
print_step "Verifying paths"
echo "Include dir: $INCLUDE_DIR"
echo "Lib dir: $LIB_DIR"
echo "Example: $EXAMPLE_C"
echo "Output: $OUTPUT_BIN"

if [ ! -f "$EXAMPLE_C" ]; then
    print_error "Example file not found: $EXAMPLE_C"
    exit 1
fi

if [ ! -f "$INCLUDE_DIR/kth/capi.h" ]; then
    print_error "Header capi.h not found"
    exit 1
fi

if [ ! -f "$LIB_DIR/libc-api.a" ]; then
    print_error "Library libc-api.a not found"
    exit 1
fi

print_success "All paths verified"

# Compile
print_step "Compiling C example"
echo ""
echo "Compilation command:"
echo "gcc -std=c11 \\"
echo "    -I$INCLUDE_DIR \\"
echo "    -L$LIB_DIR \\"
echo "    -o $OUTPUT_BIN \\"
echo "    $EXAMPLE_C \\"
echo "    -lc-api -lnode -lnetwork -ldatabase -lblockchain -lconsensus -ldomain -linfrastructure -lsecp256k1 \\"
echo "    -lstdc++ -lpthread -ldl -lm"
echo ""

gcc -std=c11 \
    -I"$INCLUDE_DIR" \
    -L"$LIB_DIR" \
    -o "$OUTPUT_BIN" \
    "$EXAMPLE_C" \
    -lc-api -lnode -lnetwork -ldatabase -lblockchain -lconsensus -ldomain -linfrastructure -lsecp256k1 \
    -lstdc++ -lpthread -ldl -lm

print_success "Compilation successful!"

# Show binary info
echo ""
print_step "Binary info"
ls -lh "$OUTPUT_BIN"
file "$OUTPUT_BIN"

echo ""
echo "=========================================="
print_success "Compilation completed!"
echo "=========================================="
echo ""

echo "To run the example:"
echo "  cd $TEST_DIR"
echo "  ./example"
echo ""
echo "Or simply run:"
echo "  $OUTPUT_BIN"
