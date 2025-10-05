#!/usr/bin/env bash
set -euo pipefail

# ---- pretty logs ----
C_BLU='\033[1;34m'; C_GRN='\033[1;32m'; C_YEL='\033[1;33m'; C_RED='\033[1;31m'; C_RST='\033[0m'
log()  { printf "${C_BLU}[*]${C_RST} %s\n" "$*"; }
ok()   { printf "${C_GRN}[✓]${C_RST} %s\n" "$*"; }
warn() { printf "${C_YEL}[!]${C_RST} %s\n" "$*"; }
err()  { printf "${C_RED}[x]${C_RST} %s\n" "$*" 1>&2; }

# ---- error trap: prints the failing line ----
trap 'err "Failed at line $LINENO. Last command: ${BASH_COMMAND:-?}"; exit 1' ERR

# ---- sudo keepalive ----
require_sudo() {
  if ! sudo -v; then err "sudo password required"; exit 1; fi
  # keep alive while this script runs
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# ---- pacman helpers ----
refresh_system() {
  log "Syncing and updating system (pacman -Syu)..."
  sudo pacman -Syu --noconfirm --needed
  ok "System updated."
}

install_pacman() {
  local pkgs=("$@")
  [[ ${#pkgs[@]} -eq 0 ]] && return 0
  log "Installing (pacman): ${pkgs[*]}"
  sudo pacman -S --noconfirm --needed "${pkgs[@]}"
  ok "Installed (pacman): ${pkgs[*]}"
}

ensure_exec_bits() {
  local root="$1"
  # scripturi din scripts/
  find "$root/scripts" -type f -name '*.sh' -print0 2>/dev/null | xargs -0 -r chmod +x
  # scripturi din bundle-urile stow (…/.config/*/scripts/*.sh)
  find "$root/stow" -type f -path '*/.config/*/scripts/*.sh' -print0 2>/dev/null | xargs -0 -r chmod +x
  # scripturi .sh din rădăcină (ex: main.sh, alte utilitare)
  find "$root" -maxdepth 1 -type f -name '*.sh' -print0 2>/dev/null | xargs -0 -r chmod +x
}


# ---- AUR helper (yay/paru) ----
ensure_aur_helper() {
  local helper="${1:-yay}"
  if command -v "$helper" >/dev/null 2>&1; then
    ok "AUR helper '$helper' already present."
    return 0
  fi
  log "Bootstrapping AUR helper '$helper'..."
  install_pacman git base-devel
  local tmpdir; tmpdir="$(mktemp -d)"
  pushd "$tmpdir" >/dev/null
  if [[ "$helper" == "yay" ]]; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
  elif [[ "$helper" == "paru" ]]; then
    git clone https://aur.archlinux.org/paru.git
    cd paru
  else
    err "Unsupported AUR helper: $helper"; exit 1
  fi
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf "$tmpdir"
  ok "AUR helper '$helper' installed."
}

install_aur() {
  local helper="$1"; shift
  local pkgs=("$@")
  [[ ${#pkgs[@]} -eq 0 ]] && return 0
  log "Installing (AUR via $helper): ${pkgs[*]}"
  "$helper" -S --noconfirm --needed "${pkgs[@]}"
  ok "Installed (AUR): ${pkgs[*]}"
}

# ---- stow helpers ----
stow_bundles() {
  local repo_root="$1"; shift
  local bundles=("$@")
  [[ ${#bundles[@]} -eq 0 ]] && { warn "No stow bundles selected."; return 0; }
  log "Stowing bundles: ${bundles[*]}"
  ( cd "$repo_root/stow" && stow -v -t "$HOME" "${bundles[@]}" )
  ok "Stowed: ${bundles[*]}"
}

unstow_bundles() {
  local repo_root="$1"; shift
  local bundles=("$@")
  [[ ${#bundles[@]} -eq 0 ]] && return 0
  log "Unstowing bundles: ${bundles[*]}"
  ( cd "$repo_root/stow" && stow -v -D -t "$HOME" "${bundles[@]}" )
  ok "Unstowed: ${bundles[*]}"
}

# ---- misc utils ----
ensure_dir() { [[ -d "$1" ]] || { log "Creating directory: $1"; mkdir -p "$1"; ok "Created $1"; }; }
chmod_x() { [[ -e "$1" ]] && { chmod +x "$1"; ok "Made executable: $1"; } || warn "Not found to chmod: $1"; }
