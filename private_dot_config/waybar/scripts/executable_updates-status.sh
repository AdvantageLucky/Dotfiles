#!/bin/bash
# custom/updates: contextual. Prints the icon only when something is pending;
# an empty text hides the module. The tooltip counts pending updates from pacman/aur.

icon=$'\U000F06B0' # nf-md-update (Nerd Font); escaped so the file stays plain ASCII

repo=$(checkupdates 2>/dev/null | wc -l)
aur=$(yay -Qua 2>/dev/null | wc -l)
total=$((repo + aur))

if ((total == 0)); then
    printf '{"text": "", "tooltip": "Actualizar sistema (yay)\\nSistema al día"}\n'
else
    printf '{"text": "%s", "tooltip": "Actualizar sistema (yay)\\n%s paquetes pendientes (%s repos, %s AUR)"}\n' "$icon" "$total" "$repo" "$aur"
fi
