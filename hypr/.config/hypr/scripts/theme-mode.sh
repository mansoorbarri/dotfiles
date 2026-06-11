#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HYPR_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
STATE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/theme-mode"
STATE_FILE="$STATE_DIR/current"
WOFI_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wofi"
SWAYNC_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/swaync"
WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
MAKO_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mako"
GHOSTTY_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml"
XFCE_XSETTINGS="${XDG_CONFIG_HOME:-$HOME/.config}/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"
LIGHT_GTK_THEME="Adwaita"
DARK_GTK_THEME="Adwaita-dark"
LIGHT_QT5_SCHEME="/usr/share/qt5ct/colors/airy.conf"
DARK_QT5_SCHEME="/usr/share/qt5ct/colors/darker.conf"
LIGHT_QT6_SCHEME="/usr/share/qt6ct/colors/airy.conf"
DARK_QT6_SCHEME="/usr/share/qt6ct/colors/darker.conf"

mkdir -p "$STATE_DIR"

usage() {
  cat <<'EOF'
Usage: theme-mode.sh [light|dark|toggle|status]
EOF
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    printf 'Missing required file: %s\n' "$path" >&2
    exit 1
  fi
}

set_or_append_line() {
  local file="$1"
  local pattern="$2"
  local line="$3"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if grep -qE "$pattern" "$file"; then
    sed -i "s|$pattern.*|$line|" "$file"
  else
    printf '%s\n' "$line" >>"$file"
  fi
}

set_force_dark_flag() {
  local file="$1"
  local enable="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"

  if [[ "$enable" == "true" ]]; then
    if ! grep -qxF -- '--force-dark-mode' "$file"; then
      printf '%s\n' '--force-dark-mode' >>"$file"
    fi
  else
    sed -i '/^--force-dark-mode$/d' "$file"
  fi
}

write_gtk_settings() {
  local theme="$1"
  local prefer_dark="$2"
  local prefer_dark_int="0"

  if [[ "$prefer_dark" == "true" ]]; then
    prefer_dark_int="1"
  fi

  mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
  for settings_file in "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"; do
    cat >"$settings_file" <<EOF
[Settings]
gtk-application-prefer-dark-theme=$prefer_dark
gtk-enable-primary-paste=true
gtk-theme-name=$theme
EOF
  done

  cat >"$HOME/.gtkrc-2.0.mine" <<EOF
gtk-theme-name="$theme"
gtk-application-prefer-dark-theme=$prefer_dark_int
EOF

  if [[ -f "$HOME/.gtkrc-2.0" ]]; then
    sed -i 's|^gtk-theme-name=.*|gtk-theme-name="'"$theme"'"|' "$HOME/.gtkrc-2.0"
  fi
}

write_portal_settings() {
  local mode="$1"
  local color_scheme="$2"
  local portal_color_scheme="2"

  if [[ "$mode" == "dark" ]]; then
    portal_color_scheme="1"
  fi

  mkdir -p "$HOME/.config/xdg-desktop-portal" "$HOME/.config/xdg-desktop-portal/portals.conf.d"

  cat >"$HOME/.config/xdg-desktop-portal/settings" <<EOF
[org.freedesktop.appearance]
color-scheme=$portal_color_scheme
EOF

  cat >"$HOME/.config/xdg-desktop-portal/portals.conf" <<'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.Settings=gtk
EOF

  cat >"$HOME/.config/xdg-desktop-portal/portals.conf.d/hyprland.conf" <<'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.Settings=gtk
EOF

  set_or_append_line "$HOME/.config/xsettingsd/xsettingsd.conf" '^Net/ColorScheme ' "Net/ColorScheme \"$color_scheme\""
}

write_xsettings() {
  local theme="$1"

  set_or_append_line "$HOME/.config/xsettingsd/xsettingsd.conf" '^Net/ThemeName ' "Net/ThemeName \"$theme\""

  if command -v xfconf-query >/dev/null 2>&1; then
    xfconf-query -c xsettings -p /Net/ThemeName --create -t string -s "$theme" >/dev/null 2>&1 || true
  elif [[ -f "$XFCE_XSETTINGS" ]]; then
    sed -i 's|\(<property name="ThemeName" type="string" value="\)[^"]*\(" */>\)|\1'"$theme"'\2|' "$XFCE_XSETTINGS"
  fi
}

