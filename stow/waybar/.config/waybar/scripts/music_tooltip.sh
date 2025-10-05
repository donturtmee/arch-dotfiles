#!/usr/bin/env bash
set -euo pipefail

# --- click action (Waybar on-click -> this_script toggle) ---
if [ "${1-}" = "toggle" ]; then
  playerctl play-pause >/dev/null 2>&1 || true
  exit 0
fi

# --- helpers ---
pango_escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }
json_escape()  { sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e ':a;N;$!ba;s/\n/ /g'; }
clean()        { tr '\n' ' ' | sed 's/[[:space:]]\+/ /g'; }

# --- status + icon ---
status=$(playerctl status 2>/dev/null || echo "Stopped")
icon=""; [ "$status" = "Playing" ] && icon=""

# --- metadata ---
title=$(playerctl metadata --format '{{title}}' 2>/dev/null || true)
artist=$(playerctl metadata --format '{{artist}}' 2>/dev/null || true)

# --- tooltip (Pango → JSON) ---
if [ -n "$title$title$artist" ]; then
  tip_raw="$(printf '%s — %s' "${artist:-Unknown}" "${title:-Unknown}")"
else
  tip_raw="No player"
fi
tip_pango=$(printf '%s' "$tip_raw" | pango_escape)
tip_json=$(printf '%s' "$tip_pango" | json_escape)

# --- output for Waybar ---
printf '{ "text": "%s", "tooltip": "%s" }\n' "$icon" "$tip_json"
