#!/bin/bash

set -e  # Exit on error

echo "=========================================="
echo "Building Knuth C++ Example"
echo "=========================================="
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_DIR="$SCRIPT_DIR/examples/example-cpp"

cd "$EXAMPLE_DIR"

# Clean previous build
rm -rf build

# Install dependencies with Conan
echo ">>> Installing dependencies with Conan..."
conan install . -of build --build=missing

# Configure with CMake using preset
echo ""
echo ">>> Configuring with CMake..."
cmake --preset conan-release -DCMAKE_VERBOSE_MAKEFILE=ON

# Build
echo ""
echo ">>> Building..."
cmake --build --preset conan-release --verbose

echo ""
echo "=========================================="
echo "✓ Build completed successfully!"
echo "=========================================="
echo ""
echo "To run the example:"
echo "  $EXAMPLE_DIR/build/build/Release/example-cpp"
