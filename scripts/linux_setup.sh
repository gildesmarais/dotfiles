#!/bin/bash

# only continue on linux
if [ "$(uname)" != "Linux" ]; then
  exit 0;
fi

GENERAL_PACKAGES="curl git zsh htop tmux watch wget vim z"
GENTOO_PACKAGES="colordiff midnight-commander node"
DEBIAN_PACKAGES="colordiff midnight-commander node"

# TODO: if gentoo,
# sudo emerge layman
# sudo layman -f --overlays https://github.com/bronislav/overlays/raw/master/layman.xml --add bronislav
# echo "=app-admin/rcm-9999 ~amd64" >> /etc/portage/package.keywords
# sudo emerge rcm

# emerge ...
# TODO: if debian, apt-get ...
# wget https://thoughtbot.github.io/rcm/debs/rcm_1.2.3-1_all.deb
# sha=$(sha256sum rcm_1.2.3-1_all.deb | cut -f1 -d' ')
# [ "$sha" = "fb8ec2611cd4d519965b66fcf950bd93d7593773659f83a8612053217daa38b4" ] && \
# sudo dpkg -i rcm_1.2.3-1_all.deb
