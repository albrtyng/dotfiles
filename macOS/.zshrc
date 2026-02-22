# local bin (claude-code, etc.)
export PATH="$HOME/.local/bin:$PATH"

# nix
[ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ] && . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'

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
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# atuin
if [[ -f "$HOME/.atuin/bin/env" ]]; then
  source "$HOME/.atuin/bin/env"
fi
eval "$(atuin init zsh)"

# starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# navigation
command -v zoxide &>/dev/null && [[ -z "$CLAUDECODE" ]] && alias cd='z'
alias lg='lazygit'
alias oops='fuck'
eval "$(thefuck --alias)"
alias deac='deactivate'
alias vim='nvim'
alias sso='aws sso login'
alias cc='claude'

# bat (syntax-highlighting cat)
alias cat='bat'

# eza (modern ls)
alias ls='eza'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --icons'

# yazi (terminal file manager)
alias y='yazi'

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
alias oc='opencode'

# claudecode.nvim: wrap make with nix dev shell
alias ccmake='nix develop .#ci -c make'

# alias for source venv/bin/activate (uv shell) like (poetry shell)
uv() {
  if [[ "$1" == "shell" ]]; then
    source .venv/bin/activate
  else
    command uv "$@"
  fi
}
