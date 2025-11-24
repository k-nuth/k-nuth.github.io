# Dockerfile for testing Knuth C API installation
# Using official GCC 15 image, forcing linux/amd64 platform
FROM --platform=linux/amd64 gcc:15

# Note: We force linux/amd64 because:
# - Knuth prebuilt packages are for x86_64 with GCC 15
# - Without --platform, Docker uses native ARM64 on Mac M1/M2/M3/M4
# - This causes Conan to build from source (slow) and some packages fail on ARM

# Previous images tested:
# - ubuntu:24.04 (works but has GCC 13, slower builds)
# - kthnode/gcc15-ubuntu20.04 (had Conan database issues)

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install additional dependencies (gcc image already has build-essential)
RUN apt-get update && apt-get install -y \
    cmake \
    python3 \
    python3-pip \
    python3-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy examples and test script
COPY examples/ /workspace/examples/
COPY test-c-only.sh /workspace/

# Make test script executable
RUN chmod +x /workspace/test-c-only.sh

CMD ["/bin/bash"]
