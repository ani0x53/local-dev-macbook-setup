#!/usr/bin/env bash
# =============================================================================
#  SSH Key Setup for GitHub
#  Safe to run standalone: bash scripts/setup-ssh.sh
# =============================================================================
set -euo pipefail

SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_CONFIG="$HOME/.ssh/config"

echo ""
echo "  ── SSH Key for GitHub ──────────────────────────────────────────────────────"
echo ""

# ── Already have a key? ───────────────────────────────────────────────────────
if [[ -f "${SSH_KEY}.pub" ]]; then
  echo "  ✔  SSH key already exists: ${SSH_KEY}.pub"
  echo ""
  echo "  Public key:"
  echo ""
  cat "${SSH_KEY}.pub"
  echo ""
  echo "  ➜  If not already added, go to: https://github.com/settings/ssh/new"
  echo ""
  exit 0
fi

# ── Prompt ────────────────────────────────────────────────────────────────────
echo "  No SSH key found at ${SSH_KEY}"
echo ""
printf "  Generate a new SSH key for GitHub? [y/N] "
read -r REPLY
echo ""

if [[ ! "$REPLY" =~ ^[Yy]$ ]]; then
  echo "  Skipped. To generate later, run:"
  echo "       bash scripts/setup-ssh.sh"
  echo "  or:  ssh-keygen -t ed25519 -C \"your@email.com\""
  echo ""
  exit 0
fi

printf "  Enter your GitHub email address: "
read -r GH_EMAIL
echo ""

# ── Generate key ──────────────────────────────────────────────────────────────
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh-keygen -t ed25519 -C "$GH_EMAIL" -f "$SSH_KEY" -N ""
chmod 600 "$SSH_KEY"
chmod 644 "${SSH_KEY}.pub"

# ── Add to ssh-agent + macOS Keychain ────────────────────────────────────────
eval "$(ssh-agent -s)" &>/dev/null
ssh-add --apple-use-keychain "$SSH_KEY" 2>/dev/null || ssh-add "$SSH_KEY"

# ── Write ~/.ssh/config so the key persists across reboots ───────────────────
if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
  {
    echo ""
    echo "Host github.com"
    echo "  AddKeysToAgent yes"
    echo "  UseKeychain yes"
    echo "  IdentityFile ~/.ssh/id_ed25519"
  } >> "$SSH_CONFIG"
  chmod 600 "$SSH_CONFIG"
fi

# ── Show + copy public key ────────────────────────────────────────────────────
echo "  ✔  SSH key generated!"
echo ""
echo "  Public key — add this to GitHub → Settings → SSH keys → New SSH key:"
echo ""
cat "${SSH_KEY}.pub"
echo ""

if pbcopy < "${SSH_KEY}.pub" 2>/dev/null; then
  echo "  ✔  Copied to clipboard!"
  echo ""
fi

echo "  ➜  Opening GitHub SSH settings in your browser..."
open "https://github.com/settings/ssh/new" 2>/dev/null || true
echo ""
echo "  After adding the key, verify with:"
echo "       ssh -T git@github.com"
echo ""
