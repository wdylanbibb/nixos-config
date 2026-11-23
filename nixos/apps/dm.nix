{
  config,
  lib,
  var,
  ...
}: let
  lightdmCfg = config.modules.apps.lightdm;
  noctaliaGreeterCfg = config.modules.apps.noctaliaGreeter;
  sddmCfg = config.modules.apps.sddm;
in {
  imports = [var.libInputs.noctalia-greeter.nixosModules.default];

  options.modules.apps.lightdm.enable = lib.mkEnableOption "Enable the LightDM display manager.";
  options.modules.apps.noctaliaGreeter.enable =
    lib.mkEnableOption "Enable greetd with the Noctalia greeter.";
  options.modules.apps.sddm.enable =
    lib.mkEnableOption "Enable the SDDM display manager.";

  config = lib.mkMerge [
    (lib.mkIf lightdmCfg.enable {
      services.xserver = {
        enable = true;
        displayManager.lightdm.enable = true;
      };
    })

    (lib.mkIf noctaliaGreeterCfg.enable {
      services.displayManager.noctalia-greeter = {
        enable = true;
        settings.session.default = "sway";
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
