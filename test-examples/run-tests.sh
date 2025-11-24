#!/bin/bash

# Script to build and run Docker container for testing Knuth installation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="knuth-test"
CONTAINER_NAME="knuth-test-container"

echo "=========================================="
echo "Knuth Docker Test Environment"
echo "=========================================="
echo ""

# Function to print colored output
print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[1;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Clean up old container if exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    print_info "Removing old container..."
    docker rm -f ${CONTAINER_NAME} > /dev/null 2>&1
fi

# Build Docker image
print_info "Building Docker image..."
cd "$SCRIPT_DIR"
docker build -t ${IMAGE_NAME} .
print_success "Docker image built successfully"

# Run tests
print_info "Running C API installation test in Docker container..."
echo ""

docker run --name ${CONTAINER_NAME} -it ${IMAGE_NAME} /workspace/test-c-only.sh

# Check exit code
if [ $? -eq 0 ]; then
    print_success "All tests passed!"
    echo ""
    print_info "To manually explore the container, run:"
    echo "  docker start -i ${CONTAINER_NAME}"
else
    print_error "Tests failed!"
    exit 1
fi

echo ""
print_info "To clean up, run:"
echo "  docker rm ${CONTAINER_NAME}"
echo "  docker rmi ${IMAGE_NAME}"
