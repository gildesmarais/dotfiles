export TERM="xterm-256color"
export PATH="/usr/local/sbin:$PATH"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# do not nag periodically about updating oh-my-zsh
DISABLE_UPDATE_PROMPT=true

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
#autoload -U promptinit && promptinit
#prompt pure

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="gentoo"

#POWERLINE_RIGHT_A="mixed"
POWERLINE_RIGHT_A="exit-status-on-fail"
POWERLINE_HIDE_HOST_NAME="true"
POWERLINE_FULL_CURRENT_PATH="true"
POWERLINE_DETECT_SSH="true"
POWERLINE_PATH="short"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment following line if you want to  shown in the command execution time stamp
# in the history command output. The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|
# yyyy-mm-dd
# HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse node npm rsync tmux )
plugins=(brew docker encode64 extract gem git gpg-agent history osx rsync ruby sublime ssh-agent tmux z)

source $ZSH/oh-my-zsh.sh
source ~/.profile

# thanks bitboxer @bitboxer and @klaustopher
# Trees should have colors
if command_exists tree; then
  alias tree="tree -C"
fi

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
  alias gas='colourify gas'
  alias ld='colourify ld'
  alias netstat='colourify netstat'
  alias ping='colourify ping'
  alias traceroute='colourify /usr/sbin/traceroute'
fi

if command_exists git; then
  # aliases found in @holman's dotfiles
  alias glog="git log --graph --pretty=format:'%Cred%h%Creset %an: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
  alias gp='git pull'
  alias gd='git diff'
  alias gc='git commit'
  alias gb='git branch'
  alias gs='git status'
fi

# ruby & rails aliases
alias be='bundle exec'
alias berd='bundle exec rspec --format documentation'
alias rroute='bundle exec rake routes | grep'

# some more aliases \o/
alias heidisql="cd ~/.wine/drive_c/Program\ Files/HeidiSQL/ && wine heidisql.exe"
alias mkvdts2ac3="mkvdts2ac3 --wd ."
alias mp3tag="wine ~/.wine/drive_c/Program\ Files/Mp3tag/Mp3tag.exe"
alias yta="youtube-dl -x --audio-format best --restrict-filenames -t"
alias ghpr="hub pull-request"
alias hgrep="history | grep"
alias psgrep="ps aux | grep"
alias p8="ping 8.8.8.8"

# temporarily alias
if command_exists nvim; then
  alias vi='nvim'
  alias vim='nvim'
fi

alias nb='newsboat'

if [ "$(uname)" = "Darwin" ]; then
  # we are on macosx
  alias lsusb="system_profiler SPUSBDataType"

  if [[ -e /usr/local/opt/curl-ca-bundle/share/ca-bundle.crt ]]; then
    export SSL_CERT_FILE=/usr/local/opt/curl-ca-bundle/share/ca-bundle.crt
  fi

  if command_exists brew; then
    [[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh
  fi
fi

# suggestions for ag based on ctags https://robots.thoughtbot.com/silver-searcher-tab-completion-with-exuberant-ctags
_ag() {
  if (( CURRENT == 2 )); then
    compadd $(cut -f 1 .git/tags .tags tmp/tags 2>/dev/null | grep -v '!_TAG')
  fi
}

compdef _ag ag

export DISABLE_SPRING=1

alias rdbm='rake db:migrate'
alias rdbr='rake db:rollback'
alias fs='foreman start'
alias rr='rake routes'

#test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

export NVM_DIR="/usr/local/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

