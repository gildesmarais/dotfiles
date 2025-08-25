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

  export PATH="/usr/local/opt/libpq/bin:$PATH"
fi
#endregion

#region shell setup with sourcing and evals

source ~/.profile

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

if command_exists asdf; then
  export ASDF_DATA_DIR="$HOME/.asdf"
  export PATH="$ASDF_DATA_DIR/shims:$PATH"

  # append completions to fpath
  # fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
  # initialise completions with ZSH's compinit
  # autoload -Uz compinit && compinit
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
alias gupstream="git_set_upstream"
alias lag="lazygit"

# git_set_upstream: set the upstream branch to the current branch
function git_set_upstream() {
  local current_branch="$(git symbolic-ref --short HEAD)"

  git branch --set-upstream-to="origin/$current_branch" "$current_branch"
}

# git_default_branch: get the default branch of the current git repository (assumes remote is named 'origin')
function git_default_branch() {
  git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

# git_changed: show files changed in the current branch, compared to the default branch
function git_changed() {
  local branch=${1:-$(git_default_branch)}
  git diff --name-only --diff-filter=AM $branch
}

alias git-changed="git_changed"
alias git-staged="git diff --name-only --cached"

#endregion

#region# ruby & rails, node aliases

function rubocop_update() {
  bundle update $(rg -o "rubocop[\w-]*" Gemfile | tr '\n' ' ')
}

alias be='bundle exec'
alias berd='RAILS_ENV=${RAILS_ENV:-test} bundle exec rspec --format documentation'
alias ber='RAILS_ENV=${RAILS_ENV:-test} bundle exec rspec'
alias rdbm='bundle exec rake db:migrate'
alias rdbr='bundle exec rake db:rollback'
alias fs='overmind start'
alias rr='bundle exec rails routes | fzf'
alias rubocop-global="rubocop --require rubocop-rails --require rubocop-rspec --require rubocop-performance --require test_prof/rubocop --require rubocop-thread_safety -c .rubocop.yml"
alias rubocop-update="rubocop_update"
alias yarn-upgrade='npx npm-check-updates -u && yarn install && npx yarn-deduplicate yarn.lock & yarn install'
#endregion

#region# start GUI applications
alias subl="open -a 'Sublime Text'"
alias marta="open -a Marta"
alias vsc="open -a 'Visual Studio Code'"
#endregion

#region# grepping code
alias todo-rg="rg '(TODO|FIXME|XXX|NOTE|OPTIMIZE|HACK|REVIEW)'"
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

if command_exists lsd; then
  alias ls='lsd'
  alias ll='lsd -l'
  alias la='lsd -a'
  alias lla='lsd -la'
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
#endregion

#endregion

#region sweetened history
# Some settings taken from various sources to enhance Zsh history:
# - https://www.soberkoder.com/better-zsh-history/
# - https://github.com/oleander/dotfiles
# - https://hassek.github.io/zsh-history-tweaking/
# Thanks! <3
setopt HIST_VERIFY            # Allow editing before executing commands retrieved from history.
setopt SHARE_HISTORY          # Share history between sessions.
setopt EXTENDED_HISTORY       # Write history in ":start:elapsed;command" format.
setopt HIST_FIND_NO_DUPS      # Prevent duplicate matching entries.
setopt INC_APPEND_HISTORY     # Immediately append to history file.
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicated entries first.
setopt HIST_IGNORE_DUPS       # Ignore consecutive duplicate entries.
setopt HIST_IGNORE_ALL_DUPS   # Delete old entry if a duplicate is recorded.
setopt HIST_IGNORE_SPACE      # Exclude entries that start with a space.
setopt HIST_SAVE_NO_DUPS      # Do not save duplicate entries.
setopt HIST_REDUCE_BLANKS     # Remove extra blanks.

export HISTFILE="$HOME/.zsh_history"
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
export HISTTIMEFORMAT="[%F %T] "

alias hgrep="history 0 | grep"
alias h="history 0 | fzf"
#endregion

#region key bindings

# jumping words with Alt and left/right arrow
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word
#endregion

#region Setup PKM tools
export WIKI_DIR="$HOME/versioned/gildesmarais/wiki"
alias wiki="$HOME/.dotfiles/scripts/wiki"

wike() {
    local editor="${VISUAL:-${EDITOR:-vi}}"
    if [ -d "$WIKI_DIR" ]; then
        "$editor" "$WIKI_DIR"
    else
        echo "Error: WIKI_DIR is not a directory or is not set." >&2
    fi
}

export TODO_NOTE_DIR="$HOME/versioned/gildesmarais/wiki/Calendar"
export TODO_AUTO_GIT_SYNC=true

alias todo="$HOME/.dotfiles/scripts/todo/todo"
alias t='todo add'
alias td='todo done'
alias tl='todo list'
alias note="todo note"
#endregion

export VISUAL=code

[[ $- == *i* ]] && todo motd
source "$HOME/.zshrc.local"
