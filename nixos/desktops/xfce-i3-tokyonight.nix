{ config, lib, pkgs, var, ... }:
let
  enabled = config.modules.desktop.profile == "xfce-i3-tokyonight";
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  config = lib.mkIf enabled {
    modules.apps = {
      gtk.enable = true;
      sddm.enable = true;
    };

    services.xserver = {
      enable = true;

      desktopManager.wallpaper.enable = false;

      desktopManager.xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };

      windowManager.i3 = {
        enable = true;
        package = wrappedPkgs.i3;
      };
    };

    environment.systemPackages = with pkgs; [
      firefox
      picom
      thunar
      xfce4-settings
      xfce4-panel
      xfce4-notifyd
      xfce4-icon-theme
      xfce4-taskmanager
      xfce4-alsa-plugin
      xfce4-screenshooter
      xfce4-i3-workspaces-plugin
      feh
      rofi
      xsetroot
      wrappedPkgs.kitty
    ];

    environment.sessionVariables.TOKYONIGHT_WALLPAPER =
      "${../../wrapped/i3/wallpapers/crosses_4k.png} ${../../wrapped/i3/wallpapers/crosses_vert.png}";

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    fonts.packages = with pkgs; [ nerd-fonts.monaspace inter font-awesome ];
  };
}
