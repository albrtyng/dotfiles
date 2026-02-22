#!/bin/bash
set -euo pipefail

# --- Helpers ---
log()   { echo "[INFO] $*"; }
warn()  { echo "[WARN] $*"; }
error() { echo "[ERROR] $*"; exit 1; }

# --- Package Install ---
install_package() {
  local pkg=$1
  local cmd=${2:-$pkg}

  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Installing $pkg..."
    sudo apt-get -y install "$pkg" || error "Failed to install $pkg"
  else
    log "$pkg already installed."
  fi
}

# --- Shell Setup (no chsh, just ensure zsh exists) ---
setup_shell() {
  log "Installing zsh..."
  install_package zsh
  command -v zsh >/dev/null 2>&1 || error "zsh install failed"
}

# --- Symlinking ---
symlink_file() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" ]]; then
    log "$(basename "$target") already symlinked."
  elif [[ -e "$target" ]]; then
    log "Replacing existing $(basename "$target")"
    rm -f "$target"
    ln -s "$source" "$target"
  else
    log "Symlinking $(basename "$target")"
    ln -s "$source" "$target"
  fi
}

# --- Oh My Zsh ---
setup_ohmyzsh() {
  local omz="$HOME/.oh-my-zsh"
  if [[ ! -d "$omz" ]]; then
    log "Installing Oh My Zsh..."
    (cd "$HOME" && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended)
  else
    log "Oh My Zsh already installed."
  fi

  local omz_custom="${ZSH_CUSTOM:-${omz}/custom}"
  mkdir -p "$omz_custom"

  local -A omz_plugins=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    [you-should-use]="https://github.com/MichaelAquilina/zsh-you-should-use.git"
  )

  local name url plugin_dir
  for name in "${!omz_plugins[@]}"; do
    url="${omz_plugins[$name]}"
    plugin_dir="${omz_custom}/plugins/${name}"
    if [[ ! -d "$plugin_dir" ]]; then
      log "Installing $name..."
      git clone "$url" "$plugin_dir"
    else
      log "$name already installed."
    fi
  done
}

# --- Starship Setup ---
setup_starship() {
  log "Setting up Starship prompt..."
  STARSHIP_DIR="$HOME/.config/starship"
  mkdir -p "$STARSHIP_DIR"

  if ! command -v starship >/dev/null 2>&1; then
    log "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y || error "Failed to install Starship prompt."
  else
    log "Starship prompt is already installed."
  fi
}

# --- Nvim Setup ---
setup_nvim() {
  log "Setting up Nvim..."
  if ! command -v nvim >/dev/null 2>&1; then
    log "Installing neovim via brew..."
    brew install neovim
  else
    log "neovim already installed."
  fi
}

# --- Tmux Setup ---
setup_tmux() {
  install_package tmux
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ ! -d "$tpm_dir" ]]; then
    log "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  else
    log "TPM already installed."
  fi
}

# --- New CLI Tools ---
setup_new_tools() {
  install_package bat batcat
  batcat cache --build

  if ! command -v eza >/dev/null 2>&1; then
    log "Installing eza..."
    brew install eza
  else
    log "eza already installed."
  fi

  if ! command -v delta >/dev/null 2>&1; then
    log "Installing delta..."
    brew install git-delta
  else
    log "delta already installed."
  fi

  if ! command -v btop >/dev/null 2>&1; then
    log "Installing btop..."
    brew install btop
  else
    log "btop already installed."
  fi

  if command -v npm >/dev/null 2>&1 && ! command -v tldr >/dev/null 2>&1; then
    log "Installing tldr..."
    npm install -g tldr
  else
    log "tldr already installed or npm not available."
  fi

  if ! command -v yazi >/dev/null 2>&1; then
    log "Installing yazi..."
    brew install yazi
  else
    log "yazi already installed."
  fi
}

# --- Ghostty terminfo ---
setup_ghostty() {
  log "Setting up Ghostty terminfo..."
  local dotdir="$HOME/.config/coderv2/dotfiles"
  if [[ -f "$dotdir/xterm-ghostty.terminfo" ]]; then
    tic -x "$dotdir/xterm-ghostty.terminfo"
    log "Ghostty terminfo installed."
  else
    warn "xterm-ghostty.terminfo not found, skipping."
  fi
}

# --- OpenCode ---
setup_opencode() {
  if ! command -v opencode >/dev/null 2>&1; then
    log "Installing opencode..."
    curl -sL opencode.ai/install | bash
  else
    log "opencode already installed."
  fi
}

# --- D-Bus / gnome-keyring for headless credential storage ---
setup_credentials() {
  install_package libsecret-1-dev
  install_package dbus-x11
  install_package gnome-keyring

  if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
    log "Starting D-Bus session for credential storage..."
    eval "$(dbus-launch --sh-syntax)"
  fi
  echo '' | gnome-keyring-daemon --unlock --components=secrets 2>/dev/null || warn "Failed to unlock gnome-keyring"
}

# --- nvm setup ---
setup_nvm() {
  if [[ ! -d "$HOME/.nvm" ]]; then
    log "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
  else
    log "nvm already installed."
  fi

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

  if command -v nvm >/dev/null 2>&1; then
    nvm use node
  else
    warn "nvm not found in PATH, skipping Node.js installation"
  fi
}

