# Knuth C API Example

This example is part of the **Single Source of Truth** system.

## Quick Start

**Edit snippets, then regenerate:**

```bash
cd test-examples
node scripts/generate-all.js c
```

## Files

**Source of Truth (edit these):**
- `snippets/*.html` - All code snippets with syntax highlighting

**Generated (do not edit):**
- `example.c` - From `snippets/example.html`
- `conanfile.txt` - From `snippets/conanfile.html`
- `CMakeLists.txt` - From `snippets/cmake.html`
- `test-docker.sh` - From multiple snippets
- `test-local.sh` - From multiple snippets

**Manually maintained:**
- `Dockerfile` - Docker configuration

## Running

**Local:**
```bash
./test-local.sh
```

**Docker:**
```bash
docker build -t kth-c-example .
docker run -it kth-c-example ./test-docker.sh
```

See [../README.md](../README.md) for full documentation.
