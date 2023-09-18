{ config, pkgs, lib, inputs, osConfig, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "vscythe";
  home.homeDirectory = "/home/vscythe";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  # Enable and configure GTK theming.
  gtk = {
    enable = true;
    
    font = {
      name = "Lexend 11";
      package = pkgs.lexend;
    };

    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-dark";
      package = pkgs.catppuccin-gtk;
    };

    iconTheme = {
      name = "Papirus-Dark";
    };
  };   
}
