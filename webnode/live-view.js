(() => {
    const el=id=>document.getElementById(id), model=window.KnuthLiveModel.create();
    const number=value=>window.KnuthFormat.number(value);
    let active=false,paused=false,serial=0,totalTx=0,totalBlocks=0;
    const reduced=matchMedia('(prefers-reduced-motion: reduce)');
    const text=(tag,value)=>{const node=document.createElement(tag);node.textContent=value;return node;};
    function pulse(kind,count,endpoint) {
        if(!active || paused || document.hidden || reduced.matches)return;
        const stage=el('live-particles');
        if(stage.childElementCount>=32)return;
        const dot=document.createElement('span');dot.className='live-particle live-particle-'+kind;
        dot.style.setProperty('--lane',String((serial++%5)*13+15)+'%');
        dot.title=endpoint || number(count)+' '+kind;stage.append(dot);
        dot.addEventListener('animationend',()=>dot.remove(),{once:true});setTimeout(()=>dot.remove(),2200);
    }
    function record(event) {
        const row=document.createElement('li'),button=text('button',event.kind==='block'?'Block '+number(event.height)+' · validated tip':number(event.count)+' transactions '+event.kind);
        button.type='button';row.append(text('time',new Date().toLocaleTimeString('en-GB',{hour12:false})),button);
        button.onclick=()=>{el('live-detail').textContent=event.kind==='block'?'Validated header tip: '+number(event.height)+'\nHash: '+event.hash+(event.count>1?'\nAdvanced '+number(event.count)+' heights since the previous update.':''):'Transactions '+event.kind+': '+number(event.count)+'\nObserved in the latest native content snapshot. Peer attribution is unavailable for these counters.';el('live-detail-dialog').showModal();};
        el('live-events').prepend(row);while(el('live-events').children.length>30)el('live-events').lastChild.remove();
    }
    function reset() {totalTx=totalBlocks=0;el('live-tx-count').textContent='0';el('live-block-count').textContent='0';el('live-events').replaceChildren();el('live-chain').replaceChildren();el('live-particles').replaceChildren();el('live-peers').replaceChildren();}
    el('live-pause').onclick=()=>{paused=!paused;el('live-pause').textContent=paused?'Resume animation':'Pause animation';el('live-pause').setAttribute('aria-pressed',String(paused));if(paused)el('live-particles').replaceChildren();};
    el('live-detail-close').onclick=()=>el('live-detail-dialog').close();
    window.addEventListener('node-view-changed',()=>{active=(window.KNUTH_PAGE_PATH?.() || location.pathname).replace(/\/$/,'')==='/live';if(!active)el('live-particles').replaceChildren();});
    window.addEventListener('node-network-changed',()=>{model.accept({type:'closed'});reset();el('live-state').textContent='Ready to start';});
    window.addEventListener('node-message',({detail:data})=>{
        const events=model.accept(data);
        if(data.type==='loading'){reset();el('live-state').textContent='Loading local chain';}
        if(data.type==='closed'){el('live-state').textContent='Stopped';el('live-particles').replaceChildren();}
        if(data.type==='progress') {
            el('live-state').textContent=data.status==='caught_up'?'Following the chain':data.status==='synchronizing'?'Synchronizing':'Connecting';
            const peers=(data.peers || []).filter(peer=>peer.connected);
            el('live-peer-count').textContent=number(peers.length);
            el('live-peers').replaceChildren(...peers.slice(0,8).map(peer=>{const item=text('span',peer.endpoint);item.title=peer.userAgent || 'User agent unavailable';return item;}));
        }
        for(const event of events) {
            if(event.kind==='peer'){pulse('peer',event.count,event.endpoint);continue;}
            if(event.kind==='received'){totalTx+=event.count;el('live-tx-count').textContent=number(totalTx);}
            if(event.kind==='block') {
                totalBlocks+=event.count;el('live-block-count').textContent=number(totalBlocks);
                const block=text('button',number(event.height));block.type='button';block.title=event.hash;block.onclick=()=>{el('live-detail').textContent='Validated header tip: '+number(event.height)+'\nHash: '+event.hash;el('live-detail-dialog').showModal();};el('live-chain').prepend(block);while(el('live-chain').children.length>6)el('live-chain').lastChild.remove();
            }
            pulse(event.kind,event.count);record(event);
        }
    });
})();
