// Metadata inspection does not open storage or create a peer session.
(async () => {
    try {
        importScripts('browser_headers_persistent_v1.js');
        const core = await createHeaders({locateFile: file => file.endsWith('.wasm') ? 'browser_headers_persistent_v1.wasm' : file});
        postMessage({type: 'libconfig', config: core.getLibconfig()});
    } catch (error) {
        postMessage({type: 'error', message: String(error)});
    }
})();
