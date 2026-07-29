---
name: crypto-update
description: |
  Met à jour cryptostack vers la dernière version publiée sur GitHub. Lance
  un git pull dans le repo local (~/cryptostack/), affiche le changelog des
  nouveaux commits, et confirme que les symlinks vers ~/.claude/skills/ sont
  bien actifs. Aucune action destructive — si tu as des éditions locales non
  commitées dans le repo, le skill stoppe et te demande quoi faire.
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
TARBALL="https://github.com/KOLMennea/cryptostack/archive/refs/heads/main.tar.gz"
TMP=$(mktemp -d)

echo "⬇️  Téléchargement de la dernière version…"
if ! curl -fsSL "$TARBALL" -o "$TMP/cs.tar.gz"; then
  echo "❌ Téléchargement échoué. Vérifie ta connexion et réessaie."
  rm -rf "$TMP"; exit 1
fi
if ! tar -xzf "$TMP/cs.tar.gz" -C "$TMP"; then
  echo "❌ Extraction échouée."
  rm -rf "$TMP"; exit 1
fi

SRC="$TMP/cryptostack-main"
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

Si C : `git pull --ff-only` (échoue si divergence, sécurisé).

## Phase 3 — Fetch + comparer avec remote

```bash
cd "$REPO_DIR"
git fetch origin --quiet

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

Si A : `git pull --ff-only origin <branch>`.

## Phase 6 — Vérifier les symlinks

```bash
SKILL_DIR="${HOME}/.claude/skills"

for skill in crypto audit-affiliation crypto-update; do
  if [ -L "$SKILL_DIR/$skill" ]; then
    TARGET=$(readlink "$SKILL_DIR/$skill")
    echo "✅ $SKILL_DIR/$skill → $TARGET"
  else
    echo "⚠️ $SKILL_DIR/$skill n'est PAS un symlink"
    echo "   Lance : ./install.sh depuis ~/cryptostack pour réparer"
  fi
done
```

## Phase 7 — Sortie finale

Affiche :
- Hash du nouveau commit local
- VERSION (lis le fichier `~/cryptostack/VERSION` s'il existe)
- "✅ cryptostack à jour. Le nouveau /crypto est immédiatement actif (symlink)."
- Si stash A choisi en Phase 2 : "Restore terminé." OU si conflit "⚠️ stash pop a échoué, résous les conflits dans ~/cryptostack/"

## Contraintes

- **Aucune action destructive** : pas de `git reset --hard`, pas de `git clean`, pas de `--force`.
- **Stash auto** seulement avec confirmation explicite de l'user (option A en Phase 2).
- **Si push manqué côté mainteneur** : indique simplement "déjà à jour" sans paniquer.
- **Pas de réinstallation des symlinks** : juste vérification. Si cassé, propose `./install.sh`.
- **Affiche toujours** le changelog avant de puller — l'user doit voir ce qui change.
