# cryptostack

Skill Claude Code pour évaluer un projet crypto sur 10 critères structurés
(Fondamentaux + Mécanique + Confiance) avec dashboard visuel, mémoire
inter-projets, et export PDF.

## Installation

Pré-requis : Claude Code, `git`, `jq`, et `weasyprint` (pour l'export PDF).

### macOS

Si Homebrew n'est pas déjà installé :

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Puis :

```bash
brew install jq weasyprint git
git clone https://github.com/KOLMennea/cryptostack ~/cryptostack
cd ~/cryptostack
./install.sh
```

### Linux Debian/Ubuntu

```bash
sudo apt-get update && sudo apt-get install -y jq weasyprint git
git clone https://github.com/KOLMennea/cryptostack ~/cryptostack
cd ~/cryptostack
./install.sh
```

### Linux Fedora/RHEL

```bash
sudo dnf install -y jq python3-weasyprint git
git clone https://github.com/KOLMennea/cryptostack ~/cryptostack
cd ~/cryptostack
./install.sh
```

### Linux Arch

```bash
sudo pacman -S --noconfirm jq weasyprint git
git clone https://github.com/KOLMennea/cryptostack ~/cryptostack
cd ~/cryptostack
./install.sh
```

### Que fait `install.sh`

- Détecte ton OS et ton package manager (brew / apt / dnf / pacman)
- Si macOS sans Homebrew, te propose la commande d'install
- Symlinke `~/.claude/skills/crypto` → `~/cryptostack/crypto/`
- Symlinke `~/.claude/skills/crypto-update` → `~/cryptostack/crypto-update/`
- Initialise la mémoire interne dans `~/.cryptostack/memory/`
- Crée le dossier rapports dans `~/Documents/cryptostack/audits/`
- Vérifie les dépendances et donne la commande d'install si une manque

## Utilisation

Dans Claude Code :

| Commande | Action |
|----------|--------|
| `/crypto` | Démarre un audit complet — parcours guidé 12 phases (35-50 min) |
| `/crypto-update` | Pull la dernière version depuis GitHub |

## Architecture

```
~/cryptostack/                         ← repo cloné (édité par le mainteneur)
├── crypto/SKILL.md                    ← skill principal, parcours 12 phases
├── crypto-update/SKILL.md             ← skill de mise à jour (git pull)
├── install.sh                         ← setup symlinks + dossiers
├── VERSION                            ← numéro de version courante
└── README.md

~/.claude/skills/crypto                → symlink vers ~/cryptostack/crypto
~/.claude/skills/crypto-update         → symlink vers ~/cryptostack/crypto-update

~/.cryptostack/memory/                 ← mémoire interne (cachée)
├── projects.jsonl                     ← 1 ligne par audit avec signature
└── stats.json                         ← cumulés (total, PASS, INVESTIGATE, AVOID)

~/Documents/cryptostack/audits/        ← rapports user-facing
└── <YYYY-MM-DD>-<slug>/
    ├── fundamentals.md
    ├── mechanics.md
    ├── trust.md
    ├── scorecard.md                   ← version interne (peut citer comparables)
    ├── scorecard-pdf.html             ← version expurgée pour PDF
    └── scorecard.pdf                  ← livrable propre
```

## Le parcours en 12 phases

| Phase | Focus | Durée |
|-------|-------|-------|
| 0 | Intake (1 question) | 2 min |
| 1-3 | 🏗️ Fondamentaux : utilité, équipe, traçabilité | 10-15 min |
| 4-6 | ⚙️ Mécanique : centralisation, liquidité, incentives | 10-15 min |
| 7-10 | 🛡️ Confiance : audit, clarté, médias, UX/UI | 10-15 min |
| 11 | Scorecard finale + update mémoire | 2 min |
| 12 | Export PDF expurgé | 1 min |

**Override AVOID automatique** : MLM 4+ niveaux, contract non-vérifié, mention
Rekt.news / SEC / DOJ.

## Mémoire inter-projets

Chaque audit terminé enrichit `~/.cryptostack/memory/projects.jsonl` avec une
signature structurelle (custody, mlm_levels, yield_source, audit_tier, etc.).

Au démarrage du parcours suivant, /crypto matche les patterns du nouveau projet
contre la mémoire et déclenche de la **vigilance accrue** (bumping du scoring,
mention dans le dashboard) si un projet AVOID partage la même signature.

**La mémoire est interne** : aucune mention de tes projets internes n'apparaît
dans le PDF final.

## Politique du PDF

Le PDF (`scorecard.pdf`) est expurgé strictement :

- ❌ **Aucune mention** de tes audits passés (slugs, stats agrégées)
- ✅ **Comparables publics conservés** (Forsage SEC 2022-163, Arbistar fiscalía,
  HyperVerse SEC 2024, BitConnect DOJ, Celsius Chapter 11)
- ✅ Arguments structurels et juridiques (L.122-6, etc.)

Le PDF peut être partagé sans révéler ta liste d'audits internes.

## Mise à jour

Tape `/crypto-update` dans Claude Code. Le skill :
1. Vérifie l'install
2. Détecte les éditions locales non commitées (et propose de stash)
3. Affiche le changelog des nouveaux commits
4. Pull en `--ff-only` après confirmation
5. Vérifie que les symlinks sont OK

Les nouvelles versions sont **immédiatement actives** grâce aux symlinks (pas
de re-copie nécessaire).

## Disclaimer

cryptostack est un outil d'aide à la décision. Il ne constitue **pas** un
conseil en investissement. Les analyses de sécurité ne remplacent pas un audit
professionnel par une firme reconnue (Trail of Bits, OpenZeppelin, Consensys
Diligence, Spearbit). Investir en crypto comporte des risques substantiels de
perte totale.
