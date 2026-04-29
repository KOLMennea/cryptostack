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

Tu mets à jour le skill `/crypto` vers la dernière version publiée sur le repo
GitHub `cryptostack`. Aucune action destructive : tu vérifies l'état local, tu
demandes confirmation si conflit, sinon tu lances un `git pull` propre.

## Phase 1 — Vérifier l'install

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

for skill in crypto crypto-update; do
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
