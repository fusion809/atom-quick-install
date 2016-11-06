#!/bin/bash
if `which wget >/dev/null 2>&1`; then

  STABLE_RELEASE=$(wget -q https://github.com/fusion809/atom-quick-install/releases/ -O - | grep tar.gz | grep href |  head -n 1 | cut -d '"' -f 2 | sed 's|/fusion809/atom-quick-install/archive/v||g' | sed 's|.tar.gz||g')

  printf "Running installer.sh for $STABLE_RELEASE...\n"
  /bin/bash -c "$(wget -cqO- https://github.com/fusion809/atom-quick-install/raw/v$STABLE_RELEASE/installer.sh)"

elif `which curl >/dev/null 2>&1`; then

  STABLE_RELEASE=$(curl -sL https://github.com/fusion809/atom-quick-install/releases/ | grep tar.gz | grep href |  head -n 1 | cut -d '"' -f 2 | sed 's|/fusion809/atom-quick-install/archive/v||g' | sed 's|.tar.gz||g')

  printf "Running installer.sh for $STABLE_RELEASE...\n"
  /bin/bash -c "$(curl -sL https://github.com/fusion809/atom-quick-install/raw/v$STABLE_RELEASE/installer.sh)"

fi
