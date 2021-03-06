# Atom Quick Installer
This repository contains shell scripts for installing Atom on a variety of different Linux distributions, using the official binary releases of Atom. This is as opposed to my [atom-installer](https://github.com/fusion809/atom-installer) repository, which by default will build Atom from source and then install it. This repository only works on 64-bit Linux platforms.

To use it on a system with wget installed run:

```bash
/bin/bash -c "$(wget -cqO- https://git.io/vX442)"
```

while on a system with cURL run:

```bash
/bin/bash -c "$(curl -sL https://git.io/vX442)"
```

## License
The contents of this repository are licensed under the GNU General Public License version 3 (GPL v3), that is found in [LICENSE](https://github.com/fusion809/atom-quick-install/blob/master/LICENSE).
