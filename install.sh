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

# Détection OS et package manager
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *)      echo "unknown" ;;
  esac
}

detect_pkg_manager() {
  if command -v brew >/dev/null 2>&1; then echo "brew"; return; fi
  if command -v apt-get >/dev/null 2>&1; then echo "apt"; return; fi
  if command -v dnf >/dev/null 2>&1; then echo "dnf"; return; fi
  if command -v pacman >/dev/null 2>&1; then echo "pacman"; return; fi
  echo "none"
}

OS=$(detect_os)
PM=$(detect_pkg_manager)

# Renvoie la commande d'install pour un package
install_cmd() {
  local pkg="$1"
  # Mapping de noms de packages spécifiques
  local pkg_brew="$pkg"
  local pkg_apt="$pkg"
  local pkg_dnf="$pkg"
  local pkg_pacman="$pkg"

  if [ "$pkg" = "weasyprint" ]; then
    pkg_dnf="python3-weasyprint"
  fi

  case "$PM" in
    brew)   echo "brew install $pkg_brew" ;;
    apt)    echo "sudo apt-get update && sudo apt-get install -y $pkg_apt" ;;
    dnf)    echo "sudo dnf install -y $pkg_dnf" ;;
    pacman) echo "sudo pacman -S --noconfirm $pkg_pacman" ;;
    none)
      if [ "$OS" = "macos" ]; then
        echo "Homebrew manquant. Installe-le d'abord :"
        echo "    /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo "  Puis : brew install $pkg"
      else
        echo "Aucun package manager détecté — installe $pkg manuellement"
      fi
      ;;
  esac
}

cyan "📦 cryptostack installer"
echo "  OS détecté : $OS"
echo "  Package manager : $PM"
echo ""

# 1. Vérifier qu'on est bien dans le repo
if [ ! -f "$REPO_DIR/crypto/SKILL.md" ] || [ ! -f "$REPO_DIR/crypto-update/SKILL.md" ]; then
  red "❌ Erreur : crypto/SKILL.md ou crypto-update/SKILL.md introuvable."
  red "   Lance ce script depuis la racine du repo cryptostack."
  exit 1
fi

# 2. Si macOS sans Homebrew → proposer l'install
if [ "$OS" = "macos" ] && [ "$PM" = "none" ]; then
  echo ""
  yellow "⚠️ Homebrew n'est pas installé. C'est requis pour jq et weasyprint."
  echo ""
  echo "Installe Homebrew d'abord avec cette commande :"
  echo ""
  cyan '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  echo ""
  echo "Puis relance ./install.sh"
  echo ""
  read -p "Continuer quand même (sans installer brew) ? [y/N] " -n 1 -r
  echo ""
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# 3. Créer le dossier ~/.claude/skills/ si absent
mkdir -p "$SKILL_DIR"

# 4. Symlink crypto et crypto-update
for skill in crypto audit-affiliation crypto-update; do
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

# 5. Init la mémoire interne
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

# 6. Init le dossier rapports
mkdir -p "$DOCS_DIR"
green "✅ Dossier rapports : $DOCS_DIR"

# 7. Vérifier dépendances
echo ""
cyan "🔍 Dépendances"

check_dep() {
  local cmd="$1"
  local optional="${2:-required}"

  if command -v "$cmd" >/dev/null 2>&1; then
    green "  ✅ $cmd"
  else
    local hint
    hint=$(install_cmd "$cmd")
    if [ "$optional" = "optional" ]; then
      yellow "  ⚠️ $cmd manquant (optionnel pour PDF)"
      echo "     Install : $hint"
    else
      red "  ❌ $cmd manquant (requis)"
      echo "     Install : $hint"
    fi
  fi
}

check_dep git required
check_dep jq required
check_dep weasyprint optional

echo ""
cyan "🎉 cryptostack installé."
echo ""
echo "Skills disponibles dans Claude Code :"
echo "  /crypto            — screening rapide (12 phases, 10 critères)"
echo "  /audit-affiliation — audit approfondi (20 fonctions, 5 axes, phases)"
echo "  /crypto-update     — met à jour cryptostack"
echo ""
echo "Rapports d'audit : $DOCS_DIR"
echo "Mémoire interne  : $MEMORY_DIR"
echo ""
echo "Lance Claude Code et tape /crypto pour démarrer."
