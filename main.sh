#!/usr/bin/env bash
# main.sh => ARCHLINUX SETUP

# Overview:
#   One-shot installer for Arch Linux systems (i3/Hypr)
#   - Installs core CLI tools, apps, browsers, i3/Hypr extras, fonts, themes
#   - Ensures AUR helper (yay/paru)
#   - Applies dotfiles via GNU Stow in a single pass

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="$REPO_ROOT:$PATH"

source "$REPO_ROOT/lib/helpers.sh"
source "$REPO_ROOT/lib/packages.sh"

ensure_exec_bits "$REPO_ROOT" # normalize +x on scripts and stow'ed script files

# ---------- flags ----------
DO_CORE=0        # Core CLI: stow, curl, wget, jq, ripgrep, fd, btop + ensure AUR helper
DO_FILES=0       # File manager + archives: zip, unzip, 7zip, tar, gzip, bzip2, xz, zstd, file-roller, nemo, nemo-fileroller
DO_BROWSERS=0    # Browsers: firefox (pacman)
DO_APPS=0        # Desktop apps: neovim, tmux, fzf, xreader, geany, obsidian, discord, libreoffice-still, mpv, audacious, playerctl, flameshot, nvidia-settings, fastfetch, kwalletmanager, kwallet-pam + visual-studio-code-bin (AUR)
DO_FONTS=0       # Fonts: ttf-jetbrains-mono-nerd, noto-fonts-emoji
DO_THEME=0       # Theme: papirus-icon-theme, nwg-look (+ AUR: papirus-folders-git)
DO_HYPR_EXTRAS=0 # Hypr extras: hyprpaper, hyprpicker, hyprlock, hypridle
DO_I3=0          # i3/X11 extras: picom, feh, xorg-xrandr, rofi (and stow i3 + i3status configs)
DO_WAYBAR=0      # Waybar + pavucontrol; chmod scripts; stow waybar config
DO_NOTIFY=0      # Notifications (Wayland): mako
DO_SHOTS=0       # Wayland screenshots: grim, slurp, swappy, wl-clipboard (+ ensure ~/Pictures/Screenshots)
DO_TERMINALS=0   # Terminals: terminator (kitty already installed) + stow kitty/terminator configs
DO_ZSH=0         # Shell: zsh + Oh My Zsh (unattended)
DO_NODE=0        # Node toolchain: NVM + Node.js 22 (default)
DO_STOW=0        # Apply stow bundles collected from selected modules
DO_POST=0        # Post-setup: fc-cache etc.
AUR_HELPER="yay" # AUR helper (yay or paru)

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

  --core              Install core CLI tools (stow, curl, wget, jq, ripgrep, fd, btop) and ensure AUR helper
  --files             Install file manager + archives (zip, unzip, 7zip, tar, gzip, bzip2, xz, zstd, file-roller, nemo, nemo-fileroller)
  --browsers          Install Firefox (pacman)
  --apps              Install desktop apps (neovim, tmux, fzf, xreader, geany, obsidian, discord,
                      libreoffice-still, mpv, audacious, playerctl, flameshot, nvidia-settings,
                      fastfetch)
  --fonts             Install fonts (ttf-jetbrains-mono-nerd, noto-fonts-emoji)
  --theme             Install theme tools (papirus-icon-theme, nwg-look) and AUR papirus-folders-git
  --hypr-extras       Install Hypr extras (hyprpaper, hyprpicker, hyprlock, hypridle)
  --i3                Install i3/X11 extras (picom, feh, xorg-xrandr, rofi) and stow i3/i3status configs
  --waybar            Install waybar and pavucontrol; mark waybar scripts executable; stow waybar
  --notify            Install mako (Wayland notifications)
  --shots             Install Wayland screenshots (grim, slurp, swappy, wl-clipboard) and create ~/Pictures/Screenshots
  --terminals         Install Terminator (kitty already present) and stow terminal configs
  --zsh               Install Zsh + Oh My Zsh (unattended)
  --node              Install NVM and Node.js 22 (set as default)
  --stow              Apply stow bundles accumulated from selected modules
  --post              Run post-setup tasks (e.g., fc-cache)
  --aur-helper=NAME   Choose AUR helper: yay or paru (default: yay)
  --all               Run everything above
  -h | --help         Show this help and exit
