#!/usr/bin/env bash
# =============================================================================
#  🍎  Mac Dev Setup — One-command laptop bootstrap
#  Usage: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/mac-setup/main/setup.sh)"
# =============================================================================

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}  ➜  ${RESET}$*"; }
success() { echo -e "${GREEN}  ✔  ${RESET}$*"; }
warn()    { echo -e "${YELLOW}  ⚠  ${RESET}$*"; }
error()   { echo -e "${RED}  ✖  ${RESET}$*" >&2; exit 1; }
header()  { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════${RESET}"; \
             echo -e "${BOLD}${CYAN}  $*${RESET}"; \
             echo -e "${BOLD}${CYAN}══════════════════════════════════════${RESET}\n"; }

# ── Banner ────────────────────────────────────────────────────────────────────
clear
echo -e "${BOLD}${CYAN}"
cat << 'EOF'
  ╔╦╗╔═╗╔═╗  ╔╦╗╔═╗╦  ╦  ╔═╗╔═╗╔╦╗╦ ╦╔═╗
  ║║║╠═╣║    ║║║║╣ ║  ║  ╚═╗║╣  ║ ║ ║╠═╝
  ╩ ╩╩ ╩╚═╝  ╩ ╩╚═╝╩═╝╩═╝╚═╝╚═╝ ╩ ╚═╝╩  
  🍎 One-command macOS dev environment
EOF
echo -e "${RESET}"

# ── Verify macOS ──────────────────────────────────────────────────────────────
[[ "$(uname)" == "Darwin" ]] || error "This script only runs on macOS."

# ── Check Apple Silicon or Intel ─────────────────────────────────────────────
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
  HOMEBREW_PREFIX="/opt/homebrew"
  info "Detected Apple Silicon (M-series)"
else
  HOMEBREW_PREFIX="/usr/local"
  info "Detected Intel Mac"
fi

# ── Xcode Command Line Tools ──────────────────────────────────────────────────
header "Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  # Wait for installation
  until xcode-select -p &>/dev/null; do sleep 5; done
  success "Xcode CLT installed"
else
  success "Xcode CLT already installed"
fi

# ── Homebrew ──────────────────────────────────────────────────────────────────
header "Homebrew"
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for the rest of this script
  eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
  success "Homebrew installed"
else
  success "Homebrew already installed — updating..."
  brew update --quiet
fi

# ── macOS System Defaults ─────────────────────────────────────────────────────
header "macOS Sensible Defaults"
bash "$(dirname "$0")/scripts/macos-defaults.sh"

# ── Brew Packages ─────────────────────────────────────────────────────────────
header "CLI Tools & Packages"
info "Installing formulae..."

FORMULAE=(
  # Core
  git
  git-lfs
  gh                  # GitHub CLI
  curl
  wget
  tree
  jq
  yq
  bat                 # better cat
  eza                 # better ls
  fd                  # better find
  fzf                 # fuzzy finder
  ripgrep             # better grep
  zoxide              # smarter cd
  tldr                # quick man pages
  htop
  watch
  gnupg
  openssh

  # Shell
  zsh
  zsh-autosuggestions
  zsh-syntax-highlighting
  starship            # cross-shell prompt

  # Dev tools
  python@3.12
  pyenv
  pipx
  node
  nvm
  maven
  gradle
  kotlin
  openjdk@21

  # Cloud & Infra
  awscli
  terraform
  docker-compose      # CLI only; Docker Desktop installed via cask

  # Utilities
  mise                # polyglot version manager
  tmux
  neovim
)

for formula in "${FORMULAE[@]}"; do
  # Skip comments
  [[ "$formula" == \#* ]] && continue
  [[ -z "$formula" ]] && continue
  if brew list "$formula" &>/dev/null 2>&1; then
    success "$formula already installed"
  else
    info "Installing $formula..."
    brew install "$formula" || warn "Failed to install $formula — skipping"
  fi
done

# ── Cask Applications ─────────────────────────────────────────────────────────
header "GUI Applications"
info "Installing casks..."

CASKS=(
  iterm2
  visual-studio-code
  sublime-text
  intellij-idea-ce    # Community Edition
  docker              # Docker Desktop
  rectangle           # window manager
  raycast             # launcher / productivity
  arc                 # modern browser (optional, remove if preferred)
  fig                 # terminal autocomplete (optional)
  postman
)

for cask in "${CASKS[@]}"; do
  [[ "$cask" == \#* ]] && continue
  [[ -z "$cask" ]] && continue
  if brew list --cask "$cask" &>/dev/null 2>&1; then
    success "$cask already installed"
  else
    info "Installing $cask..."
    brew install --cask "$cask" || warn "Failed to install $cask — skipping"
  fi
done

# ── Java / JVM Setup ─────────────────────────────────────────────────────────
header "Java / JVM"
info "Linking OpenJDK 21..."
sudo ln -sfn "$HOMEBREW_PREFIX/opt/openjdk@21/libexec/openjdk.jdk" \
  /Library/Java/JavaVirtualMachines/openjdk-21.jdk 2>/dev/null || true
success "OpenJDK 21 linked"

# ── Python Setup ──────────────────────────────────────────────────────────────
header "Python"
info "Configuring pyenv + installing Python 3.12..."
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path 2>/dev/null || true)"
pyenv install 3.12.4 --skip-existing
pyenv global 3.12.4
success "Python $(python3 --version) set as global"

info "Installing pipx tools..."
pipx ensurepath
pipx install poetry || true
pipx install black  || true
pipx install ruff   || true
success "Poetry, Black, Ruff installed via pipx"

# ── Claude Code ───────────────────────────────────────────────────────────────
header "Claude Code"
if ! command -v claude &>/dev/null; then
  info "Installing Claude Code via npm..."
  npm install -g @anthropic-ai/claude-code
  success "Claude Code installed: $(claude --version 2>/dev/null || echo 'installed')"
else
  success "Claude Code already installed"
fi

# ── AWS CLI ───────────────────────────────────────────────────────────────────
header "AWS CLI"
if ! command -v aws &>/dev/null; then
  info "Installing AWS CLI v2..."
  TMPDIR=$(mktemp -d)
  curl -fsSL "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "$TMPDIR/AWSCLIV2.pkg"
  sudo installer -pkg "$TMPDIR/AWSCLIV2.pkg" -target /
  rm -rf "$TMPDIR"
  success "AWS CLI installed: $(aws --version)"
else
  success "AWS CLI already installed: $(aws --version)"
fi

# ── ZSH Configuration ─────────────────────────────────────────────────────────
header "ZSH Configuration"
bash "$(dirname "$0")/scripts/setup-zsh.sh"

# ── iTerm2 Profile ────────────────────────────────────────────────────────────
header "iTerm2 Profile"
bash "$(dirname "$0")/scripts/setup-iterm.sh"

# ── Git Config ────────────────────────────────────────────────────────────────
header "Git Configuration"
bash "$(dirname "$0")/scripts/setup-git.sh"

# ── VS Code Extensions ────────────────────────────────────────────────────────
header "VS Code Extensions"
bash "$(dirname "$0")/scripts/setup-vscode.sh"

# ── Done! ─────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${GREEN}"
cat << 'EOF'
  ╔╦╗╔═╗╔╗╔╔═╗  ✔  All done!
   ║║║ ║║║║║╣  
  ═╩╝╚═╝╝╚╝╚═╝  Your Mac is ready to ship code 🚀
EOF
echo -e "${RESET}"
warn "⚠  Restart your terminal (or run: source ~/.zshrc) to activate all changes."
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo -e "  1. Run ${CYAN}git config --global user.name \"Your Name\"${RESET}"
echo -e "  2. Run ${CYAN}git config --global user.email \"you@example.com\"${RESET}"
echo -e "  3. Run ${CYAN}gh auth login${RESET} to authenticate with GitHub"
echo -e "  4. Run ${CYAN}aws configure${RESET} to set up AWS credentials"
echo -e "  5. Run ${CYAN}claude${RESET} to start using Claude Code"
echo ""
