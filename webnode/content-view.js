(() => {
    const byId=id=>document.getElementById(id);
    const number=value=>window.KnuthFormat.number(value);
    const bytes=value=>value<1024?number(Math.round(value))+' B':value<1048576?window.KnuthFormat.fixed(value/1024)+' KiB':window.KnuthFormat.fixed(value/1048576)+' MiB';
    const age=timestamp=>{const seconds=Math.max(0,Math.floor(Date.now()/1000-timestamp));return seconds<60?seconds+'s':seconds<3600?Math.floor(seconds/60)+'m '+seconds%60+'s':Math.floor(seconds/3600)+'h '+Math.floor(seconds%3600/60)+'m';};
    let sequence=0,pending=0,lastPoolRevision=-1,active=false,lastError='',transactions=[],page=0,dirty=true,connected=false;
    const limit=25;
    const request=()=>{if(active && window.requestObservedPool && !pending){dirty=false;pending=++sequence;window.requestObservedPool({requestId:pending});}};
    const text=(tag,value,className)=>{const el=document.createElement(tag);el.textContent=value;if(className)el.className=className;return el;};
    function render(){
        const summary=window.KnuthTransactions.poolSummary(transactions);
        byId('pool-count').textContent=number(summary.count);byId('pool-bytes').textContent=bytes(summary.bytes);
        byId('pool-average').textContent=summary.count?bytes(summary.average):'—';
        byId('pool-oldest').textContent=summary.oldest?age(summary.oldest):'—';
        const labels=['< 250 B','250–499 B','500–999 B','1–2 kB','≥ 2 kB'];
        const maximum=Math.max(1,...summary.buckets);
        byId('pool-distribution').replaceChildren(...summary.buckets.map((count,i)=>{
            const bar=document.createElement('div');bar.className='pool-bar';bar.setAttribute('aria-label',labels[i]+': '+count+' transactions');
            const track=document.createElement('div');track.className='pool-bar-track';const fill=document.createElement('span');fill.style.height=(count/maximum*100)+'%';track.append(fill);
            bar.append(text('strong',number(count)),track,text('span',labels[i]));return bar;
        }));
        const sorted=[...transactions];
        const sort=byId('pool-sort').value;
        sorted.sort((a,b)=>(sort==='largest'?b.bytes-a.bytes:sort==='oldest'?a.received_at-b.received_at:b.received_at-a.received_at)||a.txid.localeCompare(b.txid));
        const pages=Math.max(1,Math.ceil(sorted.length/limit));page=Math.min(page,pages-1);
        byId('pool-results').textContent=number(transactions.length)+' transactions';
        const fragment=document.createDocumentFragment();
        for(const tx of sorted.slice(page*limit,(page+1)*limit)){
            const row=document.createElement('tr');
            const id=document.createElement('td');id.className='pool-txid';const copy=text('button',tx.txid.slice(0,16)+'…'+tx.txid.slice(-12),'pool-copy');copy.type='button';copy.title='Copy transaction ID';copy.setAttribute('aria-label','Copy transaction ID '+tx.txid);
            copy.onclick=async()=>{
                try{
                    if(navigator.clipboard && window.isSecureContext)await navigator.clipboard.writeText(tx.txid);
                    else{
                        const field=document.createElement('textarea');field.value=tx.txid;field.readOnly=true;field.style.cssText='position:fixed;opacity:0;pointer-events:none';document.body.append(field);
                        try{field.select();if(!document.execCommand('copy'))throw Error('Clipboard unavailable');}finally{field.remove();copy.focus({preventScroll:true});}
                    }
                    copy.title='Transaction ID copied';copy.setAttribute('aria-label','Transaction ID copied');copy.classList.add('copied');
                }catch{copy.classList.remove('copied');copy.title='Could not copy transaction ID';copy.setAttribute('aria-label','Could not copy transaction ID');}
                setTimeout(()=>{copy.title='Copy transaction ID';copy.setAttribute('aria-label','Copy transaction ID '+tx.txid);copy.classList.remove('copied');},2000);
            };
            id.append(copy);row.append(id);
            const seen=text('td',age(tx.received_at)+' ago','pool-seen');seen.dataset.seen=tx.received_at;seen.title=new Date(tx.received_at*1000).toISOString();row.append(seen,text('td',bytes(tx.bytes)));
            fragment.append(row);
        }
        if(!sorted.length){const row=document.createElement('tr'),cell=document.createElement('td');cell.colSpan=3;cell.className='headers-empty';cell.append(text('strong',connected?'Waiting for transactions':'No transactions observed'),text('span',connected?'New transactions will appear here as peers announce them.':'Start the node from Overview to receive transactions.'));row.append(cell);fragment.append(row);}
        byId('pool-rows').replaceChildren(fragment);byId('pool-page').textContent=(page+1)+' / '+pages;
        byId('pool-prev').disabled=page===0;byId('pool-next').disabled=page>=pages-1;
    }
    function clear(){pending=0;lastPoolRevision=-1;transactions=[];page=0;dirty=true;connected=false;byId('pool-status').textContent='Start the node to receive transactions.';byId('pool-connection').textContent='Not started';byId('pool-dot').classList.remove('live');render();}
    byId('pool-sort').addEventListener('change',()=>{page=0;render();});
    byId('pool-prev').onclick=()=>{page=Math.max(0,page-1);render();};byId('pool-next').onclick=()=>{++page;render();};
    window.addEventListener('node-view-changed',()=>{active=window.KNUTH_PAGE_PATH().replace(/\/$/,'')==='/mempool';if(active){render();request();}});
    window.addEventListener('node-network-changed',clear);
    window.addEventListener('node-phase',({detail})=>{if(detail.status==='loading'){byId('pool-connection').textContent='Loading';byId('pool-status').textContent='Loading local chain…';}});
    window.addEventListener('node-message',({detail:data})=>{
        if(data.type==='closed'){clear();return;}
        if(data.type==='progress'){
            connected=['connected','synchronizing','caught_up'].includes(data.status);
            byId('pool-dot').classList.toggle('live',connected);byId('pool-connection').textContent=connected?'Listening to peers':data.status==='stopped'?'Stopped':'Connecting';
        }
        if(data.type==='retry'){connected=false;byId('pool-dot').classList.remove('live');byId('pool-connection').textContent='Reconnecting';}
        if(data.type==='contentProgress'){
            if(data.error && data.error!==lastError){lastError=data.error;window.appendNodeLog?.({at:new Date().toISOString(),type:'diagnostic',message:'Block cache: '+data.error});}
            byId('pool-status').textContent=data.transactions_enabled?number(data.transaction_announcements || 0)+' announced · '+number(data.transactions_received || 0)+' received · 20 min retention':'Transaction observation disabled';
            if(lastPoolRevision!==data.pool_revision){lastPoolRevision=data.pool_revision;dirty=true;if(active)request();}
        }
        if(data.type==='observedPool' && data.requestId===pending){pending=0;transactions=data.transactions;render();if(dirty)request();}
    });
    setInterval(()=>{if(!active || document.hidden)return;const oldest=window.KnuthTransactions.poolSummary(transactions).oldest;byId('pool-oldest').textContent=oldest?age(oldest):'—';for(const cell of byId('pool-rows').querySelectorAll('[data-seen]'))cell.textContent=age(Number(cell.dataset.seen))+' ago';if(dirty)request();},1000);
    clear();
})();
