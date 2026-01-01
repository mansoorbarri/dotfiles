#!/bin/sh

WALLPAPER_DIR="$HOME/.wally"

wallpaper=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

pkill swaybg 2>/dev/null
swaybg -i "$wallpaper" -m fill &
