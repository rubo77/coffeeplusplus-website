# Project notes — Coffee++ keyboard layout

## Naming

- The layout is called **Coffee++** — not "Entikey"/"ENTI-Key++" (historical
  name). All files were renamed to `Coffee++*`; the old names remain as
  symlinks pointing to the new files so external links keep working —
  do not replace the symlinks with real files, and keep the pattern when
  renaming files in the future.
- The XKB variant name installed by `dev/install-coffeeplusplus-xkb.sh` is
  `coffeeplusplus` (plain letters only — `+` is the layout+variant separator
  in `de+variant` strings and cannot be part of the name).
- Display name registered in `evdev.xml`/`evdev.lst`: `Deutsch (Coffee++)`.
- Activation: `setxkbmap -model pc105 -layout de -variant coffeeplusplus`,
  gsettings id `('xkb', 'de+coffeeplusplus')`.

## XKB install mechanics

- `dev/install-coffeeplusplus-xkb.sh` needs root — on this laptop run it via
  `pkexec bash dev/install-coffeeplusplus-xkb.sh` (polkit popup), not sudo.
- It patches `/usr/share/X11/xkb/symbols/de`, `rules/evdev.xml`,
  `rules/evdev.lst` and installs a re-apply worker + apt DPkg hook +
  systemd.path unit so `xkb-data` upgrades cannot silently remove the variant.
- The running GNOME Shell caches the xkb registry at login — newly registered
  variants do not appear in the HUD switcher until the shell is reloaded:
  Alt+F2 → `r` → Enter or `killall -3 gnome-shell` (X11, apps survive);
  `Meta.restart` via D-Bus `Eval` is disabled on Ubuntu ≥ 22.04. On Wayland
  only re-login works. `gnome-control-center` re-reads the files on every start.

## Docker mirror (dev/run.sh)

- `dev/run.sh` auto-starts the docker daemon via `pkexec systemctl start docker`
  and brings the stack up detached (`docker compose up -d`); website :8624,
  forum /phpBB3, mariadb :3395.
- Forum files live in `/var/tmp/devin/phpbb-upgrade/phpBB3` (bind-mounted):
  needs `a+rX` overall plus `a+w` on cache/, files/, store/, images/avatars/
  or Apache (www-data, uid 33) cannot read .htaccess / write the cache.
- Bind mounts pin the directory *inode*: after `mv phpBB3 phpBB3-new`,
  restart the web container or it keeps serving the old tree.
- Run phpBB CLI as www-data (`docker exec -u www-data dev-web-1 php ...`),
  otherwise it creates root-owned `cache/production/` and the site breaks.
- Forum upgraded locally 3.3.0 -> 3.3.19 (files swap keeping config.php,
  files/, images/, store/, ext/ + `bin/phpbbcli.php db:migrate`); backup
  of the 3.3.0 files: `/var/tmp/devin/phpbb-upgrade/phpBB3-3.3.0-backup`.
