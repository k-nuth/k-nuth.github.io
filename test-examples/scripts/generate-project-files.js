#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Paths
const TEST_EXAMPLES_DIR = path.join(__dirname, '..');

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
    .split('\n');

  // Remove only trailing empty lines, preserve blank lines in the middle
  while (lines.length > 0 && lines[lines.length - 1].trim() === '') {
    lines.pop();
  }

  return lines.join('\n');
}

/**
 * Mapping of snippet names to generated file names and extensions
 * Can be overridden per language if needed
 */
const FILE_MAPPINGS = {
  'example': { suffix: '', extension: null }, // Will use language-specific extension
  'conanfile': { suffix: '', extension: 'txt', name: 'conanfile.txt' },
  'cmake': { suffix: '', extension: '', name: 'CMakeLists.txt' }
};

/**
 * Get file extension for language
 */
function getLanguageExtension(lang) {
  const extensions = {
    'c': 'c',
    'cpp': 'cpp',
    'csharp': 'cs',
    'python': 'py',
    'javascript': 'js',
    'typescript': 'ts'
  };
  return extensions[lang] || lang;
}

/**
 * Generate project files from snippets for a language
 */
function processLanguage(lang) {
  const langDir = path.join(TEST_EXAMPLES_DIR, lang);
  const snippetsDir = path.join(langDir, 'snippets');

  if (!fs.existsSync(snippetsDir)) {
    console.log(`⚠️  No snippets directory for ${lang}`);
    return;
  }

  console.log(`\nGenerating project files for ${lang}:`);

  const snippetFiles = fs.readdirSync(snippetsDir)
    .filter(f => f.endsWith('.html'))
    .map(f => f.replace('.html', ''));

  for (const snippetName of snippetFiles) {
    // Check if this snippet should generate a project file
    const mapping = FILE_MAPPINGS[snippetName];
    if (!mapping) {
      continue; // Skip snippets that don't map to project files
    }

    const snippetPath = path.join(snippetsDir, `${snippetName}.html`);
    const snippetHtml = fs.readFileSync(snippetPath, 'utf8');
    const content = extractPlainText(snippetHtml);

    // Determine output filename
    let outputFile;
    if (mapping.name) {
      outputFile = mapping.name;
    } else if (mapping.extension !== null) {
      const ext = mapping.extension || getLanguageExtension(lang);
      outputFile = `${snippetName}${mapping.suffix}.${ext}`;
    } else {
      // Use language extension
      const ext = getLanguageExtension(lang);
      outputFile = `${snippetName}.${ext}`;
    }

    const outputPath = path.join(langDir, outputFile);

    // Write file
    fs.writeFileSync(outputPath, content + '\n', 'utf8');
    console.log(`  ✓ ${outputFile}`);
  }
}

// Main execution
const args = process.argv.slice(2);
const targetLang = args[0]; // Optional: specific language to process

console.log('Generating project files from snippets...');

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

console.log('\n✓ All project files generated successfully!');
