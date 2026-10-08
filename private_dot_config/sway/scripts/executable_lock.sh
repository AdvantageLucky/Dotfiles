#!/bin/bash

# Clean clock on a dark, blurred screen. No ring or box at rest; thin arcs appear only while
# typing. Colors come from the theme (swaylock.conf, generated: night colors in both modes,
# because the background is always darkened). Only structure lives here.
# Extra arguments are passed to swaylock (the last one wins), e.g. `lock.sh --grace 30`.
exec swaylock \
    --config "${SWAYLOCK_CONFIG:-$HOME/.config/theme/current/swaylock.conf}" \
    --screenshots \
    --effect-blur 20x6 \
    --effect-vignette 0.3:0.7 \
    --effect-scale 0.5 \
    --fade-in 0.4 \
    --grace 2 \
    --grace-no-mouse \
    --clock \
    --timestr "%H:%M" \
    --datestr "%A, %d de %B" \
    --font-size 72 \
    --indicator \
    --indicator-idle-visible \
    --indicator-caps-lock \
    --indicator-radius 170 \
    --indicator-thickness 3 \
    "$@"
