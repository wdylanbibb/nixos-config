{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  cfg = config.modules.apps.qtile;
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.modules.apps.qtile = with lib; {
    enable = mkEnableOption "Enable the QTile window manager.";
  };

  config = lib.mkIf cfg.enable {
    environment = {
      pathsToLink = [
        "/share/applications"
        "/share/xdg-desktop-portal"
      ];

      systemPackages = [
        pkgs.xorg.xsetroot
        wrappedPkgs.qtile
      ];
    };

    programs.dconf.enable = true;

    services.xserver = {
      enable = true;
      dpi = 96;
      displayManager.sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge /etc/X11/Xresources
        ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
      '';
      windowManager.qtile = {
        enable = true;
        configFile = wrappedPkgs.qtile.passthru.configuration."config.py".path;
        extraPackages = python3Packages:
          with python3Packages; [
            qtile-extras
            dbus-fast
          ];
      };
    };

    environment.variables = {
      GDK_SCALE = "1";
      GDK_DPI_SCALE = "1";
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
