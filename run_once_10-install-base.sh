#!/bin/bash
# Base profile: tools that do not depend on a compositor or a theme.
# No full system upgrade here (`pacman -Syu`): do that yourself before the first run.
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"; }

# @AUR helper (yay)
if ! command -v yay &>/dev/null; then
    print_step "Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
fi

# @Fonts (kitty, prompt and nvim icons)
print_step "Installing fonts..."
sudo pacman -S --needed --noconfirm \
    inter-font ttf-liberation \
    noto-fonts noto-fonts-cjk noto-fonts-emoji \
    ttf-nerd-fonts-symbols-mono otf-geist-mono-nerd

# @Languages and runtimes (LSP servers and tools used from nvim)
print_step "Installing runtimes and languages..."
sudo pacman -S --needed --noconfirm \
    python python-pip \
    clang \
    rust \
    lua luarocks \
    go \
    nodejs npm \
    jdk-openjdk

# @Terminal, shell and CLI tools
print_step "Installing terminal, shell and CLI tools..."
sudo pacman -S --needed --noconfirm \
    kitty fish eza fzf fd bat ripgrep zoxide btop git-delta \
    wget unzip zip 7zip fortune-mod

# @Editors
print_step "Installing editors..."
sudo pacman -S --needed --noconfirm \
    neovim vim nano tree-sitter tree-sitter-cli nnn

yay -S --needed --noconfirm pinfo timg

# @Browser
print_step "Installing Zen Browser..."
yay -S --needed --noconfirm zen-browser-bin

# @Maintenance
print_step "Enabling pacman cache cleanup and fstrim..."
sudo pacman -S --needed --noconfirm pacman-contrib
sudo systemctl enable paccache.timer
sudo systemctl enable fstrim.timer

# @Shell
print_step "Setting fish as the default shell..."
if [ "$SHELL" != "/usr/bin/fish" ]; then
    chsh -s /usr/bin/fish
fi

print_step "Base done. Log out and in again to apply the shell change."
