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

function confirm_or_kill() {
  echo "Are you sure you want to continue? [Y/n]: "
  read confirm
  if [ "$confirm" != "" -a "$confirm" != "Y" -a "$confirm" != "y" ];
    echo "User aborted action"
    exit 1
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
  echo "----------------------------------------------------------------------------------------------------"
  echo "Please make sure drivers for your graphics cards are installed before continuing X.Org installation"
  echo "You can see list of some of your installed graphics-related packages below:"
  `sudo pacman -Q | grep -e mesa -e libgl -e xf86-video | sed s': .*::g' | xargs`
  confirm_or_kill
  echo "----------------------------------------------------------------------------------------------------"
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
features=""
while [ $# -gt 0 ]; do
  case "$1" in
    -y)
      features="$features,yaourt"
      ;;
    -x)
      features="$features,xorg"
      ;;
    -b)
      features="$features,bspwm"
      ;;
    -g)
      features="$features,gnome"
      ;;
    -l)
      features="$features,lxdm"
      ;;
    -p)
      features="$features,pulseaudio"
      ;;
  esac
  shift
done

echo "We are going to install the following features: "
echo "$features"
confirm_or_kill

# actually do something
set -x

# requires only pacman
if [[ $features == *"pulseaudio"* ]]; then
  install_pulseaudio
fi
if [[ $features == *"xorg"* ]]; then
  install_xorg
fi
# requires desktop
if [[ $features == *"gnome"* ]]; then
  install_gnome
fi
if [[ $features == *"lxdm"* ]]; then
  install_lxdm
fi
# aur installation
if [[ $features == *"yaourt"* ]]; then
  install_yaourt
fi
# requires aur
if [[ $features == *"bspwm"* ]]; then
  install_bspwm
fi

# vim: set ts=2 sts=2 sw=2 expandtab:
