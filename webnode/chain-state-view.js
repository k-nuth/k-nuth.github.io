(() => {
    const byId=id=>document.getElementById(id);
    let active=false,pending=0,sequence=0,tipKey='',loaded=false,dirty=false;
    const number=value=>window.KnuthFormat.number(value);
    const utc=value=>new Date(Number(value)*1000).toISOString().replace('T',' ').replace('.000Z',' UTC');
    const valueText=value=>value==null?'—':typeof value==='boolean'?(value?'Yes':'No'):typeof value==='number'?number(value):String(value);
    function request(){if(active && !pending && window.requestChainState){dirty=false;pending=++sequence;window.requestChainState({requestId:pending});}}
    function clear(message){pending=0;tipKey='';loaded=false;byId('chain-state-summary').hidden=true;byId('chain-state-raw').hidden=true;byId('chain-state-fields').replaceChildren();byId('chain-state-empty').hidden=false;byId('chain-state-empty').textContent=message;}
    function panel(title,entries){
        const section=document.createElement('section');section.className='panel';if(title==='Network upgrades')section.classList.add('network-upgrades-panel');
        const heading=document.createElement('div');heading.className='section-heading';const h=document.createElement('h2');const helpTarget={'Network upgrades':'upgrade-story','DAA':'daa-story'}[title];if(helpTarget){
            const button=document.createElement('button');button.type='button';button.className='upgrade-help-title';button.textContent=title;
            button.setAttribute('popovertarget',helpTarget);button.setAttribute('aria-haspopup','dialog');h.append(button);
        }else h.textContent=title;
        heading.append(h);
        const dl=document.createElement('dl');dl.className='settings-fields chain-state-values';
        for(const [name,value,hint,person] of entries){const row=document.createElement('div'),dt=document.createElement('dt'),dd=document.createElement('dd');if(person && window.KnuthUpgrades.editions[person]){
            const button=document.createElement('button');button.type='button';button.className='upgrade-person-name';button.textContent=window.KnuthUpgrades.name(person);button.setAttribute('popovertarget','upgrade-person-'+person);button.setAttribute('aria-haspopup','dialog');
            const date=document.createElement('span');date.className='upgrade-edition';date.textContent=' - '+window.KnuthUpgrades.editions[person];dt.append(button,date);
        }else dt.textContent=name;dd.textContent=title==='Network upgrades'?(value==null?'Unknown':value?'Active':'Inactive'):valueText(value);if(name==='Enabled flags'){dd.replaceChildren(window.KnuthConsensusFlags.render(value));}if(hint){dd.title=hint;if(['Block timestamp','Parent median time past','Anchor ancestor timestamp'].includes(name))window.KnuthSettingsDisplay.help(dd,name,hint);}if(typeof value==='boolean'){dd.className=value?'state-yes':'state-no';}row.append(dt,dd);dl.append(row);}
        section.append(heading,dl);return section;
    }
    function render(state){
        byId('chain-state-empty').hidden=true;byId('chain-state-summary').hidden=false;byId('chain-state-raw').hidden=false;
        byId('chain-state-height').textContent=number(state.height);byId('chain-state-interval').textContent=state.block_interval_seconds==null?'—':number(state.block_interval_seconds)+' s';
        byId('chain-state-hash').textContent=state.hash;
        const timing=[['Block timestamp',utc(state.timestamp),window.KnuthSettingsDisplay.date(state.timestamp)],['Parent median time past',utc(state.median_time_past),window.KnuthSettingsDisplay.date(state.median_time_past)],['Block tick',state.tick],['Parent tick',state.parent_tick],['Faster blocks active',state.faster_blocks_active]];
        const consensus=[['Block version',state.version],['Minimum version',state.minimum_version],['Block bits',state.bits],['Required work · bits',state.work_required],['Enabled flags',state.enabled_flags],['Retarget height',state.is_retarget_height],['Under checkpoint',state.is_under_checkpoint],['Checkpoint conflict',state.checkpoint_conflict],['Null state',state.is_null]];
        const asert=state.asert || {};
        const sections=[panel('Time & intervals',timing),panel('Consensus',consensus),panel('DAA',[['ASERT anchor height',asert.anchor_height],['Anchor ancestor timestamp',asert.ancestor_timestamp==null?null:utc(asert.ancestor_timestamp),asert.ancestor_timestamp==null?null:window.KnuthSettingsDisplay.date(asert.ancestor_timestamp)],['Anchor bits',asert.anchor_bits],['Half-life',asert.half_life_seconds==null?null:number(asert.half_life_seconds)+' s']]),panel('Network upgrades',window.KnuthUpgrades.entries(state).map(([key,value])=>[window.KnuthUpgrades.label(key),value,key==='bitcoin_legacy'?'Historical Bitcoin milestone, displayed as active; not a native activation flag':'Upgrade edition date; activation status is for the selected network',key]))];
        byId('chain-state-fields').replaceChildren(...sections);byId('chain-state-json').textContent=JSON.stringify(state,null,2);
        byId('chain-state-status').textContent='Current block · '+number(state.height);loaded=true;
    }
    window.addEventListener('node-view-changed',()=>{active=window.KNUTH_PAGE_PATH().replace(/\/$/,'')==='/chain-state';if(active)request();});
    window.addEventListener('node-network-changed',()=>{clear('Start the node to load the current block state.');byId('chain-state-status').textContent='Not started';});
    window.addEventListener('node-phase',({detail})=>{if(detail.status==='loading'){clear('Loading the local chain…');byId('chain-state-status').textContent='Loading';}});
    window.addEventListener('node-message',({detail:data})=>{
        if(data.type==='progress'){const key=data.height+':'+data.tipHash;if(tipKey!==key){tipKey=key;dirty=true;request();}}
        if(data.type==='chainState' && data.requestId===pending){pending=0;if(data.error || data.state?.error){clear(data.error || data.state.error);byId('chain-state-status').textContent='Unavailable';return;}if(data.state){render(data.state);if(dirty)request();}else if(!loaded)clear('Start the node to load the current block state.');}
        if(data.type==='closed'){clear('The node is stopped.');byId('chain-state-status').textContent='Stopped';}
    });
    clear('Start the node to load the current block state.');
})();
