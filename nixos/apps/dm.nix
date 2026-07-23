{
  config,
  lib,
  ...
}:
let
  lightdmCfg = config.modules.apps.lightdm;
  sddmCfg = config.modules.apps.sddm;
in
{
  options.modules.apps.lightdm.enable = lib.mkEnableOption "Enable the LightDM display manager.";
  options.modules.apps.sddm.enable =
    lib.mkEnableOption "Enable the SDDM display manager.";

  config = lib.mkMerge [
    (lib.mkIf lightdmCfg.enable {
      services.xserver = {
        enable = true;
        displayManager.lightdm.enable = true;
      };
    })

    (lib.mkIf sddmCfg.enable {
      services = {
        xserver.enable = true;
        displayManager.sddm = {
          enable = true;
          wayland.enable = false;
        };
      };
    })
  ];
}
