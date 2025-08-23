# vim:fileencoding=utf-8:ft=conf:foldmethod=marker

#: Helper functions {{{
function playground {
  dir="$HOME/playground/$(date -u +'%Y-%m')"

  [ ! -d "$dir" ] && mkdir -p "$dir"
  cd "$dir" || echo "Playground: unable to change directory to $dir"
}

function command_exists {
  type "$1" >/dev/null 2>&1;
}

##
# source: https://stackoverflow.com/a/30029855/17449024
# thank you, Michal!
listening() {
    if [ $# -eq 0 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

#: }}}

#: PATH extensions {{{
# make yarn binaries available
if command_exists yarn; then
  export PATH="$PATH:`yarn global bin`"
fi

# use the dotfiles' scripts
export PATH="$HOME/.scripts:$PATH"

# make Homebrow's sbin available
export PATH="/usr/local/sbin:$PATH"

# make cargo bin available
export PATH="$HOME/.cargo/bin:$PATH"
#: }}}

#: exports {{{
export EDITOR=vim

# homebrew
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# ruby
export DISABLE_SPRING=1
export RUBYOPT="-W0"

# fzf
export FZF_DEFAULT_COMMAND='rg --files --ignore-case'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--cycle'
#: }}}
