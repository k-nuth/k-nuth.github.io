// Copyright (c) 2016-present Knuth Project developers.
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

(function () {
    'use strict';
    const examples = {
    "address-converter": {
        "title": "Address Converter",
        "code": "const address = PaymentAddress.fromString(\n    \"bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a\"\n);\nif (!address) throw new Error(\"Invalid address\");\n\nconsole.log(\"CashAddr: \" + address.encodedCashAddr());\nconsole.log(\"Legacy: \" + address.encodedLegacy());\nconsole.log(\"CashTokens: \" + address.encodedCashTokens());"
    },
    "address-validator": {
        "title": "Address Validator",
        "code": "const addresses = [\n    \"bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a\",\n    \"invalid_address_123\",\n    \"1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa\"\n];\nfor (const address of addresses) {\n    console.log(address + \": \" + PaymentAddress.isValid(address));\n}"
    },
    "wallet-generator": {
        "title": "HD Wallet",
        "code": "// Published BIP39 test vector: sample data only.\nconst mnemonic = \"abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about\";\nconst wallet = new Wallet(\n    mnemonic.split(\" \"),\n    \"m/44'/145'/0'/0\",\n    \"MAINNET\"\n);\ntry {\n    wallet.getAddresses(5).forEach((address, index) => {\n        console.log(\"[\" + index + \"]: \" + address.encodedCashAddr());\n    });\n} finally {\n    wallet.dispose();\n}"
    },
    "sha256-hash": {
        "title": "SHA256 Hash",
        "code": "const messages = [\"abc\", \"Hello Bitcoin Cash\", \"WebAssembly\"];\nfor (const message of messages) {\n    const bytes = new TextEncoder().encode(message);\n    console.log(\"Message: \" + message);\n    console.log(\"SHA256: \" + bytesToHexStr(HashFunctions.sha256(bytes)));\n}"
    },
    "transaction-inspector": {
        "title": "Transaction Inspector",
        "code": "const encoded = \"0100000001b3807042c92f449bbf79b33ca59d7dfec7f4cc71096704a9c526dddf496ee0970100000000ffffffff01905f0100000000001976a91418c0bd8d1818f1bf99cb1df2269c645318ef7b7388ac00000000\";\nconst transaction = Transaction.fromData(hexStrToBytes(encoded));\nif (!transaction) throw new Error(\"Invalid transaction\");\n\nconsole.log(\"TxID: \" + encodeHash(transaction.hash));\nconsole.log(\"Bytes: \" + transaction.serializedSize(true));\nconsole.log(\"Inputs: \" + transaction.inputs.length);\nconsole.log(\"Outputs: \" + transaction.outputs.length);\nconsole.log(\"First output: \" + transaction.outputs[0].value + \" satoshis\");"
    },
    "script-assembly": {
        "title": "Script Assembly",
        "code": "const script = Script.fromString(\"2 3 add\");\nif (!script) throw new Error(\"Invalid script\");\n\nconsole.log(\"Assembly: \" + script.toString(ScriptFlags.noRules));\nconsole.log(\"Hex: \" + bytesToHexStr(script.toData(false)));\nconsole.log(\"Operations: \" + script.operations.length);\nconsole.log(\"Bytes: \" + script.serializedSize);"
    },
    "script-execution": {
        "title": "Script Execution",
        "code": "const script = Script.fromString(\"2 3 add\");\nif (!script) throw new Error(\"Invalid script\");\n\nconst program = new Program(script);\ntry {\n    const status = Interpreter.run(program);\n    if (status !== 0) throw new Error(\"Script error: \" + status);\n    console.log(\"Status: \" + status);\n    console.log(\"Stack items: \" + program.size);\n    for (let index = 0; index < program.size; index++) {\n        console.log(\"Stack [\" + index + \"]: \" + bytesToHexStr(program.item(index)));\n    }\n    console.log(\"05 is the Script-number encoding of 5.\");\n} finally {\n    program.dispose();\n}"
    },
    "script-debugger": {
        "title": "Script Debugger",
        "code": "const script = Script.fromString(\"2 3 add\");\nif (!script) throw new Error(\"Invalid script\");\n\nconst program = new Program(script);\nconst session = new Debugger();\ntry {\n    const status = session.start(program);\n    if (status !== 0) throw new Error(\"Debugger error: \" + status);\n    while (session.stepsAvailable) {\n        const result = session.stepForward();\n        if (result !== 0) throw new Error(\"Step error: \" + result);\n        const snapshot = session.lastProgram;\n        const stack = [];\n        for (let index = 0; snapshot && index < snapshot.size; index++) {\n            stack.push(bytesToHexStr(snapshot.item(index)));\n        }\n        console.log(\"Step \" + session.stepNumber + \": [\" + stack.join(\", \") + \"]\");\n    }\n} finally {\n    session.dispose();\n    program.dispose();\n}"
    },
    "cashtokens-data": {
        "title": "CashTokens Data",
        "code": "const category = decodeHash(\"11\".repeat(32));\nconst token = new TokenData(\n    category,\n    new TokenDataBothKinds(1000n, \"mutable\", hexStrToBytes(\"cafe\"))\n);\n\nconsole.log(\"Valid: \" + token.valid);\nconsole.log(\"Category: \" + encodeHash(token.category));\nconsole.log(\"Kind: \" + token.kind);\nconsole.log(\"Amount: \" + token.data.fungible.amount);\nconsole.log(\"NFT capability: \" + token.data.nonFungible.capability);\nconsole.log(\"Commitment: \" + bytesToHexStr(token.data.nonFungible.commitment));\nconsole.log(\"Encoded: \" + bytesToHexStr(token.toData()));"
    },
    "libconfig": {
        "title": "Library Config",
        "code": "const config = Kth.getLibconfig();\nconsole.log(\"JS-WASM: \" + config.wasmLibraryVersion);\nconsole.log(\"C++ API: \" + config.cppapiVersion);\nconsole.log(\"C API: \" + config.capiVersion);\nconsole.log(\"Emscripten: \" + config.emscriptenVersion);\nconsole.log(\"Architecture: \" + config.architecture);\nconsole.log(\"Currency: \" + config.currency);"
    }
};
    if (typeof module !== 'undefined' && module.exports) {
        module.exports = Object.freeze(examples);
    } else {
        window.knuthWasmExamples = Object.freeze(examples);
    }
})();
