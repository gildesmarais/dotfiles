# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

# bind asdf
. $(brew --prefix asdf)/asdf.sh
export PATH="/usr/local/opt/libpq/bin:$PATH"

# add asdf completions
fpath=(${ASDF_DIR}/completions $fpath)

# homebrew provided zsh completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

kitty + complete setup zsh | source /dev/stdin

source ~/.profile

export DISABLE_SPRING=1

# thanks bitboxer @bitboxer and @klaustopher
# Respect ANSI Color Strings
alias less="less -R"

# And now to colourify...

# GRC add color the output (thanks to @klaustopher)
if command_exists grc; then
  alias colourify="grc -es --colour=auto"
  alias configure='colourify ./configure'
  alias diff='colourify diff'
  alias make='colourify make'
  alias gcc='colourify gcc'
  alias g++='colourify g++'
  alias as='colourify as'

  alias netstat='colourify netstat'
  alias ping='colourify ping'
  alias traceroute='colourify /usr/sbin/traceroute'
fi

# aliases found in @holman's dotfiles
alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gb='git branch'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gs='git status'

# ruby & rails aliases
alias be='bundle exec'
alias berd='bundle exec rspec --format documentation'
alias rroute='bundle exec rake routes | grep'
alias rdbm='bundle exec rake db:migrate'
alias rdbr='bundle exec rake db:rollback'
alias fs='foreman start'
alias rr='bundle exec rake routes'

# some more aliases \o/
alias mp3tag="wine ~/.wine/drive_c/Program\ Files/Mp3tag/Mp3tag.exe"
alias subl="open -a 'Sublime Text'"
alias marta="open -a Marta"

alias hgrep="history | grep"
alias psgrep="ps aux | grep"
alias p8="ping 8.8.8.8"
alias pup="pup -c"

if command_exists nvim; then
  alias vi='nvim'
  alias vim='nvim'
fi

alias todo="rg '(TODO|FIXME|XXX|NOTE|OPTIMIZE|HACK|REVIEW)'"
alias ag="rg"
alias oleoo="npx gildesmarais/oleoo-cli"
alias pg="playground"

if [ "$(uname)" = "Darwin" ]; then
  # we are on macosx
  alias lsusb="system_profiler SPUSBDataType"
fi

# jumping words with Alt and left/right arrow
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
. /usr/local/etc/profile.d/z.sh
