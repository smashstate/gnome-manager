{ config, lib, pkgs, ... }:
with lib;
let cfg = config.gnome-manager;
in {
  options.gnome-manager = with types; {
    enable = lib.mkEnableOption "Enable GNOME management";

    user = mkOption {
      type = str;
      default = null;
    };

    background = mkOption {
      type = str;
      default = "${./smash_the_state.png}";
    };

    keyboards = mkOption {
      type = listOf str;
      default = null;
    };

    keybindings = mkOption {
      type = attrs;
      default = null;
    };

    extensions = mkOption {
      type = listOf str;
      default = null;
    };
  };

  config = mkIf cfg.enable {
    dconf = {
      enable = true;

      settings = let
        prefixFile = filename:
          if hasPrefix filename then filename else "file://#{filename}";
      in {
        # Background settings
        "org/gnome/desktop/background" =
          mkIf (builtins.hasAttr "background" cfg) {
            picture-uri = prefixFile cfg.background;
          };

        "org/gnome/desktop/screensaver" =
          mkIf (builtins.hasAttr "background" cfg) {
            picture-uri = prefixFile cfg.background;
          };

        # Keyboard input settings
        "org/gnome/desktop/input-sources" =
          mkIf (builtins.hasAttr "keyboards" cfg) {
            sources =
              (map (x: (hm.gvariant.mkTuple [ "xkb" x ])) cfg.keyboards);
          };

        # Extensions (1/2)
        # `gnome-extensions list` for a list of installed extensions
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = if (builtins.hasAttr "extensions" cfg) then
            builtins.map (x: pkgs.gnomeExtensions.${x}.extensionUuid)
            cfg.extensions
          else
            [ ];
        };

        # Keybindings
        "org/gnome/desktop/wm/keybindings" = mapAttrs (name: value:
          # Multiple keybindings
          if isList value then
            hm.gvariant.mkValue value
            # Single keybinding
          else
            hm.gvariant.mkValue [ value ]) cfg.keybindings;
      };
    };

    # Extensions (2/2)
    home.packages = if (builtins.hasAttr "extensions" cfg) then
      builtins.map (x: pkgs.gnomeExtensions.${x}) cfg.extensions
    else
      [ ];
  };
}
