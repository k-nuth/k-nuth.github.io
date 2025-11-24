# Knuth Installation Testing Environment

This directory contains Docker-based testing infrastructure to verify that all installation instructions shown on the Knuth website work correctly.

## Overview

The testing environment uses Docker to create a clean Ubuntu 24.04 environment (with GCC 13+ for C++23 support) and follows the exact installation steps documented on the website.

Currently testing: **C API** (other languages will be added later)

**Note:** Ubuntu 24.04 is required because Knuth requires C++23, which needs GCC 13 or higher.

## Structure

```
test-examples/
├── Dockerfile          # Docker image definition (Ubuntu 24.04 with GCC 13+)
├── run-tests.sh        # Main script to build Docker and run tests
├── test-c-only.sh      # Script that tests C API installation (runs inside Docker)
├── test-local.sh       # Script for local testing (uses local Conan cache)
├── compile-example.sh  # Legacy: Direct gcc compilation (deprecated)
├── compile-cmake.sh    # Recommended: CMake + Conan build
├── examples/           # Example code
│   ├── example.c       # C example that tests Knuth C API
│   ├── conanfile.txt   # Conan dependencies declaration
│   └── CMakeLists.txt  # CMake build definition
└── README.md           # This file
```

## Prerequisites

**For Docker testing:**
- Docker installed and running
- Internet connection (for downloading packages)

**For local testing:**
- Conan installed (`pip3 install conan --user --upgrade`)
- CMake 3.15+ installed
- C compiler with C++23 support (GCC 13+ or Clang 16+)
- Internet connection (for downloading packages)

## Usage

### Local Testing (Recommended for Development)

Each example is in its own directory with its own `conanfile.txt` and `CMakeLists.txt`.

**Compile and run the C API example:**

```bash
./compile-c.sh
./examples/example-c/build/build/Release/example
```

**Compile and run the C++ API example:**

```bash
./compile-cpp.sh
./examples/example-cpp/build/build/Release/example-cpp
```

Each example uses:
- `conanfile.txt` to declare the Knuth dependency
- `CMakeLists.txt` to define the build
- Conan generators (CMakeDeps + CMakeToolchain) to handle all linking automatically

**This is the recommended approach** - Conan and CMake handle all transitive dependencies automatically.

**Optional:** To experiment with Conan deployers and see how dependencies are laid out:
```bash
./test-local.sh  # Installs with direct_deploy to local-test/kth-local/
```

### Run Docker Tests

To run all installation tests in Docker:

```bash
./run-tests.sh
```

This will:
1. Build a Docker image with Ubuntu 24.04 (GCC 13+)
2. Verify GCC version supports C++23
3. Install all prerequisites (Python, pip, Conan, kthbuild)
4. Configure Conan with Knuth repositories and C++23 profile
5. Install the kth/0.72.0 package
6. Report results

### Manual Exploration

If you want to manually explore the environment and test specific commands:

```bash
# Build the image
docker build -t knuth-test .

# Run interactively
docker run -it knuth-test /bin/bash

# Inside the container, you can run:
/workspace/test-all.sh          # Run all tests
# Or manually test specific installations
```

### After Tests Complete

If tests pass, you can re-enter the container to inspect or continue testing:

```bash
docker start -i knuth-test-container
```

### Cleanup

**Local test cleanup:**
```bash
rm -rf test-examples/local-test/
```

**Docker cleanup:**
```bash
docker rm knuth-test-container
docker rmi knuth-test
```

## What's Tested

### C API Installation (Current)
- ✅ Verification of GCC 13+ (C++23 support)
- ✅ Installation of Python and pip
- ✅ Installation of Conan package manager
- ✅ Installation of kthbuild helper
- ✅ Configuration of Conan with Knuth remote repository
- ✅ Installation of Conan config from GitHub
- ✅ Configuration of Conan profile for C++23 (compiler.cppstd=23)
- ✅ Installation of kth/0.72.0 package via Conan
- ✅ Verification of package installation

### Future Tests
- C++ API (node package)
- Python API (kth package)
- JavaScript/TypeScript API
- C# API
- WebAssembly

## Troubleshooting

### Docker not found
Make sure Docker is installed and running:
```bash
docker --version
```

### Permission denied
Make sure scripts are executable:
```bash
chmod +x run-tests.sh test-all.sh
```

### Tests fail
Check the output for specific error messages. Common issues:
- Network connectivity problems
- Package repository issues
- Insufficient disk space

## Adding New Tests

To add tests for additional languages:

1. Create a new test script (e.g., `test-cpp.sh`, `test-python.sh`)
2. Update the Dockerfile to copy the new script
3. Update `run-tests.sh` to use the new script
4. Add example code in `examples/` directory if needed

## Notes

- The tests verify package installation and basic API availability
- Full node execution is not tested (requires blockchain sync)
- Tests are designed to match exactly what's shown on the website
- Tests run on Ubuntu 22.04 LTS (commonly used in production)
