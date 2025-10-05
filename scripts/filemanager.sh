# scripts/install_filemanager.sh
#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

log "==> FILES: installing Nemo + archive tools"
install_pacman "${FILES_PKGS[@]}"

# If you also want RAR extraction, uncomment the array in packages.sh and this line:
# install_pacman "${FILES_EXTRA_PKGS[@]}"

ok "FILES done. Nemo context-menu (Compress/Extract) will appear next session."
