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
  
  local omz_custom="${omz}/custom"
  if [[ ! -d "$omz_custom" ]]; then
    log "Creating Oh My Zsh custom directory..."
    mkdir -p "$omz_custom"
  else
    log "Oh My Zsh custom directory already exists."
  fi

  local zsh_autosuggestions_dir="${ZSH_CUSTOM:-$omz_custom}/plugins/zsh-autosuggestions"
  if [[ ! -d "$zsh_autosuggestions_dir" ]]; then
    log "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_autosuggestions_dir"
  else
    log "zsh-autosuggestions already installed."
  fi

  local zsh_syntax_highlighting_dir="${ZSH_CUSTOM:-$omz_custom}/plugins/zsh-syntax-highlighting"
  if [[ ! -d "$zsh_syntax_highlighting_dir" ]]; then
    log "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_syntax_highlighting_dir"
  else
    log "zsh-syntax-highlighting already installed."
  fi

  local you_should_use_dir="${ZSH_CUSTOM:-$omz_custom}/plugins/you-should-use"
  if [[ ! -d "$you_should_use_dir" ]]; then
    log "Installing you-should-use..."
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$you_should_use_dir"
  else
    log "you-should-use already installed."
  fi
}

# --- Starship Setup ---
setup_starship() {
  log "Setting up Starship prompt..."
  STARSHIP_DIR="$HOME/.config/starship"
  mkdir -p "$STARSHIP_DIR"

  if ! command -v starship >/dev/null 2>&1; then
    log "Installing Starship prompt..."
    if command -v curl >/dev/null 2>&1; then
      curl -sS https://starship.rs/install.sh | sh -s -- -y || error "Failed to install Starship prompt."
    else
      error "curl is required to install Starship prompt."
    fi
  else
    log "Starship prompt is already installed."
  fi
}

# --- Nvim Setup ---
setup_nvim() {
  log "Setting up Nvim..."
  NVIM_DIR="$HOME/.config/nvim"
  mkdir -p "$NVIM_DIR"

  install_package neovim nvim
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
  symlink_file "$dotdir/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim"
  symlink_file "$dotdir/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
  symlink_file "$dotdir/.ruler" "/workspace/.ruler"
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

  if ! command -v glab >/dev/null 2>&1; then
    log "Installing glab CLI..."
    brew install glab
  else
    log "glab already installed."
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
  (cd /workspace && ruler apply --config /workspace/.ruler/ruler.toml) || warn "Failed to apply ruler rules"
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
  
  if [[ -d "$HOME/.claude" && ! -L "$HOME/.claude" ]]; then
    log "Migrating existing Claude data..."
    rsync -av "$HOME/.claude/" "$CLAUDE_DIR/" 2>/dev/null || true
    rm -rf "$HOME/.claude"
  fi
  
  if [[ ! -L "$HOME/.claude" ]]; then
    ln -s "$CLAUDE_DIR" "$HOME/.claude"
    log "Created symlink: $HOME/.claude -> $CLAUDE_DIR"
  else
    log "Claude symlink already exists."
  fi
}

# --- Main ---
main() {
  sudo apt-get update
  setup_shell
  setup_ohmyzsh
  setup_starship
  setup_nvim
  setup_nvm
  setup_tools
  setup_ruler
  setup_claude
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
