// Explicit, opt-in layout measurements for the local development server.
(() => {
    if(!new URLSearchParams(location.search).has('layout-debug'))return;
    let sent=0,last='';
    function measure(){
        if(sent>=6)return;
        const selectors=['html','body','.app-shell','header','.brand','.header-indicators','#app-nav','#node-loading','#sync-view','.dashboard-grid','.sync-panel','.metrics'];
        const boxes=selectors.map(selector=>{const e=document.querySelector(selector);if(!e)return null;const r=e.getBoundingClientRect(),c=getComputedStyle(e);return {selector,x:Math.round(r.x),w:Math.round(r.width),right:Math.round(r.right),client:e.clientWidth,scroll:e.scrollWidth,display:c.display,min:c.minWidth,columns:c.gridTemplateColumns,font:c.fontSize,box:c.boxSizing};});
        const report={version:window.KNUTH_WEB_NODE_VERSION,phase:document.querySelector('#node-status')?.dataset.status,inner:innerWidth,client:document.documentElement.clientWidth,scroll:document.documentElement.scrollWidth,screen:screen.width,dpr:devicePixelRatio,visual:visualViewport?{width:visualViewport.width,scale:visualViewport.scale,left:visualViewport.offsetLeft}:null,mobile:matchMedia('(max-width:600px)').matches,boxes};
        const wire=JSON.stringify(report);if(wire===last)return;last=wire;++sent;
        // A same-origin static request records measurements in the local HTTP access log.
        fetch('logo-white.svg?layout-report='+encodeURIComponent(wire),{cache:'no-store'}).catch(()=>{});
    }
    measure();document.fonts?.ready.then(measure);setTimeout(measure,1000);
    window.addEventListener('resize',measure);window.addEventListener('node-phase',()=>setTimeout(measure,100));
})();