EOF
}

for arg in "$@"; do
  case "$arg" in
    --core) DO_CORE=1 ;;
    --files) DO_FILES=1 ;;
    --browsers) DO_BROWSERS=1 ;;
    --apps) DO_APPS=1 ;;
    --fonts) DO_FONTS=1 ;;
    --theme) DO_THEME=1 ;;
    --hypr-extras) DO_HYPR_EXTRAS=1 ;;
    --i3) DO_I3=1 ;;
    --waybar) DO_WAYBAR=1 ;;
    --notify) DO_NOTIFY=1 ;;
    --shots) DO_SHOTS=1 ;;
    --terminals) DO_TERMINALS=1 ;;
    --zsh) DO_ZSH=1 ;;
    --node) DO_NODE=1 ;;
    --stow) DO_STOW=1 ;;
    --post) DO_POST=1 ;;
    --aur-helper=*) AUR_HELPER="${arg#*=}" ;;
    --all) DO_CORE=1; DO_FILES=1; DO_BROWSERS=1; DO_APPS=1; DO_HYPR_EXTRAS=1; DO_I3=1; DO_FONTS=1; DO_THEME=1; DO_WAYBAR=1; DO_NOTIFY=1; DO_SHOTS=1; DO_TERMINALS=1; DO_ZSH=1; DO_NODE=1; DO_STOW=1; DO_POST=1;;
    -h|--help) usage; exit 0 ;;
    *) err "Unknown option: $arg"; usage; exit 1 ;;
  esac
done

require_sudo

# Keep a list of stow bundles to apply for the selected modules
BUNDLES=()

# CORE ======================
if [[ $DO_CORE -eq 1 ]]; then
  log "==> CORE SETUP START"
  refresh_system
  install_pacman "${CORE_PKGS[@]}"
  ensure_aur_helper "$AUR_HELPER"
  ok "==> CORE SETUP DONE"
fi

# FILES =====================
if [[ $DO_FILES -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/filemanager.sh"
fi

# BROWSERS ==================
if [[ $DO_BROWSERS -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/browsers.sh" "$AUR_HELPER"
fi

# APPS ======================
if [[ $DO_APPS -eq 1 ]]; then
   bash "$REPO_ROOT/scripts/apps.sh" "$AUR_HELPER"
  BUNDLES+=("flameshot" "fastfetch" "wofi")
fi

# FONTS =====================
if [[ $DO_FONTS -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/fonts.sh"
fi

# THEME =====================
if [[ $DO_THEME -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/theme.sh" "$AUR_HELPER"
fi

# HYPR EXTRAS ===============
if [[ $DO_HYPR_EXTRAS -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/hypr_extras.sh"
  BUNDLES+=("hypr" "wallpapers")
fi

# i3 ========================
if [[ $DO_I3 -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/i3.sh"
  BUNDLES+=("i3" "i3status" "picom")
fi

# WAYBAR ====================
if [[ $DO_WAYBAR -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/waybar.sh"
  BUNDLES+=("waybar")
fi

# NOTIFICATIONS =============
if [[ $DO_NOTIFY -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/notifications.sh"
  BUNDLES+=("mako")
fi

# SCREENSHOTS ===============
if [[ $DO_SHOTS -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/screenshots.sh"
fi

# TERMINALS =================
if [[ $DO_TERMINALS -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/terminals.sh"
  BUNDLES+=("terminator" "kitty")
fi

# OH-MY-ZSH =================
if [[ $DO_ZSH -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/ohmyzsh.sh"
fi

# NODE ======================
if [[ $DO_NODE -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/node.sh"
fi

# STOW ======================
if [[ $DO_STOW -eq 1 ]]; then
  stow_bundles "$REPO_ROOT" "${BUNDLES[@]}"
fi

# POST ======================
if [[ $DO_POST -eq 1 ]]; then
  bash "$REPO_ROOT/scripts/post_setup.sh"
fi

ok "All selected tasks completed."
