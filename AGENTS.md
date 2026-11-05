# Project notes — Coffee++ keyboard layout

## Naming

- The layout is called **Coffee++** — not "Entikey"/"ENTI-Key++" (historical
  name, only kept in old files/downloads like `Enti-key*.klc`,
  `.xmodmap-ENTI-key++`, `download/entikey-1.0_i386.deb`).
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