write_qt_settings() {
  local qt5_scheme="$1"
  local qt6_scheme="$2"

  if [[ -f "$HOME/.config/qt5ct/qt5ct.conf" ]]; then
    sed -i 's|^color_scheme_path=.*|color_scheme_path='"$qt5_scheme"'|' "$HOME/.config/qt5ct/qt5ct.conf"
    sed -i 's|^custom_palette=.*|custom_palette=false|' "$HOME/.config/qt5ct/qt5ct.conf"
  fi

  if [[ -f "$HOME/.config/qt6ct/qt6ct.conf" ]]; then
    sed -i 's|^color_scheme_path=.*|color_scheme_path='"$qt6_scheme"'|' "$HOME/.config/qt6ct/qt6ct.conf"
    sed -i 's|^custom_palette=.*|custom_palette=false|' "$HOME/.config/qt6ct/qt6ct.conf"
  fi

  if command -v kwriteconfig6 >/dev/null 2>&1; then
    if [[ "$qt5_scheme" == "$LIGHT_QT5_SCHEME" ]]; then
      kwriteconfig6 --file "$HOME/.config/kdeglobals" --group General --key ColorScheme BreezeLight
      kwriteconfig6 --file "$HOME/.config/kdeglobals" --group KDE --key LookAndFeelPackage org.kde.breeze.desktop
    else
      kwriteconfig6 --file "$HOME/.config/kdeglobals" --group General --key ColorScheme BreezeDark
      kwriteconfig6 --file "$HOME/.config/kdeglobals" --group KDE --key LookAndFeelPackage org.kde.breezedark.desktop
    fi
  fi
}

write_systemd_gtk_theme() {
  local mode="$1"

  if ! command -v systemctl >/dev/null 2>&1; then
    return
  fi

  if [[ "$mode" == "dark" ]]; then
    systemctl --user set-environment GTK_THEME=Adwaita:dark >/dev/null 2>&1 || true
  else
    systemctl --user unset-environment GTK_THEME >/dev/null 2>&1 || true
  fi
}

write_hypr_theme_files() {
  local mode="$1"

  if [[ "$mode" == "light" ]]; then
    cp "$HYPR_DIR/latte.conf" "$HYPR_DIR/theme-lock.conf"
    cp "$HYPR_DIR/theme-ui-light.conf" "$HYPR_DIR/theme-ui.conf"
  else
    cp "$HYPR_DIR/mocha.conf" "$HYPR_DIR/theme-lock.conf"
    cp "$HYPR_DIR/theme-ui-dark.conf" "$HYPR_DIR/theme-ui.conf"
  fi

  : >"$HYPR_DIR/theme-session.conf"
}

write_waybar_theme() {
  local mode="$1"
  local template="$WAYBAR_DIR/style-$mode.css"
  require_file "$template"
  cp "$template" "$WAYBAR_DIR/style.css"
}

write_wofi_theme() {
  local mode="$1"
  local template="$WOFI_DIR/style-$mode.css"
  require_file "$template"
  cp "$template" "$WOFI_DIR/style.css"
}

write_swaync_theme() {
  local mode="$1"
  local template="$SWAYNC_DIR/style-$mode.css"
  require_file "$template"
  cp "$template" "$SWAYNC_DIR/style.css"
}

write_mako_theme() {
  local mode="$1"
  local template="$MAKO_DIR/config-$mode"
  require_file "$template"
  cp "$template" "$MAKO_DIR/config"
}

write_ghostty_theme() {
  local mode="$1"
  if [[ ! -f "$GHOSTTY_CONFIG" ]]; then
    return
  fi

  set_or_append_line "$GHOSTTY_CONFIG" '^background-opacity = ' 'background-opacity = 0.84'
  set_or_append_line "$GHOSTTY_CONFIG" '^window-padding-x = ' 'window-padding-x = 2'
  set_or_append_line "$GHOSTTY_CONFIG" '^window-padding-y = ' 'window-padding-y = 2'

  if [[ "$mode" == "light" ]]; then
    set_or_append_line "$GHOSTTY_CONFIG" '^theme *= *' 'theme = Catppuccin Latte'
  else
    set_or_append_line "$GHOSTTY_CONFIG" '^theme *= *' 'theme = Catppuccin Mocha'
  fi

  sed -i '/^background=/d' "$GHOSTTY_CONFIG"
}

write_starship_theme() {
  local mode="$1"
  local template="${XDG_CONFIG_HOME:-$HOME/.config}/starship.$mode.toml"
  require_file "$template"
  cp "$template" "$STARSHIP_CONFIG"
}

reset_helium_theme_prefs_if_stopped() {
  local pref_file="$HOME/.config/net.imput.helium/Default/Preferences"
  local local_state_file="$HOME/.config/net.imput.helium/Local State"
  local tmp_file

  [[ -f "$pref_file" ]] || return
  if pgrep -af '[/](helium|helium-browser)( |$)' >/dev/null 2>&1; then
    return
  fi

  tmp_file="$(mktemp)"
  jq '
    .browser.theme = {"color_scheme2": 0, "follows_system_colors": true}
    | del(.extensions.theme)
  ' "$pref_file" >"$tmp_file" && mv "$tmp_file" "$pref_file"

  if [[ -f "$local_state_file" ]]; then
    tmp_file="$(mktemp)"
    jq '
      del(.profile.info_cache.Default.profile_color_seed)
      | del(.profile.info_cache.Default.profile_highlight_color)
      | del(.profile.info_cache.Default.default_avatar_fill_color)
      | del(.profile.info_cache.Default.default_avatar_stroke_color)
    ' "$local_state_file" >"$tmp_file" && mv "$tmp_file" "$local_state_file"
  fi
}

