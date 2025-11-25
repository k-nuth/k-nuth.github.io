#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Paths
const TEST_EXAMPLES_DIR = path.join(__dirname, '..');
const INDEX_HTML_TPL = path.join(__dirname, '../../index.html.tpl');
const INDEX_HTML = path.join(__dirname, '../../index.html');
const CONFIG_PATH = path.join(TEST_EXAMPLES_DIR, 'config.json');

// Load configuration
const config = JSON.parse(fs.readFileSync(CONFIG_PATH, 'utf8'));

/**
 * Extract plain text from HTML snippet
 * Removes HTML tags and converts HTML entities
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

  return lines.join('\n');
}

/**
 * Build the complete HTML block with copy button
 */
function buildSnippetBlock(snippetHtml, plainText) {
  // Escape for HTML attribute
  const escapedText = plainText
    .replace(/&/g, '&amp;')
    .replace(/"/g, '&quot;')
    .replace(/\n/g, '&#10;');

  return `<div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300">
${snippetHtml}
                    </div>
                    <button class="copy-btn absolute top-2 right-2 p-1.5 bg-gray-800 hover:bg-primary rounded transition-all opacity-0 group-hover:opacity-100" data-clipboard-text="${escapedText}">
                      <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    </button>`;
}

/**
 * Special handling for example code - needs space-y-1 class
 */
function buildExampleBlock(snippetHtml, plainText) {
  // Escape for HTML attribute
  const escapedText = plainText
    .replace(/&/g, '&amp;')
    .replace(/'/g, '&apos;')
    .replace(/\n/g, '&#10;');

  return `<div class="bg-gray-900 rounded-lg p-3 font-mono text-base overflow-x-auto text-gray-300 space-y-1">
${snippetHtml}
                    </div>
                    <button class="copy-btn absolute top-2 right-2 p-1.5 bg-gray-800 hover:bg-primary rounded transition-all opacity-0 group-hover:opacity-100" data-clipboard-text='${escapedText}'>
                      <svg class="w-4 h-4 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                      </svg>
                    </button>`;
}

/**
 * Process snippets for a given language
 */
function processLanguage(lang, indexHtml) {
  const snippetsDir = path.join(TEST_EXAMPLES_DIR, lang, 'snippets');

  if (!fs.existsSync(snippetsDir)) {
    console.log(`⚠️  No snippets directory for ${lang}`);
    return indexHtml;
  }

  const snippetFiles = fs.readdirSync(snippetsDir).filter(f => f.endsWith('.html'));

  console.log(`\nProcessing ${lang}:`);

  for (const file of snippetFiles) {
    const snippetName = file.replace('.html', '');
    const placeholder = `<!-- SNIPPET:${lang}-${snippetName} -->`;
    const snippetPath = path.join(snippetsDir, file);

    const snippetHtml = fs.readFileSync(snippetPath, 'utf8').trim();
    const plainText = extractPlainText(snippetHtml);

    // Use special block for "example" snippets
    const isExample = snippetName === 'example';
    const block = isExample
      ? buildExampleBlock(snippetHtml, plainText)
      : buildSnippetBlock(snippetHtml, plainText);

    // Add proper indentation (20 spaces for consistency)
    const indentedBlock = block.split('\n')
      .map(line => '                    ' + line)
      .join('\n');

    // Replace placeholder
    if (indexHtml.includes(placeholder)) {
      indexHtml = indexHtml.replace(placeholder, indentedBlock);
      console.log(`  ✓ ${snippetName}`);
    } else {
      console.log(`  ⚠️  Placeholder not found: ${placeholder}`);
    }
  }

  return indexHtml;
}

// Main execution
const args = process.argv.slice(2);
const targetLang = args[0]; // Optional: specific language to process

console.log('Embedding snippets into index.html...');

// Read index.html.tpl
let indexHtml = fs.readFileSync(INDEX_HTML_TPL, 'utf8');

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
  indexHtml = processLanguage(lang, indexHtml);
}

// Write back
fs.writeFileSync(INDEX_HTML, indexHtml, 'utf8');

console.log('\n✓ All snippets embedded successfully!');
console.log(`  Generated: ${INDEX_HTML}`);
