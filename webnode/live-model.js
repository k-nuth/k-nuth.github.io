(() => {
    function create() {
        let content, tip, following=false;
        const peers=new Map();
        return {accept(data) {
            const events=[];
            if (['closed','loading','storageLoading'].includes(data.type)) {content=tip=undefined;following=false;peers.clear();return events;}
            const delta=(next,previous)=>Math.max(0,(Number(next)||0)-(Number(previous)||0));
            if(data.type==='contentProgress') {
                if(content) for(const [key,kind] of [['transaction_announcements','announced'],['transactions_received','received']]) {
                    const count=delta(data[key],content[key]);if(count)events.push({kind,count});
                }
                content=data;
            }
            if(data.type==='progress') {
                for(const peer of data.peers || []) {
                    if(peers.has(peer.endpoint) && peer.connected) {
                        const count=delta(peer.announcements,peers.get(peer.endpoint));
                        if(count)events.push({kind:'peer',count,endpoint:peer.endpoint});
                    }
                    peers.set(peer.endpoint,peer.announcements);
                }
                if(following && data.tipHash && tip && data.tipHash!==tip.hash && ['caught_up','synchronizing'].includes(data.status))
                    events.push({kind:'block',height:data.height,hash:data.tipHash,previous:tip.height,count:Math.max(1,data.height-tip.height)});
                if(data.status==='caught_up')following=true;
                if(data.tipHash)tip={height:data.height,hash:data.tipHash};
            }
            return events;
        }};
    }
    if(typeof module!=='undefined' && module.exports)module.exports={create};
    else window.KnuthLiveModel={create};
})();
