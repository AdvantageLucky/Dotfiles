if status is-login
  if test (tty) = /dev/tty1
    test -f ~/.config/fish/sway.log; and mv ~/.config/fish/sway.log ~/.config/fish/sway.log.old
    exec sway -V > ~/.config/fish/sway.log 2>&1
  end
end

# greetings
set -g fish_greeting

# alias 
alias ls 'exa -l --git --icons --group-directories-first'
alias info 'pinfo'

# abbreviatures
abbr s 'nnn'
abbr q 'exit'
abbr n 'nvim'
abbr c 'clear'
abbr cdd 'cd ..'
abbr u 'sudo pacman -Syu'
abbr nvimconfig 'cd ~/.config/nvim'
abbr swayconfig 'cd ~/.config/sway'
abbr waybarconfig 'cd ~/.config/waybar/'
abbr fuzzelconfig 'cd ~/.config/fuzzel/'
abbr makoconfig 'nvim ~/.config/mako/config'
abbr fishconfig 'nvim ~/.config/fish/config.fish'
abbr kittyconfig 'nvim ~/.config/kitty/kitty.conf'

# @Plugins
set -g fish_autosuggestion_strategy history
set -g fzf_complete 1
set -g fzf_preview_dir_cmd 'ls -la'

# @Variables
set -gx EDITOR nvim
set -gx TERMINAL kitty

# man pages con colores (bat como pager)
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx MANROFFOPT "-c"

set -gx VIRTUAL_ENV_DISABLE_PROMPT 1

# WAYLAND & SWAY VARIABLES
set -gx XDG_CURRENT_DESKTOP sway
set -gx XDG_SESSION_DESKTOP sway
set -gx XDG_SESSION_TYPE wayland
set -gx GDK_BACKEND wayland,x11
set -gx CLUTTER_BACKEND wayland
set -gx MOZ_ENABLE_WAYLAND 1
set -gx LIBVA_DRIVER_NAME iHD
set -gx GST_VAAPI_ALL_DRIVERS 1
set -gx NODE_OPTIONS "--no-warnings"
set -gx PREFER_LOW_POWER 1
set -gx QT_QPA_PLATFORM "wayland;xcb"
set -gx _JAVA_AWT_WM_NONREPARENTING 1
set -gx GRIM_DISABLE_DMABUF 1
set -gx SDL_VIDEODRIVER wayland

# ssh
set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"

# Flutter
set -gx PATH "$HOME/flutter/bin" $PATH

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
