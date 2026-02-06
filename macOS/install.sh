#!/bin/bash
set -euo pipefail

# --- Helpers ---
log()   { echo "[INFO] $*"; }
warn()  { echo "[WARN] $*"; }
error() { echo "[ERROR] $*"; exit 1; }

# --- Auto-detect dotfiles directory ---
DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Package Install (via Homebrew) ---
install_package() {
  local pkg=$1
  local cmd=${2:-$pkg}

  if ! command -v "$cmd" >/dev/null 2>&1; then
    log "Installing $pkg..."
    brew install "$pkg" || error "Failed to install $pkg"
  else
    log "$pkg already installed."
  fi
}

# --- Homebrew Setup ---
setup_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    log "Homebrew already installed."
  fi

  # Add brew to PATH for the rest of this script
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

# --- Shell Setup (verify zsh exists) ---
setup_shell() {
  log "Verifying zsh..."
  command -v zsh >/dev/null 2>&1 || error "zsh not found (should ship with macOS)"
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

  install_package starship
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
    nvm install node
  else
    warn "nvm not found in PATH, skipping Node.js installation"
  fi
}

# --- Dotfiles Symlinks ---
setup_dotfiles() {
  local dotdir_root
  dotdir_root="$(dirname "$DOTDIR")"

  symlink_file "$DOTDIR/.zshrc" "$HOME/.zshrc"
  symlink_file "$dotdir_root/.gitconfig" "$HOME/.gitconfig"
  symlink_file "$dotdir_root/.config/starship/starship.toml" "$HOME/.config/starship/starship.toml"
  symlink_file "$dotdir_root/.config/nvim/init.vim" "$HOME/.config/nvim/init.vim"
  symlink_file "$dotdir_root/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
}

# --- Dev Tools ---
setup_tools() {
  install_package fzf
  install_package fd
  install_package ripgrep rg

  ATUIN_DIR="$HOME/.config/atuin"
  mkdir -p "$ATUIN_DIR"
  if ! command -v atuin >/dev/null 2>&1; then
    log "Installing atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  else
    log "atuin already installed."
  fi

  install_package zoxide
  install_package lazygit
  install_package thefuck
  install_package glab
}

# --- Claude Code ---
setup_claude() {
  if ! command -v claude >/dev/null 2>&1; then
    log "Installing claude-code..."
    curl -fsSL https://claude.ai/install.sh | bash
  else
    log "claude-code already installed."
  fi
}

# --- Main ---
main() {
  setup_homebrew
  setup_shell
  setup_ohmyzsh
  setup_starship
  setup_nvim
  setup_nvm
  setup_tools
  setup_claude
  setup_dotfiles

  # Set zsh as default shell if not already
  if [[ "$SHELL" != "$(command -v zsh)" ]]; then
    log "Setting zsh as default shell..."
    chsh -s "$(command -v zsh)"
  fi

  log "Bootstrap complete ✅"

  # --- Hand off to zsh ---
  if command -v zsh >/dev/null 2>&1; then
    export SHELL=$(command -v zsh)
    log "Handing off to zsh..."
    exec "$SHELL" -l
  else
    warn "zsh not found, staying in bash."
  fi
}

main "$@"
