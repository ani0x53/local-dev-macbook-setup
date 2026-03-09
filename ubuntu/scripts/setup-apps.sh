#!/usr/bin/env bash
# =============================================================================
#  GUI Applications — Snap & apt installs
# =============================================================================
set -euo pipefail

echo "  ➜  Installing GUI applications..."

# ── Sublime Text ──────────────────────────────────────────────────────────────
if ! command -v subl &>/dev/null; then
  echo "  ➜  Installing Sublime Text..."
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list > /dev/null
  sudo apt update -qq && sudo apt install -y -qq sublime-text
  echo "  ✔  Sublime Text installed"
else
  echo "  ✔  Sublime Text already installed"
fi

# ── IntelliJ IDEA Community Edition ──────────────────────────────────────────
if ! command -v snap &>/dev/null; then
  echo "  ⚠  snap not found — skipping snap-based installs"
else
  SNAP_APPS=(
    "intellij-idea-community --classic"
    "postman"
  )

  for snap_app in "${SNAP_APPS[@]}"; do
    APP_NAME=$(echo "$snap_app" | awk '{print $1}')
    if snap list "$APP_NAME" &>/dev/null; then
      echo "  ✔  $APP_NAME already installed"
    else
      echo "  ➜  Installing $APP_NAME via snap..."
      sudo snap install $snap_app || echo "  ⚠  Failed to install $APP_NAME"
    fi
  done
fi

echo "  ✔  GUI applications installed"
