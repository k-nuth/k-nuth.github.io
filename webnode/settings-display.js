(() => {
    const date = value => {
        const instant = new Date(Number(value) * 1000);
        return Number.isFinite(instant.getTime()) ? new Intl.DateTimeFormat('en-GB', {day:'numeric',month:'long',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hourCycle:'h23',timeZone:'UTC',timeZoneName:'short'}).format(instant) : 'Invalid timestamp';
    };
    const timestamp = key => /(?:timestamp|activation_time)$/.test(key);
    const upgrades = {
        bch_uahf: ['Bitcoin Cash launch · 2017-Aug-01', 'User Activated Hard Fork: the upgrade that launched Bitcoin Cash, increased the block-size limit to 8 MB, introduced replay protection and the emergency difficulty adjustment. This is the mainnet edition date; test-network activation can differ.', 'https://upgradespecs.bitcoincashnode.org/uahf-technical-spec/'],
        bch_daa_cw144: ['Difficulty adjustment · 2017-Nov-13', 'CW-144 (chainwork over 144 blocks) replaced the emergency difficulty adjustment with a per-block difficulty algorithm based on accumulated work and elapsed time. The upgrade also enforced LOW_S and NULLFAIL signature rules. This is the mainnet edition date; test-network activation can differ.', 'https://upgradespecs.bitcoincashnode.org/nov-13-hardfork-spec/']
    };
    function help(element, heading, description, source) {
        let popup = document.getElementById('setting-info');
        if (!popup) {
            popup = document.createElement('aside'); popup.id = 'setting-info'; popup.className = 'upgrade-story'; popup.setAttribute('popover',''); popup.setAttribute('role','dialog'); popup.setAttribute('aria-labelledby','setting-info-title');
            const close = document.createElement('button'); close.className = 'upgrade-story-close'; close.textContent = '×'; close.setAttribute('popovertarget',popup.id); close.setAttribute('popovertargetaction','hide'); close.setAttribute('aria-label','Close information');
            const title = document.createElement('h2'); title.id = 'setting-info-title';
            const body = document.createElement('p'); body.id = 'setting-info-body';
            const link = document.createElement('a'); link.id = 'setting-info-source'; link.textContent = 'Read the specification ↗'; link.target = '_blank'; link.rel = 'noopener noreferrer';
            popup.append(close,title,body,link); document.body.append(popup);
        }
        const button = document.createElement('button'); button.type = 'button'; button.className = 'setting-hint'; button.textContent = element.textContent; button.title = description;
        button.setAttribute('popovertarget',popup.id); button.setAttribute('aria-haspopup','dialog');
        button.onclick = () => {
            document.getElementById('setting-info-title').textContent = heading;
            document.getElementById('setting-info-body').textContent = description;
            const link = document.getElementById('setting-info-source'); link.hidden = !source; if (source) link.href = source;
        };
        element.replaceChildren(button);
    }
    window.KnuthSettingsDisplay = {date, timestamp, upgrades, help};
})();
