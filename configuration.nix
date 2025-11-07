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
    dbeaver-bin
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
