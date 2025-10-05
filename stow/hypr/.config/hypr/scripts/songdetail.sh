#!/bin/bash
song_info=$(playerctl metadata --format '  {{title}} - {{artist}}')

# escape &, <, >
song_info_escaped=$(printf "%s" "$song_info" \
  | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g')

echo "$song_info_escaped"
