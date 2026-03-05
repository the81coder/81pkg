# 81pkg
The official repo of 81manorg Linux packages.

81manorg Linux uses the "81pkg" package manager which is an APT-style package manager written entirely in bash. The output of 81pkg commands may look like a mix of the archlinux yay and pacman package manager plus the ubuntu/debian package manager.

For reference:

```bash

root@81manorg:~ # 81pkg update
  =>> Refreshing package lists
  ==> Fetching from: https://the81coder.github.io/81pkg
Connecting to the81coder.github.io (185.199.109.153:443)
wget: note: TLS certificate validation not implemented
saving to '/var/cache/81pkg/lists/Packages.tmp.gz'
Packages.tmp.gz      100% |********************************|  1754  0:00:00 ETA
'/var/cache/81pkg/lists/Packages.tmp.gz' saved
  [OK] Package list up to date. 6 packages available.
root@81manorg:~ # 81pkg help

81pkg v2.0.0 — 81manorg Package Manager

USAGE
  81pkg [options] <command> [arguments...]

OPTIONS
  -v, --verbose      Enable shell tracing (set -x)
  -q, --quiet        Suppress informational output
  -y, --yes          Assume yes to all prompts
  -n, --dry-run      Assume no (simulate actions)
  --force            Override conflict / already-installed checks
  --no-download      Use cached archives only
  --arch=<arch>      Override architecture (default: amd64)
  --version          Print version and exit

COMMANDS
  update             Refresh package lists from repository
  install  <pkg...>  Download and install package(s)
  uninstall <pkg...> Remove installed package(s)
  purge    <pkg...>  Remove package(s) and their config files
  upgrade  [pkg...]  Upgrade package(s) (all if no args)
  download <pkg...>  Download .deb to current directory
  show     <pkg...>  Show detailed package information
  search   <query>   Search packages by name or description
  list     [filter]  List all available packages
  audit              List packages installed via 81pkg
  verify   [pkg...]  Verify installed package integrity
  hold     <pkg...>  Pin package at installed version
  unhold   <pkg...>  Remove version pin from package
  cache    [subcmd]  Cache management (info|clean|autoclean)
  log      [lines]   Show last N operation log entries (default 50)
  help               Show this help

EXAMPLES
  sudo 81pkg update
  sudo 81pkg install mypackage
  sudo 81pkg -y install pkgA pkgB pkgC
  81pkg search editor
  81pkg show mypackage
  sudo 81pkg upgrade
  sudo 81pkg cache clean

CONFIG   /etc/81pkg.conf
CACHE    /var/cache/81pkg/archives
LOG      /var/log/81pkg.log

root@81manorg:~ #
```
