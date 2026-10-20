<h1 align="center">Personal Dotfiles</h1>

<p align="center">
  Personal dotfiles for desktop and laptop devices<br>
  <b>SwayFX</b> - minimalist setup inspired by melange.nvim, gruvbox, sh3 ambient<br>
  <b>Niri + Noctalia</b> - colorscheme from wallpapers
</p>

<h1 align="center">
  SwayFX setup
</h1>
<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/1e1a7a08-b1a7-46b1-a23b-61dee2e9b24e" />
<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/97ecada2-d244-4652-b912-d8888746522b" />

<h1 align="center">
  Niri + Noctalia setup
</h1>
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/886cd9e3-1324-4cb8-803f-df1255bfc27e" />
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/d05ae848-63ad-4954-ba44-93d0bbbb7c28" />

---

# Profiles

`chezmoi init` asks once which profile the machine gets (saved in `~/.config/chezmoi/chezmoi.toml`):

| Profile | What it applies |
|---------|-----------------|
| **base** | Tools that do not depend on a compositor: fish, nvim, kitty, btop, fastfetch |
| **sway** | base + the SwayFX desktop (Waybar, Rofi, SwayNC, Wlogout, theme system, GTK) |
| **niri** | base + niri with the noctalia shell and its own plugins |

Files of the other desktop are skipped through `.chezmoiignore`, so a machine never gets both.
Kitty loads a per-profile `profile.conf` (font and colors of that rice).

## Installation

1. **Install chezmoi:**
   ```bash
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```
2. **Apply the dotfiles** (asks for the profile):
   ```bash
   chezmoi init --apply https://github.com/AdvantageLucky/Dotfiles.git
   ```
