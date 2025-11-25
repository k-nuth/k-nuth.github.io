#!/bin/bash

set -e

# Get script directory and load version
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config.json"
KNUTH_PKG_VERSION=$(node -p "require('$CONFIG_FILE').kthVersion")

echo "Building Knuth Executable Node Docker image..."
echo "Using Knuth version: $KNUTH_PKG_VERSION"
docker build --platform linux/amd64 --build-arg KNUTH_PKG_VERSION=$KNUTH_PKG_VERSION -t kth-executable-test .
echo "✓ Docker image built successfully!"
echo ""
echo "To run the test:"
echo "  docker run --rm kth-executable-test"
