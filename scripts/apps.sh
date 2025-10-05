#!/usr/bin/env bash
set -euo pipefail

AUR="${1:-yay}"   # receives yay/paru from main.sh
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

log "==> APPS: installing desktop applications"

# Install from the official repositories (filtered so it won’t fail on systems missing certain repos)
available=()
for p in "${APPS_PKGS[@]}"; do
  if pacman -Si "$p" >/dev/null 2>&1; then
    available+=("$p")
  else
    warn "Package '$p' does not exist in your pacman repos; skipping it."
  fi
done
if ((${#available[@]} > 0)); then
  install_pacman "${available[@]}"
fi

# Install from AUR (visual-studio-code-bin)
if [[ ${#APPS_AUR[@]} -gt 0 ]]; then
  ensure_aur_helper "$AUR"
  install_aur "$AUR" "${APPS_AUR[@]}"
fi

ok "APPS done."
