# Coffee++ keyboard layout

Free under the GNU licence, by Ruben Barkow.

**A one-hand typing keyboard layout for programmers that can optionally be used with both hands.**

Coffee++ lets you type complete texts and code **with your left hand only**, leaving the
right hand free for the mouse, the number pad — or a coffee. The four most common letters
**E, N, T and I** are additionally repeated on the right-hand side, so with both hands you
can reach a much faster typing speed than with QWERT/QWERTZ.

Unlike the Left-Hand-Dvorak layout, the left hand stays at its standard position, so it also
works well on laptops (no palm on the touchpad) and ergonomic keyboards.

![Coffee++ keyboard layout](Coffee++_keyboard_layout.gif)

## Layout concepts

- All letters are reachable on the left half of the keyboard (one-hand writing).
- The right half directly produces the special characters programmers need most —
  `( ) " = [ ] < > ' - . $ / + * , ; ! ?` — without Shift or Alt.
- With **AltGr** the same special characters and all digits are available on the left
  side (digits are duplicated on the number pad anyway; the most common `0` and `1`
  sit on the most comfortable positions).
- With **AltGr** the right-hand home position becomes a navigation cluster:
  `← ↓ →`, `Home`, `End`, `PgUp`, `PgDn`, `Del`, `Backspace`, `Enter`.
- **Caps Lock becomes a second AltGr** key (Caps Lock itself is moved onto Scroll Lock
  resp. to level 3 of the Caps key), so one-hand writing works without leaving home row.
- `A S D`, `B`, `Z`, `X`, `C`, `V`, `W`, `-`, `,`, `.` and `@` keep (nearly) their QWERT
  positions: common Ctrl-shortcuts keep working and re-learning is faster.
- Dead keys for accents: `` ` `` `´` `^` `¨` `~` `¸` `ˇ` `˘` `˚` produce letters like
  `ä ö ü é ç ñ`.
- Common digraphs (`TH`, `EN`, `ER`, `OF`, `WH`, `CH`) are placed so they can be typed
  without moving the same finger twice.

Letter layer (German hardware positions, unshifted):

```
 q  p f m u k y   $ / + * ¨ !
   w i r h l z    ( ) = [ > <
    a s d o c g   e n t i ] '
 <   v t n e b j   " , . -
