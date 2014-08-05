#!/bin/bash
### Bash script for a safe startup of Dropbox. Check if EncFS is mounted.
### use at own risk - works for me

# Is the crypted directory (encfs process) already mounted?
ps ax | grep encfs | grep Dropbox >/dev/null
if [ $? -ne 0 ]; then
  # we have to mount EncFS
 ~/.encfsmount/fs-cryptmount.command
  if [ $? -ne 0 ]; then
    exit $?
  fi
fi

# EncFS mounted, Dropbox can safely start
open ~/Applications/Dropbox.app

killall Terminal
