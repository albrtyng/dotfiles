#!/bin/bash
set -euo pipefail

# --- Auto-detect dotfiles directory ---
DOTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Helpers ---
log()   { echo "[INFO] $*"; }
warn()  { echo "[WARN] $*"; }
error() { echo "[ERROR] $*"; exit 1; }

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

# --- Symlinking ---
symlink_file() {
  local source="$1"
  local target="$2"

  if [[ -L "$target" ]]; then
    log "$(basename "$target") already symlinked."
  elif [[ -e "$target" ]]; then
    log "Replacing existing $(basename "$target")"
    rm -rf "$target"
    ln -s "$source" "$target"
  else
    log "Symlinking $(basename "$target")"
    ln -s "$source" "$target"
  fi
}

# --- Homebrew Setup ---
setup_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    log "Homebrew already installed."
  fi
}

# --- Shell Setup (verify zsh exists) ---
setup_shell() {
  log "Verifying zsh..."
  command -v zsh >/dev/null 2>&1 || error "zsh not found (should ship with macOS)"
}

# --- Oh My Zsh ---
setup_ohmyzsh() {
  local omz="$HOME/.oh-my-zsh"
  if [[ ! -d "$omz" ]]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    log "Oh My Zsh already installed."
  fi

  local omz_custom="${omz}/custom"
  mkdir -p "$omz_custom"

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
  install_package starship
  mkdir -p "$HOME/.config/starship"

  local dotdir_root
  dotdir_root="$(dirname "$DOTDIR")"
  symlink_file "$dotdir_root/.config/starship/starship.toml" "$HOME/.config/starship/starship.toml"
  log "Linked starship.toml"
}

# --- Nvim Setup ---
setup_nvim() {
  log "Setting up Nvim..."
  install_package neovim nvim

  local dotdir_root
  dotdir_root="$(dirname "$DOTDIR")"
  if [[ -d "$HOME/.config/nvim" && ! -L "$HOME/.config/nvim" ]]; then
    log "Backing up existing nvim config..."
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak.$(date +%s)"
  fi
  symlink_file "$dotdir_root/.config/nvim" "$HOME/.config/nvim"
  log "Linked nvim config"
}

# --- Tmux Setup ---
setup_tmux() {
  install_package tmux

  local dotdir_root
  dotdir_root="$(dirname "$DOTDIR")"
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ ! -d "$tpm_dir" ]]; then
    log "Installing TPM (Tmux Plugin Manager)..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
  else
    log "TPM already installed."
  fi
  symlink_file "$dotdir_root/.tmux.conf" "$HOME/.tmux.conf"
  log "Linked .tmux.conf"
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

# --- Dev Tools ---
setup_tools() {
  install_package fzf
  install_package fd
  install_package ripgrep rg
  install_package lazygit
  install_package thefuck
  install_package zoxide

  mkdir -p "$HOME/.config/atuin"
  if ! command -v atuin >/dev/null 2>&1; then
    log "Installing atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
  else
    log "atuin already installed."
  fi
  cat > "$HOME/.config/atuin/config.toml" <<'EOF'
enter_accept = true
EOF
  log "Wrote atuin config"
}

# --- New CLI Tools ---
setup_new_tools() {
  local dotdir_root
  dotdir_root="$(dirname "$DOTDIR")"

  install_package bat
  mkdir -p "$HOME/.config/bat/themes"
  symlink_file "$dotdir_root/.config/bat/themes/Catppuccin Frappe.tmTheme" "$HOME/.config/bat/themes/Catppuccin Frappe.tmTheme"
  bat cache --build
  log "Linked bat theme"

  install_package eza
  install_package git-delta delta
  install_package btop

  if command -v npm >/dev/null 2>&1 && ! command -v tldr >/dev/null 2>&1; then
    log "Installing tldr..."
    npm install -g tldr
  else
    log "tldr already installed or npm not available."
  fi

  install_package yazi
}

# --- Git Config ---
setup_git() {
  local dotdir_root
  dotdir_root="$(dirname "$DOTDIR")"

  mkdir -p "$HOME/.config/delta"
  symlink_file "$dotdir_root/.config/delta/catppuccin.gitconfig" "$HOME/.config/delta/catppuccin.gitconfig"
  symlink_file "$dotdir_root/.gitconfig" "$HOME/.gitconfig"
  log "Linked git config and delta theme"
}

# --- Ghostty ---
setup_ghostty() {
  local dotdir_root
  dotdir_root="$(dirname "$DOTDIR")"

  local ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
  mkdir -p "$ghostty_dir"
  symlink_file "$dotdir_root/.config/ghostty/config" "$ghostty_dir/config"
  log "Linked Ghostty config"
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

# --- Ruler ---
setup_ruler() {
  local dotdir_root
  dotdir_root="$(dirname "$DOTDIR")"

  if command -v npm >/dev/null 2>&1 && ! command -v ruler >/dev/null 2>&1; then
    log "Installing @intellectronica/ruler..."
    npm install -g @intellectronica/ruler || error "Failed to install ruler"
  else
    log "ruler already installed or npm not available."
  fi
  if [[ -d "$dotdir_root/.ruler" ]]; then
    symlink_file "$dotdir_root/.ruler" "$HOME/.ruler"
    log "Linked ruler config"
  fi
}

ruler_apply() {
  if command -v ruler >/dev/null 2>&1; then
    log "Applying ruler rules..."
    ruler apply --config "$HOME/.ruler/ruler.toml" --project-root "$HOME" || warn "Failed to apply ruler rules"
  else
    warn "ruler not installed, skipping apply"
  fi
}

# --- Dotfiles Symlinks ---
setup_dotfiles() {
  local dotdir_root
  dotdir_root="$(dirname "$DOTDIR")"

  symlink_file "$DOTDIR/.zshrc" "$HOME/.zshrc"
  symlink_file "$dotdir_root/.config/atuin/config.toml" "$HOME/.config/atuin/config.toml"
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
  setup_tmux
  setup_new_tools
  setup_git
  setup_ruler
  setup_claude
  setup_opencode
  setup_dotfiles
  setup_ghostty

  ruler_apply

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
