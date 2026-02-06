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
export _ZO_DATA_DIR="/workspace/zoxide"
eval "$(zoxide init zsh)"

# atuin
source "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

alias cd='z'
alias fd='fdfind'
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
