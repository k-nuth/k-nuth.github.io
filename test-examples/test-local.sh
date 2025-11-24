#!/bin/bash

set -e  # Exit on error

# Parse arguments
CLEAN=false
if [[ "$1" == "-c" ]] || [[ "$1" == "--clean" ]]; then
    CLEAN=true
fi

echo "=========================================="
echo "Knuth C API Local Test"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "${YELLOW}>>> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EXAMPLE_SRC="$SCRIPT_DIR/examples/example-c"
BUILD_ROOT="$SCRIPT_DIR/build-local"
BUILD_DIR="$BUILD_ROOT/example-c"

# Clean and create build directory
if [ "$CLEAN" = true ]; then
    print_step "Cleaning and setting up isolated build directory"
    rm -rf "$BUILD_ROOT"
    mkdir -p "$BUILD_DIR"
    print_success "Build directory cleaned: $BUILD_DIR"
else
    print_step "Setting up isolated build directory (keeping existing files)"
    mkdir -p "$BUILD_DIR"
    print_success "Build directory ready: $BUILD_DIR"
fi

# Copy source files to build directory
print_step "Copying source files"
cp "$EXAMPLE_SRC/example.c" "$BUILD_DIR/"
cp "$EXAMPLE_SRC/CMakeLists.txt" "$BUILD_DIR/"
cp "$EXAMPLE_SRC/conanfile.txt" "$BUILD_DIR/"
print_success "Source files copied"

# Build in isolated directory
cd "$BUILD_DIR"

print_step "Installing dependencies with Conan"
conan install . --build=missing

print_step "Building with CMake"
cmake --preset conan-release
cmake --build --preset conan-release

print_success "Build completed"

# Run example
print_step "Running C example"
echo ""
./build/Release/example

echo ""
echo "=========================================="
print_success "Test completed!"
echo "=========================================="
