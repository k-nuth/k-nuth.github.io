#!/bin/bash

set -e  # Exit on error

echo "=========================================="
echo "Knuth Local Installation Test"
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

# Create test directory
print_step "Creating test directory"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"
print_success "Test directory: $TEST_DIR"

# Check if Conan is installed
print_step "Checking Conan installation"
if ! command -v conan &> /dev/null; then
    print_error "Conan is not installed"
    echo "Please install Conan first:"
    echo "  pip3 install conan --user --upgrade"
    exit 1
fi

conan --version
print_success "Conan is installed"

# Check Conan profile
print_step "Checking Conan profile"
if ! conan profile show --profile default &> /dev/null; then
    echo "Creating default profile..."
    # conan profile detect
fi

# Show profile
echo "Current profile:"
conan profile show --profile default

# Check if C++23 is configured
PROFILE_PATH="$HOME/.conan2/profiles/default"
if grep -q "compiler.cppstd=23" "$PROFILE_PATH"; then
    print_success "C++23 already configured"
else
    echo "Current cppstd: $(grep compiler.cppstd $PROFILE_PATH)"
    print_error "C++23 not configured in profile"
    echo ""
    echo "To fix this, run:"
    echo "  sed -i.bak 's/compiler.cppstd=gnu17/compiler.cppstd=23/' $PROFILE_PATH"
    echo ""
    read -p "Do you want to update it now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sed -i.bak 's/compiler.cppstd=gnu17/compiler.cppstd=23/' "$PROFILE_PATH"
        print_success "Profile updated to C++23"
    else
        print_error "Exiting - C++23 is required for Knuth"
        exit 1
    fi
fi

# Install Knuth with deployer
print_step "Installing Knuth package with deployer"
echo "This will download and deploy Knuth to: $TEST_DIR/kth-local"
echo ""

conan install --requires=kth/0.72.0 --update --build=missing --deployer=direct_deploy --deployer-folder=kth-local

print_success "Knuth package installed and deployed"

# Show deployed structure
echo ""
print_step "Deployed files structure:"
ls -la kth-local/

echo ""
echo "Contents of kth-local/direct_deploy/:"
ls -la kth-local/direct_deploy/

echo ""
echo "=========================================="
print_success "Local installation completed!"
echo "=========================================="
echo ""

echo "Next steps:"
echo "1. Examine the structure in: $TEST_DIR/kth-local"
echo "2. Find headers and libraries"
echo "3. Create compilation script for example.c"
echo ""
echo "To explore:"
echo "  cd $TEST_DIR"
echo "  find kth-local -name '*.h' | head -20"
echo "  find kth-local -name '*.a' -o -name '*.so' | head -20"
