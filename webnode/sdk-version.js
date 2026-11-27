window.KNUTH_SDK_RELEASE = {"name": "@knuth/js-wasm", "version": "4.1.0", "coreVersion": "1.8.0", "coreCommit": "d59378e99aaa5bba84b42e9004c8952ba828c8c2", "emscriptenVersion": "6.0.13"};
for (const [selector, value] of [['[data-sdk-version]', window.KNUTH_SDK_RELEASE.version], ['[data-core-version]', window.KNUTH_SDK_RELEASE.coreVersion]]) {
    for (const element of document.querySelectorAll(selector)) element.textContent = value;
}
