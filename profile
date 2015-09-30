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


export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
