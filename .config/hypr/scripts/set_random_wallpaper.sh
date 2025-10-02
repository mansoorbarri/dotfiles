#!/bin/bash

# --- Configuration ---
WALLPAPER_DIR="$HOME/.wally"
# The monitor name(s) to set the wallpaper on.
# Use 'hyprctl monitors' in your terminal to find the exact name (e.g., eDP-1, DP-1).
# If you leave it as a comma-separated blank, it will apply to all monitors without a specific wallpaper.
MONITOR_NAME="eDP-1"

# --- Script Logic ---

# 1. Find a random wallpaper file in the directory
# This uses 'find' to list files, 'shuf' to pick one randomly, and 'head' to take the first result.
RANDOM_WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

if [ -n "$RANDOM_WALLPAPER" ]; then
  # 2. Preload the new wallpaper into hyprpaper's memory (optional but good practice)
  # The 'reload' command below handles preloading, but this can be useful for other managers.

  # 3. Apply the new wallpaper using hyprctl hyprpaper reload
  # This command handles preloading the new image and setting it immediately.
  # The format is: hyprctl hyprpaper reload <monitor>,<path/to/image>
  hyprctl hyprpaper reload "${MONITOR_NAME},${RANDOM_WALLPAPER}"

  # OPTIONAL: You can unload unused wallpapers to save memory.
  # hyprctl hyprpaper unload unused
fi
