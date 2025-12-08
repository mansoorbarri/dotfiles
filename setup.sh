#!/usr/bin/env bash
# ======================================================
# Dotfiles setup script
# Auto-stows every folder in ~/dotfiles/
# ======================================================

set -e            # exit on error
shopt -s nullglob # handle empty globs gracefully

# --- Colors ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

log() { echo -e "${GREEN}==>${RESET} ${1}"; }
warn() { echo -e "${YELLOW}==>${RESET} ${1}"; }
error() { echo -e "${RED}Error:${RESET} ${1}" >&2; }

# --- Ensure GNU Stow and Git ---
if ! command -v stow &>/dev/null || ! command -v git &>/dev/null; then
  log "Installing required tools..."
  if command -v pacman &>/dev/null; then
    sudo pacman -S --needed --noconfirm stow git
  elif command -v apt &>/dev/null; then
    sudo apt install -y stow git
  elif command -v brew &>/dev/null; then
    brew install stow git
  else
    error "No supported package manager found (pacman/apt/brew). Install stow + git manually."
    exit 1
  fi
fi

# --- Move to dotfiles dir ---
cd "$HOME/dotfiles" || {
  error "Dotfiles directory not found at ~/dotfiles"
  exit 1
}

log "Found dotfiles in: $(pwd)"

# --- Auto-detect subdirectories (each is one stow package) ---
for pkg in */; do
  pkg="${pkg%/}" # remove trailing slash
  if [ -d "$pkg" ]; then
    log "Stowing package: ${pkg}"
    stow -D "$pkg" 2>/dev/null || true # Unstow first if needed
    stow "$pkg"
  fi
done

log "✅ All available dotfiles have been stowed successfully."
