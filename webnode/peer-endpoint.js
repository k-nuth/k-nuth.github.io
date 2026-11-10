// Use the native discovery codec's explicit-port form before creating sessions.
(() => {
    function canonical(value) {
        const url = new URL(value);
        if (!['ws:', 'wss:'].includes(url.protocol) || url.username || url.password || url.hash)
            throw new Error('Invalid WebSocket peer endpoint');
        const port = url.port || (url.protocol === 'wss:' ? '443' : '80');
        return url.protocol + '//' + url.hostname + ':' + port + url.pathname + url.search;
    }
    function unique(values) { return [...new Set(values.map(canonical))]; }
    const api = Object.freeze({canonical, unique});
    if (typeof module !== 'undefined' && module.exports) module.exports = api;
    else (typeof window === 'undefined' ? self : window).KnuthPeerEndpoint = api;
})();
