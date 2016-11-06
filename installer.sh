#!/bin/bash

# Added thanks to this comment http://bit.ly/2eM4c2x on FB. Ironically the commenter was against this script and he helped me make it better :)
which which >/dev/null 2>&1 || ( printf 'It seems this system does not even have the basic `which` utility, so we are going to exit.' && exit "1" )

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

    if `lsb_release >/dev/null 2>&1`; then
      lsb_release -a | grep -w "Distributor ID" | sed "s/Distributor ID:\s//g"
    else
      printf 'Ah lsb_release does not appear to be present on this system and other methods of determining the OS name and version have failed. Script will now exit.'
      exit "1"
    fi

  elif [[ $1 == "VERSION_ID" ]]; then

    lsb_release -a | grep -w "Release" | sed "s/Release:\s//g"

  fi
}

function download {
  if `which wget >/dev/null 2>&1`; then
    wget -c "$1" -O "$2"
  else
    curl -L "$1" > "$2"
  fi
}

printf "Determining operating system...\n"
OS_NAME=$(osval NAME)
printf "The name of your operating system is ${OS_NAME}..."
OS_ARCH=$(uname -m)
OS_VERSION=$(osval VERSION_ID)
printf "and its version is ${OS_VERSION}. If this is incorrect please report it at https://github.com/fusion809/atom-quick-install/issues."

# This version function is borrowed from @probonopd's YAML for Atom https://git.io/vX4PL
if `which wget >/dev/null 2>&1`; then

  ATOM_VERSION=$(wget -q "https://api.github.com/repos/atom/atom/releases/latest"  -O - | grep -E "https.*atom-amd64.tar.gz" | cut -d'"' -f4 | sed 's|.*download/v||g' | sed 's|/atom-amd64.tar.gz||g')

elif `which curl >/dev/null 2>&1`; then

  ATOM_VERSION=$(curl -sL "https://api.github.com/repos/atom/atom/releases/latest" | grep -E "https.*atom-amd64.tar.gz" | cut -d'"' -f4 | sed 's|.*download/v||g' | sed 's|/atom-amd64.tar.gz||g')

else

  printf "Ah, you do not seem to have wget or cURL installed. So this script will exit, please install wget or cURL before you re-run this script.\n"
  exit "1"

fi

# Determine if Atom is installed and if so what version is installed
if `which atom >/dev/null 2>&1`; then
  PRESENT_VERSION=$(atom --version | grep "Atom" | sed 's|Atom\s.*:\s||g')
elif [[ -d $HOME/.local/share/atom*64 ]]; then
  PRESENT_VERSION=$($HOME/.local/share/atom/atom --version | grep "Atom" | sed 's|Atom\s.*:\s||g')
fi

# This is the base url to the binaries of the latest stable Atom release.
BASE_URL="https://github.com/atom/atom/releases/download/v$ATOM_VERSION"

## Architecture check
printf "Checking system architecture...\n"

if [[ $OS_ARCH == "x86_64" ]]; then

  printf "Good, you're operating on 64-bit Linux.\nInstallation will continue as per usual...\n"

else

  printf "Ah, it seems you are not using 64-bit Linux, so this installer will exit. If this is an error please report this bug at our bug tracker: https://github.com/fusion809/atom-quick-install/issues.\n"
  exit "1"

fi

function atomin {
  if [[ $OS_NAME == "openSUSE"* ]]; then

    printf "Using zypper to install Atom $ATOM_VERSION...\n"
    sudo zypper in -y $BASE_URL/atom.x86_64.rpm

  elif [[ $OS_NAME == "Fedora" ]]; then

    # Important to distinguish between Fedora <22 and >=22 as F22 and later use DNF instead of yum
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

    download $BASE_URL/atom.x86_64.rpm /tmp/atom-${ATOM_VERSION}.x86_64.rpm

    # Hopefully the sudo apt-get -f install will install missing deps similarly to how it does on Debian systems
    sudo rpm -I /tmp/atom-${ATOM_VERSION}.x86_64.rpm || sudo apt-get -f install

  elif [[ -f /etc/mandriva-release ]]; then

    printf "Downloading Atom $ATOM_VERSION rpm...\n"

    download $BASE_URL/atom.x86_64.rpm /tmp/atom-${ATOM_VERSION}.x86_64.rpm

    if [[ -f /usr/bin/apm ]]; then
      printf "Atom conflicts with APM, a package that comes pre-installed on some Mandriva-based distributions like Mageia.\n\n Do you want to exit this installer (which might be wise on older laptops) (option A) or continue to uninstall APM and install Atom (option B)? [enter either A or B as your answer]\n"
      read proceed
      if [[ $proceed == "A" ]]; then
        exit "1"
      elif [[ $proceed == "B" ]]; then
        sudo urpme apm
      fi
    fi
    printf "Installing Atom $ATOM_VERSION...\n"
    sudo urpmi /tmp/atom-${ATOM_VERSION}.x86_64.rpm

  elif [[ -f /etc/redhat-release ]]; then

    printf "Using yum to install Atom $ATOM_VERSION...\n"
    sudo yum install -y $BASE_URL/atom.x86_64.rpm

  # This test for Debian-based distros is courtesy of http://unix.stackexchange.com/a/321397/27613
  elif [[ -f /etc/debian_version ]]; then

    printf "Downloading Atom Debian package from GitHub...\n"

    download $BASE_URL/atom-amd64.deb /tmp/atom-${ATOM_VERSION}_amd64.deb

    printf "Attempting to install the Debian package with dpkg...\n"
    sudo dpkg -i /tmp/atom-${ATOM_VERSION}_amd64.deb || ( printf "Failed, probably due to unresolved dependencies... Going to attempt to solve this problem by running sudo apt-get -f install..." && sudo apt-get -f install -y )

  else

    printf "Downloading the Atom binary tarball...\n"
    download $BASE_URL/atom-amd64.tar.gz /tmp/atom-${ATOM_VERSION}_amd64.tar.gz

    printf "Installing Atom for $USER...\n"
    if ! [[ -d $HOME/.local/share/applications ]]; then
      mkdir -p $HOME/.local/share/applications
    fi
    if [[ -d $HOME/.local/share/atom-${PREVIOUS_VERSION}-amd64 ]]; then
      rm -rf $HOME/.local/share/atom-${PREVIOUS_VERSION}-amd64
    fi
    tar -xzf /tmp/atom-${ATOM_VERSION}_amd64.tar.gz -C $HOME/.local/share
    ln -sf $HOME/.local/share/atom-${ATOM_VERSION}-amd64 $HOME/.local/share/atom

    download https://github.com/fusion809/atom-quick-install/raw/master/atom.desktop $HOME/.local/share/applications/atom.desktop

    chmod +x $HOME/.local/share/applications/atom.desktop

  fi
}

## Check for a previous installation of Atom.
if [[ -n $PRESENT_VERSION ]]; then
  if ! [[ $PRESENT_VERSION == $ATOM_VERSION ]]; then

    printf "Atom is already installed, but it is an old version... Going to upgrade it."
    atomin

  else

    printf "It seems like the latest Atom version ($ATOM_VERSION) is already installed.\n"
    exit 1

  fi
else

  atomin

fi
