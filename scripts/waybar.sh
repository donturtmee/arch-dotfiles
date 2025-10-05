#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

log "==> WAYBAR: installing waybar + pavucontrol"
install_pacman "${WAYBAR_PKGS[@]}"

# If you're storing a waybar script, make it executable after stow
WAYBAR_SCRIPT="$REPO_ROOT/stow/waybar/.config/waybar/scripts/reload.sh"
chmod_x "$WAYBAR_SCRIPT"

ok "WAYBAR done."

