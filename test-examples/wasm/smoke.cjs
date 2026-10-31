// Copyright (c) 2016-present Knuth Project developers.
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

'use strict';
const assert = require('node:assert/strict');
const crypto = require('node:crypto');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');
const examples = require(path.join(root, 'js/wasm-examples.js'));
const manifest = require(path.join(root, 'js/wasm-runtime.json'));
const api = require(path.join(root, 'kth.js'));
const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
const entries = Object.entries(api).filter(([name]) => name !== 'default');
const expected = {
    'address-converter': ['Legacy: 1BpEi6DfDAUFd7GtittLSdBeYJvcoaVggu'],
    'address-validator': ['invalid_address_123: false'],
    'wallet-generator': ['[0]: bitcoincash:qqyx49mu0kkn9ftfj6hje6g2wfer34yfnq5tahq3q6'],
    'sha256-hash': ['SHA256: ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad'],
    'transaction-inspector': ['TxID: 39d2caaf112f21364be00c5d0b14e3763468934e586e416bf74647a1906b18e0', 'Bytes: 85', 'Inputs: 1', 'Outputs: 1', 'First output: 90000 satoshis'],
    'script-assembly': ['Hex: 525393', 'Operations: 3'],
    'script-execution': ['Status: 0', 'Stack [0]: 05'],
    'script-debugger': ['Step 1: [02]', 'Step 2: [03, 02]', 'Step 3: [05]'],
    'cashtokens-data': ['Valid: true', 'Kind: both', 'Amount: 1000', 'NFT capability: mutable', 'Commitment: cafe', 'Encoded: ' + '11'.repeat(32) + '7102cafefde803'],
    'libconfig': ['JS-WASM: 3.0.0', 'C++ API: 1.5.2', 'Emscripten: 6.0.13']
};
async function main() {
    for (const [name, digest] of Object.entries(manifest.sha256)) {
        assert.equal(crypto.createHash('sha256').update(fs.readFileSync(path.join(root, name))).digest('hex'), digest, name);
    }
    await api.loadLib(path.join(root, 'kth.wasm'), path.join(root, 'kth.js'));
    const config = api.Kth.getLibconfig();
    assert.equal(config.wasmLibraryVersion, manifest.version);
    assert.equal(config.cppapiVersion, manifest.coreVersion);
    assert.equal(config.emscriptenVersion, manifest.emscriptenVersion);
    assert.deepEqual(Object.keys(examples).sort(), Object.keys(expected).sort());
    for (const [id, example] of Object.entries(examples)) {
        const output = [];
        const logger = { log: (...args) => output.push(args.map(String).join(' ')) };
        const run = new AsyncFunction(...entries.map(([name]) => name), 'console', example.code);
        await run(...entries.map(([, value]) => value), logger);
        for (const line of expected[id]) assert(output.includes(line), id + ': missing ' + line);
        console.log('PASS ' + id);
    }
    for (const name of ['index.html.tpl', 'index.html']) {
        const html = fs.readFileSync(path.join(root, name), 'utf8');
        for (const id of Object.keys(examples)) assert(html.includes("loadExample('" + id + "', this)"), name + ': missing selector ' + id);
    }
    console.log('10 live examples, release metadata and runtime checksums passed.');
}
main().catch(error => { console.error(error); process.exitCode = 1; });
