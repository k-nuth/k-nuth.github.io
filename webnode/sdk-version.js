window.KNUTH_SDK_RELEASE = {"name": "@knuth/js-wasm", "version": "4.0.0", "coreVersion": "1.6.1", "coreCommit": "c7ec3c96adc9c24695e14d0a76f6f0326a8760b1", "emscriptenVersion": "6.0.13", "integrity": "sha512-W9qvJSsINXgyq9YbDCDiupXPV41AJyRwh7/a34JSaGx5i62C0ywIstIjYA1qobOOn/f6U9aNM/zEjW2Ce4McOA=="};
for (const [selector, value] of [['[data-sdk-version]', window.KNUTH_SDK_RELEASE.version], ['[data-core-version]', window.KNUTH_SDK_RELEASE.coreVersion]]) {
    for (const element of document.querySelectorAll(selector)) element.textContent = value;
}
