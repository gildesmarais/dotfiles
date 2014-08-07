#!/bin/bash
### Bash script to mount and unmount EncFS Volumes
### use at own risk - works for me

# EncFS password here
#key="EncFS password here"
key=$(security find-generic-password -ga EncFS 2>&1 >/dev/null | cut -d'"' -f2)

errorCode=0

# umount
if [ "$(basename $0)" = "fs-cryptumount.command" ]; then
  umount ~/Dropbox-Encrypted
  if [ $? -eq 0 ]; then
    echo "EncFS ... unmounted"
  else
    errorCode=$?
    echo "encfs ... error while unmounting"
  fi
  exit $errorCode
fi

# mount
echo -n "encfs ... "

mount | grep encfs >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "${key}" | encfs -S ~/Dropbox/Encrypted ~/Dropbox-Encrypted
  if [ $? -ne 0 ]; then
    errorCode=$?
    echo "error mounting/starting"
  else
    echo "succesfully mounted"
    fi
else
  echo "already mounted"
fi

exit $errorCode
