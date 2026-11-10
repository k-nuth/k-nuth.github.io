(() => {
    const miners = [
        ['BitcoinCashPool.org', /bitcoincashpool\.org/i],
        ['BlockExplorer.cash', /\/blockexplorer\.cash\//i], ['9500-tempnet', /^\s*9500-tempnet\s*$/i],
        ['ViaBTC', /viabtc/i], ['AntPool', /antpool/i], ['F2Pool', /f2pool|discus fish/i],
        ['BCHN', /bitcoin cash node|\/bchn\//i], ['Knuth', /knuth|\/kth\//i],
        ['Vcash', /vcash/i], ['Bitcoin.com', /bitcoin\.com/i], ['BTC.com', /btc\.com/i],
        ['BTC.TOP', /btc\.top/i], ['BCH.TOP', /bch\.top/i], ['Mining-Dutch', /mining[ -]?dutch/i],
        ['SBI Crypto', /sbi[ -]?crypto/i], ['SpiderPool', /spiderpool/i], ['Poolin', /poolin/i],
        ['ZULUPooL', /zulupool/i], ['CKPool', /ckpool/i], ['SoloPool', /solopool/i],
        ['P2Pool', /p2pool/i], ['molepool', /molepool/i], ['zpool', /zpool/i], ['zergpool', /zergpool/i]
    ];
    function minerName(body) {
        if (!body) return '—';
        const tag = body.coinbase_tag || '';
        // Attribution from recognizable coinbase text only. Random printable bytes are not miner names.
        const known = miners.find(([, pattern]) => pattern.test(tag))?.[0];
        if (known) return known;
        // A miner can identify itself with a /domain.name/ tag without being
        // in this catalogue. Keep arbitrary printable coinbase text unattributed.
        const declared = /\/((?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,24})\//i.exec(tag);
        return declared && declared[1].length <= 128 ? declared[1] : 'Unknown';
    }
    function poolSummary(transactions) {
        const sizes = transactions.map(tx => Number(tx.bytes));
        const total = sizes.reduce((a,b) => a+b,0);
        const bands = [250,500,1000,2000,Infinity];
        return {count:sizes.length,bytes:total,average:sizes.length ? total/sizes.length : 0,
            oldest:transactions.length ? Math.min(...transactions.map(tx=>tx.received_at)) : null,
            buckets:bands.map((upper,i)=>sizes.filter(size=>size>= (i ? bands[i-1] : 0) && size<upper).length)};
    }
    const api = {minerName,poolSummary};
    if(typeof module !== 'undefined' && module.exports) module.exports=api;
    else window.KnuthTransactions=api;
})();