```

## Installation on Linux

The layout is defined as a variant `coffeeplusplus` of the German `de` keymap.

### 1. Proper installation (recommended) — like Colemak/Dvorak/Neo

```sh
pkexec bash dev/install-coffeeplusplus-xkb.sh
```

This installs Coffee++ **the same way xkb-data ships its own variants**, so it
shows up in *Settings → Keyboard → Input Sources → German → "Deutsch (Coffee++)"*
next to the other layouts, and it **survives package upgrades**:

- appends `xkb_symbols "coffeeplusplus"` to `/usr/share/X11/xkb/symbols/de`
- registers `<variant>` `coffeeplusplus` in `/usr/share/X11/xkb/rules/evdev.xml`
  (inside the `<variantList>` of the German layout) and adds the matching
  line to `rules/evdev.lst` — both files drive the layout lists of
  GNOME/KDE/other tools
- installs `/usr/local/sbin/coffeeplusplus-xkb-apply`, an idempotent worker
  that re-injects the two patches, triggered by
  - an apt hook (`/etc/apt/apt.conf.d/99coffeeplusplus-xkb`,
    `DPkg::Post-Invoke`) — covers apt/apt-get/aptitude/unattended-upgrades, and
  - a `systemd.path` unit watching `symbols/de` and `rules/evdev.xml` —
    also covers plain `dpkg -i` or manual edits
- works on X11 (xkbcomp path) and Wayland (libxkbcommon path) alike

After installation, pick the variant in the keyboard settings, or activate the
current session directly:

```sh
setxkbmap -model pc105 -layout de -variant coffeeplusplus
```

The top-bar (HUD) input-source switcher only lists **added** input sources.
To add Coffee++ from the terminal instead of the Settings dialog (as normal
user, not root):

```sh
gsettings set org.gnome.desktop.input-sources sources "[('xkb','de'),('xkb','de+coffeeplusplus')]"
```

If the new source still does not appear in the HUD switcher afterwards: the
running GNOME Shell caches the layout registry from session start (variants
that shipped with xkb-data, like Dvorak, resolve fine — newly registered ones
do not). On X11 reload the shell **without logging out** — either press
`Alt+F2`, type `r`, hit Enter, or from a terminal:

```sh
killall -3 gnome-shell
```

(`Meta.restart` via D-Bus `Eval` is disabled by default on Ubuntu ≥ 22.04;
on Wayland a re-login is the only option since the shell is the compositor.)

Everything is removed again with `pkexec bash dev/install-coffeeplusplus-xkb.sh --uninstall`.

The symbols block below already maps the Caps key to `ISO_Level3_Shift`
(second AltGr, Caps Lock still reachable on level 3) — no extra remapping needed.
It matches the 2007-era block shipped in the `.deb` below, except that four
keysym names that are invalid in modern xkb (`eurosign`,
`guillemotsingleleft`, `guillemotsingleright`, `rightdblarrow`) were replaced
by their Unicode keysyms `EuroSign`, `U2039`, `U203A`, `U21D2` — otherwise
those key positions would be dead.

### 2. Quick test with xmodmap (X11 only)

```sh
xmodmap .xmodmap-Coffee++      # activate
xmodmap .xmodmap-QWERT         # back to normal
```

`xmodmap` is in the `x11-xserver-utils` package on Debian/Ubuntu.
Put the activate command into your session autostart to make it permanent.
Note: xmodmap does not work under Wayland, and some desktop environments
reset it when the keyboard configuration changes — use method 1 instead.

### 3. Manual XKB install (what the installer automates)

Append the `xkb_symbols "coffeeplusplus"` block (see below) to

```
/usr/share/X11/xkb/symbols/de
```

then register the variant in `/usr/share/X11/xkb/rules/evdev.xml` inside the
`<variantList>` of the German layout:

```xml
<variant>
  <configItem>
    <name>coffeeplusplus</name>
    <description>Deutsch (Coffee++)</description>
  </configItem>
</variant>
```

and add the line `  coffeeplusplus         de: Deutsch (Coffee++)` to the `! variant`
section of `rules/evdev.lst`. Keep in mind that `xkb-data` updates overwrite
these files — either re-apply manually or use the installer (method 1), which
does this automatically.

On Wayland compositors without a keyboard GUI, set the variant directly, e.g.
Sway: `input * xkb_variant coffeeplusplus` (with `xkb_layout de`), GNOME:
`gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'de+coffeeplusplus')]"`.

<details>
<summary>xkb_symbols "coffeeplusplus" — click to expand</summary>

