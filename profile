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
#: }}}

#: exports {{{
export HOMEBREW_NO_ANALYTICS=1
export EDITOR=vim

# make yarn binaries available
if command_exists yarn; then
  export PATH="$PATH:`yarn global bin`"
fi

# ruby
export DISABLE_SPRING=1
export RUBYOPT="-W0"

# fzf
export FZF_DEFAULT_COMMAND='rg --files --ignore-case'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# use the dotfiles' scripts
export PATH="$HOME/.scripts:$PATH"
#: }}}
