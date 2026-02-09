{ config, lib, ... }:
let
  cfg = config.modules.apps.lightdm;
in
{
  options.modules.apps.lightdm.enable = lib.mkEnableOption "Enable the LightDM display manager.";

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
    };
  };
}
