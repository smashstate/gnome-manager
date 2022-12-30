{
  inputs = { home-manager.url = "nixpkgs/nixos-22.11"; };

  outputs = { home-manager, ... }: {
    nixosModules = rec {
      default = gnome-manager;

      gnome-manager = {
        imports = [ home-manager.nixosModules.home-manager ./module.nix ];
      };
    };

    homeManagerModules = rec {
      default = gnome-manager;

      gnome-manager = { config, lib, pkgs, ... }: {
        imports = [ ./gnome.nix ];
      };
    };
  };
}
