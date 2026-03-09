#!/usr/bin/env bash
# =============================================================================
#  VS Code — Extensions & Settings
# =============================================================================
set -euo pipefail

# Install VS Code if not present
if ! command -v code &>/dev/null; then
  echo "  ➜  Installing VS Code..."
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg
  sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  rm -f /tmp/packages.microsoft.gpg
  sudo apt update -qq && sudo apt install -y -qq code
  echo "  ✔  VS Code installed"
fi

if ! command -v code &>/dev/null; then
  echo "  ⚠  VS Code CLI not found — skipping extensions"
  exit 0
fi

echo "  ➜  Installing VS Code extensions..."

EXTENSIONS=(
  # Theme / UI
  zhuangtongfa.material-theme          # One Dark Pro
  pkief.material-icon-theme

  # General Dev
  eamodio.gitlens
  mhutchie.git-graph
  github.copilot
  github.copilot-chat
  ms-vscode-remote.remote-containers
  ms-azuretools.vscode-docker
  humao.rest-client
  rangav.vscode-thunder-client          # REST client alternative
  redhat.vscode-yaml
  ms-vscode.live-server

  # Python
  ms-python.python
  ms-python.vscode-pylance
  ms-python.black-formatter
  charliermarsh.ruff

  # Java / Kotlin / JVM
  redhat.java
  vscjava.vscode-java-debug
  vscjava.vscode-java-test
  vscjava.vscode-maven
  vscjava.vscode-gradle
  fwcd.kotlin

  # AWS
  amazonwebservices.aws-toolkit-vscode

  # Markdown
  yzhang.markdown-all-in-one
  davidanson.vscode-markdownlint

  # Utilities
  streetsidesoftware.code-spell-checker
  usernamehw.errorlens
  christian-kohler.path-intellisense
  naumovs.color-highlight
  wayou.vscode-todo-highlight
  gruntfuggly.todo-tree
  ms-vscode.hexeditor
)

for ext in "${EXTENSIONS[@]}"; do
  [[ "$ext" == \#* ]] && continue
  [[ -z "$ext" ]] && continue
  code --install-extension "$ext" --force 2>/dev/null && echo "  ✔  $ext" || echo "  ⚠  Skipped: $ext"
done

# Write sensible settings.json
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
mkdir -p "$(dirname "$VSCODE_SETTINGS")"

ARCH=$(dpkg --print-architecture 2>/dev/null || echo "amd64")

cat > "$VSCODE_SETTINGS" << SETTINGS
{
  "workbench.colorTheme": "One Dark Pro",
  "workbench.iconTheme": "material-icon-theme",
  "editor.fontFamily": "'JetBrainsMono Nerd Font', 'JetBrains Mono', 'Fira Code', monospace",
  "editor.fontSize": 14,
  "editor.lineHeight": 1.6,
  "editor.fontLigatures": true,
  "editor.tabSize": 2,
  "editor.insertSpaces": true,
  "editor.formatOnSave": true,
  "editor.formatOnPaste": false,
  "editor.wordWrap": "off",
  "editor.minimap.enabled": false,
  "editor.cursorBlinking": "smooth",
  "editor.cursorSmoothCaretAnimation": "on",
  "editor.smoothScrolling": true,
  "editor.bracketPairColorization.enabled": true,
  "editor.guides.bracketPairs": true,
  "editor.inlineSuggest.enabled": true,
  "editor.suggestSelection": "first",
  "editor.linkedEditing": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "[python]": {
    "editor.defaultFormatter": "ms-python.black-formatter"
  },
  "[java]": {
    "editor.defaultFormatter": "redhat.java"
  },
  "[kotlin]": {
    "editor.defaultFormatter": "fwcd.kotlin"
  },
  "terminal.integrated.fontFamily": "'JetBrainsMono Nerd Font'",
  "terminal.integrated.fontSize": 13,
  "terminal.integrated.defaultProfile.linux": "zsh",
  "files.autoSave": "onFocusChange",
  "files.trimTrailingWhitespace": true,
  "files.insertFinalNewline": true,
  "files.exclude": {
    "**/__pycache__": true,
    "**/.pytest_cache": true
  },
  "explorer.confirmDelete": false,
  "explorer.confirmDragAndDrop": false,
  "git.autofetch": true,
  "git.confirmSync": false,
  "gitlens.hovers.currentLine.over": "line",
  "workbench.startupEditor": "none",
  "workbench.editor.enablePreview": false,
  "breadcrumbs.enabled": true,
  "search.exclude": {
    "**/node_modules": true,
    "**/.venv": true,
    "**/build": true,
    "**/dist": true
  },
  "python.defaultInterpreterPath": "\${workspaceFolder}/.venv/bin/python",
  "python.analysis.typeCheckingMode": "basic",
  "java.jdt.ls.java.home": "/usr/lib/jvm/java-21-openjdk-${ARCH}",
  "java.configuration.runtimes": [
    {
      "name": "JavaSE-21",
      "path": "/usr/lib/jvm/java-21-openjdk-${ARCH}",
      "default": true
    }
  ]
}
SETTINGS

echo "  ✔  VS Code settings.json written"
