#!/usr/bin/env bash
# ======================================================
# Dotfiles setup script for Arch Linux + Hyprland
# Manages configs with GNU Stow
# ======================================================

set -e # Exit on any error

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# --- Helper logging function ---
log() {
  echo -e "${GREEN}==>${RESET} ${1}"
}

warn() {
  echo -e "${YELLOW}==>${RESET} ${1}"
}

error() {
  echo -e "${RED}Error:${RESET} ${1}" >&2
}

# --- Ensure system dependencies ---
log "Installing required tools (stow, git, neovim, tmux)..."
if command -v pacman &>/dev/null; then
  sudo pacman -S --needed --noconfirm stow git neovim tmux
else
  warn "pacman not found — please manually install dependencies before continuing."
fi

# --- Clone repo if needed ---
if [ ! -d "$HOME/dotfiles" ]; then
  read -p "Enter your GitHub username: " GHUSER
  log "Cloning $GHUSER/dotfiles into ~/dotfiles..."
  git clone "git@github.com:$GHUSER/dotfiles.git" "$HOME/dotfiles"
fi

cd "$HOME/dotfiles" || {
  error "Failed to cd into ~/dotfiles"
  exit 1
}

# --- Pull latest changes ---
log "Updating repo..."
git pull || warn "Could not pull latest changes. Continuing..."

# --- Stow all configs ---
PACKAGES=(bash tmux hypr nvim)
for pkg in "${PACKAGES[@]}"; do
  if [ -d "$pkg" ]; then
    log "Stowing $pkg..."
    stow -D "$pkg" 2>/dev/null || true # Unstow if already linked
    stow "$pkg"
  else
    warn "Package '$pkg' not found, skipping..."
  fi
done

log "✅ All dotfiles stowed successfully!"
log "Done."
