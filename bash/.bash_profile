# Source bashrc for interactive shells
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# Auto-start Hyprland on TTY1
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec start-hyprland
fi

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
. "$HOME/.cargo/env"
