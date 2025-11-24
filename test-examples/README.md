# Knuth API Examples - Single Source of Truth System

All code is written **once** in HTML snippets and automatically generated into:
- Website HTML (with syntax highlighting and copy buttons)
- Project source files (example.c, conanfile.txt, CMakeLists.txt, etc.)
- Test scripts (test-docker.sh, test-local.sh)

## Directory Structure

```
test-examples/
├── scripts/                    # Generic generators (work for all languages)
│   ├── generate-all.js           # Master script - runs all generators
│   ├── generate-project-files.js # Generates source files from snippets
│   ├── generate-tests.js         # Generates test scripts
│   └── embed-snippets.js         # Generates website HTML
├── c/
│   ├── snippets/               # ← SOURCE OF TRUTH - edit only these!
│   │   ├── tooling-setup.html
│   │   ├── conanfile.html
│   │   ├── cmake.html
│   │   ├── example.html
│   │   ├── build.html
│   │   └── run.html
│   ├── Dockerfile              # Manually maintained
│   ├── example.c               # GENERATED from snippets/example.html
│   ├── conanfile.txt           # GENERATED from snippets/conanfile.html
│   ├── CMakeLists.txt          # GENERATED from snippets/cmake.html
│   ├── test-docker.sh          # GENERATED
│   └── test-local.sh           # GENERATED
├── cpp/
│   └── snippets/               # C++ snippets here
└── ...
```

## The Golden Rule

**NEVER edit generated files directly!**

All edits must be made in `{language}/snippets/*.html` files.

## Workflow

### 1. Edit Snippets (Source of Truth)

All code lives in `{language}/snippets/*.html` files with syntax highlighting:

```html
<div><span class="text-green-400">$ </span><span class="text-cyan-300">pip3 install</span> <span class="text-orange-300">kthbuild conan</span> <span class="text-purple-300">--user</span></div>
```

### 2. Generate Everything

**Recommended: Generate all files at once**
```bash
cd test-examples
node scripts/generate-all.js         # All languages
node scripts/generate-all.js c       # Just C
```

**Or run generators individually:**
```bash
node scripts/generate-project-files.js c    # example.c, conanfile.txt, etc.
node scripts/generate-tests.js c            # test-*.sh
node scripts/embed-snippets.js c            # index-modern.html
```

### 3. Commit Changes

```bash
git add snippets/ scripts/ *.c *.txt *.sh index-modern.html*
git commit -m "Update C example"
```

## What Gets Generated

From snippets, we generate:

| Snippet File | Generates | Description |
|-------------|-----------|-------------|
| `example.html` | `example.{c,cpp,cs,py,js}` | Source code file |
| `conanfile.html` | `conanfile.txt` | Conan dependencies |
| `cmake.html` | `CMakeLists.txt` | CMake config |
| `tooling-setup.html` | Part of test scripts | Setup commands |
| `build.html` | Part of test scripts | Build commands |
| `run.html` | Part of test scripts | Run command |
| All snippets | `../../index-modern.html` | Website with syntax highlighting |

## How It Works

### 1. generate-project-files.js
- Reads `{lang}/snippets/*.html`
- Removes HTML tags and styling
- Writes plain text to project files
- Maps: `example.html` → `example.c`, `conanfile.html` → `conanfile.txt`, etc.

### 2. generate-tests.js
- Reads `tooling-setup.html`, `build.html`, `run.html`
- Extracts commands
- Generates bash scripts with colored output and error handling
- Creates `test-docker.sh` and `test-local.sh`

### 3. embed-snippets.js
- Reads `../../index-modern.html.tpl` (template with placeholders)
- For each snippet:
  - Keeps HTML with syntax highlighting for display
  - Extracts plain text for clipboard
  - Builds complete block with copy button
  - Replaces `<!-- SNIPPET:{lang}-{name} -->` placeholder
- Writes `../../index-modern.html`

## Adding a New Language

Example: Adding Python support

### 1. Create directory and snippets
```bash
mkdir -p test-examples/python/snippets
```

### 2. Create snippet files

Create these files in `python/snippets/`:

- **tooling-setup.html** - Installation commands
  ```html
  <div><span class="text-green-400">$ </span><span class="text-cyan-300">pip install</span> <span class="text-orange-300">kth</span></div>
  ```

- **example.html** - Python code with syntax highlighting
  ```html
  <div><span class="text-purple-300">import</span> <span class="text-blue-300">kth</span></div>
  <div><span class="text-purple-300">import</span> <span class="text-blue-300">asyncio</span></div>
  ...
  ```

- **build.html** - Build commands (if any, can be empty for Python)
- **run.html** - Run command
  ```html
  <div><span class="text-green-400">$ </span><span class="text-cyan-300">python</span> <span class="text-orange-300">example.py</span></div>
  ```

### 3. Add placeholders to website template

Edit `index-modern.html.tpl` and add:
```html
<!-- Tooling Setup -->
<div class="relative group">
  <!-- SNIPPET:python-tooling-setup -->
</div>

<!-- Code Example -->
<div class="relative group">
  <!-- SNIPPET:python-example -->
</div>

<!-- Build (if applicable) -->
<div class="relative group">
  <!-- SNIPPET:python-build -->
</div>

<!-- Run -->
<div class="relative group">
  <!-- SNIPPET:python-run -->
</div>
```

### 4. Generate everything
```bash
cd test-examples
node scripts/generate-all.js python
```

This creates:
- `python/example.py`
- `python/test-docker.sh`
- `python/test-local.sh`
- Updates `../../index-modern.html`

### 5. Create Dockerfile (manually)
```dockerfile
FROM python:3.11
WORKDIR /workspace
COPY example.py test-docker.sh ./
RUN chmod +x test-docker.sh
CMD ["/bin/bash"]
```

Done! 🎉

## Files to Version Control

**✅ DO commit (source of truth):**
- `scripts/*.js` - Generators
- `{lang}/snippets/*.html` - All snippets
- `../../index-modern.html.tpl` - Template

**✅ DO commit (generated, for convenience):**
- `{lang}/*.{c,cpp,txt}` - Generated project files
- `{lang}/test-*.sh` - Generated test scripts
- `../../index-modern.html` - Generated website

**⚠️ DO NOT edit directly:**
- Any file generated by scripts
- Always edit snippets and regenerate

## Testing

```bash
# Generate everything for C
cd test-examples
node scripts/generate-all.js c

# Test locally
cd c
./test-local.sh

# Test with Docker
cd c
docker build -t kth-c-example .
docker run -it kth-c-example ./test-docker.sh
```

## Benefits

1. **Single Source of Truth**: Code written once in snippets
2. **Always in Sync**: Website, tests, and examples never diverge
3. **Easy Updates**: Change snippet → regenerate → done
4. **Generic System**: Works for any language (C, C++, C#, Python, etc.)
5. **Syntax Highlighting**: Beautiful code display on website
6. **Copy Button**: Users can easily copy code
7. **Automated Tests**: Generated test scripts ensure examples work
