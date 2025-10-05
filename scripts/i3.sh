#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

log "==> I3: installing X11 extras (picom, feh, xorg-xrandr)"
install_pacman "${I3_PKGS[@]}"
ok "I3 extras installed."
