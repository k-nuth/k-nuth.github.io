// One age format and one interval-relative colour scale across all block views.
(() => {
    const number=typeof module!=='undefined'&&module.exports?require('./number-format.js').number:window.KnuthFormat.number;
    function duration(seconds){
        let remaining=Math.floor(Math.abs(seconds));
        const units=remaining>=31536000?[[31536000,'yr'],[86400,'d'],[3600,'h'],[60,'min']]
            :remaining>=86400?[[86400,'d'],[3600,'h'],[60,'min']]
            :remaining>=3600?[[3600,'h'],[60,'min'],[1,'s']]
            :remaining>=60?[[60,'min'],[1,'s']]:[[1,'s']];
        const parts=[];
        for(const [size,label] of units){const value=Math.floor(remaining/size);remaining%=size;if(value || size===1)parts.push(number(value)+' '+label);}
        return parts.join(' ');
    }
    function describe(timestamp,interval,now=Date.now()/1000){
        if(!Number.isFinite(timestamp))return {text:'—',state:'unknown',title:''};
        const age=now-timestamp;
        const valid=Number.isFinite(interval)&&interval>0;
        const state=age<0?'future':!valid?'unknown':age<interval/6?'fresh':age<=interval?'normal':'over';
        const text=age<0?'In '+duration(age):duration(age)+' ago';
        const label={fresh:'Fresh',normal:'Within interval',over:'Older than one interval',future:'Future timestamp',unknown:'Interval unavailable'}[state];
        return {text,state,title:new Date(timestamp*1000).toISOString()+' · '+label+(valid?' · '+duration(interval)+' reference':'')};
    }
    function apply(element,timestamp,interval){const result=describe(timestamp,interval);element.textContent=result.text;element.dataset.ageState=result.state;element.title=result.title;}
    const api=Object.freeze({duration,describe,apply});
    if(typeof module!=='undefined'&&module.exports)module.exports=api;else window.KnuthBlockAge=api;
})();
