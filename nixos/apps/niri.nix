{
  config,
  lib,
  pkgs,
  var,
  ...
}: let
  cfg = config.modules.apps.niri;
  wrappedPkgs = var.libInputs.self.packages.${pkgs.stdenv.hostPlatform.system};
in {
  options.modules.apps.niri = with lib; {
    enable = mkEnableOption "Enable the Niri window manager.";
  };

  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      package = wrappedPkgs.niri;
      useNautilus = false;
    };
  };
}
