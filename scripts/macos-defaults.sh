#!/usr/bin/env bash
# =============================================================================
#  macOS Sensible Defaults
# =============================================================================
set -euo pipefail

echo "  ➜  Applying macOS defaults..."

# ── Finder ────────────────────────────────────────────────────────────────────
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true        # show hidden files
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # search current folder
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # list view
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ── Dock ──────────────────────────────────────────────────────────────────────
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 48

# ── Screenshots ───────────────────────────────────────────────────────────────
mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# ── Keyboard ──────────────────────────────────────────────────────────────────
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false  # enable key repeat

# ── Trackpad ──────────────────────────────────────────────────────────────────
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1    # tap to click

# ── Misc ──────────────────────────────────────────────────────────────────────
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
defaults write com.apple.LaunchServices LSQuarantine -bool false    # no "open this?" dialog
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Disable crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent YES 2>/dev/null || true

# Restart affected apps
for app in "Finder" "Dock" "SystemUIServer"; do
  killall "$app" &>/dev/null || true
done

echo "  ✔  macOS defaults applied"
