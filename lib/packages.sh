#!/usr/bin/env bash
# packages.sh — central place for package lists used by module scripts
#
# Guidelines:
#  - Keep ONLY names of packages in these arrays.
#  - Repo packages go in *_PKGS; AUR packages go in *_AUR.
#  - Module scripts (scripts/*.sh) import this file and install from these arrays.
#  - Idempotent: pacman/yay run with --needed; safe to re-run.
#
# Notes:
#  - i3/X11 vs Hyprland/Wayland: some tools are stack-specific (see comments).
#  - If you add a new app that also has dotfiles, remember to create a Stow bundle too.
#  - VS Code (Microsoft build) is installed from AUR as visual-studio-code-bin.

set -euo pipefail

# ---------- CORE ----------
# Minimal CLI toolkit present on every machine.
# Includes GNU Stow for dotfiles, network/file tools, JSON parsing, and quick system info.
CORE_PKGS=(stow brightnessctl curl wget jq ripgrep fd btop)

# ---------- I3 / X11 EXTRAS ----------
# X11-specific utilities commonly used with i3 (not needed for Hyprland/Wayland).
# - picom: compositor for X11
# - feh: image viewer / wallpaper setter (X11)
# - xorg-xrandr: display configuration (X11)
# - rofi: launcher (X11-focused)
I3_PKGS=(picom feh xorg-xrandr rofi)

# ---------- BROWSERS ----------
# Repo browsers:
BROWSER_PKGS=(firefox)           # official repo (pacman)
# AUR browsers:
BROWSER_AUR=()          # AUR (prebuilt binary)

# ---------- DESKTOP APPS (REPO) ----------
# General user applications installed from the official repos.
# Includes editors, terminal tools, office/media apps, and helpers.
APPS_PKGS=(
  neovim tmux fzf
  xreader geany obsidian discord
  libreoffice-still mpv audacious
  playerctl flameshot fastfetch
  
# Uncomment if you use NVIDIA drivers
# nvidia-settings
)

# ---------- DESKTOP APPS (AUR) ----------
# Microsoft VS Code (AUR). If you prefer Code-OSS, remove this and add 'code' to APPS_PKGS.
APPS_AUR=(visual-studio-code-bin)

# ---------- HYPRLAND EXTRAS (WAYLAND) ----------
# Wayland-native helpers for your Hyprland setup.
HYPR_EXTRA_PKGS=(hyprpaper hyprpicker hyprlock hypridle)

# ---------- TERMINALS ----------
# Extra terminals (kitty preinstalled)
TERMINAL_PKGS=(terminator)

# ---------- FONTS ----------
# Base Nerd Font + emoji coverage (for icons/glyphs in bars/menus).
FONT_PKGS=(ttf-jetbrains-mono-nerd noto-fonts-emoji)

# ---------- THEME / ICONS ----------
# Papirus icon theme and nwg-look to configure GTK themes.
THEME_PKGS=(papirus-icon-theme nwg-look)
# AUR bits for theming (Papirus folders color tool):
THEME_AUR=(papirus-folders-git)

# ---------- SCREENSHOTS (WAYLAND) ----------
# Wayland-native screenshot pipeline; on X11 you also have flameshot in APPS_PKGS.
SHOT_PKGS=(grim slurp swappy wl-clipboard)

# ---------- NOTIFICATIONS ----------
# Wayland notification daemon (for Hyprland). On X11 you have dunst in the base install.
NOTIFY_PKGS=(mako)

# ---------- WAYBAR + AUDIO ----------
# Waybar status bar (Wayland) and pavucontrol for audio control.
WAYBAR_PKGS=(waybar pavucontrol)

# ---------- FILE MANAGER / ARCHIVES ----------
# Nemo file manager + File Roller integration, plus common archive backends.
FILES_PKGS=(zip unzip 7zip tar gzip bzip2 xz zstd file-roller nemo nemo-fileroller)
# Optional: enable RAR extraction if you need it.
# FILES_EXTRA_PKGS=(unrar)


# included in archinstall >
# dmenu, dolphin, dunst, grim, htop, hyprland, i3-wm, i3blocks, i3lock, i3status,
# iwd, kitty, lightdm, lightdm-gtk-greeter, nano, openssh, polkit-kde-agent,
# qt5-wayland, qt6-wayland, slurp, smartmontools, uwsm, vim, wget, wireless_tools,
# wofi, wpa_supplicant, xdg-desktop-portal-hyprland, xdg-utils, xss-lock, xterm.