// Web Node application version (SemVer). Bump this for each release.
// This version is independent of JS-WASM and KTH C++ Core.
window.KNUTH_WEB_NODE_VERSION = '0.11.0';
for (const element of document.querySelectorAll('[data-app-version]')) {
    element.textContent = 'v' + window.KNUTH_WEB_NODE_VERSION;
    element.title = 'Knuth Web Node ' + window.KNUTH_WEB_NODE_VERSION;
}
