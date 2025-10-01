#!/bin/bash

# --- CONFIGURATION ---
INTERNAL="eDP-1" # Replace with your laptop screen's name
EXTERNAL="DP-1"  # Replace with your external monitor's name

# --- MONITOR CONFIGURATION FUNCTIONS ---

set_internal_only() {
  hyprctl keyword monitor "$INTERNAL, preferred, auto, 1"
  hyprctl keyword monitor "$EXTERNAL, disable"
  notify-send "Display Mode" "Laptop Screen Only"
}

set_external_only() {
  hyprctl keyword monitor "$INTERNAL, disable"
  hyprctl keyword monitor "$EXTERNAL, preferred, auto, 1"
  notify-send "Display Mode" "External Monitor Only"
}

set_extended() {
  # Places the external monitor to the left (0x0) and internal to the right (e.g., 1920x0)
  hyprctl keyword monitor "$EXTERNAL, preferred, 0x0, 1"
  hyprctl keyword monitor "$INTERNAL, preferred, 1920x0, 1"
  notify-send "Display Mode" "Extended (Internal Right)"
}

set_mirror() {
  # Mirrors the output. Check 'wlr-randr' for valid resolution options if this fails.
  hyprctl keyword monitor "$INTERNAL, preferred, auto, 1"
  hyprctl keyword monitor "$EXTERNAL, preferred, auto, 1, mirror,$INTERNAL"
  notify-send "Display Mode" "Mirrored"
}

# --- WOFI MENU ---

OPTIONS="Laptop Only\nExternal Only\nExtend\nMirror"

CHOICE=$(echo -e "$OPTIONS" | wofi -d -p "Display Mode" -H 150 -W 250)

case "$CHOICE" in
"Laptop Only")
  set_internal_only
  ;;
"External Only")
  set_external_only
  ;;
"Extend")
  set_extended
  ;;
"Mirror")
  set_mirror
  ;;
*)
  # Handle escape or cancel
  exit 1
  ;;
esac

# Reload Waybar or other UI elements after the change
pkill waybar && waybar &
