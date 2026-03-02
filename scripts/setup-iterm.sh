#!/usr/bin/env bash
# =============================================================================
#  iTerm2 Configuration
# =============================================================================
set -euo pipefail

ITERM_PREFS="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
ITERM_PREFS_DIR="$HOME/.config/iterm2"

mkdir -p "$ITERM_PREFS_DIR"

echo "  ➜  Writing iTerm2 preferences..."

# Tell iTerm2 to use our custom prefs folder
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM_PREFS_DIR"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

# Shell integration
curl -sL https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash 2>/dev/null || true

# Write a sensible iTerm2 profile as JSON (Dynamic Profile)
mkdir -p "$HOME/Library/Application Support/iTerm2/DynamicProfiles"
cat > "$HOME/Library/Application Support/iTerm2/DynamicProfiles/mac-setup-profile.json" << 'PROFILE'
{
  "Profiles": [
    {
      "Name": "Dev",
      "Guid": "mac-setup-dev-profile",
      "Custom Command": "No",
      "Terminal Type": "xterm-256color",
      "Scrollback Lines": 10000,
      "Font": "JetBrainsMonoNFM-Regular",
      "Non Ascii Font": "JetBrainsMonoNFM-Regular",
      "Normal Font": "JetBrainsMonoNFM-Regular 14",
      "Use Non-ASCII Font": false,
      "Horizontal Spacing": 1,
      "Vertical Spacing": 1.1,
      "Blinking Cursor": true,
      "Cursor Type": 1,
      "Cursor Color": { "Red Component": 0.78, "Green Component": 0.55, "Blue Component": 1 },
      "Background Color": { "Red Component": 0, "Green Component": 0, "Blue Component": 0, "Alpha Component": 1 },
      "Foreground Color": { "Red Component": 0.9, "Green Component": 0.9, "Blue Component": 0.9, "Alpha Component": 1 },
      "Bold Color": { "Red Component": 1, "Green Component": 1, "Blue Component": 1 },
      "Selection Color": { "Red Component": 0.2, "Green Component": 0.2, "Blue Component": 0.4 },
      "Use Bright Bold": true,
      "Use Cursor Guide": true,
      "Cursor Guide Color": { "Red Component": 0.4, "Green Component": 0.4, "Blue Component": 0.6, "Alpha Component": 0.25 },
      "Window Transparency": 0,
      "Blur": false,
      "Blur Radius": 0,
      "Badge Text": "",
      "Working Directory": "~",
      "Option Key Sends": 2,
      "Right Option Key Sends": 2,
      "Mouse Reporting": true,
      "Allow Title Reporting": true,
      "Close Sessions On End": true,
      "Prompt Before Closing 2": false,
      "Silence Bell": false,
      "Visual Bell": true,
      "Flashing Bell": false,
      "Send Code When Idle": false,
      "Tab Color": { "Red Component": 0.15, "Green Component": 0.05, "Blue Component": 0.3 },
      "Use Tab Color": true
    }
  ]
}
PROFILE

echo "  ✔  iTerm2 profile written (will be available as 'Dev' profile on next launch)"
echo "  ✔  JetBrains Mono Nerd Font set as terminal font"
