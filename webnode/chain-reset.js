// Clear the IDBFS cache for one network after its Worker has closed.
const clearNetworkStore = name => new Promise((resolve, reject) => {
    let settled = false;
    const fail = error => {
        if (settled) return;
        settled = true;
        reject(error || new Error('Unable to clear local chain'));
    };
    const request = indexedDB.open(name);
    request.onerror = () => fail(request.error);
    request.onblocked = () => fail(new Error('Storage is busy. Close other Web Node tabs and retry.'));
    request.onsuccess = () => {
        const db = request.result;
        if (settled) { db.close(); return; }
        if (!db.objectStoreNames.contains('FILE_DATA')) {
            db.close(); settled = true; resolve(); return;
        }
        try {
            const transaction = db.transaction('FILE_DATA', 'readwrite');
            transaction.objectStore('FILE_DATA').clear();
            transaction.oncomplete = () => { db.close(); settled = true; resolve(); };
            transaction.onabort = () => { db.close(); fail(transaction.error); };
            transaction.onerror = () => { /* onabort delivers the transaction failure. */ };
        } catch (error) { db.close(); fail(error); }
    };
});

window.clearStoredChain = async network => {
    const names = {mainnet:'Mainnet',testnet:'Testnet',regtest:'Regtest',testnet4:'Testnet4',scalenet:'Scalenet',chipnet:'Chipnet',tempnet:'Tempnet'};
    if(!names[network])throw new Error('Unknown storage network');
    // Independent mounts keep legacy header-only tabs from deleting new metadata.
    await Promise.all(['/kth-header-cache/','/kth-block-cache/'].map(prefix=>clearNetworkStore(prefix+names[network])));
};
