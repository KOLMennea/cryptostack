---
name: crypto-update
description: |
  Met à jour cryptostack vers la dernière version publiée sur GitHub. Lance
  un git pull dans le repo local (~/cryptostack/), affiche le changelog des
  nouveaux commits, et branche automatiquement les skills dans ~/.claude/skills/
  (crée les symlinks manquants, y compris pour un nouveau skill publié en amont).
  Fonctionne aussi sans git (chemin de secours par téléchargement direct).
  Aucune action destructive — si tu as des éditions locales non commitées dans
  le repo, le skill stoppe et te demande quoi faire.
  Use when user asks to "update crypto", "/crypto-update", "/update crypto",
  "mets à jour cryptostack", "pull latest crypto", "y a-t-il des updates crypto".
allowed-tools:
  - Bash
  - AskUserQuestion
---

# /crypto-update — Mise à jour cryptostack

Tu mets à jour cryptostack vers la dernière version publiée sur le repo GitHub.
Aucune action destructive : tu vérifies l'état local, tu demandes confirmation si
conflit, sinon tu lances un `git pull` propre. **Si git est absent ou cassé** (cas
fréquent sur un Mac sans Command Line Tools), tu bascules sur une mise à jour
**sans git** via `curl` (voir Phase 0).

## Phase 0-auth — Jeton d'accès (repo privé)

cryptostack peut être distribué depuis un **repo privé**. Dans ce cas, un jeton d'accès en
lecture seule est nécessaire. Il est stocké dans `~/.cryptostack/token` (permissions 600).

```bash
TOKEN_FILE="${HOME}/.cryptostack/token"
CS_TOKEN=""
if [ -f "$TOKEN_FILE" ]; then
  CS_TOKEN=$(tr -d '[:space:]' < "$TOKEN_FILE")
  echo "AUTH: jeton présent"
else
  echo "AUTH: aucun jeton (OK si le repo est public)"
fi
```

- **Jeton présent** : utilise-le pour toutes les opérations réseau (voir ci-dessous).
- **Aucun jeton** : continue normalement. Si une opération échoue ensuite avec une erreur
  d'authentification (`403`, `404` sur un repo qui existe, `Authentication failed`), c'est que le
  repo est passé en privé : **ne relance pas en boucle**. Affiche la marche à suivre :

  > « Ce dépôt est privé. Demande un jeton d'accès à ben@ennea.dev, puis installe-le :
  > `mkdir -p ~/.cryptostack && printf '%s' 'TON_JETON' > ~/.cryptostack/token && chmod 600 ~/.cryptostack/token`
  > Puis relance `/crypto-update`. »

  Ne demande jamais à l'user de coller son jeton dans le chat : il l'écrit lui-même dans le fichier.

**Usage du jeton, chemin git** (n'écrit jamais le jeton dans `.git/config`) :
```bash
git_auth() {
  if [ -n "$CS_TOKEN" ]; then
    git -c credential.helper='!f(){ echo username=x-access-token; echo "password=${CS_TOKEN}"; };f' "$@"
  else
    git "$@"
  fi
}
# ex. : git_auth fetch origin --quiet   |   git_auth pull --ff-only origin main
```

**Usage du jeton, chemin curl** (Phase 0-bis) : passe par l'API tarball plutôt que par l'URL
publique, avec l'en-tête d'autorisation :
```bash
if [ -n "$CS_TOKEN" ]; then
  TARBALL="https://api.github.com/repos/KOLMennea/cryptostack/tarball/main"
  CURL_AUTH=(-H "Authorization: Bearer $CS_TOKEN")
else
  TARBALL="https://github.com/KOLMennea/cryptostack/archive/refs/heads/main.tar.gz"
  CURL_AUTH=()
fi
# ex. : curl -fsSL "${CURL_AUTH[@]}" "$TARBALL" -o "$TMP/cs.tar.gz"
```
⚠️ L'archive de l'API a un nom de dossier racine différent (`KOLMennea-cryptostack-<sha>`) de
celui de l'URL publique (`cryptostack-main`). Détecte-le au lieu de le supposer :
`SRC=$(find "$TMP" -maxdepth 1 -type d -name '*cryptostack*' | head -1)`.

**Ne logge jamais le jeton**, ne l'affiche pas, ne le mets pas dans un message d'erreur.

## Phase 0 — Préflight : git est-il utilisable ?

Beaucoup de Mac n'ont pas de git fonctionnel (`/usr/bin/git` est un stub qui échoue
avec « No developer tools » tant que les Command Line Tools ne sont pas installés).
On teste **réellement** git, pas juste sa présence dans le PATH :

