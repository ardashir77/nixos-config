{
  description = "vscythe's personal NixOS flake";
  
inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  hyprland.url = "github:hyprwm/Hyprland";
  watershot.url = "github:Kirottu/watershot";
  nur.url = "github:nix-community/NUR";
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

outputs = { self, nixpkgs, hyprland, watershot, nur, home-manager, ... }@inputs: 

let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
	  config.allowUnfree = true;
    overlays = [
      (import nur)
    ];	
  };
  lib = nixpkgs.lib;

in {
  nixosConfigurations = {
      nixos-vscythe = lib.nixosSystem rec {
        inherit system;
        specialArgs = { 
          inputs = inputs;
          inherit hyprland;
        };
        modules = [ 
          ./configuration.nix
          hyprland.nixosModules.default
          nur.nixosModules.nur
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.vscythe = import ./home.nix;
          }
        ];
      };
    };
  };
}
