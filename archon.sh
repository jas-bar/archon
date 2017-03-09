#!/bin/bash
set -x

function aur_install() {
  if which yaourt; then
    yaourt -S $@ --noconfirm
  else
    for PKG in $@; do
      curl -o $PKG.tar.gz https://aur.archlinux.org/cgit/aur.git/snapshot/$PKG.tar.gz
      tar -xvzf $PKG.tar.gz
      cd $PKG
      makepkg
      sudo pacman -U $PKG-*.pkg.tar.xz
      cd ..
    done
  fi
}

function pacman_install() {
  sudo pacman -S $@ --noconfirm
}

function service_enable() {
  sudo systemctl enable "$@"
}

function install_yaourt() {
  pacman_install yajl
  aur_install package-query
  aur_install yaourt
}

function install_xorg() {
  pacman_install xorg
}

function install_bspwm() {
  pacman_install bspwm
  aur_install lemonbar-xft-git
}

function install_gnome() {
  pacman_install gnome
  service_enable gdm
}

function install_lxdm() {
  pacman_install lxdm
  service_enable lxdm
}

function install_pulseaudio() {
  pacman_install pulseaudio pulseaudio-alsa
}

while [ $# -gt 0 ]; do
  case "$1" in
    -y)
      install_yaourt
      ;;
    -x)
      install_xorg
      ;;
    -b)
      install_bspwm
      ;;
    -g)
      install_gnome
      ;;
    -l)
      install_lxdm
      ;;
    -p)
      install_pulseaudio
      ;;
  esac
  shift
done
