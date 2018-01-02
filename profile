function generateM3u {
  ls -1 ./*.mp3 >> $(basename `pwd`).m3u
}

function m4a2mp3 {
  for F in *.m4a

  do
    newname=`basename "$F" .m4a`
    echo $newname
    ffmpeg -i "$F" "$newname.wav" && lame $1 "$newname.wav" "$newname.mp3"
    rm "$newname.wav"
  done
}

function command_exists {
  type "$1" >/dev/null 2>&1;
}

if command_exists yarn; then
  export PATH="$PATH:`yarn global bin`" # make yarn binaries available
fi

function serve {
  port="${1:-8080}"
  ruby -run -e httpd . -p $port
}

export HOMEBREW_NO_ANALYTICS=1

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
