(() => {
    const list = document.getElementById('logs-list');
    const banner = document.getElementById('node-error');
    const entries = [];
    const peerStates = new Map();
    const announcements = new Map();
    let lastStatus, lastHeight = -1, lastProgressAt = 0;
    function open(){window.navigateNodeView('/webnode/logs');}
    document.getElementById('view-error-logs').onclick = () => open();
    document.getElementById('clear-logs').onclick = () => { entries.length = 0; list.replaceChildren(); };
    const messages = {loading:'Loading WebAssembly engine',storageLoading:'Loading saved chain',storageValidating:'Validating saved chain',runtimeSettings:'Native runtime settings loaded',storageRestored:'Saved chain restored',caughtUp:'Up to date with peers',stopped:'Node stopped',closed:'Worker closed',storageSaved:'Chain saved'};
    const statuses = {connecting:'Connecting to peers',synchronizing:'Synchronizing blocks',caught_up:'Up to date with peers'};
    window.clearNodeError = () => { announcements.clear(); peerStates.clear(); banner.hidden = true; document.getElementById('node-error-message').textContent = ''; };
    window.appendNodeLog = event => {
        const level = ['failure','workerError'].includes(event.type) ? 'error' : ['retry','diagnostic','storageUnavailable','peerRejected'].includes(event.type) ? 'warning' : 'info';
        const reason = event.detail || event.message;
        if (level === 'error') {
            document.getElementById('node-error-message').textContent = reason || 'Unknown node error';
            banner.hidden = false; open();
        }
        if (event.type === 'storageSaved') return;
        if (event.type === 'progress') {
            for (const peer of event.peers || []) {
                const count = peer.announcements || 0;
                if (count > (announcements.get(peer.endpoint) || 0)) window.appendNodeLog({at:event.at,type:'blockAnnouncement',message:'Block announcement from ' + peer.endpoint});
                announcements.set(peer.endpoint,count);
                const signature = peer.status + ':' + (peer.error || '');
                if (peerStates.get(peer.endpoint) !== signature) {
                    const unseen = !peerStates.has(peer.endpoint);
                    peerStates.set(peer.endpoint, signature);
                    if (unseen && peer.source && peer.source !== 'configured') window.appendNodeLog({at:event.at,type:'discovery',message:'Discovered ' + peer.endpoint + ' via ' + peer.source});
                    window.appendNodeLog({at:event.at, type:peer.status === 'rejected' ? 'peerRejected' : 'peerState', message:peer.endpoint + ' · ' + peer.status + (peer.error ? ' · ' + peer.error : '')});
                }
            }
            const now = Date.now();
            if (event.status === lastStatus && (event.height === lastHeight || now - lastProgressAt < 5000)) return;
            lastStatus = event.status; lastHeight = event.height; lastProgressAt = now;
        }
        let message = reason || messages[event.type] || event.type;
        if (event.type === 'progress') message = (statuses[event.status] || event.status) + ' · height ' + window.KnuthFormat.number(event.height);
        else if (event.type === 'retry') message = (reason || 'Connection interrupted') + ' · retry in ' + Math.ceil(event.delay / 1000) + ' s';
        else if (['storageRestored','caughtUp'].includes(event.type)) message += ' · height ' + window.KnuthFormat.number(event.height);
        const row = document.createElement('div'); row.className = 'log-row'; row.dataset.level = level;
        const time = document.createElement('time'); time.textContent = new Date(event.at).toLocaleTimeString('en-GB', {hour12:false}); time.dateTime = event.at;
        const severity = document.createElement('span'); severity.className = 'log-level'; severity.textContent = level.toUpperCase();
        const text = document.createElement('span'); text.textContent = message;
        row.append(time,severity,text); entries.push(row); list.append(row);
        if (entries.length > 200) entries.shift().remove();
        list.scrollTop = list.scrollHeight;
    };
})();