```
// <German COFFEE++>
// adopted 2007 by Ruben Barkow <entikey@spacetrace.org>
// inspired by Dvorak, de-ergo, Colemak and Neo

// these lines must be added at the end of the file
// /usr/share/X11/xkb/symbols/de

partial alphanumeric_keys modifier_keys
xkb_symbols "coffeeplusplus" {

    include "de"
    name[Group1]= "German (Coffee++)";

    key <TLDE> { [      q, Q,                   7, asciicircum                  ] };
    key <AE01> { [      p, P,                   8, exclam                       ] };
    key <AE02> { [      f, F,                   9, quotedbl                     ] };
    key <AE03> { [      m, M,                   0, backslash                    ] };
    key <AE04> { [      u, U,                   1, percent                      ] };
    key <AE05> { [      k, K,                   2, onehalf                      ] };
    key <AE06> { [      y, Y,                   3, threesuperior                ] };
    key <AE07> { [      dollar, asciitilde,     4, onequarter                   ] };
    key <AE08> { [      slash, EuroSign,        EuroSign, onethird              ] };
    key <AE09> { [      plus, ampersand,        plusminus, dead_caron           ] };
    key <AE10> { [      asterisk, section,      currency, multiply              ] };
    key <AE11> { [      dead_diaeresis, ssharp, sterling, guillemotleft         ] };
    key <AE12> { [      exclam, exclamdown,     dead_acute, guillemotright      ] };

    key <AD01> { [      w, W,                   at, apostrophe                  ] };
    key <AD02> { [      i, I,                   bracketleft, plus               ] };
    key <AD03> { [      r, R,                   bracketright, asterisk          ] };
    key <AD04> { [      h, H,                   parenleft, numbersign           ] };
    key <AD05> { [      l, L,                   parenright, EuroSign            ] };
    key <AD06> { [      z, Z,                   5, twothirds                    ] };
    key <AD07> { [      parenleft, braceleft,   dead_cedilla, cent              ] };
    key <AD08> { [      parenright, braceright, Up, R                           ] };
    key <AD09> { [      equal, percent,         Prior, percent                  ] };
    key <AD10> { [      bracketleft, bar,       Delete, brokenbar               ] };
    key <AD11> { [      greater, dead_grave,    copyright, U203A                ] };
    key <AD12> { [      less, dead_circumflex,  dead_tilde, U2039               ] };

    key <AC01> { [      a, A,                   question, ssharp                ] };
    key <AC02> { [      s, S,                   period, ampersand               ] };
    key <AC03> { [      d, D,                   Return, colon                   ] };
    key <AC04> { [      o, O,                   BackSpace, dead_diaeresis       ] };
    key <AC05> { [      c, C,                   semicolon, dead_acute           ] };
    key <AC06> { [      g, G,                   6, trademark                    ] };
    key <AC07> { [      e, E,                   Left, ae                        ] };
    key <AC08> { [      n, N,                   Down,   registered              ] };
    key <AC09> { [      t, T,                   Right,  rightarrow              ] };
    key <AC10> { [      i, I,                   oslash, Oslash                  ] };
    key <AC11> { [      bracketright, question, questiondown, U21D2             ] };
    key <BKSL> { [      apostrophe, numbersign, dead_abovering,  dead_grave     ] };

    key <LSGT> { [      x, X,                   bar, comma                      ] };
    key <AB01> { [      v, V,                   greater, less                   ] };
    key <AB02> { [      t, T,                   equal, dead_acute               ] };
    key <AB03> { [      n, N,                   underscore, dead_tilde          ] };
    key <AB04> { [      e, E,                   minus, twosuperior              ] };
    key <AB05> { [      b, B,                   braceleft, infinity             ] };
    key <AB06> { [      j, J,                   braceright, yen                 ] };
    key <AB07> { [      quotedbl, backslash,    Home, mu                        ] };
    key <AB08> { [      comma,  semicolon,      End, minus                      ] };
    key <AB09> { [      period, colon,          Next, periodcentered            ] };
    key <AB10> { [      minus, underscore,      minus, underscore               ] };

    key <SPCE> { [    space,   space, nobreakspace, nobreakspace ] };

    key  <KP7> {   [  KP_Home,   KP_7, seveneighths, oneeighth   ]   };
    key  <KP8> {   [  KP_Up,   KP_8, uparrow, fiveeighths   ]   };
    key  <KP9> {   [  KP_Prior,   KP_9, threeeighths, threeeighths ]   };
    key  <KP4> {   [  KP_Left,   KP_4, leftarrow, onequarter      ]   };
    key  <KP5> {   [  KP_Begin,   KP_5, dagger, onehalf          ]   };
    key  <KP6> {   [  KP_Right,   KP_6, rightarrow, threequarters   ]   };
    key  <KP1> {   [  KP_End,   KP_1, onesuperior, onesuperior      ]   };
    key  <KP2> {   [  KP_Down,   KP_2, downarrow, twosuperior      ]   };
    key  <KP3> {   [  KP_Next,   KP_3, threesuperior, threesuperior   ]   };
    key <KPEN> {   [     KP_Enter   ]   };
    key <KPEQ> {   [     KP_Equal   ]   };
    key  <KP0> {   [  KP_Insert,   KP_0, percent, degree         ]   };
    key <KPDL> {     [  KP_Delete,   KP_Decimal, periodcentered, comma  ]   };
    // End "Keypad" section

    include "level3(ralt_switch)"

    // Modifier section
    key <CAPS> { [ ISO_Level3_Shift, ISO_Level3_Shift,  Caps_Lock ] };

    key  <TAB> { [ Tab, ISO_Left_Tab, KP_Delete, slash ] };

};
// </German COFFEE++>
```