# --- Dotfiles Symlinks ---
setup_dotfiles() {
  local dotdir="$HOME/.config/coderv2/dotfiles"

  symlink_file "$dotdir/.zshrc" "$HOME/.zshrc"
  symlink_file "$dotdir/.gitconfig" "$HOME/.gitconfig"
  symlink_file "$dotdir/.config/starship/starship.toml" "$HOME/.config/starship/starship.toml"
  [[ -d "$HOME/.config/nvim" && ! -L "$HOME/.config/nvim" ]] && rm -rf "$HOME/.config/nvim"
  symlink_file "$dotdir/.config/nvim" "$HOME/.config/nvim"
  mkdir -p "$HOME/.config/bat"
  symlink_file "$dotdir/.config/bat/themes" "$HOME/.config/bat/themes"
  mkdir -p "$HOME/.config/delta"
  symlink_file "$dotdir/.config/delta/catppuccin.gitconfig" "$HOME/.config/delta/catppuccin.gitconfig"
  symlink_file "$dotdir/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
  symlink_file "$dotdir/.tmux.conf" "$HOME/.tmux.conf"
  symlink_file "$dotdir/.ruler" "$HOME/.ruler"
}

# --- Dev Tools ---
setup_tools() {
  install_package fzf
  install_package fd-find fdfind
  install_package ripgrep rg

  ATUIN_DIR="$HOME/.config/atuin"
  mkdir -p "$ATUIN_DIR"
  if ! command -v atuin >/dev/null 2>&1; then
    log "Installing atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  else
    log "atuin already installed."
  fi

  if ! command -v zoxide >/dev/null 2>&1; then
    log "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  else
    log "zoxide already installed."
  fi

  if ! command -v lazygit >/dev/null 2>&1; then
    log "Installing lazygit..."
    local ver
    ver=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${ver}/lazygit_${ver}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit -D -t /usr/local/bin/
    rm -rf lazygit lazygit.tar.gz
  else
    log "lazygit already installed."
  fi

  if ! command -v thefuck >/dev/null 2>&1; then
    log "Installing thefuck..."
    pip3 install thefuck --user
  else
    log "thefuck already installed."
  fi

  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    log "Homebrew already installed."
  fi
}

setup_ruler() {
  log "Setting up Ruler..."

  if ! command -v ruler >/dev/null 2>&1; then
    log "Installing @intellectronica/ruler..."
    npm install -g @intellectronica/ruler || error "Failed to install ruler"
  else
    log "ruler already installed."
  fi
}

ruler_apply() {
  log "Applying ruler rules..."
  ruler apply --config "$HOME/.ruler/ruler.toml" --project-root "$HOME" || warn "Failed to apply ruler rules"
}

setup_claude() {
  local CLAUDE_DIR="/workspace/.claude"

  if ! command -v claude >/dev/null 2>&1; then
    log "Installing claude-code..."
    curl -fsSL https://claude.ai/install.sh | bash
  else
    log "claude-code already installed."
  fi

  log "Setting up Claude Code persistence..."
  mkdir -p "$CLAUDE_DIR"

  if [[ -L "$HOME/.claude" ]]; then
    log "Claude symlink already exists."
  elif [[ -d "$HOME/.claude" ]] && mountpoint -q "$HOME/.claude" 2>/dev/null; then
    log "$HOME/.claude is a mount point (persisted in cluster), using it directly."
  elif [[ -d "$HOME/.claude" ]]; then
    log "Migrating existing $HOME/.claude directory into $CLAUDE_DIR..."
    rsync -a --ignore-existing "$HOME/.claude/" "$CLAUDE_DIR/"
    if rm -rf "$HOME/.claude" 2>/dev/null; then
      ln -s "$CLAUDE_DIR" "$HOME/.claude"
      log "Migrated and created symlink: $HOME/.claude -> $CLAUDE_DIR"
    else
      log "$HOME/.claude cannot be removed (likely mounted), keeping existing directory."
    fi
  else
    ln -s "$CLAUDE_DIR" "$HOME/.claude"
    log "Created symlink: $HOME/.claude -> $CLAUDE_DIR"
  fi
}

# --- Main ---
main() {
  sudo apt-get update
  setup_shell
  setup_ohmyzsh
  setup_starship
  setup_nvm
  setup_tools
  setup_nvim
  setup_tmux
  setup_new_tools
  setup_ghostty
  setup_credentials
  setup_ruler
  setup_claude
  setup_opencode
  setup_dotfiles

  ruler_apply

  log "Copying Cursor skills..."
  mkdir -p "$HOME/.cursor/skills-cursor"
  cp -r /workspace/.cursor/skills/* "$HOME/.cursor/skills-cursor/"

  log "Bootstrap complete ✅"

  # --- Bash → Zsh handoff ---
  if command -v zsh >/dev/null 2>&1; then
    export SHELL=$(command -v zsh)
    log "Handing off to zsh..."
    exec "$SHELL" -l
  else
    warn "zsh not found, staying in bash."
  fi
}

main "$@"
