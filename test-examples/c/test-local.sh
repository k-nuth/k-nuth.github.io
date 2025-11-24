#!/bin/bash

set -e  # Exit on error

# Parse arguments
CLEAN=false
if [[ "$1" == "-c" ]] || [[ "$1" == "--clean" ]]; then
    CLEAN=true
fi

echo "=========================================="
echo "Knuth C API Example - Local"
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
BUILD_DIR="$SCRIPT_DIR/build"

# Setup build directory
if [ "$CLEAN" = true ]; then
    print_step "Cleaning build directory"
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"
print_success "Build directory ready: $BUILD_DIR"
echo ""

# Copy source files to build directory
print_step "Copying source files"
cp "$SCRIPT_DIR"/*.* "$BUILD_DIR/" 2>/dev/null || true
print_success "Source files copied"
echo ""

# Change to build directory
cd "$BUILD_DIR"

# =============================================================================
# TOOLING SETUP (same as HTML)
# =============================================================================
print_step "Tooling Setup"
echo ""

print_step "  pip3 install kthbuild conan --user"
pip3 install kthbuild conan --user

print_step "  conan profile detect --force"
conan profile detect --force

print_step "  conan remote add kth https://packages.kth.cash/api"
conan remote add kth https://packages.kth.cash/api 2>/dev/null || echo "  (remote already exists)"

print_step "  conan config install https://github.com/k-nuth/ci-utils/raw/master/conan/config2023.zip"
conan config install https://github.com/k-nuth/ci-utils/raw/master/conan/config2023.zip

print_success "Tooling setup completed"
echo ""

# =============================================================================
# PROJECT SETUP (files already copied)
# =============================================================================
print_step "Project Setup"
echo "  Files copied to build directory"
print_success "Project files ready"
echo ""

# =============================================================================
# BUILD (same as HTML)
# =============================================================================
print_step "Build"
echo ""

print_step "  conan install . --build=missing -s compiler.cppstd=23"
conan install . --build=missing -s compiler.cppstd=23

print_step "  cmake --preset conan-release"
cmake --preset conan-release

print_step "  cmake --build --preset conan-release"
cmake --build --preset conan-release

print_success "Build completed"
echo ""

# =============================================================================
# RUN (same as HTML)
# =============================================================================
print_step "Run"
echo ""

print_step "  ./build/Release/example"
./build/Release/example

echo ""
echo "=========================================="
print_success "Example completed successfully!"
echo "=========================================="
