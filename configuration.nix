# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  # We on sum mischievous shit frfr
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Exclude packages from Plasma
  environment.gnome.excludePackages = (with pkgs.gnome; [
    cheese
    gnome-terminal
    epiphany
    geary
  ]) ++ (with pkgs; [
    gnome-tour
  ]);

  programs.dconf.enable = true;

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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
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
    webcord-vencord
    libreoffice-fresh
    wine-staging
    winetricks
    ];
  };

  # Set package overrides and non-default behavior
  nixpkgs.config = {

    allowUnfree = true;

    packageOverrides = prev: let final = prev.pkgs; in {
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

  # Set udev rules for GNOME extensions
  services.udev.packages = with pkgs; [
    gnome.gnome-settings-daemon
  ];
  
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
    firefox
    lm_sensors
    bc
    alacritty
    fish
    catppuccin-gtk
    catppuccin-kvantum
    catppuccin-papirus-folders
    papirus-icon-theme
    fastfetch
    linuxKernel.packages.linux_6_1.cpupower
    libsForQt5.qtstyleplugin-kvantum
    gnome.gnome-tweaks
    gnomeExtensions.appindicator
    gnomeExtensions.gsconnect
    gnomeExtensions.burn-my-windows
    gnomeExtensions.pop-shell
    gnomeExtensions.unite
    gnomeExtensions.freon
    gnomeExtensions.quick-settings-tweaker
    gnomeExtensions.rounded-window-corners
  ];

  environment.variables = rec {
    "MOZ_WAYLAND_ENABLE" = "1";
    "QT_STYLE_OVERRIDE" = "kvantum";
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
    serviceConfig = {
      ExecStart = "/home/vscythe/.local/share/auto-fan-control.sh";
      Type = "simple";
      Restart = "on-failure";
      User = "root";
      ProtectHome = "false";
    };
  };  


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
