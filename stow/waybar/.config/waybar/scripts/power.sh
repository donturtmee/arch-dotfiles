#!/usr/bin/env bash
set -euo pipefail

# Wofi theming (override with env vars if you like)
WOFI_STYLE="${WOFI_STYLE:-$HOME/.config/wofi/power.css}"
WOFI_CONF="${WOFI_CONF:-$HOME/.config/wofi/power.conf}"

WOFI_CMD=(wofi --dmenu -i)
[[ -f "$WOFI_STYLE" ]] && WOFI_CMD+=(--style "$WOFI_STYLE")
[[ -f "$WOFI_CONF"  ]] && WOFI_CMD+=(--conf  "$WOFI_CONF")

ask() {
  local prompt="$1"
  "${WOFI_CMD[@]}" -p "$prompt"
}

choose_action() {                     # you can change the icons freely
  printf '%s\n' \
    "  Power off" \
    "  Restart" \
    "󰜺  Cancel" | ask "System power"
}

confirm() {
  local what="$1"                      # "power off" / "restart"
  printf '%s\n' \
    "  Yes" \
    "  No" | ask "Please confirm: ${what}"
}

main() {
  local sel
  sel="$(choose_action || true)"

  case "$sel" in
    *"Power off"*) [[ "$(confirm "power off")" == *"Yes"* ]] && systemctl poweroff ;;
    *"Restart"*)   [[ "$(confirm "restart")"   == *"Yes"* ]] && systemctl reboot   ;;
    *"Cancel"*|"") exit 0 ;;
    *)             exit 0 ;;
  esac
}

main "$@"
