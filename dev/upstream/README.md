# Upstream submission: Coffee++ into xkeyboard-config

Goal: get `de(coffeeplusplus)` into the official XKB layouts so it ships with
xkb-data on Debian/Ubuntu/Fedora without any patching.

The canonical upstream is **xkeyboard-config** on freedesktop GitLab:
https://gitlab.freedesktop.org/xkeyboard-config/xkeyboard-config
(Debian/Ubuntu only package that upstream; submitting to a distro first is
pointless — they take layout changes from upstream.)

## What is prepared

`0001-de-add-Coffee-one-hand-programmer-layout-variant.patch`
— a ready-made patch against current xkeyboard-config master that:

- appends `xkb_symbols "coffeeplusplus"` to `symbols/de`
- registers the variant in `rules/base.extras.xml` with
  `popularity="exotic"` (their convention for niche layouts; CONTRIBUTING.md
  rule 6) and description `German (Coffee++)` ("<Language> (<variation>)" style)

## How to submit

1. freedesktop.org GitLab account `rubo77` — credentials in `dev/.env`
   (`GITLAB_USER`, `GITLAB_TOKEN`, gitignored; the registered SSH key is
   `~/.ssh/id_ed25519`).

   Known blocker: the account cannot create projects/forks in its
   personal namespace (projects_limit) and the token lacks
   `User: Read` / `Work Item: Create` scopes — fork via the web UI or
   ask freedesktop admins for project creation rights first.

2. fork xkeyboard-config.
3. Apply the patch on a branch:

   ```sh
   git clone https://gitlab.freedesktop.org/<you>/xkeyboard-config.git
   cd xkeyboard-config
   git checkout -b coffeeplusplus
   git am < dev/upstream/0001-de-add-Coffee-one-hand-programmer-layout-variant.patch
   git push -u origin coffeeplusplus
   ```

3. Open a merge request with this description:

   > **de: add Coffee++ one-hand programmer layout variant**
   >
   > Coffee++ is a German-keyboard-based layout for programmers that allows
   > typing entirely with the left hand (right hand stays on the mouse) while
   > E/N/T/I are duplicated on the right side for optional fast two-hand
   > typing — similar to the national variants of Dvorak one-hand layouts.
   > Homepage: https://coffeeplusplus.z11.de/
   >
   > - `symbols/de`: new variant `xkb_symbols "coffeeplusplus"`, single
   >   group, includes "de" + "level3(ralt_switch)", Caps remapped to
   >   ISO_Level3_Shift for a second AltGr
   > - `rules/base.extras.xml`: registered as `de(coffeeplusplus)` with
   >   `popularity="exotic"`, description "German (Coffee++)"
   >
   > The layout exists since 2007 (Windows PKL + Linux xmodmap/.deb) and is
   > maintained in the project repository.

4. If maintainers ask for changes, adjust the block and regenerate the patch.

## Fallback

If upstream rejects it, `dev/install-coffeeplusplus-xkb.sh` remains the
supported local install path (it patches xkb-data at runtime and re-applies
after upgrades).
