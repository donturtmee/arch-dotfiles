#!/usr/bin/env bash
set -euo pipefail

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

# --- notify on track change (plain text, no markup) ---
cache="/tmp/waybar_nowplaying.cache"
if [ "$status" = "Playing" ] && [ -n "$title$title$artist" ]; then
  current="$(printf '%s — %s' "${artist:-Unknown}" "${title:-Unknown}" | clean)"
  if [ -f "$cache" ]; then
    prev=$(cat "$cache" || true)
    if [ "$current" != "$prev" ]; then
      notify-send -a "Now Playing" -i multimedia-audio-player \
        "Now playing" \
        " $(printf '%s' "${artist:-Unknown}" | clean)\n $(printf '%s' "${title:-Unknown}" | clean)"
    fi
  fi
  printf '%s' "$current" > "$cache"
fi

# --- output for Waybar ---
printf '{ "text": "%s", "tooltip": "%s" }\n' "$icon" "$tip_json"
