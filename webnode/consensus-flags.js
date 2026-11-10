// Individual BCH flags from KTH 1.6.1 machine/script_flags.hpp.
(() => {
    const definitions = [["easy_blocks", 0], ["bip16_rule", 1], ["bip30_rule", 2], ["bip34_rule", 3], ["bip66_rule", 4], ["bip65_rule", 5], ["bip90_rule", 6], ["allow_collisions", 7], ["bip68_rule", 8], ["bip112_rule", 9], ["bip113_rule", 10], ["bch_strictenc", 11], ["bch_sighash_forkid", 12], ["bch_low_s", 13], ["bch_nullfail", 14], ["bch_reactivated_opcodes", 15], ["bch_sigpushonly", 16], ["bch_cleanstack", 17], ["bch_schnorr_multisig", 18], ["bch_minimaldata", 19], ["bch_enforce_sigchecks", 20], ["bch_64bit_integers", 21], ["bch_native_introspection", 22], ["bch_p2sh_32", 23], ["bch_tokens", 24], ["bch_vm_limits", 25], ["bch_bigint", 26], ["bch_loops", 27], ["bch_subroutines", 28], ["bch_bitwise_ops", 29], ["bch_p2s", 30], ["bch_2027_may", 31], ["bch_vm_limits_standard", 57], ["bch_minimalif", 58], ["bch_input_sigchecks", 59], ["bch_discourage_upgradable_nops", 60], ["bch_disallow_segwit_recovery", 61], ["retarget", 62], ["unverified", 63]];
    const descriptions = {
        easy_blocks:'Allow minimum-difficulty blocks', bip16_rule:'Pay-to-script-hash (P2SH)', bip30_rule:'Prevent duplicate unspent transaction IDs', bip34_rule:'Require height in the coinbase', bip66_rule:'Require strict DER signatures', bip65_rule:'CHECKLOCKTIMEVERIFY', bip90_rule:'Use fixed activation heights for legacy version rules', allow_collisions:'Assume transaction hash collisions cannot occur', bip68_rule:'Relative transaction locktime', bip112_rule:'CHECKSEQUENCEVERIFY', bip113_rule:'Use median time past for locktime',
        bch_strictenc:'Strict signature and public-key encoding', bch_sighash_forkid:'Fork-ID signature hashing and replay protection', bch_low_s:'Require low-S signatures', bch_nullfail:'Failed signature checks require empty signatures', bch_reactivated_opcodes:'Restored BCH script operations', bch_sigpushonly:'Unlocking scripts contain only pushes', bch_cleanstack:'Require a clean final stack', bch_schnorr_multisig:'Schnorr multisignatures', bch_minimaldata:'Require minimal data encoding', bch_enforce_sigchecks:'Enforce signature-check limits', bch_64bit_integers:'64-bit script integers and multiplication', bch_native_introspection:'Native transaction introspection', bch_p2sh_32:'32-byte P2SH', bch_tokens:'CashTokens', bch_vm_limits:'Updated virtual-machine limits', bch_bigint:'Big integers', bch_loops:'Script loops', bch_subroutines:'Script subroutines', bch_bitwise_ops:'Additional bitwise operations', bch_p2s:'Pay-to-Script', bch_2027_may:'May 2027 rules (Cantor)',
        bch_vm_limits_standard:'Relay policy: stricter VM costing', bch_minimalif:'Relay policy: minimal IF/NOTIF arguments', bch_input_sigchecks:'Relay policy: per-input signature-check density', bch_discourage_upgradable_nops:'Relay policy: discourage reserved NOP operations', bch_disallow_segwit_recovery:'Relay policy: disable the SegWit recovery exemption', retarget:'Enable difficulty retargeting', unverified:'Internal marker: transaction not yet validated'
    };
    function decode(value) {
        if (typeof value === 'number' && !Number.isSafeInteger(value)) throw Error('Flag mask lost integer precision');
        const mask = BigInt(value), active = [];
        let known = 0n;
        for (const [name, bit] of definitions) {
            const flag = 1n << BigInt(bit); known |= flag;
            if (mask & flag) active.push({name, description:descriptions[name]});
        }
        return {mask, active, unknown:mask & ~known};
    }
    function render(value) {
        const details = document.createElement('details'); details.className = 'consensus-flags';
        const summary = document.createElement('summary'); details.append(summary);
        if (value == null) { summary.textContent = 'Unavailable'; return details; }
        let flags;
        try { flags = decode(value); } catch { summary.textContent = 'Unavailable'; return details; }
        summary.textContent = flags.active.length + ' active flags' + (flags.unknown ? ' + unknown flags' : '');
        const note = document.createElement('p'); note.textContent = 'Active validation rules and network options. One network upgrade can enable several flags.';
        const mask = document.createElement('code'); mask.textContent = '0x' + flags.mask.toString(16).padStart(16,'0');
        const list = document.createElement('ul');
        for (const flag of flags.active) {
            const item = document.createElement('li'), name = document.createElement('code'), description = document.createElement('span');
            name.textContent = flag.name; description.textContent = flag.description; item.append(name,description); list.append(item);
        }
        if (flags.unknown) { const item = document.createElement('li'); item.textContent = 'Unknown flags: 0x' + flags.unknown.toString(16); list.append(item); }
        details.append(note,mask,list); return details;
    }
    window.KnuthConsensusFlags = {decode, render};
})();