```bash
REPO_DIR="${HOME}/cryptostack"
if git --version >/dev/null 2>&1; then
  echo "GIT_OK"
else
  echo "GIT_BROKEN"
fi
```

- Si `GIT_OK` : continue le parcours git normal (Phase 1 → 7).
- Si `GIT_BROKEN` : **ne lance AUCUNE commande git** (elles échoueront toutes). Propose
  via `AskUserQuestion` :

  > "Git n'est pas disponible sur cette machine. Comment mettre à jour cryptostack ?"

  Options :
  - A) "Mise à jour sans git (téléchargement direct)" — **recommandé, marche tout de suite**
  - B) "Installer git d'abord, puis réessayer"
  - C) "Annuler"

  Si A : va à **Phase 0-bis** (mise à jour curl). Si B : affiche les deux commandes
  ci-dessous et stoppe (l'user les lance dans son terminal, elles demandent son mot de
  passe admin — tu ne peux pas les faire à sa place) :

  ```
  xcode-select --install        # réinstalle les Command Line Tools (git inclus)
  # ou, plus rapide si Homebrew est présent :
  brew install git
  ```

  Si C : stop.

## Phase 0-bis — Mise à jour sans git (curl)

Chemin de secours, n'utilise QUE des outils du système de base macOS (`curl`, `tar`,
`mktemp`, `cp` — tous présents sans Command Line Tools). Télécharge l'archive de la
branche `main` et écrase les fichiers de skill dans `$REPO_DIR` (les symlinks
`~/.claude/skills/*` pointent vers ce dossier, donc l'update est immédiatement actif).

```bash
REPO_DIR="${HOME}/cryptostack"
TMP=$(mktemp -d)

# Jeton (Phase 0-auth) : API tarball si privé, URL publique sinon.
TOKEN_FILE="${HOME}/.cryptostack/token"
CS_TOKEN=""; [ -f "$TOKEN_FILE" ] && CS_TOKEN=$(tr -d '[:space:]' < "$TOKEN_FILE")
if [ -n "$CS_TOKEN" ]; then
  TARBALL="https://api.github.com/repos/KOLMennea/cryptostack/tarball/main"
  set -- -H "Authorization: Bearer $CS_TOKEN"
else
  TARBALL="https://github.com/KOLMennea/cryptostack/archive/refs/heads/main.tar.gz"
  set --
fi

echo "⬇️  Téléchargement de la dernière version…"
if ! curl -fsSL "$@" "$TARBALL" -o "$TMP/cs.tar.gz"; then
  echo "❌ Téléchargement échoué. Si le dépôt est privé, installe ton jeton (voir Phase 0-auth) ;"
  echo "   sinon vérifie ta connexion et réessaie."
  rm -rf "$TMP"; exit 1
fi
if ! tar -xzf "$TMP/cs.tar.gz" -C "$TMP"; then
  echo "❌ Extraction échouée."
  rm -rf "$TMP"; exit 1
fi

# Nom du dossier racine différent selon la source — détecte, ne suppose pas.
SRC=$(find "$TMP" -maxdepth 1 -type d -name '*cryptostack*' | head -1)
[ -z "$SRC" ] && { echo "❌ Archive inattendue."; rm -rf "$TMP"; exit 1; }
OLD_VERSION=$([ -f "$REPO_DIR/VERSION" ] && cat "$REPO_DIR/VERSION" || echo "inconnue")
mkdir -p "$REPO_DIR"

# Synchronise skills + méta (copie récursive, écrase l'existant)
for item in crypto audit-affiliation crypto-update install.sh VERSION CHANGELOG.md README.md docs; do
  [ -e "$SRC/$item" ] && cp -R "$SRC/$item" "$REPO_DIR/"
done
rm -rf "$TMP"

NEW_VERSION=$([ -f "$REPO_DIR/VERSION" ] && cat "$REPO_DIR/VERSION" || echo "inconnue")
echo "✅ Mise à jour sans git : $OLD_VERSION → $NEW_VERSION"
```

Puis vérifie les symlinks (**Phase 6**), affiche le CHANGELOG récent
(`head -20 "$REPO_DIR/CHANGELOG.md"`), et termine. **Ne fais pas les phases git 1-5**
sur ce chemin. Note à l'user : « Mise à jour appliquée sans git. Pour retrouver les
mises à jour incrémentales (changelog par commit, stash), installe git quand tu peux
(`xcode-select --install`). »

## Phase 1 — Vérifier l'install (chemin git uniquement)

```bash
REPO_DIR="${HOME}/cryptostack"

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "❌ Repo non installé : $REPO_DIR"
  echo ""
  echo "Pour installer :"
  echo "  git clone https://github.com/<owner>/cryptostack ~/cryptostack"
  echo "  cd ~/cryptostack && ./install.sh"
  exit 1
fi

cd "$REPO_DIR"
echo "📂 Repo : $REPO_DIR"
echo "🌿 Branche : $(git branch --show-current)"
echo "📌 Dernier commit local : $(git log -1 --oneline)"
```

Si le repo n'est pas trouvé : stoppe et indique la commande d'install.

## Phase 2 — Détecter les éditions locales non commitées

```bash
cd "$REPO_DIR"
DIRTY=$(git status --porcelain | wc -l | tr -d ' ')

if [ "$DIRTY" -gt 0 ]; then
  echo "⚠️ Tu as $DIRTY changement(s) local(aux) non commité(s) :"
  git status --short
fi
```

Si DIRTY > 0 : `AskUserQuestion` :

> "Tu as des éditions locales non commitées dans le repo cryptostack. Que faire ?"

Options :
- A) "Stash mes changements puis pull, et restore après" — recommandé
- B) "Annuler l'update — je commit ou nettoie d'abord"
- C) "Forcer le pull (--ff-only) — risque de fail si conflit"

