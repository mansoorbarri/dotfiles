#!/bin/bash

WALLPAPER_DIR="$HOME/.wally"
MONITOR_NAME="eDP-1"
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

if [ -n "$RANDOM_WALLPAPER" ]; then
  hyprctl hyprpaper reload "${MONITOR_NAME},${RANDOM_WALLPAPER}"
fi
