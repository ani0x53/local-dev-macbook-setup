#!/usr/bin/env bash
# =============================================================================
#  Ubuntu Dev Setup — One-command laptop bootstrap
#  Usage: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ani0x53/local-dev-macbook-setup/main/ubuntu/setup.sh)"
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
  ╦ ╦╔╗ ╦ ╦╔╗╔╔╦╗╦ ╦  ╔═╗╔═╗╔╦╗╦ ╦╔═╗
  ║ ║╠╩╗║ ║║║║ ║ ║ ║  ╚═╗║╣  ║ ║ ║╠═╝
  ╚═╝╚═╝╚═╝╝╚╝ ╩ ╚═╝  ╚═╝╚═╝ ╩ ╚═╝╩
  One-command Ubuntu dev environment
EOF
echo -e "${RESET}"

# ── Verify Ubuntu ─────────────────────────────────────────────────────────────
if [[ ! -f /etc/os-release ]] || ! grep -qi "ubuntu" /etc/os-release; then
  error "This script only runs on Ubuntu."
fi

UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
info "Detected Ubuntu $UBUNTU_VERSION ($(uname -m))"

# ── Update System ─────────────────────────────────────────────────────────────
header "System Update"
info "Updating package lists..."
sudo apt update -qq
info "Upgrading packages..."
sudo apt upgrade -y -qq
success "System updated"

# ── Essential Build Tools ─────────────────────────────────────────────────────
header "Build Essentials"
info "Installing build dependencies..."
sudo apt install -y -qq \
  build-essential \
  curl \
  wget \
  software-properties-common \
  apt-transport-https \
  ca-certificates \
  gnupg \
  lsb-release \
  unzip \
  zip
success "Build essentials installed"

# ── GNOME Sensible Defaults ──────────────────────────────────────────────────
header "GNOME Sensible Defaults"
bash "$(dirname "$0")/scripts/gnome-defaults.sh"

# ── CLI Tools ─────────────────────────────────────────────────────────────────
header "CLI Tools & Packages"
info "Installing CLI tools via apt..."

APT_PACKAGES=(
  # Core
  git
  git-lfs
  curl
  wget
  tree
  jq
  openssh-client
  openssh-server

  # Shell
  zsh
  tmux
  neovim

  # System monitoring
  htop
  # 'watch' is part of procps (pre-installed)

  # Dev dependencies (needed for pyenv, etc.)
  libssl-dev
  zlib1g-dev
  libbz2-dev
  libreadline-dev
  libsqlite3-dev
  libncursesw5-dev
  xz-utils
  tk-dev
  libxml2-dev
  libxmlsec1-dev
  libffi-dev
  liblzma-dev

  # Docker prerequisites
  docker.io
  docker-compose-v2

  # Misc
  xclip
  xsel
  pipx
)