write_electron_flags() {
  local mode="$1"
  local enable_dark="false"
  if [[ "$mode" == "dark" ]]; then
    enable_dark="true"
  fi

  for file in \
    "$HOME/.config/brave-flags.conf" \
    "$HOME/.config/chrome-flags.conf" \
    "$HOME/.config/chromium-flags.conf" \
    "$HOME/.config/code-flags.conf" \
    "$HOME/.config/discord-flags.conf" \
    "$HOME/.config/electron-flags.conf" \
    "$HOME/.config/electron39-flags.conf" \
    "$HOME/.config/edge-flags.conf" \
    "$HOME/.config/helium-browser-flags.conf" \
    "$HOME/.config/legcord-flags.conf" \
    "$HOME/.config/microsoft-edge-flags.conf" \
    "$HOME/.config/notion-flags.conf" \
    "$HOME/.config/vesktop-flags.conf" \
    "$HOME/.config/vscodium-flags.conf"
  do
    set_force_dark_flag "$file" "$enable_dark"
  done
}

reload_live_components() {
  local gtk_theme="$1"

  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload >/dev/null 2>&1 || true
  fi

  if pgrep -x xsettingsd >/dev/null 2>&1; then
    pkill -HUP xsettingsd || true
  fi

  if pgrep -x waybar >/dev/null 2>&1; then
    pkill -x waybar || true
  fi
  if [[ "$gtk_theme" == "$DARK_GTK_THEME" ]]; then
    nohup env GTK_THEME=Adwaita:dark waybar -c "$WAYBAR_DIR/config" -s "$WAYBAR_DIR/style.css" >/dev/null 2>&1 &
  else
    nohup env -u GTK_THEME waybar -c "$WAYBAR_DIR/config" -s "$WAYBAR_DIR/style.css" >/dev/null 2>&1 &
  fi

  if pgrep -x mako >/dev/null 2>&1 && command -v makoctl >/dev/null 2>&1; then
    makoctl reload >/dev/null 2>&1 || true
  else
    if pgrep -x swaync >/dev/null 2>&1; then
      pkill -x swaync || true
    fi
    nohup swaync >/dev/null 2>&1 &
  fi

}

reload_portals() {
  if ! command -v systemctl >/dev/null 2>&1; then
    return
  fi

  systemctl --user restart xdg-desktop-portal-gtk.service >/dev/null 2>&1 || true
  systemctl --user restart xdg-desktop-portal.service >/dev/null 2>&1 || true
}

apply_mode() {
  local mode="$1"
  local gtk_theme prefer_dark color_scheme qt5_scheme qt6_scheme

  case "$mode" in
    light)
      gtk_theme="$LIGHT_GTK_THEME"
      prefer_dark="false"
      color_scheme="prefer-light"
      qt5_scheme="$LIGHT_QT5_SCHEME"
      qt6_scheme="$LIGHT_QT6_SCHEME"
      ;;
    dark)
      gtk_theme="$DARK_GTK_THEME"
      prefer_dark="true"
      color_scheme="prefer-dark"
      qt5_scheme="$DARK_QT5_SCHEME"
      qt6_scheme="$DARK_QT6_SCHEME"
      ;;
    *)
      printf 'Unknown mode: %s\n' "$mode" >&2
      exit 1
      ;;
  esac

  gsettings set org.gnome.desktop.interface color-scheme "$color_scheme"
  gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"

  write_gtk_settings "$gtk_theme" "$prefer_dark"
  write_portal_settings "$mode" "$color_scheme"
  write_xsettings "$gtk_theme"
  write_qt_settings "$qt5_scheme" "$qt6_scheme"
  write_hypr_theme_files "$mode"
  write_waybar_theme "$mode"
  write_wofi_theme "$mode"
  write_swaync_theme "$mode"
  write_mako_theme "$mode"
  write_ghostty_theme "$mode"
  write_starship_theme "$mode"
  reset_helium_theme_prefs_if_stopped
  write_electron_flags "$mode"
  write_systemd_gtk_theme "$mode"
  reload_live_components "$gtk_theme"
  reload_portals

  printf '%s\n' "$mode" >"$STATE_FILE"
  notify-send -t 2500 "Theme" "Switched system theme to $mode mode" >/dev/null 2>&1 || true
}

current_mode() {
  local current
  current="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || true)"
  if [[ "$current" == "'prefer-dark'" ]]; then
    printf 'dark\n'
  else
    printf 'light\n'
  fi
}

command="${1:-toggle}"

case "$command" in
  light|dark)
    apply_mode "$command"
    ;;
  toggle)
    if [[ "$(current_mode)" == "dark" ]]; then
      apply_mode light
    else
      apply_mode dark
    fi
    ;;
  status)
    printf '%s\n' "$(current_mode)"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
