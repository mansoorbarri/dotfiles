#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/hypr"
STATE_FILE="$STATE_DIR/touchpad_enabled.state"
DEVICE="synaptics-tm3276-022"

mkdir -p "$STATE_DIR"

if [[ -f "$STATE_FILE" ]]; then
  state="$(cat "$STATE_FILE")"
else
  state="1"
fi

if [[ "$state" == "1" ]]; then
  hyprctl keyword "device[$DEVICE]:enabled" false >/dev/null
  echo "0" >"$STATE_FILE"
else
  hyprctl keyword "device[$DEVICE]:enabled" true >/dev/null
  echo "1" >"$STATE_FILE"
fi

