// Public Tempnet seed. The browser connects directly over native P2P/WSS.
// Use `peers: [...]` to configure multiple seeds, or `networks` for other networks.
window.KTH_BROWSER_CONFIG = {
    network: 'tempnet',
    peer: 'wss://tempnet.kth.cash/p2p',
    discovery: { enabled: true, allowPrivate: false }
};
