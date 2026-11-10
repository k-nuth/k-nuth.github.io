(() => {
    const groups = [
        ['Library', ['webnode_version', 'js_wasm_version', 'knuth_version', 'currency', 'mempool', 'db_readonly', 'debug_mode']],
        ['Build', ['compiler_name', 'compiler_version', 'optimization_level', 'build_timestamp', 'build_git_hash', 'emscripten_version', 'wasm_build_timestamp']],
        ['Platform', ['architecture', 'os_name', 'microarchitecture_id', 'endianness', 'type_sizes.size_int', 'type_sizes.size_long', 'type_sizes.size_pointer']]
    ];
    const container = document.getElementById('libconfig-fields');
    const status = document.getElementById('libconfig-status');
    let loading = false;
    function format(key, value) {
        if (value === undefined || value === null || value === '') return 'Not specified';
        if (typeof value === 'boolean') return value ? 'true' : 'false';
        if (key.endsWith('timestamp')) return value === 0 ? 'Not embedded (0)' : window.KnuthFormat.number(value);
        return typeof value === 'number' ? window.KnuthFormat.number(value) : String(value);
    }
    function load() {
        if (loading || !/^\/settings(?:\.html)?\/?$/.test(window.KNUTH_PAGE_PATH())) return;
        loading = true;
        status.textContent = 'Loading library configuration…';
        const inspector = new Worker('libconfig-worker.js?v=' + encodeURIComponent(window.KNUTH_WEB_NODE_VERSION || 'dev'));
        const timeout = setTimeout(() => finish('Library configuration timed out'), 30000);
        function finish(error) {
            clearTimeout(timeout);
            inspector.terminate();
            status.textContent = error || '';
            status.hidden = !error;
        }
        inspector.onerror = event => finish(event.message || 'Unable to load library configuration');
        inspector.onmessage = ({data}) => {
            if (data.type !== 'libconfig') { finish(data.message || 'Unable to load library configuration'); return; }
            container.replaceChildren();
            for (const [name, keys] of groups) {
                const panel = document.createElement('section'); panel.className = 'panel';
                const heading = document.createElement('div'); heading.className = 'section-heading';
                const title = document.createElement('h2'); title.textContent = name; heading.append(title);
                const fields = document.createElement('dl'); fields.className = 'settings-fields libconfig-values';
                for (const key of keys) {
                    const row = document.createElement('div');
                    const label = document.createElement('dt'); label.textContent = ({webnode_version:'Web Node',js_wasm_version:'JS-WASM',knuth_version:'Knuth'})[key] || key;
                    const value = document.createElement('dd');
                    const raw = key === 'webnode_version' ? window.KNUTH_WEB_NODE_VERSION : key === 'js_wasm_version' ? window.KNUTH_SDK_RELEASE?.version : key === 'knuth_version' ? data.config.version : key.split('.').reduce((object, part) => object?.[part], data.config);
                    value.textContent = format(key, raw);
                    if (window.KnuthSettingsDisplay.timestamp(key) && raw != null) window.KnuthSettingsDisplay.help(value, key, Number(raw) === 0 ? 'No timestamp embedded in this build' : window.KnuthSettingsDisplay.date(raw));
                    row.append(label, value); fields.append(row);
                }
                panel.append(heading, fields); container.append(panel);
            }
            finish();
        };
    }
    window.addEventListener('node-view-changed', load);
    load();
})();
