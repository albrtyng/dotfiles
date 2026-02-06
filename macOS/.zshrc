# local bin (claude-code, etc.)
export PATH="$HOME/.local/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use)

source $ZSH/oh-my-zsh.sh

function precmd() {
    print -n "\e]2;${PWD##*/}\a"
}

# homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# zoxide
eval "$(zoxide init zsh)"

# atuin
source "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

alias cd='z'
alias lg='lazygit'
alias oops='fuck'
eval "$(thefuck --alias)"
alias deac='deactivate'
alias vim='nvim'
alias sso='aws sso login'
alias cc='claude'

# alias for source venv/bin/activate (uv shell) like (poetry shell)
uv() {
  if [[ "$1" == "shell" ]]; then
    source .venv/bin/activate
  else
    command uv "$@"
  fi
}
