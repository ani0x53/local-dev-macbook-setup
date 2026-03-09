# ubuntu-setup

> One-command Ubuntu developer environment setup for Java, Kotlin & Python development.

---

## Quick Start

**Option 1 — Download the full repo ZIP**

Go to [github.com/ani0x53/local-dev-macbook-setup](https://github.com/ani0x53/local-dev-macbook-setup), click **Code → Download ZIP**, unzip it, then run:

```bash
cd local-dev-macbook-setup-main/ubuntu
chmod +x setup.sh scripts/*.sh
./setup.sh
```

**Option 2 — Clone**

```bash
git clone https://github.com/ani0x53/local-dev-macbook-setup.git
cd local-dev-macbook-setup/ubuntu
chmod +x setup.sh scripts/*.sh
./setup.sh
```

**Option 3 — Run directly**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/ani0x53/local-dev-macbook-setup/main/ubuntu/setup.sh)"
```

That's it. Go make a coffee — it takes ~15 minutes.

---

## What Gets Installed

### CLI Tools

| Tool | Purpose |
|------|---------|
| `git` + `git-lfs` | Version control |
| `gh` | GitHub CLI |
| `bat` | Better `cat` with syntax highlighting |
| `eza` | Better `ls` with icons |
| `fd` | Better `find` |
| `fzf` | Fuzzy finder |
| `ripgrep` | Better `grep` |
| `zoxide` | Smarter `cd` that learns your dirs |
| `jq` / `yq` | JSON/YAML processing |
| `tldr` | Quick cheatsheets |
| `tmux` | Terminal multiplexer |
| `starship` | Cross-shell prompt |
| `neovim` | Terminal editor |
| `mise` | Polyglot version manager |

### Dev Runtimes

| Tool | Version | Purpose |
|------|---------|---------|
| OpenJDK | 21 LTS | Java development |
| Kotlin | Latest via SDKMAN | Kotlin development |
| Maven | Latest via apt | JVM build tool |
| Gradle | Latest via SDKMAN | JVM build tool |
| Python | 3.12 via pyenv | Python development |
| Node.js | LTS via nvm | JS/tooling |
| AWS CLI | v2 | AWS access |
| Terraform | Latest | Infrastructure as code |
| Docker | docker.io + compose v2 | Containers |

### Python Extras (via pipx)

- **poetry** — dependency management
- **black** — code formatter
- **ruff** — fast linter

### Claude Code

Claude Code CLI (`claude`) — installed via npm.

### GUI Applications

| App | Source | Purpose |
|-----|--------|---------|
| VS Code | apt (Microsoft repo) | Code editor |
| Sublime Text | apt (official repo) | Lightweight editor |
| IntelliJ IDEA CE | snap | Java/Kotlin IDE |
| Postman | snap | API testing |

---

## ZSH Setup

Installs [Oh My Zsh](https://ohmyz.sh/) with a curated plugin set and the [Starship](https://starship.rs/) prompt (with a pre-configured theme showing git, Python, Java, Kotlin, AWS and time segments).

### Plugins

- `zsh-autosuggestions` — fish-like suggestions
- `zsh-syntax-highlighting` — command colouring
- `zsh-completions` — extra completions
- `zsh-history-substring-search` — up/down arrow searches history
- `fzf` — fuzzy history (`Ctrl+R`)
- `sudo` — press `ESC` twice to prepend `sudo`
- `z` — jump to recent directories
- `git`, `docker`, `aws`, `python`, `gradle`, `mvn`, `ubuntu`, and more

### Key Aliases

```bash
# Navigation
..    → cd ..
...   → cd ../..
z foo → jump to any dir matching 'foo' (zoxide)

# ls / eza
ls    → eza with icons
ll    → eza long list with sizes
lt    → tree view (2 levels)
la    → show hidden files

# Git
gs    → git status
ga    → git add
gaa   → git add --all
gc    → git commit -m
gca   → git commit --amend
gco   → git checkout
gcb   → git checkout -b
gp    → git push
gpf   → git push --force-with-lease
gpl   → git pull
gl    → pretty log graph
gd    → git diff
gds   → git diff --staged
gst   → git stash
gstp  → git stash pop
gbr   → git branch

# Docker
d     → docker
dc    → docker compose
dps   → docker ps
drm   → remove all containers
dprune → nuke everything

# Python
py    → python3
venv  → create + activate .venv
activate → source .venv/bin/activate

# AWS
awsp  → fzf profile switcher
awsw  → whoami (sts get-caller-identity)

# Claude Code
cc    → claude
ccc   → claude --continue

# Ubuntu-specific
update    → apt update + upgrade
install   → apt install
autoremove → apt autoremove
sctl      → sudo systemctl
open      → xdg-open

