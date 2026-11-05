#!/bin/bash
# Install the Coffee++ keyboard layout as a proper XKB variant
# of the German "de" layout on Ubuntu (X11 and Wayland), the same way
# xkb-data ships Colemak/Dvorak/Neo — including a re-apply mechanism so it
# survives xkb-data package upgrades.
#
# What it does (needs root, run via: pkexec bash dev/install-coffeeplusplus-xkb.sh):
#   1. appends xkb_symbols "coffeeplusplus" to /usr/share/X11/xkb/symbols/de
#   2. registers <variant> "coffeeplusplus" in /usr/share/X11/xkb/rules/evdev.xml
#      and adds a line to rules/evdev.lst  -> shows up in GNOME Settings as
#      "Deutsch (Coffee++)" like any other layout variant
#   3. installs /usr/local/sbin/coffeeplusplus-xkb-apply (idempotent
#      re-apply worker), an apt DPkg::Post-Invoke hook and a systemd.path
#      unit that re-inject 1+2 whenever xkb-data overwrites its files
#
# Options:
#   -h, --help      show this help and exit
#   --uninstall     remove the variant, hooks, units and worker again
#
# After installation pick the layout in
#   Settings -> Keyboard -> Input Sources -> + -> German -> Deutsch (Coffee++)
# or activate the current session directly with:
#   setxkbmap -model pc105 -layout de -variant coffeeplusplus

set -e

cd "$(dirname "$0")" && cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

WORKER=/usr/local/sbin/coffeeplusplus-xkb-apply
APT_HOOK=/etc/apt/apt.conf.d/99coffeeplusplus-xkb
PATH_UNIT=/etc/systemd/system/coffeeplusplus-xkb.path
SERVICE_UNIT=/etc/systemd/system/coffeeplusplus-xkb.service

show_help() {
    sed -n '2,26p' "$0"
    exit 0
}

MODE=install
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)    show_help ;;
        --uninstall)  MODE=uninstall ;;
        *) echo "Unknown option: $1" >&2; show_help ;;
    esac
    shift
done

if [ "$EUID" -ne 0 ]; then
    echo "Root required. Re-run with:" >&2
    echo "  pkexec bash $0 $*" >&2
    exit 1
fi

if [ "$MODE" = uninstall ]; then
    echo "Removing Coffee++ XKB integration..."
    systemctl disable --now coffeeplusplus-xkb.path 2>/dev/null || true
    rm -f "$PATH_UNIT" "$SERVICE_UNIT" "$APT_HOOK"
    if [ -x "$WORKER" ]; then "$WORKER" --uninstall; fi
    rm -f "$WORKER"
    systemctl daemon-reload
    echo "Done. The layout is removed from the XKB files."
    echo "(Restart GNOME Settings - gnome-control-center - to refresh the list.)"
    exit 0
fi

# ---------------------------------------------------------------- worker
echo "Installing re-apply worker to $WORKER ..."
cat > "$WORKER" <<'WORKER_EOF'
#!/bin/bash
# Idempotent re-apply of the Coffee++ XKB variant.
# Runs after apt/dpkg operations (DPkg::Post-Invoke hook) and whenever
# systemd.path reports a change on the patched xkb-data files.
set -e

SYMBOLS=/usr/share/X11/xkb/symbols/de
RULES_XML=/usr/share/X11/xkb/rules/evdev.xml
RULES_LST=/usr/share/X11/xkb/rules/evdev.lst
TAG=coffeeplusplus-xkb

log() { echo "[$TAG] $*" >&2; logger -t "$TAG" -- "$*"; }

if [ "$1" = "--uninstall" ]; then
    # removes any block this installer may have registered, under either
    # of the two variant names entikey and coffeeplusplus
    sed -i '/\/\/ <German ENTIKEY++>/,/\/\/ <\/German ENTIKEY++>/d' "$SYMBOLS" 2>/dev/null || true
    sed -i '/\/\/ <German COFFEE++>/,/\/\/ <\/German COFFEE++>/d' "$SYMBOLS" 2>/dev/null || true
    awk 'BEGIN{buf=""; inv=0}
         /<variant>/{buf=$0 ORS; inv=1; next}
         inv{buf=buf $0 ORS}
         inv && /<\/variant>/{ if (buf !~ /<name>(entikey|coffeeplusplus)<\/name>/) printf "%s", buf; buf=""; inv=0; next}
         !inv{print}' "$RULES_XML" > "$RULES_XML.tmp" && mv "$RULES_XML.tmp" "$RULES_XML" || true
    sed -i '/^  \(entikey\|coffeeplusplus\)  \+de: /d' "$RULES_LST" 2>/dev/null || true
    log "Coffee++ variant removed from xkb files"
    exit 0
fi

# 1) symbols block ---------------------------------------------------------
if [ -f "$SYMBOLS" ] && ! grep -q 'xkb_symbols "coffeeplusplus"' "$SYMBOLS"; then
    cat >> "$SYMBOLS" <<'SYMBOLS_EOF'

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
SYMBOLS_EOF
    log "appended xkb_symbols \"coffeeplusplus\" to $SYMBOLS"
fi

