#region functions
function command_exists {
  type "$1" >/dev/null 2>&1
}

fzf_git_checkout() {
  if [ $# -eq 0 ]; then
    git branch --all | fzf | tr -d '[:space:]' | xargs git checkout
  else
    git checkout "$@"
  fi
}
#endregion

#region homebrew provided stuff: zsh completions, libs
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  if [[ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]]; then
    # bind asdf
    . $(brew --prefix asdf)/libexec/asdf.sh

    # add asdf completions
    fpath=(${ASDF_DIR}/completions $fpath)
  fi

  autoload -Uz compinit
  compinit

  export PATH="/usr/local/opt/libpq/bin:$PATH"
fi
#endregion

#region shell setup with sourcing and evals

source ~/.profile

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# setup starship
if command_exists starship; then
  eval "$(starship init zsh)"
fi

# setup fzf
if command_exists fzf; then
  eval "$(fzf --zsh)"
fi

# setup zoxide
if command_exists zoxide; then
  eval "$(zoxide init zsh)"
fi

# setup zsh-autosuggestion
[ -f $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# source ~/.zshrc.local
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
#endregion

#region aliases

#region# git related (some found in @holman's dotfiles)
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gb='git branch'
alias gc='git commit'
alias gco='fzf_git_checkout'
alias gd='git diff'
alias gs='git status'
alias gup="git pull --rebase --autostash"
alias gundo="git reset --soft HEAD~1"
alias lg="lazygit"
#endregion

#region# ruby & rails, node aliases
alias be='bundle exec'
alias berd='bundle exec rspec --format documentation'
alias ber='bundle exec rspec'
alias rdbm='bundle exec rake db:migrate'
alias rdbr='bundle exec rake db:rollback'
alias fs='overmind start'
alias rr='bundle exec rails routes | fzf'
alias rubocop-global="rubocop --require rubocop-rails --require rubocop-rspec --require rubocop-performance --require test_prof/rubocop --require rubocop-thread_safety -c .rubocop.yml"
alias yarn-upgrade='npx npm-check-updates -u && yarn install && npx yarn-deduplicate yarn.lock & yarn install'
#endregion

#region# start GUI applications
alias subl="open -a 'Sublime Text'"
alias marta="open -a Marta"
alias vsc="open -a 'Visual Studio Code'"
#endregion

#region# grepping code
alias todo="rg '(TODO|FIXME|XXX|NOTE|OPTIMIZE|HACK|REVIEW)'"
alias ag="rg"
#endregion

#region# pleasent path traversal
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
#endregion

#region# magic folder commands
alias pg="playground"
alias wiki="cd ~/versioned/gildesmarais/wiki && ~/.scripts/fuz"
#endregion

#region# better cat and "imagec" (icat)
if command_exists bat; then
  # use bat for cat, and let it behave like cat
  alias cat="bat --style=plain --paging=never"
fi

if command_exists wezterm; then
  alias icat="wezterm imgcat"
fi
#endregion

#region# likewise powerful aliases beginning with 'l'
alias less="less -R"

if command_exists exa; then
  alias ll="exa -lhF --git --time-style long-iso"
fi

if [ "$(uname)" = "Darwin" ]; then
  # we are on macosx
  alias lsusb="system_profiler SPUSBDataType"
fi
#endregion

#region# powerful aliases beginning with 'p'
alias psgrep="ps aux | grep"
alias p8="ping 8.8.8.8"
alias p6="ping6 2606:4700:4700::1111"
alias pup="pup -c"
alias pw="pwgen -nyB1 $(shuf -i 46-64 -n 1) 1"
#endregion

#endregion

#region sweetened history (some things taken from https://www.soberkoder.com/better-zsh-history/ )
export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
alias hgrep="history | grep"
alias h="history | fzf"
#endregion

#region key bindings

# jumping words with Alt and left/right arrow
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word
#endregion
