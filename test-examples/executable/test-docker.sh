#!/bin/bash

set -e  # Exit on error

echo "=========================================="
echo "Knuth Executable Node - Docker Test"
echo "=========================================="
echo ""

# Load version from config.json (in /workspace/config.json in Docker)
CONFIG_FILE="/workspace/config.json"
if [ -f "$CONFIG_FILE" ]; then
    KTH_VERSION=$(node -p "require('$CONFIG_FILE').kthVersion")
else
    # Fallback if running locally
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    CONFIG_FILE="$SCRIPT_DIR/../config.json"
    KTH_VERSION=$(node -p "require('$CONFIG_FILE').kthVersion")
fi
echo "Using Knuth version: $KTH_VERSION"
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

# =============================================================================
# TOOLING SETUP
# =============================================================================
print_step "Tooling Setup"
echo ""

# Update pip first (Docker prerequisite - installs to user directory to avoid system conflicts)
print_step "  Updating pip (prerequisite)"
pip3 install --upgrade pip --user --break-system-packages
export PATH="$PATH:$HOME/.local/bin"

# Steps from HTML
print_step "  pip3 install kthbuild conan --user"
pip3 install kthbuild conan --user --break-system-packages

print_step "  conan profile detect --force"
conan profile detect --force

print_step "  conan remote add kth https://packages.kth.cash/api"
conan remote add kth https://packages.kth.cash/api || echo "  (remote already exists)"

print_step "  conan config install https://github.com/k-nuth/ci-utils/raw/master/conan/config2023.zip"
conan config install https://github.com/k-nuth/ci-utils/raw/master/conan/config2023.zip

print_success "Tooling setup completed"
echo ""

# =============================================================================
# INSTALL
# =============================================================================
print_step "Install"
echo ""

print_step "  conan install --requires=kth/$KTH_VERSION --update --deployer=direct_deploy -s compiler.cppstd=23"
conan install --requires=kth/$KTH_VERSION --update --deployer=direct_deploy -s compiler.cppstd=23

print_success "Install completed"
echo ""

# =============================================================================
# RUN (with timeout)
# =============================================================================
print_step "Run (will stop after 30 seconds)"
echo ""

print_step "  ./kth/bin/kth"
timeout 30 ./kth/bin/kth || true

echo ""
echo "=========================================="
print_success "Test completed successfully!"
echo "=========================================="
