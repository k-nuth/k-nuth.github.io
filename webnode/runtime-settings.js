(() => {
    const container = document.getElementById('runtime-fields');
    const status = document.getElementById('runtime-status');
    const titles = {node:'Node', header_sync:'Header synchronization', network:'Network', chain:'Chain'};
    let loaded = false;
    function entries(value, prefix = '') {
        return Object.entries(value).flatMap(([key, field]) => {
            const name = prefix ? prefix + '.' + key : key;
            return field && typeof field === 'object' && !Array.isArray(field) ? entries(field, name) : [[name, field]];
        });
    }
    function render(settings) {
        container.replaceChildren();
        for (const group of ['node', 'header_sync', 'network', 'chain']) {
            const panel = document.createElement('section'); panel.className = 'panel';
            const heading = document.createElement('div'); heading.className = 'section-heading';
            const title = document.createElement('h2'); title.textContent = titles[group]; heading.append(title);
            const fields = document.createElement('dl'); fields.className = 'settings-fields native-runtime-values';
            const inactive = settings.inactive_fields?.[group] || [];
            for (const [key, value] of entries(settings[group] || {})) {
                const row = document.createElement('div');
                const label = document.createElement('dt'); label.textContent = key;
                if (inactive.some(name => key === name || key.startsWith(name + '.'))) {
                    row.className = 'setting-unused';
                    const badge = document.createElement('span'); badge.className = 'setting-unused-badge'; badge.textContent = 'Unused';
                    label.append(badge);
                }
                const field = document.createElement('dd');
                field.textContent = Array.isArray(value) ? value.length ? value.map(item=>typeof item==='number'?window.KnuthFormat.number(item):String(item)).join('\n') : '[]' : value === '' ? '""' : typeof value==='number' || (typeof value==='string' && /^-?\d{16,}$/.test(value)) ? window.KnuthFormat.number(value) : String(value);
                row.append(label, field); fields.append(row);
            }
            panel.append(heading, fields); container.append(panel);
        }
        loaded = true; status.textContent = 'Current session';
    }
    window.addEventListener('node-message', ({detail}) => {
        if (detail.type === 'runtimeSettings') render(detail.settings);
    });
    window.addEventListener('node-network-changed', () => {
        loaded = false; container.replaceChildren(); status.textContent = 'Start the node to load native runtime settings';
    });
    window.addEventListener('node-phase', ({detail}) => {
        if (!loaded) return;
        status.textContent = ['stopped', 'error', 'resetting'].includes(detail.status) ? 'Last session' : 'Current session';
    });
})();
