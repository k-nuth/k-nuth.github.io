// Shared display formatting for the UI and its Worker. Keep protocol/raw data unchanged.
(() => {
    function number(value, options={maximumFractionDigits:20}) {
        const numeric = typeof value === 'string' && /^-?\d+$/.test(value) ? BigInt(value) : value;
        return (typeof numeric === 'bigint' ? numeric.toLocaleString('en-US') : Number(numeric).toLocaleString('en-US', options)).replace(/,/g, "'");
    }
    function bytes(value) {
        const size=Number(value);
        if(!Number.isFinite(size)||size<0)return '—';
        const units=['B','kB','MB','GB','TB'];
        const unit=size<1000?0:Math.min(Math.floor(Math.log10(size)/3),units.length-1);
        return number(size/1000**unit,{maximumFractionDigits:unit?2:0})+' '+units[unit];
    }
    const api = Object.freeze({number,bytes,fixed:(value,digits=1)=>number(value,{minimumFractionDigits:digits,maximumFractionDigits:digits})});
    if(typeof module !== 'undefined' && module.exports)module.exports=api;
    else (typeof window==='undefined'?self:window).KnuthFormat=api;
})();
