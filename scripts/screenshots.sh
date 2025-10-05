#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

log "==> SCREENSHOTS: installing tools"
install_pacman "${SHOT_PKGS[@]}"

log "Ensuring ~/Pictures/Screenshots exists"
ensure_dir "$HOME/Pictures/Screenshots"

ok "SCREENSHOTS done."

