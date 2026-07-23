{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  cfg = config.modules.apps.sway;
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.modules.apps.sway.enable =
    lib.mkEnableOption "Enable the Sway compositor.";

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      package = wrappedPkgs.sway;
      wrapperFeatures.gtk = true;
    };

    environment = {
      systemPackages = with pkgs; [
        fuzzel
        mako
        swaylock
        wrappedPkgs.waybar
      ];

      variables.NIXOS_OZONE_WL = "1";
    };

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
