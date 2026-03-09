#!/usr/bin/env bash
# =============================================================================
#  Git Configuration
# =============================================================================
set -euo pipefail

echo "  ➜  Configuring Git globals..."

# Core
git config --global init.defaultBranch main
git config --global core.autocrlf input
git config --global core.editor "code --wait"
git config --global core.pager "bat --style=plain"

# Pull strategy
git config --global pull.rebase false

# Better diffs
git config --global diff.colorMoved zebra
git config --global diff.algorithm histogram

# Merge
git config --global merge.conflictstyle diff3

# Rebase
git config --global rebase.autosquash true
git config --global rebase.autostash true

# Push
git config --global push.default current
git config --global push.autoSetupRemote true

# Useful aliases
git config --global alias.st   "status -sb"
git config --global alias.lg   "log --oneline --graph --decorate --all"
git config --global alias.last "log -1 HEAD --stat"
git config --global alias.undo "reset HEAD~1 --mixed"
git config --global alias.unstage "reset HEAD --"
git config --global alias.cleanup "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d"
git config --global alias.aliases "config --get-regexp alias"

# Colors
git config --global color.ui auto
git config --global color.branch.current   "yellow bold"
git config --global color.branch.local     "green bold"
git config --global color.branch.remote    "cyan bold"

# Security
git config --global transfer.fsckobjects true

# Git LFS
git lfs install --skip-smudge 2>/dev/null || true

echo "  ✔  Git configured"
echo "  ⚠  Don't forget to set your name and email:"
echo "       git config --global user.name  \"Your Name\""
echo "       git config --global user.email \"you@example.com\""
