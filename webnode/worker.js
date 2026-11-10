importScripts('number-format.js', 'node-settings.js', 'peer-endpoint.js');
const settings = self.KTH_NODE_SETTINGS;
// The Worker owns the native client and joins all outstanding callbacks before disposal.
let started = false;
let stopRequested = false;
let client;
let pendingRun;
let pendingStop;
let pendingRefresh;
self.onmessage = ({ data }) => {
    if (data.type === 'getChainState') {
        try { postMessage({type:'chainState',requestId:data.requestId,state:client?.chainStateSnapshot ? JSON.parse(client.chainStateSnapshot()) : null}); }
        catch(error) { postMessage({type:'chainState',requestId:data.requestId,state:null,error:String(error)}); }
    } else if (data.type === 'getPool') {
        postMessage({type:'observedPool',requestId:data.requestId,transactions:client?.observedTransactions ? JSON.parse(client.observedTransactions()) : []});
    } else if (data.type === 'getHeaders') {
        const result = { type: 'headerWindow', requestId: data.requestId, ready: !!client, headers: [] };
        if (client) {
            const tip = Number(client.lastHeight());
            const top = data.height == null ? tip : Number(data.height);
            result.tip = tip;
            result.tipHash = client.headerHash(BigInt(tip));
            if (Number.isSafeInteger(top) && top >= 0 && top <= tip) {
                for (let height = top; height >= 0 && result.headers.length < Math.min(100, data.count ?? 100); --height) {
                    const parentHex=height>0?client.headerHex(BigInt(height-1)):null;
                    const parentTimestamp=parentHex?parseInt(parentHex.slice(136,144).match(/../g).reverse().join(''),16):null;
                    result.headers.push({ height, parentTimestamp, hex: client.headerHex(BigInt(height)), hash: client.headerHash(BigInt(height)), body: client.blockMetadata ? JSON.parse(client.blockMetadata(BigInt(height),data.includeTransactions === true && height === top)) : null });
                }
            }
        }
        postMessage(result);
    } else if (data.type === 'stop') {
        stopRequested = true;
        if (client && pendingRun) {
            pendingStop ??= client.asyncRequestStop();
            pendingStop.catch(error => postMessage({ type: 'diagnostic', message: String(error) }));
        }
    } else if (data.type === 'resume' && started && !stopRequested) {
        if (client && pendingRun && !pendingRefresh) {
            pendingRefresh = client.asyncRequestRefresh()
                .catch(error => postMessage({ type: 'diagnostic', message: String(error) }))
                .finally(() => { pendingRefresh = undefined; });
        }
    } else if (data.type === 'start' && !started) {
        started = true;
        synchronize(data);
    }
};

async function synchronize(options) {
    let observation;
    let announcedHeight = -1;
    let peerCount = -1;
    let contentKey = '';
    let timingTip='',blockInterval;
    const snapshot = () => {
        if (!client) return;
        const height = Number(client.lastHeight());
        const status = client.status();
        if(client.contentState) {
            const content=JSON.parse(client.contentState());
            const key=[content.revision,content.pool_revision,content.rejected_bodies,content.error,content.inflight_blocks,content.transaction_announcements,content.transactions_received,content.pending_transactions].join(':');
            if(key!==contentKey) {
                contentKey=key;
                postMessage({type:'contentProgress',...content});
            }
        }
        void storage?.save(client);
        const tipHash=client.headerHash(BigInt(height));
        const timingKey=height+':'+tipHash;
        if(timingKey!==timingTip){
            timingTip=timingKey;blockInterval=undefined;
            try { const interval=JSON.parse(client.chainStateSnapshot?.() || 'null')?.block_interval_seconds;if(Number.isFinite(interval)&&interval>0)blockInterval=interval; }
            catch(error){postMessage({type:'diagnostic',message:'Block interval: '+String(error)});}
        }
        const tipHex = client.headerHex(BigInt(height));
        const tipTimestamp = /^[0-9a-f]{160}$/i.test(tipHex)
            ? parseInt(tipHex.slice(136, 144).match(/../g).reverse().join(''), 16) : undefined;
        if (client.peerCount && client.peerCount() !== peerCount) {
            peerCount = client.peerCount();
            if (client.runtimeSettings) postMessage({type:'runtimeSettings',settings:JSON.parse(client.runtimeSettings())});
        }
        const peers = Array.from({length: client.peerCount?.() ?? 0}, (_, at) => ({endpoint:client.peerEndpoint(at), status:client.peerState(at), connected:client.peerConnected(at), userAgent:client.peerAgent(at), height:Number(client.peerHeight(at)), error:client.peerError(at), source:client.peerSource(at), announcements:Number(client.peerAnnouncements?.(at) ?? 0)}));
        postMessage({ type: 'progress', peers, height, status, bytes: client.indexMemoryBytes(), tipHash, tipTimestamp, blockInterval, userAgent: peers.find(peer => peer.connected)?.userAgent ?? '' });
        if (status === 'caught_up' && height !== announcedHeight) {
            announcedHeight = height;
            postMessage({ type: 'caughtUp', height });
        }
    };
    try {
        postMessage({ type: 'loading' });
        const endpoints=self.KnuthPeerEndpoint.unique(options.peers?.length ? options.peers : [options.bridge]);
        importScripts('browser_headers_persistent_v1.js', 'header-storage.js');
        const core = await createHeaders({ locateFile: file => file.endsWith('.wasm') ? 'browser_headers_persistent_v1.wasm' : file, printErr: message => postMessage({ type: 'diagnostic', message }) });
        storage = new HeaderStorage(core, options.network ?? 'mainnet');
        await storage.open();
        if (!stopRequested) {
            if (storage.hasCache()) postMessage({type:'storageValidating'});
            client = new core.HeaderSync(endpoints[0], options.network ?? 'mainnet', options.capacity ?? settings.defaultCapacity);
            if (client.configureContent && !client.configureContent(options.content?.blocks !== false, options.content?.transactions !== false)) throw new Error('Unable to configure content sampling');
            if (client.configureDiscovery && !client.configureDiscovery(options.discovery?.enabled !== false, options.discovery?.allowPrivate === true, options.discovery?.wssOnly === true)) throw new Error('Unable to configure peer discovery');
            for (const endpoint of endpoints.slice(1)) {
                if (!client.addPeer(endpoint)) throw new Error('Unable to configure peer: ' + endpoint);
            }
            storage.attach(client);
            snapshot();
            observation = setInterval(snapshot, settings.progressInterval);
            // Native follow owns reconnect/backoff and retains rejected peers
            // until an explicit reset. Do not restart it from a JS retry loop.
            if (!stopRequested) {
                pendingRun = client.asyncFollow();
                try { await pendingRun; }
                finally { pendingRun = undefined; }
            }
        }
        snapshot();
        postMessage({ type: 'stopped' });
    } catch (error) {
        // Publish the retained valid tip even if rejection happens between UI samples.
        snapshot();
        postMessage({ type: 'failure', message: String(error), detail: client?.status(), fatal: true });
    } finally {
        clearInterval(observation);
        if (client) {
            try {
                if (pendingRefresh) await pendingRefresh;
                if (pendingStop) await pendingStop;
                await storage?.save(client, true);
                client.dispose();
            } catch (error) {
                postMessage({ type: 'failure', message: 'Cleanup: ' + String(error), fatal: true });
            }
            client = undefined;
        }
        postMessage({ type: 'closed' });
    }
}
