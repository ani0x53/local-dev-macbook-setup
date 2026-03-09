#!/usr/bin/env bash
# =============================================================================
#  GNOME Terminal Profile Configuration
# =============================================================================
set -euo pipefail

if ! command -v gsettings &>/dev/null; then
  echo "  ⚠  gsettings not found — skipping terminal profile"
  exit 0
fi

echo "  ➜  Configuring GNOME Terminal profile..."

# Get the default profile UUID
PROFILE_LIST=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null || echo "")
if [[ -z "$PROFILE_LIST" ]]; then
  echo "  ⚠  GNOME Terminal not found — skipping"
  exit 0
fi

# Remove quotes from the UUID
PROFILE_ID=$(echo "$PROFILE_LIST" | tr -d "'")
PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${PROFILE_ID}/"

# Font
gsettings set "$PROFILE_PATH" use-system-font false
gsettings set "$PROFILE_PATH" font 'JetBrainsMono Nerd Font 14'

# Colors — pure black background with light gray text
gsettings set "$PROFILE_PATH" use-theme-colors false
gsettings set "$PROFILE_PATH" background-color '#000000'
gsettings set "$PROFILE_PATH" foreground-color '#E5E5E5'
gsettings set "$PROFILE_PATH" bold-color '#FFFFFF'
gsettings set "$PROFILE_PATH" bold-color-same-as-fg false

# Cursor
gsettings set "$PROFILE_PATH" cursor-blink-mode 'on'
gsettings set "$PROFILE_PATH" cursor-shape 'ibeam'

# Scrollback
gsettings set "$PROFILE_PATH" scrollback-lines 10000
gsettings set "$PROFILE_PATH" scrollback-unlimited false

# Bell
gsettings set "$PROFILE_PATH" audible-bell false

# Profile name
gsettings set "$PROFILE_PATH" visible-name 'Dev'

echo "  ✔  GNOME Terminal profile configured"
echo "  ✔  JetBrains Mono Nerd Font set as terminal font"
