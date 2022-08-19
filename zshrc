#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
function command_exists {
  type "$1" >/dev/null 2>&1;
}

# homebrew provided zsh completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

# bind asdf
. $(brew --prefix asdf)/asdf.sh

  autoload -Uz compinit
  compinit
fi

if command_exists asdf; then
  # add asdf completions
  fpath=(${ASDF_DIR}/completions $fpath)
fi

if command_exists wezterm; then
  alias icat="wezterm imgcat"
fi

source ~/.profile

# Respect ANSI Color Strings
alias less="less -R"

# aliases found in @holman's dotfiles
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gb='git branch'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gs='git status'
alias gup="git pull --rebase --autostash"
alias lg="lazygit"

# ruby & rails aliases
alias be='bundle exec'
alias berd='bundle exec rspec --format documentation'
alias ber='bundle exec rspec'
alias rdbm='bundle exec rake db:migrate'
alias rdbr='bundle exec rake db:rollback'
alias fs='overmind start || foreman start'
alias rr='bundle exec rails routes | fzf'
alias yarn-upgrade='npx npm-check-updates -u && yarn install && npx yarn-deduplicate yarn.lock & yarn install'

# some more aliases \o/
alias subl="open -a 'Sublime Text'"
alias marta="open -a Marta"
alias vsc="open -a 'Visual Studio Code'"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

alias todo="rg '(TODO|FIXME|XXX|NOTE|OPTIMIZE|HACK|REVIEW)'"
alias ag="rg"
alias pg="playground"
alias wiki="cd ~/Documents/wiki && ~/.scripts/fuz"
alias hgrep="history | grep"
alias psgrep="ps aux | grep"
alias p8="ping 8.8.8.8"
alias p6="ping6 2606:4700:4700::1111"
alias pup="pup -c"

if command_exists exa; then
  alias ll="exa -lhF --git --time-style long-iso"
fi

if [ "$(uname)" = "Darwin" ]; then
  # we are on macosx
  alias lsusb="system_profiler SPUSBDataType"
fi


if command_exists bat; then
  # use bat for cat, and let it behave like cat
  alias cat="bat --style=plain --paging=never"
fi

# jumping words with Alt and left/right arrow
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi

export PATH="/usr/local/opt/libpq/bin:$PATH"

# setup android sdk
if [[ -d "$HOME/Library/Android/sdk" ]]; then
  export ANDROID_HOME=$HOME/Library/Android/sdk
  export PATH=$PATH:$ANDROID_HOME/emulator
  export PATH=$PATH:$ANDROID_HOME/tools
  export PATH=$PATH:$ANDROID_HOME/tools/bin
  export PATH=$PATH:$ANDROID_HOME/platform-tools
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.

# setup fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# setup zoxide
if command_exists zoxide; then
  eval "$(zoxide init zsh)"
fi

# setup starship
eval "$(starship init zsh)"
