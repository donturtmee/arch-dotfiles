#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"

log "==> POST: refreshing font cache (if present)"
if command -v fc-cache >/dev/null 2>&1; then
  fc-cache -rv || warn "fc-cache returned non-zero."
else
  warn "fc-cache not found; skipping."
fi

ok "POST done."

