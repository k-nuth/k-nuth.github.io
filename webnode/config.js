// Public Chipnet seed. The browser connects directly over native P2P/WSS.
// Use `peers: [...]` to configure multiple seeds, or `networks` for other networks.
window.KTH_BROWSER_CONFIG = {
    network: 'chipnet',
    networkRevision: 'chipnet-2026-11-15',
    peer: 'wss://chipnet.kth.cash/p2p',
    discovery: { enabled: true, allowPrivate: false }
};
