#!/usr/bin/env bash
set -euo pipefail
AUR="${1:-yay}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

log "==> THEME: installing GTK theme, icons, helpers"
install_pacman "${THEME_PKGS[@]}"
ensure_aur_helper "$AUR"

# Graphite theme
tmpdir="$(mktemp -d)"
log "Cloning Graphite-gtk-theme into $tmpdir"
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git --depth=1 "$tmpdir/Graphite-gtk-theme"
pushd "$tmpdir/Graphite-gtk-theme" >/dev/null
log "Running Graphite installer"
./install.sh -c dark -s standard -s compact -l --tweaks black rimless
popd >/dev/null
rm -rf "$tmpdir"
ok "GTK theme installed."

# Papirus + folders
install_aur "$AUR" "${THEME_AUR[@]}"
log "Applying Papirus folders color (black)"
papirus-folders -C black || warn "papirus-folders apply failed (non-fatal)."

ok "THEME done. Open 'nwg-look' manually to choose theme/icons."

