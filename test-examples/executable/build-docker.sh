#!/bin/bash

set -e

echo "Building Knuth Executable Node Docker image..."
docker build --platform linux/amd64 -t kth-executable-test .
echo "✓ Docker image built successfully!"
echo ""
echo "To run the test:"
echo "  docker run --rm kth-executable-test"
