{ lib, pkgs, config, ... }:
let normalUsers = builtins.filter(x: x.isNormalUser) config.users.users; in 
{
  imports = [
    <home-manager/nixos>
  ];

  # Declaring option types
  options = {
    gnome-manager = {
      enable = lib.mkEnableOption "Enable GNOME management";

      user = lib.mkOption {
        type = lib.types.str;
        default = null;
      };

      background = lib.mkOption {
        type = lib.types.str;
        default = "${./smash_the_state.png}";
      };

      keyboards = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = null;
      };
      
      keybindings = lib.mkOption {
        type = lib.types.attrs;
        default = null;
      };

      extensions = lib.mkOption {
        #type = lib.types.listOf lib.types.package;
        type = lib.types.listOf lib.types.str;
        default = null;
      };
    };
  };

  config = lib.mkIf config.gnome-manager.enable {
    programs.dconf.enable = true;

    home-manager.users."${config.gnome-manager.user}" = { lib, ... } : {
      home.stateVersion = "22.11";

      dconf.settings = {
        # Background settings
        "org/gnome/desktop/background" = lib.mkIf (builtins.hasAttr "background" config.gnome-manager) {
          picture-uri = if lib.hasPrefix "file://" config.gnome-manager.background then config.gnome-manager.background
                        else "file://" + config.gnome-manager.background;
        };
        "org/gnome/desktop/screensaver" = lib.mkIf (builtins.hasAttr "background" config.gnome-manager) {
          picture-uri = if lib.hasPrefix "file://" config.gnome-manager.background then config.gnome-manager.background
                        else "file://" + config.gnome-manager.background;
        };

        # Keyboard input settings
        "org/gnome/desktop/input-sources" = lib.mkIf (builtins.hasAttr "keyboards" config.gnome-manager) {
          sources = (map(x: (lib.hm.gvariant.mkTuple [ "xkb" x ])) config.gnome-manager.keyboards);
        };

        # Extensions (1/2)
        # `gnome-extensions list` for a list of installed extensions
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = if (builtins.hasAttr "extensions" config.gnome-manager) then builtins.map(x: pkgs.gnomeExtensions.${x}.extensionUuid) config.gnome-manager.extensions else [];
        };

        # Keybindings
        "org/gnome/desktop/wm/keybindings" = lib.mapAttrs (name: value:
          # Multiple keybindings
          if lib.isList value then lib.hm.gvariant.mkValue value
          # Single keybinding
          else lib.hm.gvariant.mkValue [ value ]) config.gnome-manager.keybindings;
      };

      # Extensions (2/2)
      home.packages = if (builtins.hasAttr "extensions" config.gnome-manager) then builtins.map (x: pkgs.gnomeExtensions.${x}) config.gnome-manager.extensions else [];

    };
  };
}

