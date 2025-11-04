# 🚀 NixOS Beast Mode: Minimal Sway Setup in VMware (2025 Edition)

[![NixOS Flake](https://nixos.org/logo/nixos-logo.png)](https://nixos.org)  
**Declarative tiling paradise—because who needs a DE when Sway + NixOS delivers pure, reproducible power?**  

Fresh off a November 2025 install sesh: This guide cranks up **NixOS 25.05** in **VMware** with a **minimal base** (no bloaty GNOME/Plasma), then unleashes **Sway** for i3-style tiling on Wayland. Battle-tested on VMware Workstation 17+—think 4GB RAM, 2 cores, 50GB disk, 3D accel ON for silky graphics.  

Total time: ~20-40 mins (install + rebuilds). SSH from your host for remote config wizardry. Locale: English (UK), TZ: America/Panama, Keyboard: GB.  

> **VMware Hack:** NAT networking for easy SSH. Eject ISO post-install. Pro tip: Enable `virtualisation.vmware.guest.enable = true;` for seamless clipboard/sharing.  

## 🛠️ Prerequisites  
- **VM Creation:** Linux > Other 64-bit. Mount NixOS graphical ISO (25.05 stable) from [nixos.org/download](https://nixos.org/download).  
- **Host Prep:** OpenSSH client (Windows: `Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0`).  
- **User:** We'll placeholder as `[your-username]` (e.g., swap "erick" → your pick). Strong password: 8+ chars.  
- **Net:** Ethernet sim in VM—ditch public WiFi for rebuilds (they chug 5-30 mins on downloads).  

## 📦 Step 1: Boot & Installer Grind  
1. **VM Power-On:** ISO mounted? Boot hits the menu in ~3s. Mash **Tab** for kernel tweaks if you're fancy.  

   ![NixOS Boot Menu](screenshots/boot-menu.png)  
   *Pick "NixOS Installer (Minimal)"—keeps it lean for Sway later.*

2. **Calamares Magic:** Graphical installer launches. English everywhere.  

### 1.1 Welcome  
- Lang: **American English**.  
- **Next** →  

![Welcome Screen](screenshots/welcome.png)

### 1.2 Location  
- Region: **America** | Zone: **Panama**.  
- Sys Lang: **English (UK)** | Numbers/Dates: British English (Panama).  
- **Next** →  

![Location Setup](screenshots/location.png)

### 1.3 Keyboard  
- Layout: **English (UK)**.  
- Test: "The quick brown fox..."—nail those £ keys.  
- **Next** →  

![Keyboard Setup](screenshots/keyboard.png)

### 1.4 Users  
- Username: `[your-username]`.  
- Password: Your fortress (auto-login? Check it).  
- Admin PW: Same or separate.  
- **Next** →  

![Users Setup](screenshots/users.png)

### 1.5 Desktop  
- **No desktop**—minimal AF, Sway incoming.  
- **Next** →  

![Desktop: No Desktop](screenshots/desktop-none.png)

### 1.6 Unfree  
- Check **Allow unfree software** (VMware tools, anyone?).  
- EULA nod → **Next**.  

![Unfree Software](screenshots/unfree.png)

### 1.7 Partitions  
- **Erase disk** (VMs are throwaways).  
- No swap (VM overhead). Auto-part: ext4 on `/dev/sda1`.  
- Bootloader: **MBR**.  
- **Next** > **Install** (~5-10 mins).  

![Partitions Erase](screenshots/partitions.png)

### 1.8 Summary & Go  
- Scan: UK locale, GB keys, [your-username], no DE, unfree OK, erase/install.  
- **Install** → Reboot (eject ISO).  

![Summary](screenshots/summary.png)

## 🔧 Step 2: Post-Boot—SSH Unlock & Rebuild  
TTY1 login: `[your-username]` + PW.  

1. **SSH Enable:**  
   ```bash
   sudo nano /etc/nixos/configuration.nix
   ```  
   Append (pre-closing `}`):  
   ```nix
   services.openssh.enable = true;
   ```  
   **Ctrl+X** > **Y** > **Enter**.  

2. **Rebuild:**  
   ```bash
   sudo nixos-rebuild switch
   ```  
   *Brew coffee—downloads/compiles galore.*  

![TTY Edit](screenshots/tty-edit.png)  
![Rebuild](screenshots/rebuild.png)

3. **Reboot & IP Hunt:**  
   ```bash
   sudo reboot now  # PW prompt
   ip addr show     # Snag 192.168.x.x (enp0s3)
   ```  

![Login Prompt](screenshots/login.png)

## 🌐 Step 3: Host SSH Assault  
PowerShell/Terminal:  
```bash
ssh [your-username]@192.168.x.x
```  
- `yes` to fingerprint. PW in. Remote reign begins.  

![SSH Connect](screenshots/ssh-connect.png)

## 🪟 Step 4: Sway Summon—Full Config Drop  
SSH'd in:  
```bash
sudo nano /etc/nixos/configuration.nix
```  
Nuke & paste this beast (imports `hardware-configuration.nix`—gen it with `sudo nixos-generate-config` if MIA):  

```nix
{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];
  # Bootloader
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  # Locale & Timezone
  time.timeZone = "America/Panama";
  i18n.defaultLocale = "en_GB.UTF-8";
  services.xserver.xkb.layout = "gb";
  console.keyMap = "uk";
  # User
  users.users.[your-username] = {
    isNormalUser = true;
    description = "[your-username]";
    extraGroups = [ "networkmanager" "wheel" "docker" "wireshark" ];
    shell = pkgs.bashInteractive;
  };
  nixpkgs.config.allowUnfree = true;
  # Services
  services.openssh.enable = true;
  services.printing.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  # Sway + Wayland
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      swaylock-effects
      swayidle
      swaybg
      waybar
      wofi
      mako
      wl-clipboard
      grim
      slurp
    ];
  };
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-emoji
    dejavu_fonts
  ];
  # System packages
  environment.systemPackages = with pkgs; [
    # Essentials
    wget curl git vim tree htop unzip file which killall btop cowsay neofetch
    # Terminal
    foot starship zoxide fzf ripgrep fd bat eza
    # File managers
    nautilus gvfs ranger
    # Development (general)
    neovim gcc go
    # MERN stack
    nodejs
    nodePackages.npm
    nodePackages.yarn
    mongodb
    sqlite
    dbeaver-bin # Reemplazo de PostgreSQL
    # Python & Data Science
    python3
    python3Packages.pip
    python3Packages.virtualenv
    python3Packages.pandas
    python3Packages.numpy
    python3Packages.matplotlib
    python3Packages.scikit-learn
    python3Packages.jupyter
    python3Packages.seaborn
    R
    # Networking & Security
    wireshark nmap netcat-gnu tcpdump hashcat cmatrix
    # Apps
    firefox mpv imv zathura
    # System monitoring
    lm_sensors pciutils usbutils
    # Archives
    p7zip unrar
    # Appearance
    lxappearance papirus-icon-theme arc-theme
    # Containers/DevOps
    docker-compose kubectl
  ];
  programs.git.enable = true;
  environment.variables = {
    EDITOR = "nvim";
    BROWSER = "firefox";
    TERMINAL = "foot";
  };
  programs.firefox.enable = true;
  programs.wireshark.enable = true;
  system.stateVersion = "25.05";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```  
**Ctrl+X** > **Y** > **Enter**.  

Rebuild:  
```bash
sudo nixos-rebuild switch  # Patience, grasshopper
sudo reboot now
```  

![Config Paste](screenshots/config-paste.png)

## 🎨 Step 5: Sway Launch & Wallpaper Ritual  
GDM greets: Pick **Sway** session > `[your-username]` + PW. Tiling glory.  

![Sway Login](screenshots/sway-login.png)

1. **Wallpaper Quest:**  
   Super (Win) + Enter → `firefox`.  
   Hunt "beautiful Chinese art wallpaper" → DL to `~/Downloads/china.jpg` (or your fave).  

   ![Firefox Search](screenshots/firefox-search.png)

2. **Sway Config Flex:**  
   ```bash
   nano ~/.config/sway/config
   ```  
   Paste this clean, Catppuccin-tinted monster:  

   ```bash
   # Sway configuration - Clean and functional
   set $mod Mod4
   set $term foot
   set $menu wofi --show drun --allow-images --insensitive
   set $browser firefox
   set $fm xfce.thunar
   # Background
   output * bg ~/Downloads/china.jpg fill
   ### Key bindings ###
   # Apps
   bindsym $mod+Return exec $term
   bindsym $mod+d exec $menu
   bindsym $mod+Shift+f exec $browser
   bindsym $mod+Shift+n exec $fm
   # Dev quick launch
   bindsym $mod+Shift+v exec neovim
   # Exit / reload
   bindsym $mod+Shift+q kill
   bindsym $mod+Shift+c reload
   bindsym $mod+Shift+e exec swaynag -t warning -m 'Exit sway?' -b 'Yes' 'swaymsg exit'
   # Move focus
   bindsym $mod+h focus left
   bindsym $mod+j focus down
   bindsym $mod+k focus up
   bindsym $mod+l focus right
   bindsym $mod+Left focus left
   bindsym $mod+Down focus down
   bindsym $mod+Up focus up
   bindsym $mod+Right focus right
   # Move windows
   bindsym $mod+Shift+h move left
   bindsym $mod+Shift+j move down
   bindsym $mod+Shift+k move up
   bindsym $mod+Shift+l move right
   bindsym $mod+Shift+Left move left
   bindsym $mod+Shift+Down move down
   bindsym $mod+Shift+Up move up
   bindsym $mod+Shift+Right move right
   # Workspaces
   set $ws1 "1:term"
   set $ws2 "2:web"
   set $ws3 "3:code"
   set $ws4 "4:files"
   set $ws5 "5:db"
   set $ws6 "6:media"
   set $ws7 "7:net"
   set $ws8 "8:other"
   bindsym $mod+1 workspace $ws1
   bindsym $mod+2 workspace $ws2
   bindsym $mod+3 workspace $ws3
   bindsym $mod+4 workspace $ws4
   bindsym $mod+5 workspace $ws5
   bindsym $mod+6 workspace $ws6
   bindsym $mod+7 workspace $ws7
   bindsym $mod+8 workspace $ws8
   bindsym $mod+9 workspace number 9
   bindsym $mod+0 workspace number 10
   # Move containers to workspaces
   bindsym $mod+Shift+1 move container to workspace $ws1
   bindsym $mod+Shift+2 move container to workspace $ws2
   bindsym $mod+Shift+3 move container to workspace $ws3
   bindsym $mod+Shift+4 move container to workspace $ws4
   bindsym $mod+Shift+5 move container to workspace $ws5
   bindsym $mod+Shift+6 move container to workspace $ws6
   bindsym $mod+Shift+7 move container to workspace $ws7
   bindsym $mod+Shift+8 move container to workspace $ws8
   bindsym $mod+Shift+9 move container to workspace number 9
   bindsym $mod+Shift+0 move container to workspace number 10
   # Layout
   bindsym $mod+b splith
   bindsym $mod+v splitv
   bindsym $mod+s layout stacking
   bindsym $mod+w layout tabbed
   bindsym $mod+e layout toggle split
   bindsym $mod+f fullscreen
   bindsym $mod+Shift+space floating toggle
   bindsym $mod+space focus mode_toggle
   bindsym $mod+a focus parent
   # Resize mode
   mode "resize" {
       bindsym h resize shrink width 10px
       bindsym j resize grow height 10px
       bindsym k resize shrink height 10px
       bindsym l resize grow width 10px
       bindsym Left resize shrink width 10px
       bindsym Down resize grow height 10px
       bindsym Up resize shrink height 10px
       bindsym Right resize grow width 10px
       bindsym Return mode "default"
       bindsym Escape mode "default"
   }
   bindsym $mod+r mode "resize"
   # Screenshots
   bindsym Print exec grim ~/Pictures/screenshot_$(date +'%Y%m%d_%H%M%S').png
   bindsym Shift+Print exec grim -g "$(slurp)" ~/Pictures/screenshot_$(date +'%Y%m%d_%H%M%S').png
   # Floating modifier
   floating_modifier $mod normal
   # Aesthetic
   default_border pixel 2
   gaps inner 8
   gaps outer 4
   # Colors (Catppuccin theme)
   set $base #1e1e2e
   set $surface0 #313244
   set $surface1 #45475a
   set $text #cdd6f4
   set $rosewater #f5e0dc
   set $blue #89b4fa
   set $red #f38ba8
   client.focused $blue $base $text $rosewater $blue
   client.focused_inactive $surface1 $base $text $rosewater $surface1
   client.unfocused $surface1 $base $text $rosewater $surface1
   client.urgent $red $base $red $rosewater $red
   # Status bar
   bar {
       position top
       status_command while date +'%Y-%m-%d %I:%M:%S %p'; do sleep 1; done
       colors {
           statusline $text
           background $base
           focused_workspace $blue $blue $base
           active_workspace $surface1 $surface1 $text
           inactive_workspace $base $base $text
       }
   }
   # Autostart
   exec mako
   ```  
   Tweak `~/Downloads/china.jpg` → your DL path. Save.  

   Reload: **Super + Shift + C**.  

![Sway Config Edit](screenshots/sway-config.png)  
![Final Wallpaper](screenshots/final-wallpaper.png)

## ⚡ Power Moves & Keybinds  
- **Core Binds:** Super+Enter (term), +D (menu), +Shift+V (nvim), +1-8 (workspaces: term/web/code/etc.).  
- **Resize:** Super+R → H/J/K/L.  
- **Screenshots:** Print (full), Shift+Print (select).  
- **VM Boost:** Add `virtualisation.vmware.guest.enable = true;` to config.nix.  

| Workspace | Vibe          |  
|-----------|---------------|  
| 1         | Term          |  
| 2         | Web           |  
| 3         | Code          |  
| 4         | Files         |  
| 5         | DB            |  
| 6         | Media         |  
| 7         | Net/Sec       |  
| 8         | Misc          |  