3. **Dependencies:** run automatically on the first `apply` (do a `pacman -Syu` first):
   * `run_once_10-install-base.sh` - every profile: yay, fonts, runtimes, terminal and CLI tools, editors
   * `run_once_20-install-sway.sh.tmpl` - sway profile only: SwayFX, desktop components, audio, network, apps, theme
   * niri profile: no installer yet, install the packages listed in [Niri + Noctalia](#niri--noctalia) by hand

To change the profile later: `chezmoi init --prompt` and then `chezmoi apply`.

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

## Component list in detail
### Core
* **Drivers:** intel-ucode, mesa, vulkan-intel, intel-media-driver
* **Power:** tlp
* **Audio:** Pipewire, Wireplumber, Pavucontrol
* **Music:** mpd (`mpd.socket`), mpdscribble (scrobbler), rmpc (TUI client)
* **Network:** NetworkManager, Bluetooth (bluez)
* **WM:** SwayFX, Waybar, SwayNC, Rofi, Swaybg, Swayidle, Autotiling-RS
* **Theming:** bibata-cursor-theme (cursor), Adwaita (icons, built-in), Colloid-gtk-theme (gtk theme)
* **Utilities:** Grim, Slurp, Swappy, Brightnessctl, Btop, Fzf, FD, Bat, Ripgrep, Eza, Zoxide, Wget, Unzip, Zip, P7zip, Fortune-mod
* **Apps:** Nautilus, Cliphist, Neovim, Swayimg, Mpv, Zathura, Kitty, Fish

### AUR
* zen-browser-bin (browser)
* swaylock-effects (lock screen)
* swayfx (WM)
* bibata-cursor-theme (cursor)
* wlogout (power menu)
* otf-geist-mono-nerd (main font)
* obsidian (notes)

---

# Niri + Noctalia

A scrolling desktop: windows live in an endless strip of columns, and the bar is a row of
floating islands over the wallpaper. Noctalia generates one palette from the wallpaper and
pushes it everywhere: bar, panels, desktop widgets, niri borders, kitty and nvim.

## Components

| Component | Program |
|-----------|---------|
| **WM** | niri (scrolling tiling) |
| **Shell** | noctalia: bar, launcher, control center, notifications, OSD, lock screen, session menu, clipboard, wallpaper |
| **Terminal** | Kitty |
| **Shell** | Fish (Eza · Zoxide · Fzf) |
| **Text Editor** | Neovim (mini.base16 with the noctalia palette) |
| **Browser** | Zen Browser |
| **Music** | Feishin (floating scratchpad) |
| **File Manager** | Nautilus |
| **Fetch** | fastfetch (picture logo + `icon → value`) |

## Theming

| Item | Value |
|------|-------|
| **Colors** | Generated from the wallpaper (noctalia, `vibrant` scheme, dark) |
| **Cursor** | capitaine-cursors (24px) |
| **Font** | Maple Mono Normal NF (shell, bar, terminal) |
| **Windows** | Gradient borders, rounded corners, shadows from the palette |
| **Panels** | Floating frosted glass, rounded screen corners |

Noctalia renders the palette through templates (`noctalia/config.toml`):

| Target | Output | Reload |
|--------|--------|--------|
| Kitty | `~/.config/kitty/themes/noctalia.conf` | `SIGUSR1` |
| Neovim | `~/.local/state/nvim/noctalia.lua` | `SIGUSR1` |
| Niri | `~/.config/niri/noctalia.kdl` (borders, shadows, tabs) | niri reloads includes itself |

## Own noctalia plugins

They live in `~/.local/share/noctalia/plugins` and are written in Luau.

* **sleepy/desk** - the desktop kit:
  * Desktop cards in one style (CAPS label, glyph, big value, thin bar): clock, weather, system stats, now playing
  * Bar now-playing with a live audio spectrum; click opens the media + mixer panel
  * MPRIS service over D-Bus events (no playerctl, no polling); follows the player that is playing
* **sleepy/homelab** - homelab services over Tailscale:
  * Bar status, dashboard panel (`Super + Shift + X`), desktop card and launcher entries
  * Services in `homelab.json`: Navidrome, Photoview, Syncthing, Vaultwarden, Glance and a lazymc
    Minecraft server (shows awake / asleep)

## Keybinds
`Super` = ⊞ (Windows key). `Super + F1` shows them all.

### Apps and shell

| Shortcut | Action |
|----------|--------|
| `Super + t` | Terminal (Kitty) |
| `Super + f` | Browser (Zen) |
| `Super + d` | Files (Nautilus) |
| `Super + a` | Launcher |
| `Super + c` | Clipboard history |
| `Super + x` | Control center |
| `Super + Shift + x` | Homelab dashboard |
| `Super + m` | Toggle music (Feishin scratchpad) |
| `Super + p` / `Super + .` / `Super + ,` | Play-pause / next / previous |
| `Super + Esc` | Lock screen |
| `Super + Shift + e` / `PowerButton` | Session menu |
| `Super + Shift + c` | Reload niri |

### Windows

| Shortcut | Action |
|----------|--------|
| `Super + h/l` or `←/→` | Focus column left / right |
| `Super + j/k` or `↓/↑` | Focus window down / up in the column |
| `Super + Shift + h/j/k/l` | Move column / window |
| `Super + Ctrl + h/j/k/l` | Resize width / height (±10%) |
| `Super + r` / `Super + Shift + r` | Cycle column width (1/3, 1/2, 2/3) |
| `Super + e` | Maximize column |
| `Super + Ctrl + e` | Expand column to the free space |
| `Super + s` | Center column |
| `Super + v` / `Super + w` | Pull window into the column / push it out (left / right) |
| `Super + Shift + w` | Tabbed column |
| `Super + Return` | Fullscreen |
| `Super + Shift + Space` | Toggle floating |
| `Super + Space` | Switch focus floating ↔ tiling |
| `Super + Home/End` | First / last column |
| `Super + q` | Close window |

### Workspaces

| Shortcut | Action |
|----------|--------|
| `Super + 1..0` | Go to workspace |
| `Super + Shift + 1..0` | Move column to workspace |
| `Super + u/i` | Workspace down / up |
| `Super + Shift + u/i` | Move column down / up |
| `Super + Tab` | Previous workspace |
| `Super + o` | Overview |
| `Super + wheel` | Workspace down / up |

### Screenshots

| Shortcut | Action |
|----------|--------|
| `Print` | Full screenshot |
| `Super + Shift + s` | Area screenshot |
| `Super + Ctrl + s` | Freeze the screen and annotate |

## Packages

* **Desktop:** niri, noctalia, xwayland-satellite, capitaine-cursors
* **Apps:** kitty, zen-browser-bin (AUR), nautilus, feishin, fastfetch
* **Audio:** pipewire, wireplumber
* **Font:** Maple Mono Normal NF (`maplemononormal-nf-unhinted`, AUR)
* **Homelab:** tailscale

---

# Shared (every profile)

### Fonts
* GeistMono Nerd Font (mono - main UI / terminal / bar on sway)
* inter-font, ttf-liberation
* noto-fonts, noto-fonts-cjk, noto-fonts-emoji
* ttf-nerd-fonts-symbols-mono

### Terminal and CLI
* kitty, fish, eza, fzf, fd, bat, ripgrep, zoxide, btop, git-delta
* neovim, vim, nano, tree-sitter, nnn

### Runtimes / Languages
* Python & Pip
* Clang (C/C++)
* Rust & Cargo
* Lua & Luarocks
* Go
* Node.js & NPM
* Java (JDK)
