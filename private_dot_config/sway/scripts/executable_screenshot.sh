#!/bin/bash

# Screenshot: full | selection
# Grabs the screen (or a dragged area) and shows a preview: Space keeps it (saved and copied),
# P opens it in swappy to annotate first, Esc discards it.

DIR=~/Pictures/Screenshots
mkdir -p "$DIR"

TMP="$(mktemp "${XDG_RUNTIME_DIR:-/tmp}/screenshot-XXXXXX.png")"

# A fullscreen window the preview is shown over (see below), put back on exit
FS=
restore_fullscreen() {
    [ -n "$FS" ] || return 0
    swaymsg "[con_id=${FS% *}] fullscreen enable$([ "${FS#* }" = 2 ] && echo ' global')" >/dev/null
}
trap 'rm -f "$TMP"; restore_fullscreen' EXIT

case $1 in
    full)
        NAME=full
        TITLE="📷 Capturado"
        MSG="Otro instante guardado."
        grim "$TMP"
        ;;
    selection)
        NAME=area
        TITLE="📷 Recorte"
        MSG="Un fragmento, guardado."
        # cancelling slurp (Esc) must not leave a file or notify
        geometry="$(slurp)" || exit 0
        grim -g "$geometry" "$TMP"
        ;;
    *)
        exit 1
        ;;
esac

FILE="$DIR/${NAME}_$(date +'%Y-%m-%d_%H-%M-%S').png"

# A fullscreen window hides floating ones and keeps the keyboard focus: the preview would be invisible
# and Space/Esc would go to the app. Leave fullscreen while it is open (the capture is already taken).
FS="$(swaymsg -t get_tree | python3 -c '
import json, sys
def focused(n):
    if n.get("focused"):
        return n
    for c in n.get("nodes", []) + n.get("floating_nodes", []):
        if f := focused(c):
            return f
n = focused(json.load(sys.stdin))
if n and n.get("fullscreen_mode"):
    print(n["id"], n["fullscreen_mode"])')"
[ -n "$FS" ] && swaymsg "[con_id=${FS% *}] fullscreen disable" >/dev/null

# Preview window: floating (rules.conf), sized to the capture (at most 60% of the screen) plus a margin
# all around (the hint line sits in the bottom one), centered. It reports the choice through its exit code (see swayimg/screenshot.lua).
read -r PW PH PX PY < <(swaymsg -t get_outputs -r | python3 -c '
import json, sys
from PIL import Image
o = next(o for o in json.load(sys.stdin) if o["focused"])["rect"]
iw, ih = Image.open(sys.argv[1]).size
M, MINW = 44, 560  # margin around the image (hint line lives in the bottom one); narrowest window that fits the hint
s = min(1, (o["width"] * 6 // 10 - 2 * M) / iw, (o["height"] * 6 // 10 - 2 * M) / ih)
w, h = max(MINW, round(iw * s) + 2 * M), round(ih * s) + 2 * M
print(w, h, (o["width"] - w) // 2, (o["height"] - h) // 2)' "$TMP")
swayimg --appid screenshot-preview --config ~/.config/swayimg/screenshot.lua \
    --size "$PW,$PH" --position "$PX,$PY" "$TMP"
case $? in
    10)
        cp "$TMP" "$FILE"
        ;;
    11)
        cp "$TMP" "$FILE"
        swappy -f "$FILE" -o "$FILE"
        ;;
    *)
        exit 0
        ;;
esac

wl-copy -t image/png < "$FILE"
notify-send -a "System" -i "$FILE" "$TITLE" "$MSG"
