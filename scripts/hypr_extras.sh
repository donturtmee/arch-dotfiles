#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

log "==> HYPR EXTRAS: installing hyprpaper + hyprpicker"
install_pacman "${HYPR_EXTRA_PKGS[@]}"
# după install_pacman "${HYPR_EXTRA_PKGS[@]}"
HYPR_SCRIPT="$REPO_ROOT/stow/hypr/.config/hypr/scripts/songdetail.sh"
chmod_x "$HYPR_SCRIPT"
ok "HYPR EXTRAS done."