# Misc
cat   → bat (syntax highlighted)
ports → show listening ports (ss)
myip  → show public IP
reload → reload .zshrc
flushdns → flush DNS cache (resolvectl)
```

### Useful Functions

```bash
mkcd my-project         # mkdir + cd in one
extract archive.tar.gz  # universal extractor (supports .deb too)
weather London          # show weather
jdk 17                  # switch Java version
port 8080               # what's on port 8080?
killport 3000           # kill whatever's on :3000
newpr                   # open new GitHub PR in browser
```

---

## SSH Key for GitHub

The setup script will prompt you to generate an SSH key during installation. If you skip it or run via the one-liner `curl | bash` (which is non-interactive), you can run it any time:

```bash
bash scripts/setup-ssh.sh
```

What it does:
- Generates an `ed25519` key at `~/.ssh/id_ed25519`
- Adds it to the SSH agent
- Writes `~/.ssh/config` so the key persists
- Copies the public key to your clipboard (via `xclip`) and opens `github.com/settings/ssh/new`

Verify it worked:
```bash
ssh -T git@github.com
# Hi your-username! You've successfully authenticated...
```

---

## GNOME Terminal Profile

The default GNOME Terminal profile is configured with:

- JetBrains Mono Nerd Font 14pt
- Pure black background
- 10,000 line scrollback
- I-beam cursor with blinking
- No audible bell

---

## GNOME Desktop Defaults

- Dark mode enabled
- 24h clock format
- Tap-to-click on touchpad
- Edge tiling for window snapping
- Fast key repeat
- Auto-cleanup of old trash and temp files
- 15 min screen blank, no sleep on AC power

---

## VS Code Extensions

Extensions installed across these categories:

- **Theme**: One Dark Pro + Material Icons
- **Git**: GitLens, Git Graph
- **AI**: GitHub Copilot + Copilot Chat
- **Python**: Pylance, Black, Ruff
- **Java/Kotlin**: Language support, Debug, Test, Maven, Gradle
- **AWS**: AWS Toolkit
- **Containers**: Docker, Remote Containers
- **API**: REST Client, Thunder Client
- **Utilities**: Error Lens, Todo Tree, Path Intellisense, Spell Checker, Color Highlight, Markdown All-in-One

Settings are also written to `settings.json` — One Dark Pro theme, JetBrains Mono font, format-on-save, per-language formatters, and sane defaults.

---

## Post-Setup Steps

After the script finishes, run these once:

```bash
# 1. Log out and back in (for Docker group + ZSH)

# 2. Set your Git identity
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"

# 3. Authenticate GitHub CLI
gh auth login

# 4. Set up SSH key for GitHub (if you skipped during setup)
bash scripts/setup-ssh.sh

# 5. Configure AWS credentials
aws configure

# 6. Reload your shell
source ~/.zshrc

# 7. Start Claude Code
claude
```

---

## Repository Structure

```
ubuntu-setup/
├── setup.sh                  # Main entry point
├── scripts/
│   ├── gnome-defaults.sh     # Sensible GNOME desktop preferences
│   ├── setup-zsh.sh          # Oh My Zsh, plugins, .zshrc
│   ├── setup-git.sh          # Git globals and aliases
│   ├── setup-ssh.sh          # SSH key generation for GitHub (optional)
│   ├── setup-terminal.sh     # GNOME Terminal profile
│   ├── setup-vscode.sh       # VS Code install, extensions, settings.json
│   └── setup-apps.sh         # GUI applications (Sublime, IntelliJ, Postman)
└── README.md
```

---

## Re-running / Updating

The script is **idempotent** — safe to run multiple times. Already-installed items are skipped.

To update packages only:

```bash
sudo apt update && sudo apt upgrade -y
```

To re-run just one component:

```bash
./scripts/setup-zsh.sh
./scripts/setup-vscode.sh
```

---

## Customisation

- Add personal overrides to `~/.zshrc.local` (auto-sourced, never overwritten by re-runs)
- Edit `scripts/setup-vscode.sh` to add your own extensions
- Edit `scripts/setup-apps.sh` to add/remove GUI applications

---

## Key Differences from mac-setup

| Feature | mac-setup | ubuntu-setup |
|---------|-----------|-------------|
| Package manager | Homebrew | apt + snap |
| Terminal | iTerm2 | GNOME Terminal |
| Window manager | Rectangle | GNOME edge tiling |
| Launcher | Raycast | GNOME Activities |
| Desktop config | `defaults write` | `gsettings` |
| Docker | Docker Desktop (cask) | docker.io (apt) |
| JVM tools | Homebrew | SDKMAN (Gradle, Kotlin) |
| Clipboard | `pbcopy` | `xclip` / `xsel` |
| Open URLs | `open` | `xdg-open` |

---

## Tested On

- Ubuntu 24.04 LTS (Noble Numbat) — x86_64 and aarch64
- Ubuntu 22.04 LTS (Jammy Jellyfish)

---

## Licence

MIT — use freely, no warranty.
