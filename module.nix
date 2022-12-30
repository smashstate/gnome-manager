{ config, lib, pkgs, ... }:

with lib;
let cfg = config.gnome-manager;

in {
  options.gnome-manager = with types; {
    enable = mkEnableOption "Enable Gnome configuration via Home Manager.";
  };

  config = mkIf cfg.enable {
    programs.dconf.enable = true;

    home-manager.users =
      let regularUsers = filterAttrs (_: userOpts: userOpts.isNormalUser);
      in mapAttrs (username: _: import ./gnome.nix) regularUsers;
  };
}
