#!/usr/bin/env sh

if command -v gsettings >/dev/null 2>&1 &&
  [ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" = "'prefer-dark'" ]; then
  export GTK_THEME=Adwaita:dark
else
  unset GTK_THEME
fi

exec nm-applet
