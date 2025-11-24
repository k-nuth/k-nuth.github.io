#!/usr/bin/env node

/**
 * Master script that runs all generators in order
 */

const { execSync } = require('child_process');
const path = require('path');

const args = process.argv.slice(2);
const targetLang = args[0] ? ` ${args[0]}` : '';

console.log('==========================================');
console.log('Knuth Examples - Generate All');
console.log('==========================================\n');

const scripts = [
  { name: 'Project Files', script: 'generate-project-files.js' },
  { name: 'Test Scripts', script: 'generate-tests.js' },
  { name: 'Website HTML', script: 'embed-snippets.js' }
];

for (const { name, script } of scripts) {
  console.log(`\n[${ name}]`);
  console.log('─'.repeat(40));
  try {
    execSync(`node ${path.join(__dirname, script)}${targetLang}`, { stdio: 'inherit' });
  } catch (error) {
    console.error(`\n❌ Failed to generate ${name}`);
    process.exit(1);
  }
}

console.log('\n==========================================');
console.log('✓ All files generated successfully!');
console.log('==========================================');