for pkg in "${APT_PACKAGES[@]}"; do
  [[ "$pkg" == \#* ]] && continue
  [[ -z "$pkg" ]] && continue
  if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
    success "$pkg already installed"
  else
    info "Installing $pkg..."
    sudo apt install -y -qq "$pkg" || warn "Failed to install $pkg — skipping"
  fi
done

# ── Modern CLI Tools (not in default repos) ──────────────────────────────────
header "Modern CLI Tools"

# GitHub CLI
if ! command -v gh &>/dev/null; then
  info "Installing GitHub CLI..."
  (type -p wget >/dev/null || sudo apt install wget -y -qq) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -qO "$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update -qq && sudo apt install gh -y -qq
  success "GitHub CLI installed"
else
  success "GitHub CLI already installed"
fi

# bat (better cat)
if ! command -v bat &>/dev/null && ! command -v batcat &>/dev/null; then
  info "Installing bat..."
  sudo apt install -y -qq bat || warn "Failed to install bat"
  # Ubuntu installs bat as 'batcat' — create symlink
  mkdir -p "$HOME/.local/bin"
  ln -sf /usr/bin/batcat "$HOME/.local/bin/bat" 2>/dev/null || true
  success "bat installed"
else
  success "bat already installed"
  # Ensure symlink exists
  if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf /usr/bin/batcat "$HOME/.local/bin/bat" 2>/dev/null || true
  fi
fi

# fd (better find) — Ubuntu ships as 'fd-find'
if ! command -v fd &>/dev/null && ! command -v fdfind &>/dev/null; then
  info "Installing fd-find..."
  sudo apt install -y -qq fd-find || warn "Failed to install fd-find"
  mkdir -p "$HOME/.local/bin"
  ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd" 2>/dev/null || true
  success "fd installed"
else
  success "fd already installed"
  if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd" 2>/dev/null || true
  fi
fi

# ripgrep (better grep)
if ! command -v rg &>/dev/null; then
  info "Installing ripgrep..."
  sudo apt install -y -qq ripgrep || warn "Failed to install ripgrep"
  success "ripgrep installed"
else
  success "ripgrep already installed"
fi

# fzf (fuzzy finder)
if ! command -v fzf &>/dev/null; then
  info "Installing fzf..."
  sudo apt install -y -qq fzf || warn "Failed to install fzf"
  success "fzf installed"
else
  success "fzf already installed"
fi

# eza (better ls)
if ! command -v eza &>/dev/null; then
  info "Installing eza..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
  sudo apt update -qq && sudo apt install -y -qq eza || warn "Failed to install eza"
  success "eza installed"
else
  success "eza already installed"
fi

# zoxide (smarter cd)
if ! command -v zoxide &>/dev/null; then
  info "Installing zoxide..."
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  success "zoxide installed"
else
  success "zoxide already installed"
fi

# yq (YAML processor)
if ! command -v yq &>/dev/null; then
  info "Installing yq..."
  YQ_ARCH=$(dpkg --print-architecture)
  sudo wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${YQ_ARCH}"
  sudo chmod +x /usr/local/bin/yq
  success "yq installed"
else
  success "yq already installed"
fi

# tldr (quick man pages)
if ! command -v tldr &>/dev/null; then
  info "Installing tldr..."
  sudo apt install -y -qq tldr || warn "Failed to install tldr"
  success "tldr installed"
else
  success "tldr already installed"
fi

# mise (polyglot version manager)
if ! command -v mise &>/dev/null; then
  info "Installing mise..."
  curl https://mise.jdx.dev/install.sh | sh
  success "mise installed"
else
  success "mise already installed"
fi

# ── Docker Setup ──────────────────────────────────────────────────────────────
header "Docker"
if groups "$USER" | grep -q docker; then
  success "User already in docker group"
else
  info "Adding $USER to docker group..."
  sudo usermod -aG docker "$USER" || warn "Failed to add to docker group"
  success "Added $USER to docker group (log out and back in to take effect)"
fi
sudo systemctl enable docker --now 2>/dev/null || true

# ── Java / JVM Setup ─────────────────────────────────────────────────────────
header "Java / JVM"
info "Installing OpenJDK 21, Maven, Gradle, Kotlin..."

sudo apt install -y -qq openjdk-21-jdk || warn "Failed to install openjdk-21-jdk"

# Maven
if ! command -v mvn &>/dev/null; then
  sudo apt install -y -qq maven || warn "Failed to install maven"
fi

# Gradle (via SDKMAN for latest version)
if ! command -v gradle &>/dev/null; then
  info "Installing Gradle via SDKMAN..."
  if [[ ! -d "$HOME/.sdkman" ]]; then
    curl -s "https://get.sdkman.io?rcupdate=false" | bash
  fi
  source "$HOME/.sdkman/bin/sdkman-init.sh" 2>/dev/null || true
  sdk install gradle < /dev/null || warn "Failed to install Gradle"
fi

# Kotlin
if ! command -v kotlin &>/dev/null; then
  info "Installing Kotlin via SDKMAN..."
  source "$HOME/.sdkman/bin/sdkman-init.sh" 2>/dev/null || true
  sdk install kotlin < /dev/null || warn "Failed to install Kotlin"
fi

success "JVM tools installed"

# ── Python Setup ──────────────────────────────────────────────────────────────
header "Python"

# pyenv
if ! command -v pyenv &>/dev/null; then
  info "Installing pyenv..."
  curl https://pyenv.run | bash
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path 2>/dev/null || true)"

info "Installing Python 3.12..."
pyenv install 3.12.4 --skip-existing
pyenv global 3.12.4
success "Python $(python3 --version 2>/dev/null || echo '3.12') set as global"

info "Installing pipx tools..."
pipx ensurepath
pipx install poetry || true
pipx install black  || true
pipx install ruff   || true
success "Poetry, Black, Ruff installed via pipx"

# ── Node.js via nvm ──────────────────────────────────────────────────────────
header "Node.js"
export NVM_DIR="$HOME/.nvm"
if [[ ! -d "$NVM_DIR" ]]; then
  info "Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"

if ! command -v node &>/dev/null; then
  info "Installing Node.js LTS via nvm..."
  nvm install --lts
  nvm alias default lts/*
  success "Node.js $(node --version) set as default"
else
  success "Node.js $(node --version) already available"
fi

# ── Claude Code ──────────────────────────────────────────────────────────────
header "Claude Code"
if ! command -v claude &>/dev/null; then
  info "Installing Claude Code via npm..."
  npm install -g @anthropic-ai/claude-code
  success "Claude Code installed"
else
  success "Claude Code already installed"
fi

# ── AWS CLI ──────────────────────────────────────────────────────────────────
header "AWS CLI"
if ! command -v aws &>/dev/null; then
  info "Installing AWS CLI v2..."
  AWSCLI_ARCH=$(uname -m)
  [[ "$AWSCLI_ARCH" == "aarch64" ]] && AWSCLI_ARCH="aarch64" || AWSCLI_ARCH="x86_64"
  curl -sL "https://awscli.amazonaws.com/awscli-exe-linux-${AWSCLI_ARCH}.zip" -o /tmp/awscliv2.zip
  unzip -qo /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install --update 2>/dev/null || sudo /tmp/aws/install
  rm -rf /tmp/awscliv2.zip /tmp/aws
  success "AWS CLI installed"
else
  success "AWS CLI already installed"
fi

# ── Terraform ─────────────────────────────────────────────────────────────────
header "Terraform"
if ! command -v terraform &>/dev/null; then
  info "Installing Terraform..."
  wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>/dev/null || true
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
  sudo apt update -qq && sudo apt install -y -qq terraform
  success "Terraform installed"
else
  success "Terraform already installed"
fi

# ── ZSH Configuration ───────────────────────────────────────────────────────
header "ZSH Configuration"
bash "$(dirname "$0")/scripts/setup-zsh.sh"

# ── GNOME Terminal Profile ───────────────────────────────────────────────────
header "GNOME Terminal Profile"
bash "$(dirname "$0")/scripts/setup-terminal.sh"

# ── Git Config ───────────────────────────────────────────────────────────────
header "Git Configuration"
bash "$(dirname "$0")/scripts/setup-git.sh"

# ── SSH Key for GitHub (optional, interactive only) ──────────────────────────
header "SSH Key for GitHub"
if [[ -t 0 ]]; then
  bash "$(dirname "$0")/scripts/setup-ssh.sh"
else
  warn "Non-interactive mode detected — skipping SSH key setup."
  info "Run afterwards: bash scripts/setup-ssh.sh"
fi

# ── VS Code ──────────────────────────────────────────────────────────────────
header "VS Code Extensions"
bash "$(dirname "$0")/scripts/setup-vscode.sh"

# ── GUI Applications ─────────────────────────────────────────────────────────
header "GUI Applications"
bash "$(dirname "$0")/scripts/setup-apps.sh"

# ── Done! ─────────────────────────────────────────────────────────────────────
echo -e "\n${BOLD}${GREEN}"
cat << 'EOF'
  ╔╦╗╔═╗╔╗╔╔═╗  ✔  All done!
   ║║║ ║║║║║╣
  ═╩╝╚═╝╝╚╝╚═╝  Your Ubuntu box is ready to ship code
EOF
echo -e "${RESET}"
warn "Log out and back in (or reboot) for Docker group and shell changes to take effect."
echo ""
echo -e "  ${BOLD}Next steps:${RESET}"
echo -e "  1. Run ${CYAN}git config --global user.name \"Your Name\"${RESET}"
echo -e "  2. Run ${CYAN}git config --global user.email \"you@example.com\"${RESET}"
echo -e "  3. Run ${CYAN}gh auth login${RESET} to authenticate with GitHub"
echo -e "  4. Run ${CYAN}aws configure${RESET} to set up AWS credentials"
echo -e "  5. Run ${CYAN}claude${RESET} to start using Claude Code"
echo -e "  6. SSH key: ${CYAN}bash scripts/setup-ssh.sh${RESET} if you skipped it above"
echo ""
