# gnome-manager v0.0.1

gnome-manager is a simple [NixOS module](https://nixos.wiki/wiki/NixOS_modules) providing configuration flags for the GNOME desktop.

# Features

The following GNOME settings can be set from your `configuration.nix`:

- keyboard layouts
- custom keybindings
- background image (lockscreen/desktop)
- enabled extensions
- more? (PR welcome)

# Requirements

[home-manager](https://github.com/nix-community/home-manager) is required for this module to work, because it sets [dconf](https://en.wikipedia.org/wiki/Dconf) settings inside a specific user's session. As of december 2022, it can be installed with the following commands:

- `sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz home-manager`
- `sudo nix-channel --update`

Check out home-manager docs for more detailed and up-to-date [installation instructions](https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module).

# Installation

Once home-manager is installed, you can clone the repository whereever you please, then import the `gnome.nix` file in your `/etc/nixos/configuration.nix`. For example, if you cloned the repository in `/etc/nixos/gnome-manager`, your imports would look like:

```
  imports = [ ./hardware-configuration.nix ./gnome/gnome.nix ];
```

Then you can add a `gnome-manager` attribute to your configuration.

# Configuration flags

## `enable`

**Type**: bool (default: false)

Enables gnome-manager

## `user`

**Type**: string

Configures which user the gnome-manager config is applied to.

## `background`

**Type**: string (default: `[./smash_the_state.png](smash_the_state.png)`)

Changes the background image on the desktop/lockscreen. Expects an absolute path, to which `file://` will be prepended (if not already). Use string antiquoting (`"${./myfile.png}"`) to use a path relative to your NixOS config.

**Example**:

```
    background = "/etc/nixos/background.png";
```

**dconf keys**: 

- `/org/gnome/desktop/background/picture-uri`
- `/org/gnome/desktop/screensaver/picture-uri`

## `extensions`

**Type**: string list (default: `[]`)

Changes the list of enabled [GNOME extensions](https://extensions.gnome.org/). The names used here refer to NixOS package names for the extensions. You can find a list of extensions already packaged for NixOS [here](https://search.nixos.org/packages?channel=22.11&from=0&size=50&sort=relevance&type=packages&query=gnomeExtensions.*) (687 at time of writing). Note that not all extensions packaged actually work with the latest GNOME version packaged for NixOS.

**Example**:

```
    extensions = [ "window-list" "places-status-indicator" "force-quit"  ]
```

**dconf keys**:

- `/org/gnome/shell/disable-user-extensions`
- `/org/gnome/shell/enabled-extensions`

**NixOS keys**:

- `home.packages`

## `keybindings`

**Type**: attribute set of string-> (keybind or list of keybinds)

Changes the actions assigned to certain keys (key bindings). To list the actions on your system, you can use the `gsettings list-recursively org.gnome.desktop.wm.keybindings` command.

**Example**:

```
    keybindings = {
      "switch-windows" = "<Alt>Tab";
      "switch-windows-backward" = "<Shift><Alt>Tab";
    };
```

**dconf keys**:

- `/org/gnome/desktop/wm/keybindings`
- (not yet) `/org/gnome/settings-daemon/plugins/media-keys/`
- others to be aware?

## `keyboards`

**Type**: string list

Changes the keyboard layouts available. The first keyboard layout declared is the default one, and you can use the `primary-input-on-lockscreen` extension to ensure it's the default layout on the lockscreen (no matter what the current layout was inside the session). If you'd like to use a variant, please use the `+` symbol, like `fr+oss`.

**Example**:

```
    keyboards = [ "fr+oss" "ru" ];
```

**dconf keys**:

- `/org/gnome/desktop/input-sources`

# Example config

Here's a snippet from my NixOS `configuration.nix`:

```
...
  imports =
    [
      ...
      ./gnome/gnome.nix
    ];
...

  gnome-manager = {
     enable = true;
     user = "dev";

     #background = "/path/to.png";

     keyboards = [ "fr+oss" "ru" "us" ];

     keybindings = {
       "switch-windows" = "<Alt>Tab";
       "switch-windows-backward" = "<Shift><Alt>Tab";
       "switch-applications" = "";
       "switch-applications-backward" = "";
     };

     extensions = [
        "window-list"
        "places-status-indicator"
        "logo-menu"
        "tray-icons-reloaded"
        "lock-keys"
        "trash"
        "force-quit"
     ];
  };

```

# Limitations

- `lib.mkIf` with default setting `null` seems to remove any preset value... how do i make setting the value optional without erasing user-defined values?
- no config options to configure extension settings
- no way to set the config for every declared user in NixOS config? i tried and failed

# License

This code is distributed under GNU GPL v3. The [Smash the State](smash_the_state.png) background image is distributed under no specific license on the [nix-anarchy repository](https://github.com/krebs/nix-anarchy), and was slightly edited to act as a background image.
