#!/bin/bash

set -e

# Get script directory and load version
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config.json"
KTH_VERSION=$(node -p "require('$CONFIG_FILE').kthVersion")

echo "Building Knuth Executable Node Docker image..."
echo "Using Knuth version: $KTH_VERSION"
docker build --platform linux/amd64 --build-arg KTH_VERSION=$KTH_VERSION -t kth-executable-test .
echo "✓ Docker image built successfully!"
echo ""
echo "To run the test:"
echo "  docker run --rm kth-executable-test"
