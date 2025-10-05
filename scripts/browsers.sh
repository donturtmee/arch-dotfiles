#!/usr/bin/env bash
set -euo pipefail
AUR="${1:-yay}"   # receives yay/paru from main.sh (default: yay)
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

log "==> BROWSERS: installing Firefox (pacman) + Brave (AUR)"

# 1) Official repo
install_pacman "${BROWSER_PKGS[@]}"

# 2) AUR (only if we have something in the list)
if [[ ${#BROWSER_AUR[@]} -gt 0 ]]; then
  ensure_aur_helper "$AUR"
  install_aur "$AUR" "${BROWSER_AUR[@]}"
fi

ok "BROWSERS done."

