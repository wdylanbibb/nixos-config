{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.apps.qtile;
in
{
  options.modules.apps.qtile = with lib; {
    enable = mkEnableOption "Enable the QTile window manager.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nautilus
      file-roller
      evince
      xclip
    ];

    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    programs.dconf.enable = true;

    services.xserver = {
      enable = true;
      dpi = 96;
      windowManager.qtile = {
        enable = true;
        extraPackages =
          python3Packages: with python3Packages; [
            qtile-extras
            dbus-fast
          ];
      };
    };

    environment.variables = {
      GDK_SCALE = "1";
      GDK_DPI_SCALE = "1";
    };

    xdg.icons = {
      enable = true;
    };

    xdg.portal = {
      enable = true;
      config.common.default = "gtk";
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      xdgOpenUsePortal = true;
    };

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    fonts.packages = with pkgs; [
      nerd-fonts.monaspace
      inter
      font-awesome
    ];
  };
}
