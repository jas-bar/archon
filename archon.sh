#!/bin/bash
set -x

function aur_install() {
  curl -o $1.tar.gz https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz
  tar -xvzf $1.tar.gz
  cd $1
  makepkg
  sudo pacman -U $1-*.pkg.tar.xz
  cd ..
}

function install_yaourt() {
  sudo pacman -S yajl
  aur_install package-query
  aur_install yaourt
}

while [ $# -gt 0 ]; do
  case "$1" in
    -y)
      install_yaourt
      ;;
  esac
  shift
done
