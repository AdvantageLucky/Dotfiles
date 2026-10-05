#!/bin/bash

run_once() {
    pgrep -x "$(basename "$1")" >/dev/null || "$@" &
}

# Environment
systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP

# Idle: lock at 3 min, screen off at 5, lock on suspend
LOCK_SCRIPT="$HOME/.config/sway/scripts/lock.sh"
if ! pgrep -x swayidle >/dev/null; then
    swayidle -w \
        timeout 180 "$LOCK_SCRIPT" \
        timeout 300 'swaymsg "output * dpms off"' \
        resume 'swaymsg "output * dpms on"' \
        before-sleep "$LOCK_SCRIPT" \
        after-resume 'swaymsg "output * dpms on"' &
fi

# Daemons
run_once mako # mako notifications daemon
run_once autotiling-rs # autotiling 
run_once wlsunset -l 19.4 -L -99.1 # cdmx latitude

# Clipboard history
run_once wl-paste --type text --watch cliphist store # text watchdog
run_once wl-paste --type image --watch cliphist store # imgs watchdog
pgrep -f polkit-mate-authentication-agent-1 >/dev/null || \
    /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 &

# GTK theme (color-scheme is owned by the `theme` command: day/night)
gsettings set org.gnome.desktop.interface gtk-theme 'Colloid-Orange-Dark-Gruvbox'

# micmute LED
if [[ "$(pamixer --default-source --get-mute)" == "true" ]]; then
    brightnessctl -d "platform::micmute" set 0
else
    brightnessctl -d "platform::micmute" set 1
fi