Si A : `git stash push -m "crypto-update auto-stash $(date +%s)"` puis pull, puis `git stash pop`. Si conflit au pop, indique à l'user de résoudre.

Si B : stop, pas de pull.

Si C : `git_auth pull --ff-only` (échoue si divergence, sécurisé).

## Phase 3 — Fetch + comparer avec remote

```bash
cd "$REPO_DIR"
git_auth fetch origin --quiet   # voir Phase 0-auth ; sans jeton, équivaut à `git fetch`

LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse @{u} 2>/dev/null || git rev-parse origin/main)

if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
  echo "✅ Déjà à jour ($LOCAL_COMMIT)"
  echo "Dernière version : $(git log -1 --format='%h - %s (%ad)' --date=relative)"
  exit 0
fi
```

Si déjà à jour : annonce, montre le hash, stop.

## Phase 4 — Afficher le changelog des nouveaux commits

```bash
echo "📦 Nouveaux commits depuis ta dernière update :"
echo ""
git log --oneline --no-decorate "$LOCAL_COMMIT..$REMOTE_COMMIT"
echo ""
NEW_COUNT=$(git rev-list --count "$LOCAL_COMMIT..$REMOTE_COMMIT")
echo "→ $NEW_COUNT nouveau(x) commit(s) à puller"
```

## Phase 5 — Confirmer avant pull

`AskUserQuestion` :

> "Pull les <N> nouveau(x) commit(s) maintenant ?"

Options :
- A) "Pull maintenant" — recommandé
- B) "Annuler"

