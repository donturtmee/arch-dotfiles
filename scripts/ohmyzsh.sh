#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"

log "==> ZSH: installing zsh"
install_pacman zsh

log "==> ZSH: installing Oh My Zsh (unattended)"
RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended || \
warn "Oh My Zsh install script returned non-zero; check connectivity."

# Optional: change shell (commented for manual choice)
chsh -s /bin/zsh "$USER" || warn "chsh failed; run 'chsh -s /bin/zsh' manually."

ok "ZSH done."

