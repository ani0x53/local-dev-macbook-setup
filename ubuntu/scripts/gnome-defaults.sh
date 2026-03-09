#!/usr/bin/env bash
# =============================================================================
#  GNOME Sensible Defaults
# =============================================================================
set -euo pipefail

echo "  ➜  Applying GNOME defaults..."

# Check if GNOME is available
if ! command -v gsettings &>/dev/null; then
  echo "  ⚠  gsettings not found — skipping GNOME defaults"
  exit 0
fi

# ── Appearance ───────────────────────────────────────────────────────────────
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface clock-format '24h'
gsettings set org.gnome.desktop.interface show-battery-percentage true 2>/dev/null || true

# ── Dock ─────────────────────────────────────────────────────────────────────
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM' 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock autohide true 2>/dev/null || true
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false 2>/dev/null || true

# ── File Manager (Nautilus) ──────────────────────────────────────────────────
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
gsettings set org.gnome.nautilus.list-view default-zoom-level 'small'
gsettings set org.gtk.gtk4.settings.file-chooser sort-directories-first true 2>/dev/null || true

# ── Keyboard ─────────────────────────────────────────────────────────────────
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30
gsettings set org.gnome.desktop.peripherals.keyboard delay 250

# ── Touchpad ─────────────────────────────────────────────────────────────────
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

# ── Window Management ────────────────────────────────────────────────────────
gsettings set org.gnome.mutter edge-tiling true
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

# ── Screenshots ──────────────────────────────────────────────────────────────
mkdir -p "$HOME/Pictures/Screenshots"

# ── Power ────────────────────────────────────────────────────────────────────
gsettings set org.gnome.desktop.session idle-delay 900       # 15 min before screen blank
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0 2>/dev/null || true  # never sleep on AC

# ── Privacy ──────────────────────────────────────────────────────────────────
gsettings set org.gnome.desktop.privacy remove-old-temp-files true
gsettings set org.gnome.desktop.privacy remove-old-trash-files true

echo "  ✔  GNOME defaults applied"
