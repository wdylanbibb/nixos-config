{ config, lib, ... }:
let
  cfg = config.modules.system.nvidia;
in
{
  options.modules.system.nvidia = with lib; {
    enable = mkEnableOption "Enable nvidia drivers.";

    package = mkOption {
      type = with types; package;
      default = config.boot.kernelPackages.nvidiaPackages.stable;
      description = "The nvidia driver package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    hardware.graphics.enable = true;

    services.xserver.videoDrivers = [ "nvidia" ];

    hardware.nvidia = {
      inherit (cfg) package;
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      open = false;
      nvidiaSettings = true;
    };
  };
}
