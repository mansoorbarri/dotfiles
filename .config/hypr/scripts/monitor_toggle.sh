#!/bin/bash

INTERNAL="eDP-1"
EXTERNAL="HDMI-A-1"

set_internal_only() {
  hyprctl dispatch focusmonitor "$INTERNAL"
  hyprctl dispatch moveworkspacetomonitor current "$INTERNAL"
  hyprctl keyword monitor "$EXTERNAL, disable"
  hyprctl keyword monitor "$INTERNAL, preferred, auto, 1"
  notify-send "Display Mode" "Laptop Screen Only"
}

set_external_only() {
  hyprctl dispatch focusmonitor "$EXTERNAL"
  hyprctl dispatch moveworkspacetomonitor current "$EXTERNAL"
  hyprctl keyword monitor "$INTERNAL, disable"
  hyprctl keyword monitor "$EXTERNAL, preferred, auto, 1"
  notify-send "Display Mode" "External Monitor Only"
}

set_extended() {
  hyprctl keyword monitor "$EXTERNAL, preferred, 0x0, 1"
  hyprctl keyword monitor "$INTERNAL, preferred, 1920x0, 1"
  notify-send "Display Mode" "Extended (Internal Right)"
}

set_mirror() {
  hyprctl keyword monitor "$INTERNAL, preferred, auto, 1"
  hyprctl keyword monitor "$EXTERNAL, preferred, auto, 1, mirror,$INTERNAL"
  notify-send "Display Mode" "Mirrored"
}

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
  exit 1
  ;;
esac

pkill waybar && waybar &