</details>

### 4. Debian package (historic)

`download/coffeeplusplus-1.0_i386.deb` (architecture-independent despite the name) appends
the symbols block above and installs small switcher scripts into `/usr/local/bin/`:

```sh
entikey.bs    # setxkbmap -model pc105 -layout de -variant coffeeplusplus
qwertz.bs     # setxkbmap -model pc105 -layout de -variant basic
```

Install with `sudo dpkg -i download/coffeeplusplus-1.0_i386.deb`.
The package dates from 2007 — prefer method 1 on current systems.

### Caps Lock as a second AltGr (without the full layout)

To get only the second AltGr on an otherwise standard layout, put into `~/.Xmodmap`:

```
remove Lock = Caps_Lock
keysym Caps_Lock = ISO_Level3_Shift
```

and load it with `xmodmap ~/.Xmodmap`, or use the modern equivalent
`setxkbmap -option lv3:caps_switch` (Wayland: set the same `lv3:caps_switch`
option in the compositor/desktop keyboard settings).

## Windows and macOS

- **Windows:** `Portable_Coffee++V21.zip` (Portable Keyboard Layout, thanks to
  Máté Farkas) — run `pkl.exe`, add to autostart for permanent use. The source
  `.klc` files (`Coffee++_v14.klc`, `Coffee++_v15.klc`) can be edited with the
  *MS Keyboard Layout Creator*. `CapsLock2AltGr_ScrollLock2CapsLock.ktw` and
  `CapsLock2BackspaceScrollLock2CapsLock.ktw` are KeyTweak files to remap
  Caps Lock to a second AltGr or to Backspace.
- **macOS:** a Ukulele-generated `Coffee++.keylayout` lives in the companion
  repository [rubo77/Coffee-plus-plus](https://github.com/rubo77/Coffee-plus-plus) —
  copy it to `~/Library/Keyboard Layouts/` and add it in the keyboard settings.

## Files in this repository

| File / dir | Purpose |
|---|---|
| `.xmodmap-Coffee++` | xmodmap map (activate) |
| `.xmodmap-QWERT` | xmodmap map to switch back |
| `Coffee++_v14.klc`, `Coffee++_v15.klc` | MS Keyboard Layout Creator sources |
| `klc2xmodmap/` | PHP tool converting `.klc` files to xmodmap (generated the `.xmodmap-*` files) |
| `dev/install-coffeeplusplus-xkb.sh` | installs the `coffeeplusplus` variant properly (symbols + evdev registry + upgrade-proof re-apply), see [Installation on Linux](#installation-on-linux) |
| `dev/deploy.sh` | rsyncs the site to the live docroot (`dev/.env`; `-n` = dry-run, never `--delete`) |
| `dev/run.sh` | starts the local docker mirror (website+forum :8624, mariadb :3395) via `dev/docker-compose.yml` |
| `download/coffeeplusplus-1.0_i386.deb` | historic Debian package (XKB symbols + switcher scripts) |
| `Anleitung-Linux-Kubuntu.doc` | original German Ubuntu/XKB install instructions (2007) |
| `Linux beta9/README_Linux.txt` | original xmodmap install instructions |
| `Coffee++_keyboard_layout.gif/.pdf/.xcf/.sla` | layout images (print + sources) |
| `course.txt`, `lessons/`, `lesson.coffeeplusplus.txt` | typing-tutor course material |
| `v8.5_README.txt` / `v8.5_README_de.txt` | original beta readme (EN/DE) |
| `beta_versions/` | older remapper versions |

All files were renamed from their historical `ENTI-key++*`/`Enti-key*`/`entikey*`
names to `Coffee++*`; the old names are kept as symlinks so external links
still resolve.

## Learning to type

- Tips for learning: <http://colemak.com/Learn#Tips_for_learning>
- Practise on <https://10-fast-fingers.com/>
- Or feed `course.txt` into your favourite typing tutor. Print the layout first —
  the finger animations of generic courses won't match Coffee++.

## Contact

Questions and suggestions: Ruben Barkow — enticode-AT-spacetrace.org
