#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$REPO_ROOT/lib/helpers.sh"

NVM_VERSION="${NVM_VERSION:-v0.40.3}"   # poți suprascrie cu: NVM_VERSION=v0.x ./node.sh
NODE_VERSION="${NODE_VERSION:-24}"      # poți suprascrie cu: NODE_VERSION=20 ./node.sh

log "==> NODE: installing NVM ($NVM_VERSION) and Node.js $NODE_VERSION"

# 1) Install / ensure NVM
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  ok "NVM already present at ~/.nvm"
else
  log "Downloading NVM installer $NVM_VERSION"
  curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
fi

# 2) Source NVM for this session
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"

# 3) Make sure shell init files will load NVM next logins (zsh + bash), idempotent
append_once() {
  local line="$1" file="$2"
  grep -Fqs "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}
append_once 'export NVM_DIR="$HOME/.nvm"' "$HOME/.zshrc"
append_once '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' "$HOME/.zshrc"
append_once 'export NVM_DIR="$HOME/.nvm"' "$HOME/.bashrc"
append_once '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' "$HOME/.bashrc"

# 4) Install Node and set as default
if nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
  ok "Node $NODE_VERSION already installed via nvm."
else
  log "Installing Node $NODE_VERSION via nvm"
  nvm install "$NODE_VERSION"
fi

log "Setting default Node to $NODE_VERSION"
nvm alias default "$NODE_VERSION" >/dev/null
nvm use default >/dev/null

# 5) Print versions (may differ slightly from your examples as releases move)
node_v="$(node -v || true)"
npm_v="$(npm -v || true)"
current="$(nvm current || true)"

ok "Node installed."
log "node -v   => ${node_v:-<not found>}"
log "npm -v    => ${npm_v:-<not found>}"
log "nvm current => ${current:-<not found>}"

# (optional) enable corepack (yarn/pnpm shims)
# if command -v corepack >/dev/null 2>&1; then
#   log "Enabling corepack (yarn/pnpm)"
#   corepack enable || warn "corepack enable failed (non-fatal)"
# fi

ok "==> NODE done."
