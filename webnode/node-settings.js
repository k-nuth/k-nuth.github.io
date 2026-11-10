// Shared application defaults used by the UI, Worker and storage helper.
(typeof window === 'undefined' ? self : window).KTH_NODE_SETTINGS = Object.freeze({
    tempnetCapacity: 600000,
    defaultCapacity: 1500000,
    maxPeers: 8,
    storageSaveInterval: 2000,
    progressInterval: 200,
    retryInitial: 5000,
    retryMaximum: 60000,
    retryJitter: 1000
});
