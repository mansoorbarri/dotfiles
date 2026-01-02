#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/.wally"

RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \
  \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" \) | shuf -n 1)

if [ -n "$RANDOM_WALLPAPER" ]; then
  hyprctl hyprpaper preload "$RANDOM_WALLPAPER"
  hyprctl hyprpaper wallpaper ",$RANDOM_WALLPAPER"
fi
