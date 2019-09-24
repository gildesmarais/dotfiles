function generateM3u {
  ls -1 ./*.mp3 >> $(basename `pwd`).m3u
}

function wav2mp3 {
  for F in *.wav

  do
    newname=`basename "$F".wav`
    echo $newname
    lame $1 "$newname.wav" "$newname.mp3"
    rm "$newname.wav"
  done
}

function all2wav {
  for F in *.{mp3,m4a,mp4,ogg,wav,opus}

  do
    newname=`basename "$F" .dff`
    echo $newname
    ffmpeg -i "$F" "$newname.wav"
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

function generate_videos_for_web {
  SOURCE_FILE="$1"
  BASE_NAME=$(basename "${SOURCE_FILE%.*}")

  # assuming macosx here:
  THREADS=$(sysctl -n hw.logicalcpu)
  THREADS="${THREADS:-2}"

  # h264
  ffmpeg -i "$SOURCE_FILE" -threads "$THREADS" -vcodec h264 -acodec aac -strict -2 "$BASE_NAME.x264.mp4"

  # h265
  ffmpeg -i "$SOURCE_FILE" -threads "$THREADS" -c:v libx265 -preset medium -x265-params crf=28 -c:a aac -strict experimental -b:a 128k "$BASE_NAME.x265.mp4"

  # webm vp9
  # https://developers.google.com/media/vp9/the-basics/
  ffmpeg -i "$SOURCE_FILE" -threads "$THREADS" -vcodec libvpx-vp9 -b:v 1M -quality good -acodec libvorbis "$BASE_NAME.vp9.webm"
}

export HOMEBREW_NO_ANALYTICS=1

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
