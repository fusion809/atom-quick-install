#!/bin/bash
function osval {
  if [[ -f /etc/os-release ]]; then

    cat /etc/os-release | grep -w "$1" | sed "s/$1=//g" | sed 's/"//g'

  elif [[ -f /etc/pclinuxos-release ]]; then

    cat /etc/pclinuxos-release | grep -w "$1" | sed "s/$1=//g" | sed 's/"//g'

  elif [[ -f /usr/bin/emerge ]]; then

    if [[ -f /usr/bin/equo ]]; then
      if [[ $1 == "NAME" ]]; then
        printf "Sabayon Linux"
      elif [[ $1 == "VERSION_ID" ]]; then
        printf "Rolling"
      fi
    else
      if [[ $1 == "NAME" ]]; then
        printf "Gentoo Linux"
      elif [[ $1 == "VERSION_ID" ]]; then
        printf "Rolling"
      fi
    fi

  elif [[ $1 == "NAME" ]]; then

    lsb_release -a | grep -w "Distributor ID" | sed "s/Distributor ID:\s//g"

  elif [[ $1 == "VERSION_ID" ]]; then

    lsb_release -a | grep -w "Release" | sed "s/Release:\s//g"

  fi
}

OS_NAME=$(osval NAME)
OS_ARCH=$(uname -m)
OS_VERSION=$(osval VERSION_ID)
ATOM_VERSION=$(wget -q "https://api.github.com/repos/atom/atom/releases/latest"  -O - | grep -E "https.*atom-amd64.tar.gz" | cut -d'"' -f4 | sed 's|.*download/v||g' | sed 's|/atom-amd64.tar.gz||g')
BASE_URL="https://github.com/atom/atom/releases/download/v$ATOM_VERSION"

## Architecture check
printf "Checking system architecture...\n"

if [[ $OS_ARCH == "x86_64" ]]; then

  printf "Good, you're operating on 64-bit Linux!\n"

else

  printf "Ah, it seems you are not using 64-bit Linux, so this installer will exit. If this is an error please report this bug at our bug tracker: https://github.com/fusion809/atom-quick-install/issues.\n"
  exit 1

fi

## OS check
if [[ $OS_NAME == "openSUSE"* ]]; then

  printf "Using zypper to install Atom $ATOM_VERSION...\n"
  sudo zypper in -y $BASE_URL/atom.x86_64.rpm

elif [[ $OS_NAME == "Fedora" ]]; then

  if [[ $OS_VERSION < "22" ]]; then

    printf "Using yum to install Atom $ATOM_VERSION...\n"
    sudo yum install -y $BASE_URL/atom.x86_64.rpm

  else

    printf "Using DNF to install Atom $ATOM_VERSION...\n"
    sudo dnf install -y $BASE_URL/atom.x86_64.rpm

  fi

elif [[ $OS_NAME == "CentOS" ]]; then

  printf "Using yum to install Atom $ATOM_VERSION...\n"
  sudo yum install -y $BASE_URL/atom.x86_64.rpm

elif [[ -f /etc/pclinuxos-release ]]; then

  printf "Downloading Atom $ATOM_VERSION rpm...\n"
  wget -c $BASE_URL/atom.x86_64.rpm -O /tmp/atom-${ATOM_VERSION}.x86_64.rpm
  sudo rpm -I /tmp/atom-${ATOM_VERSION}.x86_64.rpm || sudo apt-get -f install

elif [[ -f /etc/mandriva-release ]]; then

  printf "Downloading Atom $ATOM_VERSION rpm...\n"
  wget -c $BASE_URL/atom.x86_64.rpm -O /tmp/atom-${ATOM_VERSION}.x86_64.rpm
  if [[ -f /usr/bin/apm ]]; then
    printf "Atom conflicts with APM, a package that comes pre-installed on some Mandriva-based distributions like Mageia. To my knowledge uninstalling it causes no problems, as it is no longer really required.\n This script is going to uninstall it...\n"
    sudo urpme apm
  fi
  printf "Installing Atom $ATOM_VERSION...\n"
  sudo urpmi /tmp/atom-${ATOM_VERSION}.x86_64.rpm

elif [[ -f /etc/redhat-release ]]; then

  printf "Using yum to install Atom $ATOM_VERSION...\n"
  sudo yum install -y $BASE_URL/atom.x86_64.rpm

elif [[ -f /etc/debian_version ]]; then

  printf "Downloading Atom Debian package from GitHub...\n"
  wget -c $BASE_URL/atom-amd64.deb -O /tmp/atom-${ATOM_VERSION}_amd64.deb
  printf "Attempting to install the Debian package with dpkg...\n"
  sudo dpkg -i /tmp/atom-${ATOM_VERSION}_amd64.deb || ( printf "Failed, probably due to unresolved dependencies... Going to attempt to solve this problem by running sudo apt-get -f install..." && sudo apt-get -f install -y )

else

  printf "Downloading the Atom binary tarball...\n"
  wget -c $BASE_URL/atom-amd64.tar.gz -O /tmp/atom-${ATOM_VERSION}_amd64.tar.gz

  printf "Installing Atom for $USER...\n"
  if ! [[ -d $HOME/.local/share/applications ]]; then
    mkdir -p $HOME/.local/share/applications
  fi
  tar -xzf /tmp/atom-${ATOM_VERSION}_amd64.tar.gz -C $HOME/.local/share
  ln -sf $HOME/.local/share/atom-${ATOM_VERSION}-amd64 $HOME/.local/share/atom
  wget -c https://github.com/fusion809/atom-quick-install/raw/master/atom.desktop -O $HOME/.local/share/applications/atom.desktop
  chmod +x $HOME/.local/share/applications/atom.desktop

fi
