{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.apps.niri;
in
{
  options.modules.apps.niri = with lib; {
    enable = mkEnableOption "Enable the Niri window manager.";
  };

  config = lib.mkIf cfg.enable {
    environment.variables.NIXOS_OZONE_WL = "1";

    programs.niri.enable = true;

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
