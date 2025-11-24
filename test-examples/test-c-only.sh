#!/bin/bash

set -e  # Exit on error

echo "=========================================="
echo "Knuth C API Installation Test"
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

# Step 0: Update pip
print_step "Step 0: Updating pip"
pip3 install --upgrade pip --user --break-system-packages
export PATH="$PATH:$HOME/.local/bin"
pip3 --version
print_success "pip updated"

# Step 1: Install kthbuild first (with all its dependencies including microarch)
print_step "Step 1: Installing kthbuild with dependencies"
pip3 install kthbuild --user --upgrade --break-system-packages
print_success "kthbuild installed"

# Step 2: Now upgrade Conan to latest version (kthbuild may have installed an older one)
print_step "Step 2: Upgrading Conan to latest version"
pip3 install conan --user --upgrade --break-system-packages
conan --version
print_success "Conan upgraded to latest"

# Step 3: Configure Conan profile
print_step "Step 3: Configuring Conan profile"
conan profile detect --force

# Update profile to use C++23
PROFILE_PATH="$HOME/.conan2/profiles/default"
if [ -f "$PROFILE_PATH" ]; then
    sed -i 's/compiler.cppstd=gnu17/compiler.cppstd=23/' "$PROFILE_PATH"
    sed -i 's/compiler.cppstd=gnu14/compiler.cppstd=23/' "$PROFILE_PATH"
    print_success "Profile updated to use C++23"
fi

# Step 4: Add Knuth remote and config
print_step "Step 4: Configuring Knuth remote"
conan remote add kth https://packages.kth.cash/api || echo "Remote 'kth' already exists"
conan config install https://github.com/k-nuth/ci-utils/raw/master/conan/config2023.zip
print_success "Conan configured"

# Step 5: Print complete system information
print_step "Step 5: System Information Snapshot"
echo ""
echo "=== Operating System ==="
uname -a
cat /etc/os-release 2>/dev/null || echo "OS release info not available"
echo ""

echo "=== CPU Architecture ==="
lscpu | grep -E "Architecture|CPU op-mode|Byte Order|CPU\(s\):" || echo "CPU info not available"
echo ""

echo "=== Compiler Versions ==="
gcc --version
echo ""
g++ --version
echo ""

echo "=== Build Tools ==="
cmake --version
echo ""
make --version | head -1
echo ""

echo "=== Python Environment ==="
python3 --version
pip3 --version
echo ""

echo "=== Conan Configuration ==="
conan --version
echo ""
echo "Conan profile:"
conan profile show --profile default
echo ""
echo "Conan remotes:"
conan remote list
echo ""

echo "=== Python Packages (Conan related) ==="
pip3 list | grep -i conan || echo "No Conan packages found"
pip3 list | grep -i kth || echo "No kth packages found"
pip3 list | grep -i microarch || echo "No microarch package found"
echo ""

echo "=== Conan Cache Status ==="
ls -la ~/.conan2/ 2>/dev/null || echo "Conan cache not initialized"
echo ""

print_success "System information collected"
echo ""

# Step 6: Diagnostic - Check what binaries are available
print_step "Step 6: Conan Binary Diagnostics"
cd /workspace/examples/example-c

echo ""
echo "=== 0. Checking configured remotes ==="
conan remote list
echo ""

echo "=== 1. Listing all available kth/0.73.0 binaries in remote ==="
conan list "kth/0.73.0:*" -r=kth
echo ""

echo "=== 2. Explaining missing binaries ==="
conan graph explain .
echo ""

print_success "Diagnostics completed"
echo ""
echo "=========================================="
echo "Review the output above to understand why binaries are missing"
echo "=========================================="
