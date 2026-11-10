// Historical Bitcoin milestones followed by BCH upgrade editions.
// These identify the edition, not a network's possibly earlier activation date.
(() => {
    const editions=Object.freeze({
        bitcoin_legacy:'2009-Jan',
        uahf:'2017-Aug',daa_cw144:'2017-Nov',
        pythagoras:'2018-May',euclid:'2018-Nov',pisano:'2019-May',mersenne:'2019-Nov',
        fermat:'2020-May',euler:'2020-Nov',gauss:'2022-May',descartes:'2023-May',
        lobachevski:'2024-May',galois:'2025-May',leibniz:'2026-May',cantor:'2027-May'
    });
    const names=Object.freeze({bitcoin_legacy:'Bitcoin · Original upgrades',uahf:'UAHF',daa_cw144:'DAA (CW-144)'});
    const titles=Object.freeze({bitcoin_legacy:'Bitcoin · From the initial release to CSV',uahf:'Bitcoin Cash launch (UAHF)',daa_cw144:'Difficulty adjustment upgrade (CW-144)'});
    // Curated historical baselines, always displayed as active. These are not
    // activation booleans read from the current native chain-state snapshot.
    const historical=new Set(['bitcoin_legacy']);
    const changes=Object.freeze({
    "bitcoin_legacy": {
        "items": [
            "2009-Jan · Bitcoin v0.1 — Satoshi’s initial peer-to-peer electronic cash implementation: proof-of-work blocks, signed transactions and the original difficulty adjustment.",
            "2010-Jul · Bitcoin v0.3.6 — Security correction for an implementation bug that could make bogus transactions appear accepted.",
            "2010-Aug · Bitcoin v0.3.10 — Fixed the value-overflow vulnerability exposed at block 74'638, preventing transaction amounts from bypassing monetary limits.",
            "2012-Mar · BIP30 — Prevented duplicate transaction IDs from overwriting existing unspent outputs.",
            "2012-Apr · BIP16 (P2SH) — Added consensus rules for spending outputs committed to a script hash.",
            "2013-Mar · BIP34 — Required the block height in the coinbase and introduced version 2 blocks.",
            "2014 · BIP42 — Corrected the subsidy calculation so the issuance schedule cannot restart after many halvings. This fixed future behavior rather than activating a new rule at that date.",
            "2015 · BIP66 — Required strict DER encoding of transaction signatures, reducing dependence on OpenSSL’s parsing behavior.",
            "2015 · BIP65 (CLTV) — Enabled scripts to require an absolute block height or time before funds can be spent.",
            "2016 · BIP68 / BIP112 / BIP113 (CSV) — Added relative transaction locks, CHECKSEQUENCEVERIFY and median-time-past-based lock-time evaluation.",
            "Shared Bitcoin history before the Bitcoin Cash split: Satoshi authored the initial implementation and early fixes; later upgrades were developed by subsequent contributors. Active identifies this inherited baseline, not an unchanged set of original parameters."
        ],
        "source": "https://github.com/bitcoin/bitcoin/blob/master/doc/bips.md",
        "sourceLabel": "Read the implemented BIPs and their specifications ↗",
        "sources": [
            ["Satoshi · Bitcoin v0.1 announcement", "https://satoshi.nakamotoinstitute.org/emails/cryptography/16/"],
            ["Satoshi · v0.3.6 security announcement", "https://satoshi.nakamotoinstitute.org/posts/bitcointalk/threads/145/"],
            ["Satoshi · v0.3.10 overflow patch", "https://satoshi.nakamotoinstitute.org/posts/bitcointalk/threads/186/"]
        ]
    },
    "uahf": {
        "items": [
            "Launched Bitcoin Cash with an 8 MB block-size limit; the first fork block had to exceed 1 MB.",
            "Introduced replay-protected transaction signatures using SIGHASH_FORKID.",
            "Added the Emergency Difficulty Adjustment (EDA) to respond to large drops in mining hashrate.",
            "Required strict signature and public-key encodings."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/uahf-technical-spec/"
    },
    "daa_cw144": {
        "items": [
            "Replaced EDA with CW-144, adjusting mining difficulty after each block using recent accumulated chainwork.",
            "Required low-S transaction signatures to reduce signature malleability.",
            "Enforced NULLFAIL: a failed signature check must use empty signatures."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/nov-13-hardfork-spec/"
    },
    "pythagoras": {
        "items": [
            "Raised the block-size limit to 32 MB.",
            "Restored selected Script operations for byte strings and arithmetic.",
            "Relay policy: increased the recommended OP_RETURN allowance to 223 bytes."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/may-2018-hardfork/"
    },
    "euclid": {
        "items": [
            "Introduced canonical transaction ordering (CTOR) inside blocks.",
            "Added OP_CHECKDATASIG and OP_CHECKDATASIGVERIFY to verify signatures over arbitrary messages.",
            "Required transactions to be at least 100 bytes.",
            "Required push-only scriptSig inputs and a single successful result on the final stack (clean stack)."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/2018-nov-upgrade/"
    },
    "pisano": {
        "items": [
            "Enabled Schnorr signatures in CHECKSIG and CHECKDATASIG.",
            "Restored miners’ ability to recover BCH accidentally sent to SegWit P2SH addresses."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/2019-05-15-upgrade/"
    },
    "mersenne": {
        "items": [
            "Extended Schnorr signature support to CHECKMULTISIG and CHECKMULTISIGVERIFY.",
            "Required minimal encodings for pushed data and Script numbers, reducing alternative ways to encode the same operation."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/2019-11-15-upgrade/"
    },
    "fermat": {
        "items": [
            "Replaced SigOps accounting with SigChecks, which limits signature checks actually performed during Script execution.",
            "Added OP_REVERSEBYTES to reverse a byte string.",
            "Mempool policy: recommended raising ancestor and descendant limits from 25 to 50 transactions."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/2020-05-15-upgrade/"
    },
    "euler": {
        "items": [
            "Replaced the CW-144 difficulty adjustment algorithm with ASERT (aserti3-2d). ASERT adjusts the next block’s difficulty relative to an anchor and the intended block schedule.",
            "Kept the signature ForkID fixed at zero, discontinuing scheduled automatic replay-protection changes."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/2020-11-15-upgrade/"
    },
    "gauss": {
        "items": [
            "Expanded Script arithmetic to 64-bit integers.",
            "Added native introspection opcodes, allowing contracts to inspect transaction inputs, outputs and other transaction fields directly."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/2022-05-15-upgrade/"
    },
    "descartes": {
        "items": [
            "Introduced CashTokens: consensus-enforced fungible tokens and non-fungible tokens (NFTs).",
            "Added P2SH32, using a 32-byte script hash for stronger commitment security.",
            "Reduced the minimum transaction size from 100 to 65 bytes.",
            "Restricted transaction versions to 1 and 2."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/2023-05-15-upgrade/"
    },
    "lobachevski": {
        "items": [
            "Introduced ABLA, the Adaptive Blocksize Limit Algorithm. The block-size limit responds to observed block usage instead of remaining fixed.",
            "Retained a 32 MB baseline while allowing capacity to grow under sustained demand."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/2024-05-15-upgrade/"
    },
    "galois": {
        "items": [
            "Reworked virtual-machine limits to account more closely for the resources a script consumes.",
            "Added high-precision Script arithmetic (BigInt), bounded by the virtual machine’s resource limits."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/2025-05-15-upgrade/"
    },
    "leibniz": {
        "items": [
            "Added Pay to Script (P2S), a new way to specify spending conditions directly.",
            "Added bounded loops for repeated Script operations.",
            "Added function-definition and invocation operations for reusable Script logic.",
            "Re-enabled additional bitwise operations."
        ],
        "source": "https://upgradespecs.bitcoincashnode.org/2026-05-15-upgrade/"
    },
    "cantor": {
        "items": [
            "CHIP-2025-03: Faster Blocks for Bitcoin Cash proposes reducing the target block interval from 10 minutes to 1 minute.",
            "The proposal rescales block-based parameters to preserve the intended issuance schedule and time-based behavior.",
            "Not yet confirmed for mainnet. Its inclusion in the May 2027 upgrade remains a proposal; activation on an experimental network does not imply mainnet approval."
        ],
        "pending": true,
        "source": "https://gitlab.com/0353F40E/fablous",
        "sourceLabel": "Read CHIP-2025-03 · Faster Blocks for Bitcoin Cash ↗"
    }
});
    const people=Object.freeze({
    "pythagoras": [
        "Pythagoras of Samos",
        "Pythagoras",
        "Associated with the theorem bearing his name, numerical relationships and musical ratios. Much of his personal mathematical work is uncertain; the theorem was known before his lifetime.",
        "A broad intellectual connection: the study of numbers and mathematical proof belongs to the tradition that eventually enabled cryptography. The Pythagorean theorem is not a Bitcoin consensus primitive."
    ],
    "euclid": [
        "Euclid of Alexandria",
        "Euclid",
        "His Elements organized geometry and number theory around definitions, axioms and proofs. The Euclidean algorithm efficiently finds the greatest common divisor of two integers.",
        "A concrete mathematical connection: the extended Euclidean algorithm computes modular inverses, an operation used in elliptic-curve arithmetic and ECDSA. It is one way to compute inverses, not a requirement that every Bitcoin implementation use that algorithm."
    ],
    "pisano": [
        "Leonardo Pisano · Fibonacci",
        "Fibonacci",
        "Liber Abaci helped spread Hindu-Arabic numerals and positional arithmetic in medieval Europe. He also studied number-theoretic problems and the sequence now named after him.",
        "His connection is the transmission of practical arithmetic and number theory. Bitcoin does not use the Fibonacci sequence to determine mining difficulty, issuance or consensus."
    ],
    "mersenne": [
        "Marin Mersenne",
        "Mersenne",
        "Studied prime numbers of the form 2ⁿ − 1 and connected scholars through a remarkable network of scientific correspondence.",
        "Prime-number research forms part of the heritage of finite-field cryptography. Bitcoin’s secp256k1 field uses the prime 2²⁵⁶ − 2³² − 977, not a Mersenne prime; this is a historical connection rather than a direct use of his prime family."
    ],
    "fermat": [
        "Pierre de Fermat",
        "Fermat",
        "Made major discoveries in number theory, including Fermat’s little theorem, and helped establish probability theory through correspondence with Pascal.",
        "Fermat’s little theorem gives a way to compute inverses modulo a prime: a⁻¹ = aᵖ⁻² mod p for nonzero a. Such inverses are used in elliptic-curve cryptography, including Bitcoin signatures. His Last Theorem is not used by Bitcoin."
    ],
    "euler": [
        "Leonhard Euler",
        "Euler",
        "Advanced number theory, analysis and graph theory. Euler’s theorem generalized Fermat’s little theorem, and his work helped establish the language of modern mathematics.",
        "Modular arithmetic is central to Bitcoin’s signature mathematics. Euler’s work is part of that foundation; Euler’s theorem is also central to RSA, but Bitcoin signatures use elliptic curves, not RSA."
    ],
    "gauss": [
        "Carl Friedrich Gauss",
        "Gauss",
        "Systematized number theory in Disquisitiones Arithmeticae, developed congruence notation and made foundational contributions to quadratic residues and many other fields.",
        "Arithmetic modulo a prime is the setting for Bitcoin’s secp256k1 curve. Gauss’s language of congruences helps describe these operations precisely, though elliptic-curve cryptography was developed much later."
    ],
    "descartes": [
        "René Descartes",
        "Descartes",
        "Helped establish analytic geometry, linking geometric problems to algebraic equations and coordinates. He also advanced algebraic notation.",
        "Bitcoin’s public keys are points on an elliptic curve described by an equation, y² = x³ + 7, over a finite field. Connecting equations with geometry is an intellectual precursor; Descartes did not develop finite-field elliptic-curve cryptography."
    ],
    "lobachevski": [
        "Nikolai Lobachevsky",
        "Lobachevsky",
        "Independently developed non-Euclidean geometry, showing how a different parallel postulate leads to a coherent mathematical system.",
        "His place on this path is conceptual: abstract mathematics can be valuable long before an application is known. Bitcoin does not use hyperbolic geometry, and an elliptic curve is not the same thing as elliptic or hyperbolic geometry."
    ],
    "galois": [
        "Évariste Galois",
        "Galois",
        "Connected the solvability of polynomial equations with symmetry, laying foundations for group theory and the study of finite fields.",
        "This is a strong mathematical connection: Bitcoin’s elliptic-curve points form a group, and their coordinates lie in a finite field. These structures support public keys and digital signatures; Galois himself did not design modern cryptography."
    ],
    "leibniz": [
        "Gottfried Wilhelm Leibniz",
        "Leibniz",
        "Independently developed calculus, described binary arithmetic and pursued symbolic reasoning and mechanical calculation.",
        "Binary arithmetic and the ambition to mechanize reasoning are important precursors of computing. Bitcoin’s software, hashes and network messages operate on bits, although its cryptographic designs came centuries later."
    ],
    "cantor": [
        "Georg Cantor",
        "Cantor",
        "Founded modern set theory and distinguished different sizes of infinity, transforming mathematical foundations.",
        "Set-theoretic language supports modern mathematics and computer science. The connection to Bitcoin is foundational and indirect: Bitcoin’s keys and hashes belong to finite spaces, and its security does not rely on infinite cardinalities."
    ]
});
    function name(key){return names[key] || key[0].toUpperCase()+key.slice(1);}
    function label(key){return editions[key]?name(key)+' - '+editions[key]:name(key);}

    // Compatibility with the deployed snapshot, which exports the native
    // consensus flags but omits dedicated 2017 booleans. These cumulative masks
    // match domain/machine/script_flags.hpp in the matching Core build.
    const legacyMasks=Object.freeze({uahf:(1n<<11n)|(1n<<12n),daa_cw144:(1n<<11n)|(1n<<12n)|(1n<<13n)|(1n<<14n)});
    function entries(state){
        const upgrades=state.upgrades || {};
        let flags=null;
        try{
            const raw=state.enabled_flags;
            if((typeof raw==='string' && /^\d+$/.test(raw)) || (typeof raw==='number' && Number.isSafeInteger(raw) && raw>=0))flags=BigInt(raw);
        }catch{}
        const keys=[...Object.keys(editions),...Object.keys(upgrades).filter(key=>!editions[key])];
        return keys.map(key=>{
            if(historical.has(key))return [key,true];
            if(Object.prototype.hasOwnProperty.call(upgrades,key))return [key,upgrades[key]];
            const mask=legacyMasks[key];
            return [key,mask!==undefined && flags!==null?(flags&mask)===mask:null];
        });
    }
    if(typeof document!=='undefined'){
        for(const key of Object.keys(editions)){
            const person=people[key];
            const [fullName,source,achievement,connection]=person || [titles[key]];
            const popup=document.createElement('aside');popup.id='upgrade-person-'+key;popup.className='upgrade-story';popup.setAttribute('popover','');popup.setAttribute('role','dialog');popup.setAttribute('aria-labelledby',popup.id+'-title');
            const close=document.createElement('button');close.className='upgrade-story-close';close.textContent='×';close.setAttribute('popovertarget',popup.id);close.setAttribute('popovertargetaction','hide');close.setAttribute('aria-label','Close upgrade details');
            const eyebrow=document.createElement('p');eyebrow.className='eyebrow';eyebrow.textContent=person?'THE PATH TO SATOSHI':historical.has(key)?'BITCOIN · SHARED HISTORY':'BITCOIN CASH NETWORK UPGRADE';
            const heading=document.createElement('h2');heading.id=popup.id+'-title';heading.textContent=fullName;
            const upgrade=changes[key];
            const upgradeHeading=document.createElement('h3');upgradeHeading.textContent=historical.has(key)?'2009–2016 · Before Bitcoin Cash':'What changed · '+editions[key];
            const features=document.createElement('ul');features.className='upgrade-changes';
            for(const item of upgrade.items){const feature=document.createElement('li');feature.textContent=item;features.append(feature);}
            const specification=document.createElement('a');specification.className='upgrade-specification';specification.href=upgrade.source;specification.target='_blank';specification.rel='noopener noreferrer';specification.textContent=upgrade.sourceLabel || (upgrade.pending?'Current KTH upgrade rules ↗':'Read the upgrade specification ↗');
            popup.append(close,eyebrow,heading,upgradeHeading,features,specification);
            for(const [text,url] of upgrade.sources || []){
                const link=document.createElement('a');link.className='upgrade-specification';link.textContent=text+' ↗';link.href=url;link.target='_blank';link.rel='noopener noreferrer';
                const paragraph=document.createElement('p');paragraph.append(link);popup.append(paragraph);
            }
            if(person){
                const biographyHeading=document.createElement('h3');biographyHeading.textContent='About the mathematician';
                const description=document.createElement('p');description.textContent=achievement;
                const subheading=document.createElement('h3');subheading.textContent='Connection to Bitcoin';
                const relation=document.createElement('p');relation.textContent=connection;
                const link=document.createElement('a');link.href='https://mathshistory.st-andrews.ac.uk/Biographies/'+source+'/';link.target='_blank';link.rel='noopener noreferrer';link.textContent='Read the biography · MacTutor, University of St Andrews ↗';
                popup.append(biographyHeading,description,subheading,relation,link);
            }
            document.body.append(popup);
        }
    }
    const api=Object.freeze({editions,people,changes,name,label,entries});
    if(typeof module!=='undefined'&&module.exports)module.exports=api;else window.KnuthUpgrades=api;
})();
