// Worker-owned IDBFS cache. Each network has its own database and one atomic header file.
class HeaderStorage {
    constructor(core, network) {
        const names = {mainnet:'Mainnet',testnet:'Testnet',regtest:'Regtest',testnet4:'Testnet4',scalenet:'Scalenet',chipnet:'Chipnet',tempnet:'Tempnet'};
        const name = names[network];
        if (!name) throw new Error('Unknown storage network');
        this.core = core;
        this.path = '/kth-header-cache/' + name;
        this.file = this.path + '/chain-v1.bin';
        this.contentPath = '/kth-block-cache/' + name;
        this.available = false;
        this.inflight = undefined;
        this.stamp = undefined;
        this.lastSave = -Infinity;
    }
    sync(populate) {
        return new Promise((resolve, reject) => this.core.FS.syncfs(populate, error => error ? reject(error) : resolve()));
    }
    report(error) {
        this.available = false;
        postMessage({type:'storageUnavailable',message:'Unable to save the chain in this browser: ' + String(error)});
    }
    async open() {
        try {
            postMessage({type:'storageLoading'});
            this.core.FS.mkdirTree(this.path);
            this.core.FS.mount(this.core.IDBFS, {}, this.path);
            this.core.FS.mkdirTree(this.contentPath);
            this.core.FS.mount(this.core.IDBFS, {}, this.contentPath);
            await this.sync(true);
            this.available = true;
        } catch (error) { this.report(error); }
    }
    hasCache() {
        return this.available && this.core.FS.analyzePath(this.file).exists;
    }
    attach(client) {
        if (!this.available) return;
        const height = Number(client.lastHeight());
        if (this.hasCache()) this.stamp = height + ':' + client.headerHash(BigInt(height)) + ':' + (client.contentState ? JSON.parse(client.contentState()).revision : 0);
        postMessage({type:'storageRestored',height});
        const blocks=client.contentState ? JSON.parse(client.contentState()).cached_blocks : 0;
        if(blocks)postMessage({type:'contentRestored',blocks,message:'Recent block cache restored · '+self.KnuthFormat.number(blocks)+' blocks'});
    }
    async discard() {
        this.core.FS.unlink(this.file);
        const content = this.contentPath + '/content-v1.bin';
        if (this.core.FS.analyzePath(content).exists) this.core.FS.unlink(content);
        this.stamp = undefined;
        try { await this.sync(false); } catch (error) { this.report(error); }
        postMessage({type:'storageReset',message:'The saved chain failed validation. Synchronization will restart from genesis.'});
    }
    async save(client, force = false) {
        if (!this.available) return;
        if (this.inflight) {
            if (force) { await this.inflight; return this.save(client, true); }
            return;
        }
        if (!force && performance.now() - this.lastSave < (self.KTH_NODE_SETTINGS?.storageSaveInterval ?? 2000)) return;
        try {
            const height = Number(client.lastHeight());
            const stamp = height + ':' + client.headerHash(BigInt(height)) + ':' + (client.contentState ? JSON.parse(client.contentState()).revision : 0);
            if (this.stamp === stamp || !this.hasCache()) return;
            if (this.core.FS.stat(this.file).size !== (height + 1) * 80) throw new Error('Incomplete local block snapshot');
            this.lastSave = performance.now();
            this.inflight = this.sync(false).then(() => {
                this.stamp = stamp;
                postMessage({type:'storageSaved',height});
            }).catch(error => this.report(error));
            await this.inflight;
        } catch (error) { this.report(error); }
        finally { this.inflight = undefined; }
    }
}
self.HeaderStorage = HeaderStorage;