# 2) evdev.xml variant registration ---------------------------------------
if [ -f "$RULES_XML" ] && ! grep -q '<name>coffeeplusplus</name>' "$RULES_XML"; then
    de_line=$(grep -n '<name>de</name>' "$RULES_XML" | head -1 | cut -d: -f1)
    if [ -n "$de_line" ]; then
        vlist=$(awk -v s="$de_line" 'NR>s && /<variantList/{print NR; exit}' "$RULES_XML")
        if [ -n "$vlist" ]; then
            if awk -v s="$vlist" 'NR==s && /<variantList\/>/{found=1} END{exit !found}' "$RULES_XML"; then
                # empty <variantList/> -> expand it
                sed -i "${vlist}s|<variantList/>|<variantList>\n        <variant>\n          <configItem>\n            <name>coffeeplusplus</name>\n            <description>Deutsch (Coffee++)</description>\n          </configItem>\n        </variant>\n      </variantList>|" "$RULES_XML"
            else
                sed -i "${vlist}a\\        <variant>\n          <configItem>\n            <name>coffeeplusplus</name>\n            <description>Deutsch (Coffee++)</description>\n          </configItem>\n        </variant>" "$RULES_XML"
            fi
            log "registered variant coffeeplusplus in $RULES_XML"
        else
            log "WARNING: no variantList found for de layout in $RULES_XML"
        fi
    else
        log "WARNING: de layout not found in $RULES_XML"
    fi
fi

# 3) evdev.lst entry --------------------------------------------------------
if [ -f "$RULES_LST" ] && ! grep -q '^  coffeeplusplus  *de: ' "$RULES_LST"; then
    last_de=$(grep -n '^  [a-zA-Z0-9_]*  *de: ' "$RULES_LST" | tail -1 | cut -d: -f1)
    if [ -n "$last_de" ]; then
        sed -i "${last_de}a\\  coffeeplusplus         de: Deutsch (Coffee++)" "$RULES_LST"
        log "added coffeeplusplus line to $RULES_LST"
    fi
fi
WORKER_EOF
chmod 755 "$WORKER"

# ---------------------------------------------------------------- apt hook
echo "Installing apt re-apply hook to $APT_HOOK ..."
cat > "$APT_HOOK" <<'HOOK_EOF'
// Re-apply the Coffee++ XKB variant after package upgrades
// in case xkb-data overwrote its patched files.
DPkg::Post-Invoke {"/usr/local/sbin/coffeeplusplus-xkb-apply || true";};
HOOK_EOF

# ---------------------------------------------------------------- systemd
echo "Installing systemd.path watcher ..."
cat > "$SERVICE_UNIT" <<'UNIT_EOF'
[Unit]
Description=Re-apply Coffee++ XKB variant after xkb-data changes

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/coffeeplusplus-xkb-apply
UNIT_EOF

cat > "$PATH_UNIT" <<'UNIT_EOF'
[Unit]
Description=Watch xkb-data files for changes (Coffee++ XKB re-apply)

[Path]
PathModified=/usr/share/X11/xkb/symbols/de
PathModified=/usr/share/X11/xkb/rules/evdev.xml
Unit=coffeeplusplus-xkb.service

[Install]
WantedBy=multi-user.target
UNIT_EOF

systemctl daemon-reload
systemctl enable --now coffeeplusplus-xkb.path

# ---------------------------------------------------------------- apply
echo "Applying Coffee++ XKB variant ..."
"$WORKER"

echo
echo "Verification: compiling de(coffeeplusplus) keymap ..."
# no X display under pkexec -> feed a complete keymap directly to xkbcomp
TESTDIR=$(mktemp -d /var/tmp/coffeeplusplus-verify-XXXXXX)
cat > "$TESTDIR/map.xkb" <<'KM_EOF'
xkb_keymap {
    xkb_keycodes  { include "evdev+aliases(qwertz)" };
    xkb_types     { include "complete"              };
    xkb_compat    { include "complete"              };
    xkb_symbols   { include "pc+de(coffeeplusplus)+inet(evdev)" };
    xkb_geometry  { include "pc(pc105)"             };
};
KM_EOF
if xkbcomp -xkb "$TESTDIR/map.xkb" "$TESTDIR/out.xkb" >/dev/null 2>&1 \
    && grep -A3 'key <AD01>' "$TESTDIR/out.xkb" | grep -q 'w,               W,'; then
    echo "OK: keymap compiles, coffeeplusplus variant is active"
else
    echo "WARNING: keymap did not compile, check /usr/share/X11/xkb/symbols/de" >&2
fi
rm -rf "$TESTDIR"

echo
echo "Done. Coffee++ is now registered as German layout variant:"
echo "  - undo everything with:"
echo "    pkexec bash $0 --uninstall"
echo "  - pick it in Settings -> Keyboard -> Input Sources -> + ->"
echo "    German -> 'Deutsch (Coffee++)'"
echo "    (restart GNOME Settings - gnome-control-center - to refresh the list)"
echo "  - the same from the terminal: persistent GNOME input source,"
echo "    shows in the Settings list and the top-bar HUD switcher:"
echo "    gsettings set org.gnome.desktop.input-sources sources \"[('xkb','de'),('xkb','de+coffeeplusplus')]\""
echo "  - or a quick session-only test without a GNOME entry: invisible"
echo "    to the HUD, can be overridden by GNOME, gone after login:"
echo "    setxkbmap -model pc105 -layout de -variant coffeeplusplus"
