#!/bin/bash
# Control hub: one rofi entry point for the things that used to be separate shortcuts and bar
# clicks (clipboard, Wi-Fi, Bluetooth, audio output, theme, screenshot, lock / session)
# Every menu is a plain rofi dmenu with the launcher theme

ROFI_DIR="$HOME/.config/rofi"
SWAY_SCRIPTS="$HOME/.config/sway/scripts"

# menu <prompt> <entry>...: prints the index of the picked entry, nothing on Esc
menu() {
    local prompt="$1"
    shift
    printf '%s\n' "$@" | rofi -dmenu -i -no-custom -format i -p "$prompt" -theme "$ROFI_DIR/theme.rasi"
}

notify() { notify-send -a System "$1" "$2"; }

# nmcli translates its output (radio wifi prints "activado" here)
nm() { LC_ALL=C nmcli "$@"; }

# -- Wi-Fi ---------------------------------------------------------------------------------
wifi_menu() {
    local state ssids=() labels=() line in_use ssid signal sec out
    state=$(nm radio wifi)
    if [[ "$state" != enabled ]]; then
        [[ $(menu "Wi-Fi" "Wi-Fi apagado: encender") == 0 ]] && nm radio wifi on
        return
    fi

    # A scan takes ~5 s and `--rescan auto` blocks on it when the cache is stale, so the menu
    # appeared late. Show the cached list at once and refresh it in the background for next time.
    nm device wifi rescan >/dev/null 2>&1 &

    # IN-USE:SSID:SIGNAL:SECURITY. The SSID may contain ':', so read the fixed fields from the
    # ends. Strongest first; each SSID only once.
    declare -A seen
    while IFS= read -r line; do
        in_use="${line%%:*}"
        sec="${line##*:}"
        line="${line%:*}"
        signal="${line##*:}"
        ssid="${line#*:}"
        ssid="${ssid%:*}"
        [[ -z "$ssid" || -n "${seen[$ssid]:-}" ]] && continue
        seen[$ssid]=1
        ssids+=("$ssid")
        labels+=("$ssid  ${signal}%${sec:+  $sec}$([[ "$in_use" == '*' ]] && echo '  (conectada)')")
    done < <(nm -t --escape no -f IN-USE,SSID,SIGNAL,SECURITY dev wifi list --rescan no)

    local pick
    pick=$(menu "Wi-Fi" "${labels[@]}" "Apagar Wi-Fi")
    [[ -z "$pick" ]] && return
    if ((pick == ${#ssids[@]})); then
        nm radio wifi off
        return
    fi

    ssid="${ssids[$pick]}"
    # a saved connection reuses its secret; otherwise ask once for the password
    if nm -g NAME connection show | grep -qxF "$ssid"; then
        if out=$(nm connection up id "$ssid" 2>&1); then
            notify "Wi-Fi" "Conectado a $ssid"
        else
            notify "Wi-Fi" "No se pudo conectar a $ssid: ${out##*Error: }"
        fi
    else
        local pass=""
        if [[ "${labels[$pick]}" == *WPA* || "${labels[$pick]}" == *WEP* ]]; then
            pass=$(rofi -dmenu -password -p "Contraseña" -theme "$ROFI_DIR/theme.rasi" </dev/null) || return
        fi
        if out=$(nm device wifi connect "$ssid" ${pass:+password "$pass"} 2>&1); then
            notify "Wi-Fi" "Conectado a $ssid"
        else
            notify "Wi-Fi" "No se pudo conectar a $ssid: ${out##*Error: }"
        fi
    fi
}

# -- Bluetooth -----------------------------------------------------------------------------
bluetooth_menu() {
    if ! bluetoothctl show | grep -q "Powered: yes"; then
        [[ $(menu "Bluetooth" "Bluetooth apagado: encender") == 0 ]] && bluetoothctl power on >/dev/null
        return
    fi

    local macs=() labels=() mac name
    while read -r _ mac name; do
        macs+=("$mac")
        if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
            labels+=("$name  (conectado)")
        else
            labels+=("$name")
        fi
    done < <(bluetoothctl devices Paired)

    local pick
    pick=$(menu "Bluetooth" "${labels[@]}" "Apagar Bluetooth")
    [[ -z "$pick" ]] && return
    if ((pick == ${#macs[@]})); then
        bluetoothctl power off >/dev/null
        return
    fi

    mac="${macs[$pick]}"
    if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
        bluetoothctl disconnect "$mac" >/dev/null && notify "Bluetooth" "Desconectado: ${labels[$pick]%  (conectado)}"
    else
        bluetoothctl connect "$mac" >/dev/null && notify "Bluetooth" "Conectado: ${labels[$pick]}" || notify "Bluetooth" "No se pudo conectar: ${labels[$pick]}"
    fi
}

# -- Audio output --------------------------------------------------------------------------
audio_menu() {
    local names=() labels=() default name desc
    default=$(pactl get-default-sink)
    while IFS=$'\t' read -r name desc; do
        names+=("$name")
        labels+=("$desc$([[ "$name" == "$default" ]] && echo '  (actual)')")
    done < <(pactl --format=json list sinks | python3 -c '
import json, sys
for s in json.load(sys.stdin):
    # pactl reports "(null)" as description for some USB devices; the node property is the real name
    desc = s["description"]
    if desc == "(null)":
        desc = s["properties"].get("device.description") or s["name"]
    print(s["name"], desc, sep="\t")')

    local pick
    pick=$(menu "Salida de audio" "${labels[@]}")
    [[ -z "$pick" ]] && return
    name="${names[$pick]}"
    pactl set-default-sink "$name"
    # move streams that are already playing, otherwise they stay on the old output
    pactl list short sink-inputs | cut -f1 | while read -r id; do
        pactl move-sink-input "$id" "$name"
    done
}

# -- Theme ---------------------------------------------------------------------------------
theme_menu() {
    local current other
    current=$(basename "$(readlink -f "$HOME/.config/theme/current")")
    [[ "$current" == night ]] && other=day || other=night
    [[ "$other" == day ]] && other_label="Modo día" || other_label="Modo noche"
    [[ -n $(menu "Tema (ahora: $current)" "$other_label") ]] && theme "$other"
}

# -- Screenshot ----------------------------------------------------------------------------
shot_menu() {
    local pick
    pick=$(menu "Captura" "Área" "Pantalla completa")
    [[ -z "$pick" ]] && return
    sleep 0.4 # let rofi leave the screen before grabbing it
    ((pick == 0)) && "$SWAY_SCRIPTS/screenshot.sh" selection || "$SWAY_SCRIPTS/screenshot.sh" full
}

main=("Portapapeles" "Wi-Fi" "Bluetooth" "Salida de audio" "Tema" "Captura" "Bloquear" "Sesión")
case $(menu "Control" "${main[@]}") in
    0) exec "$SWAY_SCRIPTS/clipboard-history.sh" ;;
    1) wifi_menu ;;
    2) bluetooth_menu ;;
    3) audio_menu ;;
    4) theme_menu ;;
    5) shot_menu ;;
    6) exec "$SWAY_SCRIPTS/lock.sh" ;;
    7) exec "$SWAY_SCRIPTS/wlogout.sh" ;;
esac
