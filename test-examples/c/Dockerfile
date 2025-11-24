# Dockerfile for Knuth C API Example
# Using official GCC 15 image, forcing linux/amd64 platform
FROM --platform=linux/amd64 gcc:15

# Note: We force linux/amd64 because:
# - Knuth prebuilt packages are for x86_64 with GCC 15
# - Without --platform, Docker uses native ARM64 on Mac M1/M2/M3/M4
# - This causes Conan to build from source (slow) and some packages fail on ARM

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install system prerequisites (matches HTML Prerequisites section)
RUN apt-get update && apt-get install -y \
    cmake \
    python3 \
    python3-pip \
    python3-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /workspace

# Copy all example files
COPY example.c CMakeLists.txt conanfile.txt test-docker.sh ./

# Make test script executable
RUN chmod +x test-docker.sh

CMD ["/bin/bash"]
