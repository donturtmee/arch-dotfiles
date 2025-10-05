#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

log "==> CORE: installing essentials"
refresh_system
install_pacman "${CORE_PKGS[@]}"
ok "CORE: essentials installed."
