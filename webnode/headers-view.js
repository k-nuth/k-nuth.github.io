(() => {
    const byId = id => document.getElementById(id);
    const number = value => window.KnuthFormat.number(value);
    let blockInterval;
    let ageTooltipTimestamp;
    let latestTimestamp;
    let active = false;
    let loading = false;
    let tip = -1;
    let tipHash;
    let rows = [];
    let sequence = 0;
    let pending = 0;
    let lastRequest = 0;
    let dirty = true;
    const href = (height, detail = false) => '/webnode/headers' + (height == null ? '' : '?height=' + height + (detail ? '&detail=1' : ''));
    function selection() {
        const value = new URLSearchParams(location.search).get('height');
        return value !== null && /^\d+$/.test(value) && Number.isSafeInteger(Number(value)) ? Number(value) : null;
    }
    function cell(row, text, className) {
        const td = document.createElement('td');
        td.textContent = text;
        if (className) td.className = className;
        row.append(td);
        return td;
    }
    function decode(item) {
        if (!/^[0-9a-f]{160}$/i.test(item.hex) || !/^[0-9a-f]{64}$/i.test(item.hash)) throw new Error('The index returned an incomplete block.');
        const bytes = Uint8Array.from(item.hex.match(/../g), byte => parseInt(byte, 16));
        const data = new DataView(bytes.buffer);
        const reverse = (start, end) => Array.from(bytes.slice(start, end)).reverse().map(byte => byte.toString(16).padStart(2, '0')).join('');
        return { ...item, version: data.getUint32(0, true), previous: reverse(4, 36), merkle: reverse(36, 68), timestamp: data.getUint32(68, true), bits: data.getUint32(72, true).toString(16).padStart(8, '0'), nonce: data.getUint32(76, true) };
    }
    function empty(message = loading ? 'Loading local blocks…' : 'The browser node has not started yet.') {
        rows = [];
        const tr = document.createElement('tr');
        const td = cell(tr, '', 'headers-empty'); td.colSpan = 7;
        const title = document.createElement('strong'); title.textContent = message;
        const text = document.createElement('span'); text.textContent = loading ? 'Restoring the local chain and preparing the index.' : 'Blocks will appear here as they are validated.';
        const link = document.createElement('a'); link.href = '/webnode/'; link.dataset.viewLink = ''; link.textContent = 'Go to overview →';
        td.append(title, text);
        if (!loading) td.append(document.createElement('br'), link);
        byId('header-rows').replaceChildren(tr);
        byId('header-detail').hidden = true;
        for (const id of ['headers-older', 'headers-newer']) byId(id).setAttribute('aria-disabled', 'true');
    }
    function render() {
        const body = byId('header-rows');
        if(rows[0]?.height===tip)latestTimestamp=rows[0].timestamp;
        const fragment = document.createDocumentFragment();
        for (const item of rows) {
            const tr = document.createElement('tr'); tr.dataset.height = item.height;
            const height = cell(tr, '', 'height-cell');
            const link = document.createElement('a'); link.href = href(item.height, true); link.dataset.viewLink = ''; link.textContent = number(item.height); height.append(link);
            const since = cell(tr, '', 'age-cell');const badge=document.createElement('button');badge.type='button';badge.className='block-age timestamp-trigger';badge.dataset.timestamp=item.timestamp;
            badge.textContent=new Date(item.timestamp*1000).toISOString().replace('T',' ').replace('.000Z','');
            badge.dataset.ageState=window.KnuthBlockAge.describe(item.timestamp,blockInterval).state;
            badge.setAttribute('popovertarget','block-age-tooltip');badge.setAttribute('aria-haspopup','dialog');badge.setAttribute('aria-label',badge.textContent+' UTC · Show block age');
            badge.onclick=()=>{ageTooltipTimestamp=item.timestamp;byId('block-age-tooltip-title').textContent='Block '+number(item.height);updateAgeTooltip();};since.append(badge);
            const delta=item.parentTimestamp==null?null:item.timestamp-item.parentTimestamp;
            const elapsed=cell(tr,delta==null?'—':(delta<0?'−':'')+window.KnuthBlockAge.duration(delta),'block-time-cell');
            if(delta!=null){elapsed.dataset.blockSeconds=delta;elapsed.dataset.ageState=window.KnuthBlockAge.describe(0,blockInterval,delta).state;}
            elapsed.title=delta==null?'No preceding block':number(delta)+' seconds between this block’s header timestamp and its parent’s. Miner timestamps are not an exact measurement of mining time.';
            cell(tr, item.body ? number(item.body.transactions) : '—', 'tx-count-cell');
            cell(tr, item.body ? window.KnuthFormat.bytes(item.body.bytes) : '—', 'block-size-cell');
            const tag=cell(tr, window.KnuthTransactions.minerName(item.body), 'miner-tag-cell');
            tag.title=item.body?.coinbase_tag?.trim() || 'Block body not downloaded';
            const arrow = cell(tr, '', 'arrow-cell'); const details = link.cloneNode(true); details.textContent = '→'; details.setAttribute('aria-label', 'View block ' + item.height); arrow.append(details);
            fragment.append(tr);
        }
        body.replaceChildren(fragment);updateLatestBlockAge();
        const top = rows[0].height, bottom = rows.at(-1).height;
        const older = byId('headers-older'), newer = byId('headers-newer');
        older.href = href(Math.max(0, bottom - 1)); older.setAttribute('aria-disabled', String(bottom === 0));
        newer.href = href(Math.min(tip, top + 100)); newer.setAttribute('aria-disabled', String(top >= tip));
        const detail = new URLSearchParams(location.search).get('detail') === '1';
        byId('header-detail').hidden = !detail;
        if (detail) {
            const item = rows[0];
            byId('header-detail-title').textContent = 'Block ' + number(item.height);
            const fields = [['Hash', item.hash], ['Previous block', item.previous], ['Merkle root', item.merkle], ['Timestamp · UTC', new Date(item.timestamp * 1000).toISOString()], ['Version', '0x' + item.version.toString(16)], ['Bits', '0x' + item.bits], ['Nonce', number(item.nonce)]];
            const entries = fields.map(([name, value], index) => {
                const div = document.createElement('div'); if (index < 3) div.className = 'wide';
                const dt = document.createElement('dt'); dt.textContent = name;
                const dd = document.createElement('dd'); dd.textContent = value; div.append(dt, dd); return div;
            });
            if (item.body) {
                for(const [name,value] of [['Miner',window.KnuthTransactions.minerName(item.body)],['Body checks','Header · Merkle root · Structure'],['Transactions',number(item.body.transactions)],['Block size',number(item.body.bytes)+' bytes'],['Coinbase tag',item.body.coinbase_tag?.trim() || '—']]) {
                    const div=document.createElement('div'),dt=document.createElement('dt'),dd=document.createElement('dd');dt.textContent=name;dd.textContent=value;div.append(dt,dd);entries.push(div);
                }
                const raw=document.createElement('details');raw.className='wide';const title=document.createElement('summary');title.textContent='Coinbase transaction';const pre=document.createElement('pre');pre.className='content-hex';pre.textContent=item.body.coinbase_hex || '';raw.append(title,pre);entries.push(raw);
                const list=document.createElement('details');list.className='wide';const heading=document.createElement('summary');heading.textContent='Transaction IDs · '+(item.body.txids_retained ? number(item.body.txids?.length || 0) : 'Evicted by cache limit');list.append(heading);
                const ids=document.createElement('pre');ids.className='content-hex';ids.textContent=(item.body.txids || []).slice(0,200).join('\n');list.append(ids);
                if(item.body.txids?.length>200){const more=document.createElement('p');more.textContent='Showing the first 200 transaction IDs.';list.append(more);}entries.push(list);
            }
            byId('header-fields').replaceChildren(...entries);
        }
    }
    function request(force = false) {
        if (!active || !window.requestHeaderWindow) return;
        if (!force && (pending || performance.now() - lastRequest < 1000)) return;
        pending = ++sequence; lastRequest = performance.now();
        window.requestHeaderWindow({ requestId: pending, height: selection(), count: 100, includeTransactions: new URLSearchParams(location.search).get('detail') === '1' });
    }
    function route() {
        active = /^\/headers(?:\.html)?\/?$/.test(window.KNUTH_PAGE_PATH());
        const aboutView = /^\/about\/?$/.test(window.KNUTH_PAGE_PATH());
        byId('about-web-node').hidden = !aboutView;
        const logsView = /^\/logs\/?$/.test(window.KNUTH_PAGE_PATH());
        byId('logs-panel').hidden = !logsView;
        const chainView = /^\/chain-state\/?$/.test(window.KNUTH_PAGE_PATH());
        byId('chain-state-view').hidden = !chainView;
        const poolView = /^\/mempool\/?$/.test(window.KNUTH_PAGE_PATH());
        byId('mempool-view').hidden = !poolView;
        const settingsView = /^\/settings(?:\.html)?\/?$/.test(window.KNUTH_PAGE_PATH());
        byId('settings-view').hidden = !settingsView;
        byId('sync-view').hidden = active || settingsView || poolView || chainView || logsView || aboutView;
        byId('headers-view').hidden = !active;
        document.body.dataset.view = aboutView ? 'about' : logsView ? 'logs' : chainView ? 'chain-state' : poolView ? 'mempool' : settingsView ? 'settings' : active ? 'headers' : 'sync';
        for (const link of document.querySelectorAll('#app-nav a')) {
            const selected = link.getAttribute('href') === (aboutView ? '/webnode/about' : logsView ? '/webnode/logs' : chainView ? '/webnode/chain-state' : poolView ? '/webnode/mempool' : settingsView ? '/webnode/settings' : active ? '/webnode/headers' : '/webnode/');
            if (selected) link.setAttribute('aria-current', 'page');
            else link.removeAttribute('aria-current');
        }
        document.title = aboutView ? 'About · Knuth Web Node' : logsView ? 'Logs · Knuth Web Node' : chainView ? 'Chain state · Knuth Web Node' : poolView ? 'Mempool · Knuth Web Node' : settingsView ? 'Settings · Knuth Web Node' : active ? 'Blocks · Knuth Web Node' : 'Knuth Web Node';
        window.dispatchEvent(new Event('node-view-changed'));
        if (active) { updateAges(); request(true); }
    }
    window.navigateNodeView = path => {history.pushState({}, '', path);route();window.scrollTo(0,0);};
    document.addEventListener('click', event => {
        const link = event.target.closest('a[data-view-link]');
        if (!link || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
        if (link.getAttribute('aria-disabled') === 'true') { event.preventDefault(); return; }
        event.preventDefault(); history.pushState({}, '', link.href); route(); window.scrollTo(0, 0);
    });
    window.addEventListener('popstate', route);
    window.addEventListener('node-ui-ready', route);
    window.addEventListener('node-phase', ({detail}) => {
        loading = detail.status === 'loading';
        if (loading) {
            byId('headers-dot').classList.remove('live');
            byId('headers-node-state').textContent = 'Loading';
            empty();
        }
    });
    window.addEventListener('node-network-changed', () => {
        pending = 0; tip = -1; tipHash = undefined; dirty = true; blockInterval=undefined;
        byId('headers-error').textContent = '';
        byId('headers-dot').classList.remove('live');
        byId('headers-node-state').textContent = 'Not started';
        empty();
        if (active) { history.replaceState({}, '', '/webnode/headers'); request(true); }
    });
    window.addEventListener('node-message', ({ detail: data }) => {
        if (data.type === 'headerWindow') {
            if (data.requestId !== pending) return;
            pending = 0;
            byId('headers-error').textContent = data.error || '';
            if (!data.ready) { empty(); return; }
            tip = data.tip; tipHash = data.tipHash; dirty = false;
            if (!data.headers.length) { empty('This height is not in the validated index yet.'); return; }
            try { rows = data.headers.map(decode); render(); }
            catch (error) { byId('headers-error').textContent = error.message; }
        } else if (data.type === 'contentProgress') {
            dirty = true; if(active)request();
        } else if (data.type === 'progress') {
            if(Number.isFinite(data.tipTimestamp))latestTimestamp=data.tipTimestamp;
            if(Number.isFinite(data.blockInterval) && data.blockInterval>0 && blockInterval!==data.blockInterval){blockInterval=data.blockInterval;updateAges();}
            const changed = tip !== data.height || tipHash !== data.tipHash;
            tip = data.height; tipHash = data.tipHash;
            const connected = ['connected', 'synchronizing', 'caught_up'].includes(data.status);
            byId('headers-dot').classList.toggle('live', connected);
            byId('headers-node-state').textContent = data.status === 'caught_up' ? 'Up to date · ' + number(tip) : data.status === 'synchronizing' ? 'Syncing · ' + number(tip) : data.status === 'stopped' ? 'Stopped' : 'Connecting';
            dirty ||= changed;
            if (active && (dirty || !rows.length)) request();
        } else if (data.type === 'closed') {
            pending = 0; tip = -1; tipHash = undefined; dirty = true; blockInterval=undefined;
            byId('headers-dot').classList.remove('live'); byId('headers-node-state').textContent = 'Stopped'; empty('The browser node is stopped.');
        } else if (data.type === 'retry') {
            byId('headers-dot').classList.remove('live'); byId('headers-node-state').textContent = 'Reconnecting';
        }
    });
    function updateAgeTooltip(){if(ageTooltipTimestamp!=null)byId('block-age-tooltip-value').textContent=window.KnuthBlockAge.describe(ageTooltipTimestamp,blockInterval).text;}
    function updateLatestBlockAge(){
        const element=byId('latest-block-age');
        if(Number.isFinite(latestTimestamp))window.KnuthBlockAge.apply(element,latestTimestamp,blockInterval);
        else {element.textContent=loading?'Loading…':'—';delete element.dataset.ageState;element.title='';}
    }
    window.addEventListener('node-phase',({detail})=>{if(detail.status==='loading'){latestTimestamp=undefined;updateLatestBlockAge();}});
    window.addEventListener('node-network-changed',()=>{latestTimestamp=undefined;updateLatestBlockAge();});
    function updateAges() {
        if (!active || document.hidden) return;
        updateLatestBlockAge();
        updateAgeTooltip();
        for(const cell of byId('header-rows').querySelectorAll('[data-block-seconds]'))cell.dataset.ageState=window.KnuthBlockAge.describe(0,blockInterval,Number(cell.dataset.blockSeconds)).state;
        for (const cell of byId('header-rows').querySelectorAll('[data-timestamp]')) {
            cell.dataset.ageState=window.KnuthBlockAge.describe(Number(cell.dataset.timestamp),blockInterval).state;
        }
    }
    setInterval(updateAges, 1000);
    document.addEventListener('visibilitychange', updateAges);
    route();
})();
