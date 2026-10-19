#!/bin/bash
# scratchpad.sh <app-id> [command...]
# this emulates sway's `scratchpad show` for one floating app.
#   not running          -> launch it (windows/rules.kdl makes it floating)
#   focused              -> hide it on the last (empty) workspace
#   elsewhere / hidden   -> bring it to the current workspace and focus it

APP="$1"
shift
CMD=("${@:-$APP}")

id=$(niri msg -j windows | jq -r --arg app "$APP" '[.[] | select(.app_id == $app)][0].id // empty')
if [ -z "$id" ]; then
    exec niri msg action spawn -- "${CMD[@]}"
fi

focused=$(niri msg -j focused-window | jq -r '.id // empty')
if [ "$id" = "$focused" ]; then
    # an index past the end lands on the trailing empty workspace
    niri msg action move-window-to-workspace --window-id "$id" --focus false 255
else
    current=$(niri msg -j workspaces | jq -r '.[] | select(.is_focused) | .idx')
    niri msg action move-window-to-workspace --window-id "$id" --focus false "$current"
    niri msg action focus-window --id "$id"
fi
