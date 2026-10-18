# Sway session: everything in the shell that only makes sense on the sway machine.
# config.fish keeps what is universal (aliases, abbreviations, editor, PATH...).

# Start sway on tty1 (log kept for debugging)
if status is-login
  if test (tty) = /dev/tty1
    test -f ~/.config/fish/sway.log; and mv ~/.config/fish/sway.log ~/.config/fish/sway.log.old
    exec sway -V > ~/.config/fish/sway.log 2>&1
  end
end

# Shortcuts to the config of the graphical stack
abbr swayconfig 'cd ~/.config/sway'
abbr roficonfig 'cd ~/.config/rofi'
abbr themeconfig 'cd ~/.config/theme'
abbr waybarconfig 'cd ~/.config/waybar'
abbr swayncconfig 'cd ~/.config/swaync'

# Wayland / sway environment
set -gx XDG_CURRENT_DESKTOP sway
set -gx XDG_SESSION_DESKTOP sway
set -gx XDG_SESSION_TYPE wayland
set -gx GDK_BACKEND wayland,x11
set -gx CLUTTER_BACKEND wayland
set -gx MOZ_ENABLE_WAYLAND 1
set -gx QT_QPA_PLATFORM "wayland;xcb"
set -gx _JAVA_AWT_WM_NONREPARENTING 1
set -gx GRIM_DISABLE_DMABUF 1
set -gx SDL_VIDEODRIVER wayland

# Intel iGPU of this laptop (video acceleration, power)
set -gx LIBVA_DRIVER_NAME iHD
set -gx GST_VAAPI_ALL_DRIVERS 1
set -gx PREFER_LOW_POWER 1