Si A : `git_auth pull --ff-only origin <branch>` (voir Phase 0-auth — sans jeton, équivaut à `git pull`).

## Phase 6 — Vérifier ET réparer les symlinks (auto)

Un `git pull` récupère les **dossiers** des skills, mais pas les symlinks vers `~/.claude/skills/`.
Sans symlink, un skill nouvellement publié en amont (ex. un nouveau `/audit-affiliation`) est présent
sur le disque mais **la commande n'existe pas** dans Claude Code. Cette phase répare automatiquement.

Le parcours des skills est **dérivé du repo**, pas codé en dur : tout nouveau skill publié en amont est
donc pris en charge sans modifier ce fichier.

```bash
REPO_DIR="${HOME}/cryptostack"
SKILL_DIR="${HOME}/.claude/skills"
mkdir -p "$SKILL_DIR"
CREATED=0

# Tout dossier du repo contenant un SKILL.md est un skill à brancher.
for SKILL_PATH in "$REPO_DIR"/*/SKILL.md; do
  [ -e "$SKILL_PATH" ] || continue
  skill=$(basename "$(dirname "$SKILL_PATH")")
  TARGET="$REPO_DIR/$skill"
  LINK="$SKILL_DIR/$skill"

  if [ -L "$LINK" ]; then
    CURRENT=$(readlink "$LINK")
    if [ "$CURRENT" = "$TARGET" ]; then
      echo "✅ $skill"
    else
      rm "$LINK" && ln -s "$TARGET" "$LINK"
      echo "🔧 $skill : symlink repointé ($CURRENT → $TARGET)"
      CREATED=$((CREATED+1))
    fi
  elif [ -e "$LINK" ]; then
    # Vrai fichier/dossier : NE PAS écraser (risque de perte de travail).
    echo "⛔ $LINK existe et n'est PAS un symlink — non modifié."
    echo "   Sauvegarde-le puis relance : mv \"$LINK\" \"$LINK.bak\" && cd $REPO_DIR && ./install.sh"
  else
    ln -s "$TARGET" "$LINK"
    echo "🆕 $skill : symlink créé (nouveau skill disponible)"
    CREATED=$((CREATED+1))
  fi
done

[ "$CREATED" -gt 0 ] && echo "" && echo "→ $CREATED symlink(s) ajouté(s)/réparé(s). Redémarre Claude Code pour que les commandes apparaissent."
```

Si un ou plusieurs symlinks ont été **créés** (nouveau skill), annonce-le explicitement à l'user en
Phase 7 avec le nom de la ou des nouvelles commandes disponibles, et rappelle le redémarrage de
Claude Code (les skills sont chargés au démarrage).

## Phase 7 — Sortie finale

Affiche :
- Hash du nouveau commit local
- VERSION (lis le fichier `~/cryptostack/VERSION` s'il existe)
- La liste des skills actifs (issue de la Phase 6)
- **Si un nouveau symlink a été créé** : "🆕 Nouvelle(s) commande(s) disponible(s) : /<skill>. **Redémarre Claude Code** pour qu'elle(s) apparaisse(nt)."
- Sinon : "✅ cryptostack à jour. Les skills sont immédiatement actifs (symlinks)."
- Si stash A choisi en Phase 2 : "Restore terminé." OU si conflit "⚠️ stash pop a échoué, résous les conflits dans ~/cryptostack/"

## Contraintes

- **Aucune action destructive** : pas de `git reset --hard`, pas de `git clean`, pas de `--force`.
- **Stash auto** seulement avec confirmation explicite de l'user (option A en Phase 2).
- **Si push manqué côté mainteneur** : indique simplement "déjà à jour" sans paniquer.
- **Symlinks réparés automatiquement** (Phase 6) : création d'un symlink manquant et repointage d'un symlink erroné sont des actions sûres et non destructives. **Exception stricte** : si le chemin existe et n'est **pas** un symlink (vrai fichier/dossier), on n'y touche JAMAIS — on affiche la marche à suivre et on continue.
- **Affiche toujours** le changelog avant de puller — l'user doit voir ce qui change.
