#!/bin/sh

# Prevent multiple swayidle instances
pkill swayidle 2>/dev/null

exec swayidle -w \
  timeout 300 'pgrep swaylock || swaylock' \
  timeout 600 'swaymsg "output * power off"' \
  resume 'swaymsg "output * power on"' \
  before-sleep 'sleep 1 && swaylock'
