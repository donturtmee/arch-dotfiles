#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

log "==> FONTS: installing JetBrainsMono Nerd"
install_pacman "${FONT_PKGS[@]}"
ok "FONTS done."
