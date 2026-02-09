{
  config,
  lib,
  var,
  ...
}:
let
  cfg = config.modules.system.network;
in
{
  options.modules.system.network.tailscale = with lib; {
    enable = mkEnableOption "Enable tailscale.";
  };

  config = {
    services.tailscale = {
      enable = cfg.tailscale.enable;
      authKeyFile = config.sops.secrets.ts-authkey.path;
      extraUpFlags = [
        "--ssh"
        "--accept-routes"
      ];
    };

    networking = {
      hostName = var.hostName;
      networkmanager.enable = true;
    };

    services.openssh.enable = true;
  };
}
