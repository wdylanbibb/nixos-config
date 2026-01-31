{ config, ... }:
{
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.ts-authkey.path;
    extraUpFlags = [
      "--ssh"
      "--accept-routes"
    ];
  };
}
