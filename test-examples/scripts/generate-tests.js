#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Paths
const TEST_EXAMPLES_DIR = path.join(__dirname, '..');
const CONFIG_PATH = path.join(TEST_EXAMPLES_DIR, 'config.json');

// Load configuration
const config = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));

/**
 * Extract plain text from HTML snippet
 */
function extractPlainText(html) {
  const lines = html
    .trim()
    .replace(/<div>/g, '')
    .replace(/<\/div>/g, '')
    .replace(/<span[^>]*>/g, '')
    .replace(/<\/span>/g, '')
    .replace(/&nbsp;/g, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .split('\n')
    .map(line => line.replace(/^\$ /, '')); // Remove shell prompt

  // Remove only trailing empty lines, preserve blank lines in the middle
  while (lines.length > 0 && lines[lines.length - 1].trim() === '') {
    lines.pop();
  }

  let result = lines.join('\n');

  // Replace KNUTH_PKG_VERSION placeholder with actual version
  result = result.replace(/KNUTH_PKG_VERSION/g, config.kthVersion);

  return result;
}

/**
 * Read and extract commands from a snippet file
 * Returns empty array if snippet doesn't exist (for optional snippets)
 */
function getCommands(snippetsDir, snippetName) {
  const snippetPath = path.join(snippetsDir, `${snippetName}.html`);
  if (!fs.existsSync(snippetPath)) {
    return [];
  }
  const html = fs.readFileSync(snippetPath, 'utf8');
  return extractPlainText(html).split('\n').filter(line => line.trim());
}

/**
 * Generate test-docker.sh for a language
 */
function generateDockerTest(lang, snippetsDir) {
  const toolingCommands = getCommands(snippetsDir, 'tooling-setup');
  const buildCommands = getCommands(snippetsDir, 'build');
  const runCommands = getCommands(snippetsDir, 'run');
  const runCommand = runCommands[0]; // Keep for compatibility

  const langUpper = lang.toUpperCase();

  return `#!/bin/bash

set -e  # Exit on error

echo "=========================================="
echo "Knuth ${langUpper} API Example - Docker"
echo "=========================================="
echo ""

# Colors for output
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m'

print_step() {
    echo -e "\${YELLOW}>>> $1\${NC}"
}

print_success() {
    echo -e "\${GREEN}✓ $1\${NC}"
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
${toolingCommands.map(cmd => `print_step "  ${cmd}"\n${cmd}${cmd.includes('conan remote add') ? ' || echo "  (remote already exists)"' : cmd.includes('pip3 install') ? ' --break-system-packages' : ''}`).join('\n\n')}

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

${buildCommands.map(cmd => `print_step "  ${cmd}"\n${cmd}`).join('\n\n')}

print_success "Build completed"
echo ""

# =============================================================================
# RUN (same as HTML)
# =============================================================================
print_step "Run"
echo ""

${runCommands.map(cmd => `print_step "  ${cmd}"\n${cmd}`).join('\n\n')}
`;
}

/**
 * Generate test-local.sh for a language
 */
function generateLocalTest(lang, snippetsDir) {
  const toolingCommands = getCommands(snippetsDir, 'tooling-setup');
  const buildCommands = getCommands(snippetsDir, 'build');
  const runCommands = getCommands(snippetsDir, 'run');
  const runCommand = runCommands[0]; // Keep for compatibility

  const langUpper = lang.toUpperCase();

  return `#!/bin/bash

set -e  # Exit on error

# Parse arguments
CLEAN=false
if [[ "$1" == "-c" ]] || [[ "$1" == "--clean" ]]; then
    CLEAN=true
fi

echo "=========================================="
echo "Knuth ${langUpper} API Example - Local"
echo "=========================================="
echo ""

# Colors for output
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m'

print_step() {
    echo -e "\${YELLOW}>>> $1\${NC}"
}

print_success() {
    echo -e "\${GREEN}✓ $1\${NC}"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

# Setup build directory
if [ "$CLEAN" = true ]; then
    print_step "Cleaning build directory"
    rm -rf "$BUILD_DIR"
fi
mkdir -p "$BUILD_DIR"
print_success "Build directory ready: $BUILD_DIR"
echo ""

# Copy source files to build directory
print_step "Copying source files"
cp "$SCRIPT_DIR"/*.* "$BUILD_DIR/" 2>/dev/null || true
print_success "Source files copied"
echo ""

# Change to build directory
cd "$BUILD_DIR"

# =============================================================================
# TOOLING SETUP (same as HTML)
# =============================================================================
print_step "Tooling Setup"
echo ""

${toolingCommands.map(cmd => `print_step "  ${cmd}"\n${cmd}${cmd.includes('conan remote add') ? ' 2>/dev/null || echo "  (remote already exists)"' : ''}`).join('\n\n')}

print_success "Tooling setup completed"
echo ""

# =============================================================================
# PROJECT SETUP (files already copied)
# =============================================================================
print_step "Project Setup"
echo "  Files copied to build directory"
print_success "Project files ready"
echo ""

# =============================================================================
# BUILD (same as HTML)
# =============================================================================
print_step "Build"
echo ""

# Clean CMake cache to avoid conflicts with other projects
print_step "  Cleaning CMake cache"
rm -rf build/CMakeCache.txt build/CMakeFiles build/build

${buildCommands.map(cmd => `print_step "  ${cmd}"\n${cmd}`).join('\n\n')}

print_success "Build completed"
echo ""

# =============================================================================
# RUN (same as HTML)
# =============================================================================
print_step "Run"
echo ""

${runCommands.map(cmd => `print_step "  ${cmd}"\n${cmd}`).join('\n\n')}

echo ""
echo "=========================================="
print_success "Example completed successfully!"
echo "=========================================="
`;
}

/**
 * Process a single language
 */
function processLanguage(lang) {
  const langDir = path.join(TEST_EXAMPLES_DIR, lang);
  const snippetsDir = path.join(langDir, 'snippets');

  if (!fs.existsSync(snippetsDir)) {
    console.log(`⚠️  No snippets directory for ${lang}`);
    return;
  }

  console.log(`\nGenerating test scripts for ${lang}:`);

  try {
    // Generate test-docker.sh
    const dockerTest = generateDockerTest(lang, snippetsDir);
    const dockerPath = path.join(langDir, 'test-docker.sh');
    fs.writeFileSync(dockerPath, dockerTest, { mode: 0o755 });
    console.log(`  ✓ test-docker.sh`);

    // Generate test-local.sh
    const localTest = generateLocalTest(lang, snippetsDir);
    const localPath = path.join(langDir, 'test-local.sh');
    fs.writeFileSync(localPath, localTest, { mode: 0o755 });
    console.log(`  ✓ test-local.sh`);
  } catch (error) {
    console.error(`  ❌ Error: ${error.message}`);
  }
}

// Main execution
const args = process.argv.slice(2);
const targetLang = args[0]; // Optional: specific language to process

console.log('Generating test scripts from snippets...');

// Get all languages or just the target
const languages = targetLang
  ? [targetLang]
  : fs.readdirSync(TEST_EXAMPLES_DIR)
      .filter(f => {
        const fullPath = path.join(TEST_EXAMPLES_DIR, f);
        return fs.statSync(fullPath).isDirectory() && f !== 'scripts';
      });

// Process each language
for (const lang of languages) {
  processLanguage(lang);
}

console.log('\n✓ All test scripts generated successfully!');
