<h1 align="center">Personal Dotfiles</h1>

<p align="center">
  Minimalist SwayFX setup - inspired by melange.nvim, gruvbox, sh3 ambient
  Noctalia-based Niri desktop setup - inspired by wallpaper colors
</p>

<p align="center">
  SwayFX setup
</p>
<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/1e1a7a08-b1a7-46b1-a23b-61dee2e9b24e" />
<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/97ecada2-d244-4652-b912-d8888746522b" />

<p align="center">
  Niri + Noctalia setup
</p>
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/886cd9e3-1324-4cb8-803f-df1255bfc27e" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d05ae848-63ad-4954-ba44-93d0bbbb7c28" />

---
# SwayFX

## Components

| Component | Program |
|-----------|---------|
| **WM** | SwayFX |
| **Bar** | Waybar |
| **Terminal** | Kitty |
| **Shell** | Fish (Eza · Zoxide · Fzf) |
| **Text Editor** | Neovim |
| **Launcher** | Rofi |
| **Browser** | Zen Browser |
| **Music** | mpd + rmpc |
| **File Manager** | Nautilus (GTK4) |
| **Notifications** | SwayNC |
| **Lock screen** | Swaylock-effects |
| **Power menu** | Wlogout |

## Theming

| Item | Value |
|------|-------|
| **Cursor** | Bibata-Modern-Amber (24px) |
| **Icons** | Adwaita (GTK built-in) |
| **GTK theme** | Colloid-gtk-theme |
| **Fonts** | GeistMono Nerd Font (mono / terminal / bar / UI) |

## Installation
Everything is managed with **chezmoi**.

1. **Install chezmoi:**
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```
2. **Apply the dotfiles:**
   ```bash
   chezmoi init --apply https://github.com/your-user/dotfiles.git
   ```
3. **Install dependencies** (runs automatically after the first `apply`, or manually):
   ```bash
   ~/.local/share/chezmoi/run_once_install-dependencies.sh
   ```

## Keybinds
`Super` = ⊞ (Windows key)

| Shortcut | Action |
|----------|--------|
| `Super + t` | Terminal (Kitty) |
| `Super + f` | Browser (Zen) |
| `Super + d` | Files (Nautilus) |
| `Super + a` | Launcher (Rofi) |
| `Super + m` | Toggle jukebox (rmpc) |
| `Super + q` | Close window |
| `Super + Shift + c` | Reload SwayFX |
| `Super + Shift + s` | Area screenshot (slurp) |
| `Print` | Full screenshot |
| `Super + Esc` | Lock screen (Swaylock) |
| `Super + Shift + e` / `PowerButton` | Power menu (Wlogout) |
| `Super + c`| Cliphist (Rofi + Cliphist)|
---

# Component list in detail
## Core
* **Drivers:** intel-ucode, mesa, vulkan-intel, intel-media-driver
* **Power:** tlp
* **Audio:** Pipewire, Wireplumber, Pavucontrol
* **Music:** mpd (`mpd.socket`), mpdscribble (scrobbler), rmpc (TUI client)
* **Network:** NetworkManager, Bluetooth (bluez)
* **WM:** SwayFX, Waybar, SwayNC, Rofi, Swaybg, Swayidle, Autotiling-RS
* **Theming:** bibata-cursor-theme (cursor), Adwaita (icons, built-in), Colloid-gtk-theme (gtk theme)
* **Utilities:** Grim, Slurp, Swappy, Brightnessctl, Btop, Fzf, FD, Bat, Ripgrep, Eza, Zoxide, Wget, Unzip, Zip, P7zip, Fortune-mod
* **Apps:** Nautilus, Cliphist, Neovim, Swayimg, Mpv, Zathura, Kitty, Fish

## Fonts
* GeistMono Nerd Font (mono — main UI / terminal / bar)
* ttf-liberation
* noto-fonts, noto-fonts-cjk, noto-fonts-emoji
* ttf-nerd-fonts-symbols-mono

## AUR
* zen-browser-bin (browser)
* swaylock-effects (lock screen)
* swayfx (WM)
* bibata-cursor-theme (cursor)
* wlogout (power menu)
* otf-geist-mono-nerd (main font)
* obsidian (notes)

## Runtimes / Languages
* Python & Pip
* Clang (C/C++)
* Rust & Cargo
* Lua & Luarocks
* Go
* Node.js & NPM
* Java (JDK)
