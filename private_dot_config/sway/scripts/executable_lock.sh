#!/bin/bash

# Colors come from the theme (swaylock.conf, generated); only structure lives here.
exec swaylock \
    --config "$HOME/.config/theme/current/swaylock.conf" \
    --screenshots \
    --clock \
    --indicator \
    --indicator-radius 140 \
    --indicator-thickness 8 \
    --effect-blur 12x6 \
    --effect-vignette 0.5:0.8 \
    --effect-scale 0.5 \
    --fade-in 0.3 \
    --grace 2 \
    --grace-no-mouse \
    --font-size 28 \
    --datestr "%A, %d de %B" \
    --timestr "%H:%M" \
    --indicator-caps-lock \
    --indicator-idle-visible
