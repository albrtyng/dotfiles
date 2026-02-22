# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use)

source $ZSH/oh-my-zsh.sh

function precmd() {
    print -n "\e]2;${PWD##*/}\a"
}

# homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# zoxide
if command -v zoxide &>/dev/null; then
  export _ZO_DATA_DIR="/workspace/zoxide"
  eval "$(zoxide init zsh)"
fi

# atuin
if [[ -f "$HOME/.atuin/bin/env" ]]; then
  source "$HOME/.atuin/bin/env"
fi
eval "$(atuin init zsh)"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# navigation
command -v zoxide &>/dev/null && alias cd='z'
alias fd='fdfind'
alias lg='lazygit'
alias oops='fuck'
eval "$(thefuck --alias)"
alias deac='deactivate'
alias vim='nvim'
alias sso='aws sso login'
alias cc='claude'
alias oc='opencode'

# bat (syntax-highlighting cat)
alias bat='batcat'

# eza (modern ls)
alias ls='eza'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --icons'

# yazi (terminal file manager)
alias y='yazi'

# D-Bus + gnome-keyring for headless credential storage
if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
  eval "$(dbus-launch --sh-syntax)" 2>/dev/null
fi
echo '' | gnome-keyring-daemon --unlock --components=secrets 2>/dev/null

# alias for source venv/bin/activate (uv shell) like (poetry shell)
uv() {
  if [[ "$1" == "shell" ]]; then
    source .venv/bin/activate
  else
    command uv "$@"
  fi
}
