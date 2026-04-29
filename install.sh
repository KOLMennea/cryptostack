#!/usr/bin/env bash
# cryptostack — install script
# Symlink les skills vers ~/.claude/skills/, init la mémoire et le dossier rapports.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="${HOME}/.claude/skills"
DOCS_DIR="${HOME}/Documents/cryptostack/audits"
MEMORY_DIR="${HOME}/.cryptostack/memory"

cyan() { printf '\033[36m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
red() { printf '\033[31m%s\033[0m\n' "$*"; }

cyan "📦 cryptostack installer"
echo ""

# 1. Vérifier qu'on est bien dans le repo
if [ ! -f "$REPO_DIR/crypto/SKILL.md" ] || [ ! -f "$REPO_DIR/crypto-update/SKILL.md" ]; then
  red "❌ Erreur : crypto/SKILL.md ou crypto-update/SKILL.md introuvable."
  red "   Lance ce script depuis la racine du repo cryptostack."
  exit 1
fi

# 2. Créer le dossier ~/.claude/skills/ si absent
mkdir -p "$SKILL_DIR"

# 3. Symlink crypto et crypto-update
for skill in crypto crypto-update; do
  TARGET="$REPO_DIR/$skill"
  LINK="$SKILL_DIR/$skill"

  if [ -L "$LINK" ]; then
    EXISTING=$(readlink "$LINK")
    if [ "$EXISTING" = "$TARGET" ]; then
      green "✅ Symlink $skill déjà en place"
      continue
    else
      yellow "⚠️ Symlink $skill pointe vers $EXISTING, je le repointe vers $TARGET"
      rm "$LINK"
      ln -s "$TARGET" "$LINK"
    fi
  elif [ -e "$LINK" ]; then
    red "❌ $LINK existe et n'est PAS un symlink."
    red "   Sauvegarde-le manuellement (mv $LINK ${LINK}.bak) puis relance install.sh"
    exit 1
  else
    ln -s "$TARGET" "$LINK"
    green "✅ Symlink créé : $LINK → $TARGET"
  fi
done

# 4. Init la mémoire interne
mkdir -p "$MEMORY_DIR/patterns"
[ ! -f "$MEMORY_DIR/projects.jsonl" ] && touch "$MEMORY_DIR/projects.jsonl"
if [ ! -f "$MEMORY_DIR/stats.json" ]; then
  cat > "$MEMORY_DIR/stats.json" <<EOF
{
  "version": "1.0",
  "total_audits": 0,
  "verdicts": {"PASS": 0, "INVESTIGATE": 0, "AVOID": 0},
  "last_updated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
fi
green "✅ Mémoire initialisée : $MEMORY_DIR"

# 5. Init le dossier rapports
mkdir -p "$DOCS_DIR"
green "✅ Dossier rapports : $DOCS_DIR"

# 6. Vérifier dépendances
echo ""
cyan "🔍 Dépendances"

check_dep() {
  local cmd="$1"
  local install_cmd="$2"
  local optional="${3:-required}"

  if command -v "$cmd" >/dev/null 2>&1; then
    green "  ✅ $cmd"
  else
    if [ "$optional" = "optional" ]; then
      yellow "  ⚠️ $cmd manquant (optionnel) — install : $install_cmd"
    else
      red "  ❌ $cmd manquant — install : $install_cmd"
    fi
  fi
}

check_dep jq "brew install jq" required
check_dep weasyprint "brew install weasyprint" optional
check_dep git "brew install git" required

echo ""
cyan "🎉 cryptostack installé."
echo ""
echo "Skills disponibles dans Claude Code :"
echo "  /crypto         — démarre un audit complet (12 phases)"
echo "  /crypto-update  — met à jour cryptostack"
echo ""
echo "Rapports d'audit : $DOCS_DIR"
echo "Mémoire interne  : $MEMORY_DIR"
echo ""
echo "Lance Claude Code et tape /crypto pour démarrer."
