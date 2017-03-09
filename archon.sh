#!/bin/bash

PACMAN_FLAGS=--noconfirm
AUR_FLAGS=--noconfirm
AUR_URL_PREFIX="https://aur.archlinux.org/cgit/aur.git/snapshot"

function aur_install() {
  if which yaourt; then
    yaourt $AUR_FLAGS -S $@
  else
    [ ! -d aur ] && mkdir aur && cd aur
    for PKG in $@; do
      curl -o $PKG.tar.gz $AUR_URL_PREFIX/$PKG.tar.gz
      tar -xvzf $PKG.tar.gz
      cd $PKG
      makepkg
      sudo pacman $AUR_FLAGS -U $PKG-*.pkg.tar.xz
      cd ..
    done
    cd ..
  fi
}

function pacman_install() {
  sudo pacman $PACMAN_FLAGS -S $@
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

if [ $# -eq 0 ]; then
  echo "archon.sh: ArchLinux Post-Installation Helper Script"
  echo "Usage: $0 [options...]"
  echo "Available options:"
  echo -e "\t-b\tbspwm" "\n\t\t" "pacman -S bspwm && aur -S lemonbar-xft-git"
  echo -e "\t-g\tgnome" "\n\t\t" "pacman -S gnome && systemctl enable gdm"
  echo -e "\t-l\tlxdm" "\n\t\t" "pacman -S lxdm && systemctl enable lxdm"
  echo -e "\t-p\tPulseAudio(+alsa)" "\n\t\t" "pacman -S pulseaudio pulseaudio-alsa"
  echo -e "\t-x\tX.Org server" "\n\t\t" "pacman -S xorg"
  echo -e "\t-y\tYaourt (AUR helper)" "\n\t\t" "curl aur/yaourt.tgz && makepkg && pacman -U yaourt.pkg.xz"
  exit 1
fi

# parse options
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

# actually do something
set -x

# vim: set ts=2 sts=2 sw=2 expandtab:
