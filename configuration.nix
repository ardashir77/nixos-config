# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  # Enable nix-command and Flakes support
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-vscythe"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Bogota";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_CO.UTF-8";
    LC_IDENTIFICATION = "es_CO.UTF-8";
    LC_MEASUREMENT = "es_CO.UTF-8";
    LC_MONETARY = "es_CO.UTF-8";
    LC_NAME = "es_CO.UTF-8";
    LC_NUMERIC = "es_CO.UTF-8";
    LC_PAPER = "es_CO.UTF-8";
    LC_TELEPHONE = "es_CO.UTF-8";
    LC_TIME = "es_CO.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Hyprland Wayland compositor + the SDDM display manager
  services.xserver.displayManager.sddm.enable = true;
  programs.hyprland.enable = true;

  # Enable Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # Enable Thunar file manager
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount and trash support
  services.tumbler.enable = true; # Thumbnail support

  # Enable OpenTabletDriver
  hardware.opentabletdriver.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "latam";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "la-latin1";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable Flatpak
  services.flatpak.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.vscythe = {
    isNormalUser = true;
    description = "vscythe";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    krita
    qbittorrent
    libreoffice-fresh
    rclone
    fastfetch
    pfetch-rs
    gedit
    wine-staging
    winetricks
    ];
  };

  # Set package overrides and non-default behavior
  nixpkgs.config = {

    allowUnfree = true;

    packageOverrides = prev: 
      let final = prev.pkgs; in {
        catppuccin-gtk = prev.catppuccin-gtk.override {
          accents = [ "mauve" ];
          size = "standard";
          variant = "mocha";
        };
      
        catppuccin-kvantum = prev.catppuccin-kvantum.override {
          accent = "Mauve";
          variant = "Mocha";
        };
      
        catppuccin-papirus-folders = prev.catppuccin-papirus-folders.override {
          accent = "mauve";
          flavor = "mocha";
        };
     };
  };

  # lmao fonts
  fonts.packages = with pkgs; [
     noto-fonts
     noto-fonts-cjk
     noto-fonts-emoji
     liberation_ttf
     fira-code
     fira-code-symbols
     mplus-outline-fonts.githubRelease
     dina-font
     font-awesome
     lexend
     proggyfonts
     jetbrains-mono
     roboto
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    google-chrome
    lm_sensors
    bc
    brightnessctl
    libnotify
    foot
    fish
    catppuccin-gtk
    catppuccin-kvantum
    catppuccin-papirus-folders
    linuxKernel.packages.linux_6_1.cpupower
    libsForQt5.qtstyleplugin-kvantum
    qt5ct
    qt6ct
    swappy
    slurp
    grim
    waybar
    nur.repos.babariviere.nerd-font-symbols
    nur.repos.iagocq.ultimmc
    nur.repos.rewine.ttf-ms-win10
    wl-clipboard
    networkmanagerapplet
    rofi-wayland
    swayidle
    swaylock-fancy
    swaylock-effects
    swaybg
    swaynotificationcenter
    waybar
    wlogout
    starship
    btop
    pavucontrol
    pamixer
  ];

  environment.variables = rec {
    "MOZ_WAYLAND_ENABLE" = "1";
    "QT_QPA_PLATFORMTHEME" = "qt6ct";
    "KRITA_NO_STYLE_OVERRIDE" = "1";
    "EDITOR" = "vim";
 };   

  systemd.timers."cpupower-ondemand" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "59m";
        OnUnitActiveSec = "59m";
        Unit = "cpupower-ondemand.service";
      };
  };

  systemd.services."cpupower-ondemand" = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    path =  with pkgs; [
      kmod
      linuxKernel.packages.linux_6_1.cpupower
    ];
    script = "cpupower frequency-set -g ondemand";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };

  systemd.services.auto-fan-control = {
    enable = true;
    description = "Automatic Fan Control";
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      bash
      bc
      gawk
      coreutils
      lm_sensors
    ];
    environment = {};
    script = "bash /home/vscythe/.config/auto-fan-control/auto-fan-control.sh";
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      User = "root";
      ProtectHome = "false";
    };
  };  

  # Further NixOS configuration
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };
  
  security.pam.services.swaylock = {};

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPortRanges = [
  #    KDE Connect / GSConnect
  #  { from = 1714; to = 1764; }
  # ];

  # networking.firewall.allowedUDPPortRanges = [
  #    KDE Connect / GSConnect
  #  { from = 1714; to = 1764; }
  # ];

  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
