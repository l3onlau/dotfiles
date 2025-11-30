#!/usr/bin/env bash
#
# Sync dotfiles between $HOME and repository
# Usage: ./script.sh pull|push
#

set -euo pipefail

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
REPO_DIR="$(dirname "$SCRIPT_PATH")"
HOME_REPO="$REPO_DIR/home"

tracked=(
  ".config/Code/User/keybindings.json"
  ".config/Code/User/settings.json"
  ".config/dunst"
  ".config/easyeffects"
  ".config/i3"
  ".config/i3status"
  ".config/mpv"
  ".config/redshift"
  ".fehbg"
  ".local/bin"
  ".npmrc"
  ".vimrc"
  ".xinitrc"
  ".Xresources"
  ".zprofile"
  ".zshrc"
)

usage() {
  echo "Usage: $0 {pull|push|diff}"
  exit 1
}

sync_dir() {
  local src="$1"
  local dest="$2"

  mkdir -p "$dest"
  # Remove everything in destination to ensure exact match
  rm -rf "$dest"/*
  cp -r "$src/." "$dest/"
}

sync_pull() {
  for item in "${tracked[@]}"; do
    src="$HOME_REPO/$item"
    dest="$HOME/$item"

    if [[ ! -e "$src" && ! -L "$src" ]]; then
      rm -rf "$dest"
      continue
    fi

    mkdir -p "$(dirname "$dest")"

    if [[ -d "$src" ]]; then
      sync_dir "$src" "$dest"
    else
      rm -f "$dest"
      cp -a "$src" "$dest"
    fi
  done
}

sync_push() {
  for item in "${tracked[@]}"; do
    src="$HOME/$item"
    dest="$HOME_REPO/$item"

    [[ ! -e "$src" && ! -L "$src" ]] && continue

    mkdir -p "$(dirname "$dest")"

    if [[ -d "$src" ]]; then
      sync_dir "$src" "$dest"
    else
      rm -f "$dest"
      cp -a "$src" "$dest"
    fi
  done
}

sync_diff() {
  for item in "${tracked[@]}"; do
    src="$HOME/$item"
    dest="$HOME_REPO/$item"

    # Only compare if both exist
    if [[ -e "$src" || -L "$src" ]] && [[ -e "$dest" || -L "$dest" ]]; then
      echo "=== Diff for $item ==="
      if [[ -d "$src" && -d "$dest" ]]; then
        diff -ruN "$dest" "$src" || true
      else
        diff -u "$dest" "$src" || true
      fi
      echo
    fi
  done
}

# --- Main ---
[[ $# -ne 1 ]] && usage

case "$1" in
  pull) sync_pull ;;
  push) sync_push ;;
  diff) sync_diff ;;
  *) usage ;;
esac
