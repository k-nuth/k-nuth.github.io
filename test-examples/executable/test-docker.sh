#!/bin/bash

set -e  # Exit on error

echo "=========================================="
echo "Knuth EXECUTABLE API Example - Docker"
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

# =============================================================================
# TOOLING SETUP (same as HTML)
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
# PROJECT SETUP (files already exist in /workspace/)
# =============================================================================
print_step "Project Setup"
echo "  Files in /workspace/"
print_success "Project files ready"
echo ""

# =============================================================================
# BUILD (same as HTML)
# =============================================================================
print_step "Build"
echo ""

print_step "  conan install --requires=kth/0.73.0 --build=missing --update --deployer=direct_deploy -s compiler.cppstd=23"
conan install --requires=kth/0.73.0 --build=missing --update --deployer=direct_deploy -s compiler.cppstd=23

print_success "Build completed"
echo ""

# =============================================================================
# RUN (same as HTML)
# =============================================================================
print_step "Run"
echo ""

print_step "  $(find . -name kth -type f -executable | head -1)"
exec $(find . -name kth -type f -executable | head -1)
