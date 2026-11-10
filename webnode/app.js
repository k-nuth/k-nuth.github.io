const element = id => document.getElementById(id);
const labels = { idle: 'Preparing index', connecting: 'Connecting to peer', connected: 'P2P connection established', synchronizing: 'Downloading and validating blocks', caught_up: 'Up to date with peers', stopped: 'Node stopped' };
const config = window.KTH_BROWSER_CONFIG || {};
const settings = window.KTH_NODE_SETTINGS;
const networkNames = {tempnet:'Tempnet',mainnet:'Mainnet',chipnet:'Chipnet',testnet4:'Testnet4',testnet:'Testnet',scalenet:'Scalenet',regtest:'Regtest'};
let network = networkNames[config.network] ? config.network : 'tempnet';
try { const saved = sessionStorage.getItem('kth-network'); if (networkNames[saved]) network = saved; } catch {}
let switching = false;
let nextNetwork;
function peersFor(name) {
    const entry = config.networks?.[name];
    let endpoints = entry?.peers ?? (entry?.peer ? [entry.peer] : null);
    if (!endpoints && name === (config.network || 'tempnet'))
        endpoints = config.peers ?? [config.peer || ((location.protocol === 'https:' ? 'wss://' : 'ws://') + location.host + '/p2p')];
    if (!Array.isArray(endpoints)) return [];
    return [...new Set(endpoints.filter(value => typeof value === 'string').map(value => {
        try { const url = new URL(value); return ['ws:', 'wss:'].includes(url.protocol) && !url.username && !url.password && !url.hash ? url.href : null; }
        catch { return null; }
    }).filter(Boolean))].slice(0, settings.maxPeers);
}
function peerFor(name) { return peersFor(name)[0] || null; }
function capacityFor(name) {
    return config.networks?.[name]?.capacity ?? (name === 'tempnet' ? settings.tempnetCapacity : settings.defaultCapacity);
}
function showSettings() {
    const peer = peerFor(network);
    const values = {
        'setting-network': networkNames[network],
        'setting-peer': peersFor(network).join('\n') || 'Not configured',
        'setting-peer-source': !peer ? 'Not configured' : (config.networks?.[network]?.peer || config.networks?.[network]?.peers) ? 'Network configuration' : (config.peer || config.peers) ? 'Default configuration' : 'Same-origin /p2p',
        'setting-transport': peer ? (peer.startsWith('wss:') ? 'WSS · TLS' : 'WS') : '—',
        'setting-peers': String(settings.maxPeers),
        'setting-capacity': window.KnuthFormat.number(capacityFor(network)) + ' blocks',
        'setting-database': '/kth-header-cache/' + networkNames[network],
        'setting-origin': location.origin,
        'setting-save': settings.storageSaveInterval / 1000 + ' s',
        'setting-resume': desired ? 'Enabled' : 'Disabled',
        'setting-retry': settings.retryInitial / 1000 + '–' + settings.retryMaximum / 1000 + ' s · exponential',
        'setting-jitter': '0–' + (settings.retryJitter - 1) + ' ms',
        'setting-progress': settings.progressInterval + ' ms'
    };
    for (const [id, value] of Object.entries(values)) element(id).textContent = value;
}
function peerState(status = 'Disconnected', userAgent = '', peers) {
    const connected = ['connected', 'synchronizing', 'caught_up'].includes(status);
    const states = peers || peersFor(network).map((endpoint, at) => ({endpoint, connected:at === 0 && connected, userAgent:at === 0 ? userAgent : '', status:at === 0 ? status : 'idle'}));
    element('peer-count').textContent = String(states.filter(peer => peer.connected).length);
    const names = {idle:'Disconnected',stopped:'Stopped',connecting:'Connecting',retry:'Reconnecting',disconnected:'Disconnected',rejected:'Rejected',synchronizing:'Syncing',caught_up:'Up to date'};
    const first = states[0];
    element('peer-endpoint').textContent = first?.endpoint || 'No endpoint configured';
    element('peer-endpoint').title = first?.source && first.source !== 'configured' ? 'Discovered via ' + first.source : 'Configured endpoint';
    element('peer-agent').textContent = first?.connected && first.userAgent ? first.userAgent : '—';
    element('peer-transport').textContent = first ? (first.endpoint.startsWith('wss:') ? 'WSS / TLS' : 'WS') : '—';
    element('peer-state').textContent = first ? (names[first.status] || (first.connected ? 'Connected' : 'Disconnected')) : 'Disconnected';
    element('peer-state').dataset.connected = String(!!first?.connected);
    element('peer-state').title = first?.error || '';
    const extra = element('peer-additional');
    extra.replaceChildren();
    for (const peer of states.slice(1)) {
        const row = document.createElement('div'); row.className = 'peer-row';
        const endpoint = document.createElement('code'); endpoint.textContent = peer.endpoint; endpoint.title = peer.source && peer.source !== 'configured' ? 'Discovered via ' + peer.source : 'Configured endpoint';
        const agent = document.createElement('code'); agent.textContent = peer.connected && peer.userAgent ? peer.userAgent : '—';
        const transport = document.createElement('span'); transport.textContent = peer.endpoint.startsWith('wss:') ? 'WSS / TLS' : 'WS';
        const state = document.createElement('span'); state.textContent = names[peer.status] || 'Disconnected'; state.dataset.connected = String(peer.connected); state.title = peer.error || '';
        row.append(endpoint, agent, transport, state); extra.append(row);
    }
}
function updateHeaderNetwork() { element('header-network').textContent=element('node-status').dataset.status==='loading'?'Loading':networkNames[network].toUpperCase(); }
function showNetwork() {
    showSettings();
    const peer = peerFor(network);
    if (element('network')) element('network').value = network;
    element('network-name').textContent = networkNames[network];
    element('peer-endpoint').textContent = peer || 'No endpoint configured';
    element('peer-transport').textContent = peer ? (peer.startsWith('wss:') ? 'WSS / TLS' : 'WS') : '—';
    element('start').disabled = !peer || (desired && !blocked);
    updateHeaderNetwork();
}
const intentKey = 'kth-headers-started';
let desired = false;
try { desired = sessionStorage.getItem(intentKey) === '1'; } catch {}
let worker;
let blocked = false;
let restartTimer;
let restartDelay = settings.retryInitial;
let startedAt;
let lastHeight = 0;
let sampleHeight = 0;
let sampleTime = 0;
let clock;
let stopping = false;
let resetting = false;
let synced = false;
let tipTimestamp;
let blockInterval;
let isLoading = false;
function nodeStatus(status) {
    if (stopping && status !== 'stopped' && status !== 'error') status = 'stopping';
    const names = {resetting:'Resetting',loading:'Loading',stopped:'Stopped',starting:'Starting',syncing:'Syncing',running:'Running',reconnecting:'Reconnecting',stopping:'Stopping',error:'Error'};
    const wasLoading = isLoading;
    isLoading = status === 'loading';
    if (wasLoading && !isLoading) element('rate').textContent = '—';
    element('node-loading').hidden = !isLoading;
    window.dispatchEvent(new CustomEvent('node-phase', {detail:{status}}));
    element('reset-chain').disabled = resetting || stopping || switching;
    element('node-status').textContent = names[status];
    element('node-status').dataset.status = status;
    const headerLabel=status==='loading'?'Loading':networkNames[network]+' · '+names[status];
    element('node-header-indicator').title=headerLabel;
    element('node-header-indicator').ariaLabel=headerLabel;
    updateHeaderNetwork();
    element('light').className = ['running','syncing'].includes(status) ? 'active' : '';
    updateMetric();
}
function showLoading(phase) {
    if (stopping || blocked) return;
    const phases = {
        engine: ['Loading node', 'Initializing the local engine…'],
        storage: ['Loading local chain', 'Reading blocks from browser storage…'],
        validation: ['Loading local chain', 'Validating saved blocks and building the memory index…']
    };
    const [title, detail] = phases[phase];
    element('loading-title').textContent = title;
    element('loading-detail').textContent = detail;
    if (phase === 'storage') element('storage-state').textContent = 'Loading…';
    if (phase === 'validation') element('storage-state').textContent = 'Validating…';
    nodeStatus('loading');
    state(title + '…');
    updateMetric();
}
function updateMetric() {
    delete element('rate').dataset.ageState;
    element('rate').title='';
    if (isLoading) {
        element('rate-label').textContent = 'Local data';
        element('rate').textContent = 'Loading…';
        return;
    }
    element('rate-label').textContent = synced ? 'Last block' : 'Blocks / second';
    if (!synced) return;
    if (!Number.isFinite(tipTimestamp)) { element('rate').textContent = '—'; return; }
    window.KnuthBlockAge.apply(element('rate'),tipTimestamp,blockInterval);
}
window.__experiment = { started: desired, height: 0, events: [] };
function intent(value) {
    desired = value;
    showSettings();
    window.__experiment.started = value;
    try {
        if (value) sessionStorage.setItem(intentKey, '1');
        else sessionStorage.removeItem(intentKey);
    } catch {}
}
function log(data) {
    const row = { at: new Date().toISOString(), network, ...data };
    window.appendNodeLog?.(row);
    window.__experiment.events.push(row);
    if (window.__experiment.events.length > 120) window.__experiment.events.shift();
    element('events').textContent = window.__experiment.events.map(item => JSON.stringify(item)).join('\n');
}
function state(message) { element('state').textContent = message; }
function startNode() {
    if (worker || !desired || blocked || switching || resetting || !peerFor(network)) return;
    clearTimeout(restartTimer);
    window.clearNodeError?.();
    stopping = false; synced = false; tipTimestamp = undefined; blockInterval = undefined;
    showLoading('engine');
    peerState();
    element('start').disabled = true;
    element('stop').disabled = false;
    element('height').textContent = '0';
    element('detail').textContent = 'Loading local data…';
    startedAt = performance.now(); sampleTime = startedAt; sampleHeight = 0; lastHeight = 0;
    clock = setInterval(() => {
        const seconds = Math.floor((performance.now() - startedAt) / 1000);
        element('elapsed').textContent = String(Math.floor(seconds / 60)).padStart(2, '0') + ':' + String(seconds % 60).padStart(2, '0');
    }, 1000);
    state('Loading node…');
    worker = new Worker('worker.js?v=' + encodeURIComponent(window.KNUTH_WEB_NODE_VERSION || 'dev'));
    worker.onmessage = ({ data }) => {
        window.dispatchEvent(new CustomEvent('node-message', { detail: data }));
        if (['headerWindow','observedPool','contentProgress'].includes(data.type)) return;
        if (data.type === 'loading') showLoading('engine');
        else if (data.type === 'storageLoading') showLoading('storage');
        else if (data.type === 'storageValidating') showLoading('validation');
        else if (data.type === 'storageSaved') { window.__experiment.savedHeight = data.height; element('storage-state').textContent = window.KnuthFormat.number(data.height); }
        else if (data.type === 'storageRestored') {
            window.__experiment.restoredHeight = data.height;
            element('storage-state').textContent = window.KnuthFormat.number(data.height);
            sampleHeight = data.height; sampleTime = performance.now();
            delete window.__experiment.storageError;
            if (data.height > 0) element('detail').textContent = 'Saved chain restored at height ' + window.KnuthFormat.number(data.height) + '. Checking for new blocks…';
        } else if (data.type === 'storageUnavailable') {
            window.__experiment.storageError = data.message;
            element('storage-state').textContent = 'Unavailable · memory only';
            element('detail').textContent = data.message;
        } else if (data.type === 'storageReset') element('detail').textContent = data.message;
        log(data);
        if (data.type === 'progress') {
            peerState(data.status, data.userAgent, data.peers);
            if (Number.isFinite(data.tipTimestamp)) tipTimestamp = data.tipTimestamp;
            if (Number.isFinite(data.blockInterval) && data.blockInterval>0) blockInterval=data.blockInterval;
            if (data.status === 'caught_up') { synced = true; if (!stopping && !window.__experiment.storageError) element('detail').textContent = ''; }
            nodeStatus(({idle:'starting',connecting:'starting',connected:'syncing',synchronizing:'syncing',caught_up:'running',stopped:'reconnecting'})[data.status] || 'reconnecting');
            updateMetric();
            lastHeight = data.height;
            window.__experiment.height = data.height;
            element('height').textContent = window.KnuthFormat.number(data.height);
            element('memory').textContent = window.KnuthFormat.fixed(data.bytes / 1048576) + ' MiB';
            if (!stopping && labels[data.status]) state(labels[data.status]);
            if (!stopping && !window.__experiment.storageError && ['connecting','connected','synchronizing'].includes(data.status)) {
                element('detail').textContent = data.status === 'connecting' ? 'Connecting to peers…' : 'Receiving and validating blocks…';
            }
            const now = performance.now();
            if (now - sampleTime >= 1000) {
                if (!synced) element('rate').textContent = window.KnuthFormat.number(Math.max(0, Math.round((lastHeight - sampleHeight) * 1000 / (now - sampleTime))));
                sampleTime = now; sampleHeight = lastHeight;
            }
        } else if (data.type === 'caughtUp') {
            restartDelay = settings.retryInitial;
            synced = true; updateMetric(); nodeStatus('running');
            if (!stopping) state('Up to date with peers');
            element('detail').textContent = window.__experiment.storageError || '';
        } else if (data.type === 'retry') {
            nodeStatus('reconnecting');
            peerState('retry');
            state('Connection interrupted; retrying in ' + Math.ceil(data.delay / 1000) + ' seconds');
        } else if (data.type === 'stopped') state('Node stopped');
        else if (data.type === 'failure') {
            blocked = true;
            nodeStatus('error');
            peerState('Disconnected');
            state('Synchronization error');
            element('detail').textContent = data.detail || data.message;
        } else if (data.type === 'closed') finish();
    };
    worker.onerror = error => {
        log({ type: 'workerError', message: error.message });
        nodeStatus('reconnecting');
        state('Worker interrupted; recovery scheduled');
        finish();
    };
    worker.postMessage({ type: 'start', bridge: peerFor(network), peers: peersFor(network), discovery:{enabled:config.discovery?.enabled !== false, allowPrivate:config.discovery?.allowPrivate === true, wssOnly:location.protocol === 'https:'}, network, capacity: capacityFor(network) });
}
function finish() {
    clearInterval(clock);
    worker?.terminate(); worker = undefined;
    if (resetting) { void completeChainReset(); return; }
    peerState();
    element('start').disabled = !peerFor(network) || (desired && !blocked);
    element('stop').disabled = !desired || blocked;
    stopping = false;
    nodeStatus(blocked ? 'error' : desired ? 'reconnecting' : 'stopped');
    if (!desired && !blocked) state('Node stopped');
    if (switching) {
        network = nextNetwork;
        switching = false;
        nextNetwork = undefined;
        try { sessionStorage.setItem('kth-network', network); } catch {}
        resetNetwork();
        if (desired) startNode();
        return;
    }
    if (desired && !blocked && peerFor(network)) {
        restartTimer = setTimeout(startNode, restartDelay);
        restartDelay = Math.min(settings.retryMaximum, restartDelay * 2);
    }
}
function resumeNode() {
    if (!desired || blocked) return;
    if (worker) worker.postMessage({ type: 'resume' });
    else startNode();
}
async function completeChainReset() {
    stopping = false;
    nodeStatus('resetting');
    peerState();
    state('Clearing local chain…');
    try {
        await window.clearStoredChain(network);
        resetting = false;
        blocked = false;
        resetNetwork();
        intent(true);
        startNode();
    } catch (error) {
        resetting = false;
        blocked = true;
        nodeStatus('error');
        state('Chain reset failed');
        element('detail').textContent = error.message || String(error);
        element('start').disabled = !peerFor(network);
        element('stop').disabled = true;
    }
}
element('reset-chain').onclick = () => {
    if (resetting || stopping || switching) return;
    element('reset-network').textContent = networkNames[network];
    element('reset-dialog').showModal();
};
element('cancel-chain-reset').onclick = () => element('reset-dialog').close();
element('close-chain-reset').onclick = () => element('reset-dialog').close();
element('confirm-chain-reset').onclick = () => {
    element('reset-dialog').close();
    if (resetting || stopping || switching) return;
    resetting = true;
    stopping = true;
    blocked = true;
    intent(false);
    clearTimeout(restartTimer);
    element('start').disabled = true;
    element('stop').disabled = true;
    nodeStatus('stopping');
    state('Stopping before chain reset…');
    if (worker) worker.postMessage({type:'stop'});
    else void completeChainReset();
};
element('start').onclick = () => { blocked = false; intent(true); startNode(); };
element('stop').onclick = () => {
    intent(false);
    stopping = true;
    nodeStatus('stopping');
    element('start').disabled = true;
    clearTimeout(restartTimer);
    element('stop').disabled = true;
    state('Saving and stopping…');
    if (worker) worker.postMessage({ type: 'stop' });
    else finish();
};
document.addEventListener('visibilitychange', () => { if (!document.hidden) resumeNode(); });
document.addEventListener('resume', resumeNode);
window.addEventListener('online', resumeNode);
window.addEventListener('pageshow', resumeNode);
function resetNetwork() {
    blocked = false;
    stopping = false; synced = false; tipTimestamp = undefined; blockInterval = undefined;
    nodeStatus('stopped'); updateMetric();
    if (element('network')) element('network').disabled = false;
    element('stop').disabled = !desired || !peerFor(network);
    element('height').textContent = '—';
    element('rate').textContent = '—';
    element('memory').textContent = '—';
    element('elapsed').textContent = '00:00';
    element('storage-state').textContent = 'Not loaded';
    for (const key of ['height','savedHeight','restoredHeight','storageError']) delete window.__experiment[key];
    peerState();
    showNetwork();
    state(peerFor(network) ? 'Ready to start' : 'Peer configuration required');
    element('detail').textContent = 'Saved chains are isolated by network. Start the node to restore this chain.';
    window.dispatchEvent(new CustomEvent('node-network-changed', {detail:{network}}));
}
if (element('network')) element('network').onchange = () => {
    const selected = element('network').value;
    if (!networkNames[selected] || selected === network || switching || resetting) return;
    clearTimeout(restartTimer);
    if (worker) {
        switching = true;
        nextNetwork = selected;
        element('network').disabled = true;
        element('start').disabled = true;
        state('Saving chain before switching networks…');
        worker.postMessage({type:'stop'});
    } else {
        network = selected;
        try { sessionStorage.setItem('kth-network', network); } catch {}
        resetNetwork();
        if (desired) startNode();
    }
};
showNetwork();
peerState();
nodeStatus('stopped');
updateMetric();
// Relative block age keeps advancing even while the node is stopped.
setInterval(updateMetric, 1000);
if (desired) startNode();

window.requestHeaderWindow = request => {
    if (worker) worker.postMessage({ type: 'getHeaders', ...request });
    else window.dispatchEvent(new CustomEvent('node-message', { detail: { type: 'headerWindow', requestId: request.requestId, ready: false } }));
};
window.dispatchEvent(new Event('node-ui-ready'));

window.requestObservedPool = request => { if (worker) worker.postMessage({type:'getPool',...request}); else window.dispatchEvent(new CustomEvent('node-message',{detail:{type:'observedPool',requestId:request.requestId,transactions:[]}})); };

window.requestChainState = request => { if(worker) worker.postMessage({type:'getChainState',...request}); else window.dispatchEvent(new CustomEvent('node-message',{detail:{type:'chainState',requestId:request.requestId,state:null}})); };
