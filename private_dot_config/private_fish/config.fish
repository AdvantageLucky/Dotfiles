# greetings
set -g fish_greeting

# alias 
alias ls 'exa -l --git --icons --group-directories-first'
alias info 'pinfo'

# abbreviatures

# shortcuts
abbr s 'nnn'
abbr q 'exit'
abbr n 'nvim'
abbr c 'clear'
abbr cdd 'cd ..'
abbr u 'sudo pacman -Syu'

# configs
abbr nvimconfig 'cd ~/.config/nvim'
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
set -gx NODE_OPTIONS "--no-warnings"

# ssh
set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"

# Flutter
set -gx PATH "$HOME/dev/flutter/bin" $PATH

# Go
set -gx GOPATH "$HOME/dev/go"
fish_add_path -g $GOPATH/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

# claude-code
fish_add_path -g $HOME/.local/bin
